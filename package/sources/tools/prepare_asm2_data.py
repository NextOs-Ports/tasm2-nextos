#!/usr/bin/env python3
"""Prepare exact ASM2 1.2.7d runtime files inside an NXExtract stage.

The supported APK has damaged ZIP bookkeeping and one raw-DEFLATE stream with
one missing byte.  NXExtract first proves the Android package identity through
the readable manifest and stages the three exact OBB files.  This hook then
finds the owner's byte-exact source APK, rebuilds a standards-compliant runtime
APK, recovers the ARMv7 and x86 libraries through physical local headers and
creates the two offline shop files.  The source files are never modified or
deleted.
"""

from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import zipfile

from extract_apk import physical_headers, unpack_entry


SOURCE_APK_SIZE = 31_774_872
SOURCE_APK_SHA256 = (
    "4188a463432b921dfb767a3ddf316e970655789a7bdf806298757f45071a8c87"
)
RUNTIME_APK_SIZE = 67_667_020
RUNTIME_APK_SHA256 = (
    "a3f7c790f2ad0a3f62826668f8466f398aa7e15237287c8f693310a232fa44fc"
)
ARM_LIBRARY_ENTRY = "lib/armeabi-v7a/libtasm2.so"
ARM_LIBRARY_SIZE = 20_241_296
ARM_LIBRARY_SHA256 = (
    "d091fe95c56af681f1a06453e9868622935ecbb759c05c340fc16bf8df2ae62e"
)
X86_LIBRARY_ENTRY = "lib/x86/libtasm2.so"
X86_LIBRARY_SIZE = 32_152_072
X86_LIBRARY_SHA256 = (
    "d146d38574c19a105df8a46e523f626c06004c8f71bbeed5cf77e919dbf81a12"
)
PACKAGE = "com.gameloft.android.ANMP.GloftASHM"
OBB_DIRECTORY = Path("gamefiles/Android/obb") / PACKAGE
MAIN_OBB = "main.12032.com.gameloft.android.ANMP.GloftASHM.obb"
PATCH_12438 = "patch.12438.com.gameloft.android.ANMP.GloftASHM.obb"
PATCH_12723 = "patch.12723.com.gameloft.android.ANMP.GloftASHM.obb"

EXPECTED_OUTPUTS = {
    "gamefiles/base.apk": (
        RUNTIME_APK_SIZE,
        RUNTIME_APK_SHA256,
    ),
    "libtasm2.so": (
        ARM_LIBRARY_SIZE,
        ARM_LIBRARY_SHA256,
    ),
    "libtasm2-x86.so": (
        X86_LIBRARY_SIZE,
        X86_LIBRARY_SHA256,
    ),
    str(OBB_DIRECTORY / MAIN_OBB): (
        1_236_510_228,
        "276c413051b3349e7738afb23521f972d085a186cb22ab18db230906aab46981",
    ),
    str(OBB_DIRECTORY / PATCH_12438): (
        24_099_405,
        "58d9ed565ad67ee7362a2376a74387316535975460110eccf3df7eb3b6503981",
    ),
    str(OBB_DIRECTORY / PATCH_12723): (
        98_576_965,
        "0faae1e92ab998b8808e3984e4cdafbe732a87c26da58a44ad11c633e643cb80",
    ),
    "assets/IapLocalData_Google.json": (
        9_577,
        "93aecb98da97508352af354f04d42e8b5b4b3b50d993dc9b300002941c77721f",
    ),
    "assets/IapStoreItems_Offline.json": (
        4_717,
        "c857e6f3b2685bf514dc53af345db43059b2e4c44fe3d4add28059e973c029b9",
    ),
}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while True:
            block = stream.read(8 * 1024 * 1024)
            if not block:
                break
            digest.update(block)
    return digest.hexdigest()


def validate_file(path: Path, size: int, digest: str, label: str) -> None:
    if path.is_symlink() or not path.is_file():
        raise RuntimeError(f"{label} is missing, linked or not a regular file")
    actual_size = path.stat().st_size
    if actual_size != size:
        raise RuntimeError(
            f"{label} has size {actual_size}, expected {size}"
        )
    actual_digest = sha256_file(path)
    if actual_digest != digest:
        raise RuntimeError(
            f"{label} failed SHA-256 validation ({actual_digest})"
        )


def find_source_apk(game_dir: Path) -> Path:
    candidates = []
    for directory in (game_dir / "gamedata", game_dir):
        if directory.is_symlink() or not directory.is_dir():
            continue
        for entry in sorted(directory.iterdir(), key=lambda item: item.name.casefold()):
            try:
                if (
                    entry.is_symlink()
                    or not entry.is_file()
                    or entry.stat().st_size != SOURCE_APK_SIZE
                ):
                    continue
            except OSError:
                continue
            if sha256_file(entry) == SOURCE_APK_SHA256:
                candidates.append(entry)
    if not candidates:
        raise RuntimeError(
            "the exact owner-supplied ASM2 Android 1.2.7d APK was not found "
            "in gamedata"
        )
    selected = candidates[0]
    print(
        "ASM2 source APK accepted by size and SHA-256"
        + (" (%d identical copies found)" % len(candidates) if len(candidates) > 1 else "")
    )
    return selected


def atomic_write(path: Path, payload: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            prefix=f".{path.name}.",
            suffix=".new",
            dir=path.parent,
            delete=False,
        ) as stream:
            temporary = Path(stream.name)
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
        temporary.chmod(0o644)
        os.replace(temporary, path)
        temporary = None
        directory_fd = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    finally:
        if temporary is not None:
            try:
                temporary.unlink()
            except FileNotFoundError:
                pass


def recover_library(
    source_apk: Path,
    destination: Path,
    entry_name: str,
    expected_size: int,
    expected_digest: str,
) -> None:
    blob = source_apk.read_bytes()
    headers = physical_headers(blob)
    with zipfile.ZipFile(source_apk, "r") as archive:
        info = archive.getinfo(entry_name)
        offset = headers.get(entry_name)
        if offset is None:
            raise RuntimeError(
                f"physical {entry_name} local header was not found"
            )
        payload, _actual_crc, _repair = unpack_entry(blob, info, offset)
    if len(payload) != expected_size:
        raise RuntimeError(
            f"recovered {entry_name} has an unexpected size"
        )
    if hashlib.sha256(payload).hexdigest() != expected_digest:
        raise RuntimeError(
            f"recovered {entry_name} failed SHA-256 validation"
        )
    atomic_write(destination, payload)


def run_tool(tool: Path, *arguments) -> None:
    subprocess.run(
        [sys.executable, str(tool), *(str(argument) for argument in arguments)],
        check=True,
    )


def progress(value: int, message: str) -> None:
    print(f"NXEXTRACT_PROGRESS {value} 100 {message}", flush=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--stage", required=True, type=Path)
    parser.add_argument("--game-dir", required=True, type=Path)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    stage = args.stage.resolve(strict=True)
    game_dir = args.game_dir.resolve(strict=True)
    tools = Path(__file__).resolve().parent
    source_apk = find_source_apk(game_dir)

    progress(5, "VALIDATING OWNER-SUPPLIED ASM2 1.2.7d FILES")
    for relative, (size, digest) in EXPECTED_OUTPUTS.items():
        if relative.startswith("gamefiles/Android/obb/"):
            validate_file(stage / relative, size, digest, relative)

    progress(15, "REBUILDING STANDARDS-COMPLIANT RUNTIME APK")
    runtime_apk = stage / "gamefiles/base.apk"
    run_tool(
        tools / "rebuild_runtime_apk.py",
        source_apk,
        runtime_apk,
        "--force",
    )
    validate_file(
        runtime_apk,
        RUNTIME_APK_SIZE,
        RUNTIME_APK_SHA256,
        "runtime base.apk",
    )

    progress(50, "RECOVERING ARMV7 AND X86 GAME LIBRARIES")
    arm_library = stage / "libtasm2.so"
    recover_library(
        source_apk,
        arm_library,
        ARM_LIBRARY_ENTRY,
        ARM_LIBRARY_SIZE,
        ARM_LIBRARY_SHA256,
    )
    validate_file(
        arm_library,
        ARM_LIBRARY_SIZE,
        ARM_LIBRARY_SHA256,
        "libtasm2.so",
    )
    x86_library = stage / "libtasm2-x86.so"
    recover_library(
        source_apk,
        x86_library,
        X86_LIBRARY_ENTRY,
        X86_LIBRARY_SIZE,
        X86_LIBRARY_SHA256,
    )
    validate_file(
        x86_library,
        X86_LIBRARY_SIZE,
        X86_LIBRARY_SHA256,
        "libtasm2-x86.so",
    )

    progress(75, "BUILDING OFFLINE SHOP CATALOG")
    assets = stage / "assets"
    run_tool(
        tools / "extract_shop_assets.py",
        stage / OBB_DIRECTORY / MAIN_OBB,
        assets,
    )

    progress(90, "VERIFYING COMPLETE ASM2 DATA SET")
    for relative, (size, digest) in EXPECTED_OUTPUTS.items():
        validate_file(stage / relative, size, digest, relative)

    progress(100, "ASM2 1.2.7d DATA PREPARED")
    print("OK: all eight proprietary runtime outputs validated in NXExtract stage")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, RuntimeError, subprocess.CalledProcessError, zipfile.BadZipFile) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(2)
