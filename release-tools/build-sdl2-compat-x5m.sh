#!/usr/bin/env bash
# Rebuild AArch64 sdl2-compat against the target NextOS SDL3 development tree.
set -euo pipefail

SOURCE_DIR=${1:?usage: build-sdl2-compat-x5m.sh SOURCE_DIR BUILD_DIR}
BUILD_DIR=${2:?usage: build-sdl2-compat-x5m.sh SOURCE_DIR BUILD_DIR}
AARCH64_CC=${AARCH64_CC:-aarch64-linux-gnu-gcc}
SDL3_CMAKE_DIR=${SDL3_CMAKE_DIR:?set SDL3_CMAKE_DIR to SDL3Config.cmake directory}
SDL3_INCLUDE_DIRS=${SDL3_INCLUDE_DIRS:?set SDL3_INCLUDE_DIRS to target SDL3 headers}
TARGET_SYSROOT=${TARGET_SYSROOT:?set TARGET_SYSROOT to the current target NextOS sysroot}
AARCH64_READELF=${AARCH64_READELF:-aarch64-linux-gnu-readelf}
EXPECTED_SHA256=${EXPECTED_SHA256:-}

[ -d "$SOURCE_DIR" ] || {
  printf 'sdl2-compat source directory not found: %s\n' "$SOURCE_DIR" >&2
  exit 1
}
[ -d "$TARGET_SYSROOT" ] || {
  printf 'target sysroot not found: %s\n' "$TARGET_SYSROOT" >&2
  exit 1
}
[ -d "$SDL3_CMAKE_DIR" ] || {
  printf 'SDL3 CMake directory not found: %s\n' "$SDL3_CMAKE_DIR" >&2
  exit 1
}
for tool in awk cmake find ninja sed sha256sum "$AARCH64_CC" \
            "$AARCH64_READELF"; do
  command -v "$tool" >/dev/null 2>&1 || {
    printf 'required build tool not found: %s\n' "$tool" >&2
    exit 1
  }
done

cmake -S "$SOURCE_DIR" -B "$BUILD_DIR" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER="$AARCH64_CC" \
  -DCMAKE_SYSROOT="$TARGET_SYSROOT" \
  -DCMAKE_FIND_ROOT_PATH="$TARGET_SYSROOT" \
  -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
  -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
  -DSDL3_DIR="$SDL3_CMAKE_DIR" \
  -DSDL3_INCLUDE_DIRS="$SDL3_INCLUDE_DIRS" \
  -DSDL2COMPAT_LIBC=OFF \
  -DSDL2COMPAT_STATIC=OFF
cmake --build "$BUILD_DIR"

library=$(find "$BUILD_DIR" -maxdepth 1 -type f \
  -name 'libSDL2-2.0.so.0.*' -print -quit)
[ -n "$library" ] || {
  printf 'sdl2-compat output not found\n' >&2
  exit 1
}

machine=$("$AARCH64_READELF" -h "$library" |
  sed -n 's/^[[:space:]]*Machine:[[:space:]]*//p')
[ "$machine" = AArch64 ] || {
  printf 'unexpected sdl2-compat architecture: %s\n' "$machine" >&2
  exit 1
}

actual_sha256=$(sha256sum "$library" | awk '{print $1}')
if [ -n "$EXPECTED_SHA256" ] && [ "$actual_sha256" != "$EXPECTED_SHA256" ]; then
  printf 'sdl2-compat hash mismatch: %s\n' "$actual_sha256" >&2
  exit 1
fi
printf '%s  %s\n' "$actual_sha256" "$library"
