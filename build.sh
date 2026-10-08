#!/bin/sh
# test build into build/, using the latest vkroots and Vulkan-Headers
set -e
cd "$(dirname "$0")"

rm -rf external
git clone -q --depth=1 https://github.com/misyltoad/vkroots external/vkroots
git clone -q --depth=1 https://github.com/KhronosGroup/Vulkan-Headers external/Vulkan-Headers

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    -DVKROOTS_INCLUDE_DIR="$PWD/external/vkroots" \
    -DVULKAN_HEADERS_INCLUDE_DIR="$PWD/external/Vulkan-Headers/include"
cmake --build build
DESTDIR="$PWD/build/install" cmake --install build
