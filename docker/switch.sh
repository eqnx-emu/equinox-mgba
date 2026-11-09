#!/usr/bin/env bash
# Builds equinox-mgba.nro inside the devkitPro container.
# The CMake build tree lives in a Docker volume (/build) because bind mounts on
# Windows are slow; only the final files are copied back to the repo.
set -euo pipefail

SRC=/src
BUILD=/build/switch
OUT="$SRC/build/docker"
JOBS="${JOBS:-$(nproc)}"
BUILD_TYPE="${BUILD_TYPE:-Release}"

git config --global --add safe.directory '*'

if [ ! -f "$SRC/extern/mgba/CMakeLists.txt" ]; then
    echo "Submodules are missing. Run: git submodule update --init --recursive" >&2
    exit 1
fi

# SDL2 and SDL2_ttf come from devkitPro portlibs.
for pkg in switch-sdl2 switch-sdl2_ttf switch-freetype switch-libpng switch-bzip2 switch-zlib; do
    dkp-pacman -Q "$pkg" >/dev/null 2>&1 || dkp-pacman -S --noconfirm "$pkg"
done

# mGBA core as a static library, with its own CMake build tree.
cmake -S "$SRC/extern/mgba" -B "$BUILD-core" \
    -DCMAKE_TOOLCHAIN_FILE=/opt/devkitpro/cmake/Switch.cmake \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DLIBMGBA_ONLY=ON -DBUILD_LIBRETRO=ON -DLIBRETRO_STATIC=ON -DLIBRETRO_SUFFIX=_libnx \
    -DSKIP_LIBRARY=ON -DNSWITCH=ON
cmake --build "$BUILD-core" --target mgba_libretro -j"$JOBS"
CORE_LIB="$BUILD-core/mgba_libretro_libnx.a"

cmake -S "$SRC" -B "$BUILD" \
    -DCMAKE_TOOLCHAIN_FILE=/opt/devkitpro/cmake/Switch.cmake \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DEQX_CORE_LIB="$CORE_LIB"
cmake --build "$BUILD" --target equinox-mgba_nro -j"$JOBS"

mkdir -p "$OUT"
cp "$BUILD/equinox-mgba.nro" "$OUT/equinox-mgba.nro"
cp "$BUILD/equinox-mgba.elf" "$OUT/equinox-mgba.elf"
echo "Done: build/docker/equinox-mgba.nro"
