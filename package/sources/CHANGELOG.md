# Changelog

## 1.1.5

- Accepts four audited owner-input profiles: two Android 1.2.7d APK layouts,
  one universal ARMv7+x86 1.2.8d APK and one self-contained ARM32-only 1.2.8d
  installer.
- Accepts the matching cache as loose OBB files, a companion ZIP or the
  validated self-contained installer. `main.12032` and `patch.12723` remain
  byte-exact requirements; `patch.12438` is now optional and is still fully
  validated whenever present.
- Replaces whole-container rejection at the preparation hook with explicit
  profile and native-library validation, fixing first-run failures that
  occurred after NXExtract had already staged valid data.
- Keeps the X5M route strict: ARM32-only input is rejected with a clear
  compatibility message, while all inputs carrying the exact x86 library
  remain eligible for Box32.
- Validates all four preparation profiles, both transactional input layouts,
  existing-install adoption, ARM32-only x86 rejection and real Mali-450
  gameplay without the optional older patch OBB. A physical Mali-450 also
  completed all four transactional ARMv7 extraction profiles, including a
  successful resume after interruption.

## 1.1.4

- Clarifies everywhere that the game is not APK-only: installation requires
  one exact Android 1.2.7d APK plus the complete three-file OBB cache.
- Adds a bilingual `INSTALLATION.md` inside the port and lists the exact
  `main.12032`, `patch.12438` and `patch.12723` filenames.
- Tells users to leave the OBB files intact in `gamedata`; no runtime binary,
  extractor recipe or generated-data contract changed from 1.1.3.

## 1.1.3

- Keeps the packaged X5M `sdl2-compat` private to the Box32 game process.
  NXExtract now starts with the X5M firmware SDL2/KMSDRM stack, matching the
  proven Horizon Chase first-run handoff and preventing a black extractor UI.
- Adds an extractor-only physical validation gate for maintainers; it can
  complete and publish a clean first-run transaction without starting
  gameplay, and is never enabled in the public launcher.
- Extends the deterministic package contract and provenance checks so a future
  build cannot leak the game SDL into the extractor environment.

## 1.1.2

- Aligns the X5M launch lifecycle with the 100%-working Horizon Chase port:
  EmulationStation/PortMaster owns DRM handoff, while the complete game
  launcher remains in the foreground.
- Stops handing the raw Box32 host to a platform helper. That helper cannot
  preserve the required i386 guest arguments and scoped runtime environment.
- Closes the universal release gate after deterministic package/source builds,
  reinstall/update preservation, full extractor validation on all three
  physical targets and exact-package ARM smoke tests.

## 1.1.1

- Makes the normalized runtime APK byte-identical across firmware zlib
  versions by storing all 622 already-recovered members without compression.
  Full per-member CRC/SHA-256 verification and the final archive hash remain
  mandatory before NXExtract can publish the transaction.
- Bumps the extraction recipe so an older compressed runtime APK cannot satisfy
  the new portable marker.

## 1.1.0

- Adds the validated AArch64 NextOS X5M route: the owner's original Android
  x86 library runs through a narrowly scoped Box32 host and `sdl2-compat` on
  the `amlogic,s7d` / Mali-G310 platform. The required scoped profile is
  `DYNAREC=1`, `BIGBLOCK=0`, `SAFEFLAGS=2`; long gameplay,
  save/create/update/reload and reopen completed with RC0.
- Extends NXExtract's single transaction to recover and validate both ARMv7
  and x86 native game libraries. An older ARM-only marker cannot skip the new
  output.
- Keeps the two proven ARMHF routes: a current-NextOS build and a low-glibc
  PortMaster build selected at runtime.
- Preserves the native first-run order, including the one-shot legal touch,
  cloud-data notice, control presentation, progressive loading and gameplay.
- Adds exact runtime hash/dependency preflight, corresponding source and
  license material for Box64 and `sdl2-compat`.
- Replaces catalogue artwork with a real 640×480 R36S gameplay capture and
  records its provenance.

## 1.0.1

- Preserves the original Android exit/restart lifecycle: `sExitGame()` invokes
  the game's `GameOptions.onExit()` callback once, while `RestartGame()` exits
  with status 75 and the launcher performs at most one foreground restart.
- Fixes a version-locked first-profile teardown crash seen after a genuinely
  empty installation, without skipping any native startup or loading stage.
- Adds an atomic launcher lock and verifies that old game processes are gone
  before starting, including executables replaced while still running.
- Validates the selected loader as ARMHF, verifies its declared interpreter
  and resolves all runtime libraries before extraction or game startup.
- Adds ARMHF library paths used by minimal PortMaster firmwares and accepts
  Wayland only when the corresponding socket actually exists.
- Refreshes both loader builds and records their exact hashes in
  `BUILD-PROVENANCE.json`.

## 1.0.0

- Public BYO-data ARMHF package for Android 1.2.7d.
- Separate current-NextOS and low-glibc PortMaster loaders, selected at run
  time without forcing an SDL video or audio backend.
- Transactional first-run preparation through NXExtract 1.1.2 with a
  downstream fix for primary loose files whose extension was removed.
- Exact validation of the source APK, three OBBs, recovered ARMv7 library,
  rebuilt runtime APK and generated offline shop catalogs.
- Updates commit only the seven generated proprietary outputs; saves,
  preferences, cache and the owner's source packages stay outside the
  transaction and are preserved.
- First physical controller action can accept the original first-run legal
  disclaimer through the loader's one-shot touch bridge.
