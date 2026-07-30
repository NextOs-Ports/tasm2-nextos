#!/usr/bin/env bash
# Build the deterministic public ASM2 1.2.7d BYO-data package.
set -euo pipefail

export LC_ALL=C
export TZ=UTC

fail() {
  printf 'package error: %s\n' "$*" >&2
  exit 1
}

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
SOURCE_DIR="$SCRIPT_DIR/sources"
ALLOWLIST="$SCRIPT_DIR/package-files.txt"
SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-1785369600}
OUTPUT=${1:-"$SCRIPT_DIR/dist/asm2.zip"}

# The 4c5/v6 pair reached real gameplay with the scoped safety profile.
# Identities are pinned after save/TERM/reopen and the complete physical
# universal-package matrix returned a clean final status.
X86_RELEASE_SHA256=4c5b49ca7639ca7bbea4433793fb8defecd63c1ec304feb9703002a9000fc86d
X86_RELEASE_SIZE=208856
X86_RELEASE_BUILD_ID=23c6519da8299329f06d22935a791422e22835ec
BOX32_RELEASE_SHA256=48571604ccfb9399c6abba06349887d724dd23b5e8d80d4ac129c3acc39e405e
BOX32_RELEASE_SIZE=25720640
BOX32_RELEASE_BUILD_ID=993190f7bb2c8c6326d5e9d9ad893a941084551b
X5M_RELEASE_DEVICE_GATE_PASSED=1

for tool in awk bash cmp comm dirname file find grep install mkdir mktemp \
            python3 readelf rm sed sha256sum sort stat tail touch unzip wc zip; do
  command -v "$tool" >/dev/null 2>&1 || fail "missing host tool: $tool"
done

case "$SOURCE_DATE_EPOCH" in
  ''|*[!0-9]*) fail "SOURCE_DATE_EPOCH must be a Unix timestamp" ;;
esac
(( SOURCE_DATE_EPOCH >= 315532800 )) ||
  fail "SOURCE_DATE_EPOCH predates ZIP timestamps"
(( SOURCE_DATE_EPOCH <= 4354819198 )) ||
  fail "SOURCE_DATE_EPOCH exceeds ZIP timestamps"
(( SOURCE_DATE_EPOCH % 2 == 0 )) ||
  fail "SOURCE_DATE_EPOCH must use ZIP two-second granularity"

[[ -f "$ALLOWLIST" ]] || fail "missing allowlist: $ALLOWLIST"
EXPECTED=$(mktemp "${TMPDIR:-/tmp}/asm2-allowlist.XXXXXX")
sort -u "$ALLOWLIST" > "$EXPECTED"
cmp -s "$ALLOWLIST" "$EXPECTED" ||
  fail "package-files.txt must be sorted and unique"

while IFS= read -r relative; do
  [[ -n "$relative" ]] || fail "blank allowlist entry"
  case "$relative" in
    /*|../*|*/../*|*/..|*/./*|./*)
      fail "unsafe allowlist path: $relative"
      ;;
  esac
done < "$ALLOWLIST"

TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/asm2-portmaster.XXXXXX")
STAGE="$TMP_ROOT/stage"
TMP_ZIP="$TMP_ROOT/asm2.zip"
cleanup() {
  rm -rf -- "$TMP_ROOT"
  rm -f -- "$EXPECTED"
}
trap cleanup EXIT INT TERM
mkdir -p -- "$STAGE"

put() {
  local mode=$1 source=$2 destination=$3
  [[ -f "$source" ]] || fail "missing package source: $source"
  [[ ! -L "$source" ]] || fail "package source is a symlink: $source"
  install -D -m "$mode" -- "$source" "$STAGE/$destination"
}

put 0755 "$SOURCE_DIR/The Amazing Spider-Man 2.sh" \
  "The Amazing Spider-Man 2.sh"
put 0755 "$SOURCE_DIR/bin/asm2-nextos-armhf" \
  "asm2_127/bin/asm2-nextos-armhf"
put 0755 "$SOURCE_DIR/bin/asm2-portmaster-armhf" \
  "asm2_127/bin/asm2-portmaster-armhf"
[[ "$X5M_RELEASE_DEVICE_GATE_PASSED" == 1 ]] ||
  fail "X5M release gate is open; 4c5/v6 safe profile must finish save/TERM/reopen with RC0"
[[ -n "$X86_RELEASE_SHA256" &&
   -n "$X86_RELEASE_SIZE" &&
   -n "$X86_RELEASE_BUILD_ID" &&
   -n "$BOX32_RELEASE_SHA256" &&
   -n "$BOX32_RELEASE_SIZE" &&
   -n "$BOX32_RELEASE_BUILD_ID" ]] ||
  fail "X5M release identities are not frozen"
[[ "$X86_RELEASE_SHA256" != \
  fd6b48f4d89b1b9ff67af2cb34a67a4e61d7259eed34e52c781ff91a85481b8d ]] ||
  fail "refusing the rejected fd6 i386 loader with broken ASM-to-C resolver alignment"
put 0755 "$SOURCE_DIR/asm2_127_x86_box32" \
  "asm2_127/asm2_127_x86_box32"
put 0755 "$SOURCE_DIR/run.sh" \
  "asm2_127/run.sh"
put 0755 "$SOURCE_DIR/x5m-runtime-env.sh" \
  "asm2_127/x5m-runtime-env.sh"
put 0755 "$SOURCE_DIR/run-extractor.sh" \
  "asm2_127/run-extractor.sh"
put 0755 "$SOURCE_DIR/nxextract.py" \
  "asm2_127/nxextract.py"
put 0755 "$SOURCE_DIR/nxextract-ui" \
  "asm2_127/nxextract-ui"
put 0755 "$SOURCE_DIR/tools/extract_apk.py" \
  "asm2_127/tools/extract_apk.py"
put 0755 "$SOURCE_DIR/tools/rebuild_runtime_apk.py" \
  "asm2_127/tools/rebuild_runtime_apk.py"
put 0755 "$SOURCE_DIR/tools/extract_shop_assets.py" \
  "asm2_127/tools/extract_shop_assets.py"
put 0755 "$SOURCE_DIR/tools/prepare_asm2_data.py" \
  "asm2_127/tools/prepare_asm2_data.py"
put 0755 "$SOURCE_DIR/runtime/x5m/box64" \
  "asm2_127/runtime/x5m/box64"
put 0644 "$SOURCE_DIR/runtime/x5m/native/libSDL2-2.0.so.0" \
  "asm2_127/runtime/x5m/native/libSDL2-2.0.so.0"

for relative in \
  ART-PROVENANCE.json \
  BUILD-PROVENANCE.json \
  CHANGELOG.md \
  CLEANROOM.md \
  NOTICE.md \
  README.md \
  extractor.json \
  gamedata/README.txt \
  gameinfo.xml \
  licenses/Box64-MIT.txt \
  licenses/GPL-3.0.txt \
  licenses/NXExtract-MIT.txt \
  licenses/SDL2-compat-zlib.txt \
  port.json \
  runtime/x5m/BOX32-PROVENANCE.md \
  screenshot.png \
  version.txt; do
  put 0644 "$SOURCE_DIR/$relative" "asm2_127/$relative"
done

check_armhf_glibc() {
  local elf=$1 maximum=$2 expected=$3 machine class flags newest highest
  machine=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Machine:[[:space:]]*//p')
  class=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Class:[[:space:]]*//p')
  flags=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Flags:[[:space:]]*//p')
  [[ "$machine" == "ARM" ]] ||
    fail "$elf is not ARM (found: $machine)"
  [[ "$class" == "ELF32" ]] ||
    fail "$elf is not ELF32 (found: $class)"
  [[ "$flags" == *"hard-float ABI"* ]] ||
    fail "$elf is not ARM hard-float"
  newest=$(readelf --version-info "$elf" 2>/dev/null |
    grep -oE 'GLIBC_[0-9]+([.][0-9]+)*' |
    sed 's/^GLIBC_//' | sort -Vu | tail -1)
  [[ -n "$newest" ]] || fail "$elf has no GLIBC version provenance"
  highest=$(printf '%s\n%s\n' "$maximum" "$newest" | sort -V | tail -1)
  [[ "$highest" == "$maximum" ]] ||
    fail "$elf requires GLIBC_$newest (maximum: GLIBC_$maximum)"
  [[ "$newest" == "$expected" ]] ||
    fail "$elf newest GLIBC is $newest (expected: $expected)"
}

check_aarch64_glibc() {
  local elf=$1 maximum=$2 machine class newest highest
  machine=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Machine:[[:space:]]*//p')
  class=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Class:[[:space:]]*//p')
  [[ "$machine" == "AArch64" ]] ||
    fail "$elf is not AArch64 (found: $machine)"
  [[ "$class" == "ELF64" ]] ||
    fail "$elf is not ELF64 (found: $class)"
  newest=$(readelf --version-info "$elf" 2>/dev/null |
    grep -oE 'GLIBC_[0-9]+([.][0-9]+)*' |
    sed 's/^GLIBC_//' | sort -Vu | tail -1)
  [[ -n "$newest" ]] || return 0
  highest=$(printf '%s\n%s\n' "$maximum" "$newest" | sort -V | tail -1)
  [[ "$highest" == "$maximum" ]] ||
    fail "$elf requires GLIBC_$newest (maximum: GLIBC_$maximum)"
}

check_i386_glibc() {
  local elf=$1 maximum=$2 expected=$3 machine class type newest highest
  machine=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Machine:[[:space:]]*//p')
  class=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Class:[[:space:]]*//p')
  type=$(readelf -h "$elf" |
    sed -n 's/^[[:space:]]*Type:[[:space:]]*//p')
  [[ "$machine" == "Intel 80386" ]] ||
    fail "$elf is not i386 (found: $machine)"
  [[ "$class" == "ELF32" ]] ||
    fail "$elf is not ELF32 (found: $class)"
  [[ "$type" == EXEC* ]] ||
    fail "$elf is not an i386 executable (found: $type)"
  newest=$(readelf --version-info "$elf" 2>/dev/null |
    grep -oE 'GLIBC_[0-9]+([.][0-9]+)*' |
    sed 's/^GLIBC_//' | sort -Vu | tail -1)
  [[ -n "$newest" ]] || fail "$elf has no GLIBC version provenance"
  highest=$(printf '%s\n%s\n' "$maximum" "$newest" | sort -V | tail -1)
  [[ "$highest" == "$maximum" ]] ||
    fail "$elf requires GLIBC_$newest (maximum: GLIBC_$maximum)"
  [[ "$newest" == "$expected" ]] ||
    fail "$elf newest GLIBC is $newest (expected: $expected)"
}

NEXTOS_BIN="$STAGE/asm2_127/bin/asm2-nextos-armhf"
PORTMASTER_BIN="$STAGE/asm2_127/bin/asm2-portmaster-armhf"
NX_UI="$STAGE/asm2_127/nxextract-ui"
X86_LOADER="$STAGE/asm2_127/asm2_127_x86_box32"
X5_BOX32="$STAGE/asm2_127/runtime/x5m/box64"
X5_SDL2="$STAGE/asm2_127/runtime/x5m/native/libSDL2-2.0.so.0"
check_armhf_glibc "$NEXTOS_BIN" 2.43 2.43
check_armhf_glibc "$PORTMASTER_BIN" 2.30 2.27
check_aarch64_glibc "$NX_UI" 2.30
check_i386_glibc "$X86_LOADER" 2.38 2.38
check_aarch64_glibc "$X5_BOX32" 2.43
check_aarch64_glibc "$X5_SDL2" 2.34

[[ "$(readelf -h "$X5_BOX32" |
  sed -n 's/^[[:space:]]*Type:[[:space:]]*//p')" == EXEC* ]] ||
  fail "X5M Box32 host is not an ELF executable"
[[ "$(readelf -h "$X5_SDL2" |
  sed -n 's/^[[:space:]]*Type:[[:space:]]*//p')" == DYN* ]] ||
  fail "X5M SDL2 compatibility library is not an ELF shared object"
[[ "$(readelf -l "$X86_LOADER" |
  sed -n 's/.*Requesting program interpreter: \(.*\)\]/\1/p')" == \
  /lib/ld-linux.so.2 ]] ||
  fail "i386 loader interpreter changed"
[[ "$(readelf -l "$X5_BOX32" |
  sed -n 's/.*Requesting program interpreter: \(.*\)\]/\1/p')" == \
  /lib/ld-linux-aarch64.so.1 ]] ||
  fail "X5M Box32 interpreter changed"

i386_needed=$(readelf -d "$X86_LOADER" |
  sed -n 's/.*Shared library: \[\(.*\)\]/\1/p' | sort)
i386_expected=$(printf '%s\n' \
  libc.so.6 libm.so.6 libSDL2-2.0.so.0 | sort)
[[ "$i386_needed" == "$i386_expected" ]] ||
  fail "i386 loader dependency set changed: ${i386_needed//$'\n'/, }"
if readelf -d "$X86_LOADER" | grep -Eq '[(](RPATH|RUNPATH)[)]'; then
  fail "i386 loader must not contain RPATH or RUNPATH"
fi

[[ "$(sha256sum "$NEXTOS_BIN" | awk '{print $1}')" == \
  14bdb04a7e908d7c3d03fe0dbe89eb29359b8374e23d582d0a48498f79d09016 ]] ||
  fail "NextOS loader hash changed"
[[ "$(sha256sum "$PORTMASTER_BIN" | awk '{print $1}')" == \
  6297e7ad1fb296048db21e9105f4b76619ecfa2a6f873286dc35abe6a72bd044 ]] ||
  fail "PortMaster loader hash changed"
[[ "$(sha256sum "$NX_UI" | awk '{print $1}')" == \
  046afb583f5a211c946495e639409f81d9cfec706788eeccb7924b0e8e5a50b6 ]] ||
  fail "NXExtract UI hash changed"
[[ "$(stat -c %s "$X86_LOADER")" == "$X86_RELEASE_SIZE" ]] ||
  fail "i386 loader size changed"
[[ "$(sha256sum "$X86_LOADER" | awk '{print $1}')" == \
  "$X86_RELEASE_SHA256" ]] ||
  fail "i386 loader hash changed"
[[ "$(readelf -n "$X86_LOADER" |
  sed -n 's/^[[:space:]]*Build ID: //p')" == \
  "$X86_RELEASE_BUILD_ID" ]] ||
  fail "i386 loader Build ID changed"
[[ "$(stat -c %s "$X5_BOX32")" == "$BOX32_RELEASE_SIZE" ]] ||
  fail "X5M Box32 size changed"
[[ "$(sha256sum "$X5_BOX32" | awk '{print $1}')" == \
  "$BOX32_RELEASE_SHA256" ]] ||
  fail "X5M Box32 hash changed"
[[ "$(readelf -n "$X5_BOX32" |
  sed -n 's/^[[:space:]]*Build ID: //p')" == \
  "$BOX32_RELEASE_BUILD_ID" ]] ||
  fail "X5M Box32 Build ID changed"
[[ "$(stat -c %s "$X5_SDL2")" == 467752 ]] ||
  fail "X5M SDL2 compatibility library size changed"
[[ "$(sha256sum "$X5_SDL2" | awk '{print $1}')" == \
  eae4f55286eb9f888302878fa18d6a9d21f61bee9e1678d0991fa25f6ac207d5 ]] ||
  fail "X5M SDL2 compatibility library hash changed"
[[ "$(readelf -n "$X5_SDL2" |
  sed -n 's/^[[:space:]]*Build ID: //p')" == \
  0dfade075d971c3e24a50fbb4545c37eb0794fed ]] ||
  fail "X5M SDL2 compatibility library Build ID changed"

bash -n "$STAGE/The Amazing Spider-Man 2.sh"
bash -n "$STAGE/asm2_127/run.sh"
bash -n "$STAGE/asm2_127/x5m-runtime-env.sh"
bash -n "$STAGE/asm2_127/run-extractor.sh"
python3 - "$STAGE/asm2_127" <<'PY'
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
for path in sorted(root.rglob("*.py")):
    compile(path.read_bytes(), str(path), "exec")
PY
python3 "$STAGE/asm2_127/nxextract.py" recipe-check \
  --recipe "$STAGE/asm2_127/extractor.json" > "$TMP_ROOT/recipe-check.txt"
grep -Fq \
  'digest=63ae6af29d0ce8958ce369263780c27123ccfd0d2e9f0eefd09e390dae772978' \
  "$TMP_ROOT/recipe-check.txt" ||
  fail "extractor recipe digest changed without provenance update"

if grep -En \
    '^[[:space:]]*(export[[:space:]]+)?SDL_(AUDIODRIVER|AUDIO_DRIVER)=' \
    "$STAGE/The Amazing Spider-Man 2.sh" "$STAGE/asm2_127/run.sh"; then
  fail "launcher must not force an SDL audio backend"
fi
if grep -En \
    '^[[:space:]]*(export[[:space:]]+)?SDL_(VIDEODRIVER|VIDEO_DRIVER|KMSDRM_DEVICE_INDEX|KMSDRM_REQUIRE_DRM_MASTER)=' \
    "$STAGE/The Amazing Spider-Man 2.sh"; then
  fail "outer launcher must not force an SDL video backend"
fi
if grep -En \
    '^[[:space:]]*(export[[:space:]]+)?ASM2_EXTRACTOR_ONLY=' \
    "$STAGE/The Amazing Spider-Man 2.sh" "$STAGE/asm2_127/run.sh" \
    "$STAGE/asm2_127/x5m-runtime-env.sh"; then
  fail "extractor-only validation mode must not ship in the public launcher"
fi

KMS_ASSIGNMENTS="$TMP_ROOT/kms-assignments.txt"
X5_FUNCTION="$TMP_ROOT/configure-x5m-runtime.sh"
awk '
  /^configure_x5m_runtime[(][)] \{/ { inside=1 }
  inside { print }
  inside && /^}/ { exit }
' "$STAGE/asm2_127/run.sh" > "$X5_FUNCTION"
grep -E \
  '^[[:space:]]*export (SDL_VIDEODRIVER|SDL_VIDEO_DRIVER|SDL_KMSDRM_DEVICE_INDEX|SDL_KMSDRM_REQUIRE_DRM_MASTER)=' \
  "$STAGE/asm2_127/run.sh" > "$KMS_ASSIGNMENTS" || true
[[ "$(wc -l < "$KMS_ASSIGNMENTS")" -eq 4 ]] ||
  fail "X5M launcher must contain exactly four KMSDRM assignments"
for x5_assignment in \
  '  export SDL_VIDEODRIVER=kmsdrm' \
  '  export SDL_VIDEO_DRIVER=kmsdrm' \
  '  export SDL_KMSDRM_DEVICE_INDEX=0' \
  '  export SDL_KMSDRM_REQUIRE_DRM_MASTER=1'; do
  grep -Fxq "$x5_assignment" "$KMS_ASSIGNMENTS" ||
    fail "X5M KMSDRM assignment is missing: $x5_assignment"
  grep -Fxq "$x5_assignment" "$X5_FUNCTION" ||
    fail "KMSDRM assignment escaped configure_x5m_runtime: $x5_assignment"
done
if grep -Eq '(^|[[:space:]])(export[[:space:]]+)?LD_LIBRARY_PATH=' \
    "$X5_FUNCTION"; then
  fail "game-only X5M SDL path leaked into the shared extractor environment"
fi
grep -Fq \
  'LD_LIBRARY_PATH="$native_lib_dir:/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \' \
  "$STAGE/asm2_127/x5m-runtime-env.sh" ||
  fail "X5M sdl2-compat must be scoped to the Box32 game invocation"
grep -Fq \
  'LD_LIBRARY_PATH="/usr/local/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu:/usr/lib:/lib:$control_folder/libs:$control_folder/libs.aarch64" \' \
  "$STAGE/asm2_127/x5m-runtime-env.sh" ||
  fail "X5M NXExtract UI must prefer the proven firmware SDL2/KMSDRM stack"

if grep -En \
    '^[[:space:]]*(export[[:space:]]+)?BOX64_DYNAREC_EAGER=' \
    "$STAGE/The Amazing Spider-Man 2.sh" "$STAGE/asm2_127/run.sh"; then
  fail "release launcher must not enable experimental eager mode"
fi
DYNAREC_ASSIGNMENTS="$TMP_ROOT/dynarec-assignments.txt"
grep -E \
  '^[[:space:]]*export BOX64_DYNAREC(=|_(BIGBLOCK|SAFEFLAGS)=)' \
  "$STAGE/asm2_127/run.sh" > "$DYNAREC_ASSIGNMENTS" || true
[[ "$(wc -l < "$DYNAREC_ASSIGNMENTS")" -eq 3 ]] ||
  fail "X5M launcher must contain exactly three dynarec safety assignments"
for dynarec_assignment in \
  '  export BOX64_DYNAREC=1' \
  '  export BOX64_DYNAREC_BIGBLOCK=0' \
  '  export BOX64_DYNAREC_SAFEFLAGS=2'; do
  grep -Fxq "$dynarec_assignment" "$DYNAREC_ASSIGNMENTS" ||
    fail "X5M dynarec safety assignment is missing: $dynarec_assignment"
  grep -Fxq "$dynarec_assignment" "$X5_FUNCTION" ||
    fail "dynarec safety assignment escaped configure_x5m_runtime: $dynarec_assignment"
done
if grep -En \
    '(^|[[:space:]])(setsid|nohup|systemctl[[:space:]]+(stop|mask))([[:space:]]|$)' \
    "$STAGE/The Amazing Spider-Man 2.sh" "$STAGE/asm2_127/run.sh"; then
  fail "launcher contains a forbidden lifecycle command"
fi

for launcher_contract in \
  'flock -n 9' \
  'mkdir "$LOCK_DIR"' \
  '/lib/arm-linux-gnueabihf' \
  '"$CONTROLFOLDER/libs.armhf"' \
  '"$interpreter" --verify "$BIN"' \
  '"$interpreter" --list "$BIN"' \
  '[ -S "$wayland_candidate" ]' \
  '[ "$game_status" -eq 75 ]' \
  'selected tested NextOS S905X5M Box32 path' \
  'selected current-NextOS ARMHF build' \
  'selected low-glibc PortMaster ARMHF build' \
  'prepare_owner_data || return $?' \
  'asm2_x5m_run_extractor "$GAMEDIR" "$CONTROLFOLDER"' \
  'asm2_x5m_run_game "$GAMEDIR" "$X5_NATIVE_LIB_DIR" "$X5_BOX32_BIN"' \
  'using Horizon-style X5M foreground lifecycle' \
  'pm_platform_helper "$PLATFORM_HELPER_TARGET"' \
  'source "$X5_ENV_HELPER"'; do
  grep -Fq "$launcher_contract" "$STAGE/asm2_127/run.sh" ||
    fail "runtime launcher contract is missing: $launcher_contract"
done
grep -Fq "X5_BOX32_SHA256=$BOX32_RELEASE_SHA256" \
  "$STAGE/asm2_127/run.sh" ||
  fail "runtime launcher does not pin the gated Box32 hash"
grep -Fq "X5_GUEST_BIN_SHA256=$X86_RELEASE_SHA256" \
  "$STAGE/asm2_127/run.sh" ||
  fail "runtime launcher does not pin the gated i386 loader hash"
finish_calls=$(grep -Eh \
  '^[[:space:]]*command -v pm_finish .*&& pm_finish[[:space:]]*$' \
  "$STAGE/The Amazing Spider-Man 2.sh" "$STAGE/asm2_127/run.sh" |
  wc -l || true)
[[ "$finish_calls" -eq 1 ]] ||
  fail "complete launcher flow must call pm_finish exactly once"

python3 - \
  "$STAGE/asm2_127/port.json" \
  "$STAGE/asm2_127/gameinfo.xml" \
  "$STAGE/asm2_127/BUILD-PROVENANCE.json" \
  "$STAGE/asm2_127/version.txt" \
  "$NEXTOS_BIN" \
  "$PORTMASTER_BIN" \
  "$X86_LOADER" \
  "$X5_BOX32" \
  "$X5_SDL2" \
  "$STAGE/asm2_127/ART-PROVENANCE.json" \
  "$STAGE/asm2_127/screenshot.png" \
  "$BOX32_RELEASE_SIZE" \
  "$BOX32_RELEASE_SHA256" \
  "$BOX32_RELEASE_BUILD_ID" \
  "$X86_RELEASE_SIZE" \
  "$X86_RELEASE_SHA256" \
  "$X86_RELEASE_BUILD_ID" <<'PY'
import hashlib
import json
import sys
import xml.etree.ElementTree as ET

with open(sys.argv[1], encoding="utf-8") as stream:
    metadata = json.load(stream)
if metadata.get("version") != 4:
    raise SystemExit("port.json schema must be version 4")
if metadata.get("name") != "asm2.zip":
    raise SystemExit("port.json stable name must be asm2.zip")
if metadata.get("items") != ["The Amazing Spider-Man 2.sh", "asm2_127"]:
    raise SystemExit("port.json items do not match archive layout")
if metadata.get("attr", {}).get("arch") != ["aarch64", "armhf"]:
    raise SystemExit("port.json must declare the scoped AArch64 and ARMHF routes")
images = {
    "screenshot": "screenshot.png",
    "covers": [],
    "thumbnail": "screenshot.png",
    "video": None,
}
if metadata.get("attr", {}).get("image") != images:
    raise SystemExit("port.json image metadata is incomplete")

game = ET.parse(sys.argv[2]).getroot().find("game")
if game is None or game.findtext("path") != "./The Amazing Spider-Man 2.sh":
    raise SystemExit("gameinfo.xml launcher path is invalid")
if game.findtext("image") != "./asm2_127/screenshot.png":
    raise SystemExit("gameinfo.xml screenshot path is invalid")

with open(sys.argv[3], encoding="utf-8") as stream:
    provenance = json.load(stream)
if provenance.get("package_version") != "1.1.3":
    raise SystemExit("build provenance package version is invalid")
with open(sys.argv[4], encoding="utf-8") as stream:
    package_version = stream.read().strip()
if package_version != provenance["package_version"]:
    raise SystemExit("version.txt and build provenance disagree")
for relative, path in (
    ("bin/asm2-nextos-armhf", sys.argv[5]),
    ("bin/asm2-portmaster-armhf", sys.argv[6]),
    ("asm2_127_x86_box32", sys.argv[7]),
):
    with open(path, "rb") as stream:
        actual_hash = hashlib.sha256(stream.read()).hexdigest()
    declared_hash = provenance.get("loaders", {}).get(relative, {}).get("sha256")
    if actual_hash != declared_hash:
        raise SystemExit(f"{relative} hash disagrees with build provenance")
i386_component = provenance.get("loaders", {}).get("asm2_127_x86_box32", {})
if (
    i386_component.get("size") != int(sys.argv[15])
    or i386_component.get("sha256") != sys.argv[16]
    or i386_component.get("build_id") != sys.argv[17]
):
    raise SystemExit("i386 loader identity disagrees with build provenance")
if provenance.get("target_game", {}).get("android_version_code") != 12723:
    raise SystemExit("build provenance game version is invalid")
recipe = provenance.get("recipe", {})
if recipe.get("file_sha256") != (
    "5813fdb8e819f745cf625561a8af99f2bc63cd0d0f51cea81a68c243a0152a41"
):
    raise SystemExit("build provenance recipe file hash is invalid")
if recipe.get("nxextract_digest") != (
    "63ae6af29d0ce8958ce369263780c27123ccfd0d2e9f0eefd09e390dae772978"
):
    raise SystemExit("build provenance recipe digest is invalid")

x5_runtime = provenance.get("x5m_runtime", {})
selection = x5_runtime.get("selection_scope", {})
if (
    selection.get("host_architecture") != "aarch64"
    or selection.get("operating_system") != "NextOS"
    or selection.get("device_tree_compatible") != "amlogic,s7d"
):
    raise SystemExit("X5M runtime selection scope is not narrow enough")
for relative, path, expected_size, expected_hash, expected_build_id in (
    (
        "runtime/x5m/box64",
        sys.argv[8],
        int(sys.argv[12]),
        sys.argv[13],
        sys.argv[14],
    ),
    (
        "runtime/x5m/native/libSDL2-2.0.so.0",
        sys.argv[9],
        467752,
        "eae4f55286eb9f888302878fa18d6a9d21f61bee9e1678d0991fa25f6ac207d5",
        "0dfade075d971c3e24a50fbb4545c37eb0794fed",
    ),
):
    component = x5_runtime.get(relative, {})
    with open(path, "rb") as stream:
        data = stream.read()
    if len(data) != expected_size or hashlib.sha256(data).hexdigest() != expected_hash:
        raise SystemExit(f"{relative} frozen bytes changed")
    if (
        component.get("size") != expected_size
        or component.get("sha256") != expected_hash
        or component.get("build_id") != expected_build_id
    ):
        raise SystemExit(f"{relative} disagrees with build provenance")
validation = x5_runtime.get("validation", {})
if validation.get("component_bytes_frozen") is not True:
    raise SystemExit("X5M component freeze is not recorded")
profile = validation.get("dynarec_safety_profile", {})
if (
    profile.get("BOX64_DYNAREC") != "1"
    or profile.get("BOX64_DYNAREC_BIGBLOCK") != "0"
    or profile.get("BOX64_DYNAREC_SAFEFLAGS") != "2"
    or profile.get("scope") != "configure_x5m_runtime only"
):
    raise SystemExit("X5M dynarec safety profile provenance is incomplete")
if validation.get("universal_release_gate") != "passed":
    raise SystemExit("universal package release gate is not passed")
for release_check in (
    "corresponding_source_release_mode",
    "deterministic_public_and_source_archives",
    "host_reinstall_update_preservation",
    "x5m_full_extraction_and_fast_path",
    "x5m_extractor_firmware_sdl_kmsdrm_physical",
    "mali450_full_extraction_and_exact_package_smoke",
    "r36s_full_extraction_and_exact_package_smoke",
):
    if validation.get(release_check) is not True:
        raise SystemExit(f"universal release check is not recorded: {release_check}")

owner_x86 = provenance.get("owner_extracted_x86_library", {})
if owner_x86.get("included_in_public_zip") is not False:
    raise SystemExit("proprietary x86 library must be owner-extracted")
if owner_x86.get("sha256") != (
    "d146d38574c19a105df8a46e523f626c06004c8f71bbeed5cf77e919dbf81a12"
):
    raise SystemExit("owner x86 library provenance changed")

with open(sys.argv[10], encoding="utf-8") as stream:
    art = json.load(stream)
screenshot_art = art.get("screenshot.png", {})
with open(sys.argv[11], "rb") as stream:
    screenshot_hash = hashlib.sha256(stream.read()).hexdigest()
if screenshot_hash != (
    "5935351d03b43bd472dece3e610c0c5ce93decc1eba6bb2a2579e8ac1fe7888e"
):
    raise SystemExit("approved R36S screenshot bytes changed")
if (
    screenshot_art.get("sha256") != screenshot_hash
    or screenshot_art.get("release_allowed") is not True
):
    raise SystemExit("screenshot art provenance is incomplete")
PY

python3 - "$STAGE/asm2_127" <<'PY'
import pathlib
import struct
import sys

root = pathlib.Path(sys.argv[1])
expected = {
    "screenshot.png": (640, 480),
}
for name, dimensions in expected.items():
    header = (root / name).read_bytes()[:24]
    if len(header) != 24 or header[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit(f"{name} is not a valid PNG")
    actual = struct.unpack(">II", header[16:24])
    if actual != dimensions:
        raise SystemExit(
            f"{name} dimensions are {actual[0]}x{actual[1]}, "
            f"expected {dimensions[0]}x{dimensions[1]}"
        )
PY

if find "$STAGE" -type l -print -quit | grep . >/dev/null; then
  fail "symlink entered the public staging tree"
fi
if find "$STAGE" \( \
    -name '*.apk' -o -name '*.apks' -o -name '*.apkm' -o \
    -name '*.xapk' -o -name '*.obb' -o -name '*.dex' -o \
    -name 'libtasm2.so' -o -name 'libtasm2-x86.so' -o \
    -name 'IapLocalData_Google.json' -o \
    -name 'IapStoreItems_Offline.json' \
  \) -print -quit | grep . >/dev/null; then
  fail "proprietary game data entered the public staging tree"
fi
if find "$STAGE" \( \
    -name '*.log' -o -name '*.raw' -o -name '__pycache__' -o \
    -name '*.pyc' -o -name '*.pyo' -o -name 'debug.log' -o \
    -name 'gamefiles' -o -name 'assets' \
  \) -print -quit | grep . >/dev/null; then
  fail "development or generated runtime data entered public staging"
fi
if grep -IRnE \
  '192[.]168[.]|/home/|/mnt/ARQUIVOS|/tmp/claude|root@|ark@' \
  "$STAGE" \
  --include='*.sh' --include='*.py' --include='*.md' \
  --include='*.txt' --include='*.json' --include='*.xml'; then
  fail "release text contains a test address, credential or personal path"
fi

(
  cd -- "$STAGE"
  while IFS= read -r relative; do
    case "$relative" in
      asm2_127/PACKAGE-MANIFEST.sha256)
        continue
        ;;
    esac
    sha256sum -- "$relative"
  done < "$ALLOWLIST"
) > "$STAGE/asm2_127/PACKAGE-MANIFEST.sha256"

ACTUAL="$TMP_ROOT/actual.txt"
find "$STAGE" -type f -printf '%P\n' | sort > "$ACTUAL"
cmp -s "$ALLOWLIST" "$ACTUAL" || {
  comm -3 "$ALLOWLIST" "$ACTUAL" >&2
  fail "staged files differ from package-files.txt"
}

find "$STAGE" -exec touch -h -d "@$SOURCE_DATE_EPOCH" {} +
(
  cd -- "$STAGE"
  zip -X -9 -q "$TMP_ZIP" -@ < "$ALLOWLIST"
)
unzip -tq "$TMP_ZIP" >/dev/null
unzip -Z1 "$TMP_ZIP" > "$TMP_ROOT/archive.txt"
cmp -s "$ALLOWLIST" "$TMP_ROOT/archive.txt" ||
  fail "ZIP entries or ordering differ from package-files.txt"

VERIFY="$TMP_ROOT/verify"
mkdir -p -- "$VERIFY"
unzip -q "$TMP_ZIP" -d "$VERIFY"
(
  cd -- "$VERIFY"
  sha256sum -c asm2_127/PACKAGE-MANIFEST.sha256 >/dev/null
)

mkdir -p -- "$(dirname -- "$OUTPUT")"
OUTPUT_DIR=$(cd -- "$(dirname -- "$OUTPUT")" && pwd -P)
OUTPUT="$OUTPUT_DIR/$(basename -- "$OUTPUT")"
install -m 0644 -- "$TMP_ZIP" "$OUTPUT"
(
  cd -- "$OUTPUT_DIR"
  sha256sum "$(basename -- "$OUTPUT")" > "$(basename -- "$OUTPUT").sha256"
)

printf 'OK: %s\n' "$OUTPUT"
printf 'NextOS loader: '
sha256sum "$NEXTOS_BIN"
printf 'PortMaster loader: '
sha256sum "$PORTMASTER_BIN"
printf 'Package: '
sha256sum "$OUTPUT"
