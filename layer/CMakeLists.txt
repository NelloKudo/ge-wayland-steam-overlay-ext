cmake_minimum_required(VERSION 3.16)

project(steam_overlay_wayland
    VERSION 1.0.0
    LANGUAGES C CXX
)

include(GNUInstallDirs)

find_package(Threads REQUIRED)

# Install the bridge next to the layers, which find it through $ORIGIN.
set(LAYER_SAVED_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}/steam-overlay-wayland")
add_subdirectory(
    "${CMAKE_CURRENT_SOURCE_DIR}/../bridge"
    "${CMAKE_CURRENT_BINARY_DIR}/lsteamclient-overlay-bridge"
)
set(CMAKE_INSTALL_LIBDIR "${LAYER_SAVED_INSTALL_LIBDIR}")

set(VULKAN_HEADERS_INCLUDE_DIR "" CACHE PATH "Directory containing Vulkan headers")
if(NOT EXISTS "${VULKAN_HEADERS_INCLUDE_DIR}/vulkan/vulkan.h")
    message(FATAL_ERROR "VULKAN_HEADERS_INCLUDE_DIR must contain vulkan/vulkan.h")
endif()

set(VKROOTS_INCLUDE_DIR "" CACHE PATH "Directory containing vkroots.h")
if(NOT EXISTS "${VKROOTS_INCLUDE_DIR}/vkroots.h")
    message(FATAL_ERROR "VKROOTS_INCLUDE_DIR must contain vkroots.h")
endif()

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(LAYER_ARCH "64")
else()
    set(LAYER_ARCH "32")
endif()

set(FRONT_LAYER_NAME "VK_LAYER_GE_wayland_steam_overlay_front_${LAYER_ARCH}")
set(BACK_LAYER_NAME "VK_LAYER_GE_wayland_steam_overlay_back_${LAYER_ARCH}")
set(META_LAYER_NAME "VK_LAYER_GE_wayland_steam_overlay_${LAYER_ARCH}")
set(STEAM_COMPONENT_LAYER_NAME "VK_LAYER_GE_steam_overlay_component_${LAYER_ARCH}")

add_library(VkLayer_GE_Wayland_SteamOverlay_Front SHARED
    src/vulkan_layer.cpp
)

add_library(VkLayer_GE_Wayland_SteamOverlay_Back SHARED
    src/vulkan_translate_layer.c
)

target_compile_features(VkLayer_GE_Wayland_SteamOverlay_Front PRIVATE
    c_std_11
    cxx_std_20
)
target_compile_features(VkLayer_GE_Wayland_SteamOverlay_Back PRIVATE c_std_11)

target_compile_definitions(VkLayer_GE_Wayland_SteamOverlay_Front PRIVATE
    _GNU_SOURCE
    GE_STEAM_OVERLAY_BACK_LIBRARY="libVkLayer_GE_Wayland_SteamOverlay_Back.so"
)
target_compile_definitions(VkLayer_GE_Wayland_SteamOverlay_Back PRIVATE
    _GNU_SOURCE
)

target_compile_options(VkLayer_GE_Wayland_SteamOverlay_Front PRIVATE
    -Wall
    -Wextra
    -Wformat=2
    -Wshadow
    $<$<COMPILE_LANGUAGE:C>:-Wstrict-prototypes>
)
target_compile_options(VkLayer_GE_Wayland_SteamOverlay_Back PRIVATE
    -Wall
    -Wextra
    -Wformat=2
    -Wshadow
    -Wstrict-prototypes
)

target_include_directories(VkLayer_GE_Wayland_SteamOverlay_Front PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${VULKAN_HEADERS_INCLUDE_DIR}
    ${VKROOTS_INCLUDE_DIR}
)
target_include_directories(VkLayer_GE_Wayland_SteamOverlay_Back PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${VULKAN_HEADERS_INCLUDE_DIR}
    ${VKROOTS_INCLUDE_DIR}
)

target_link_libraries(VkLayer_GE_Wayland_SteamOverlay_Front PRIVATE
    lsteamclient_overlay_bridge
)
target_link_libraries(VkLayer_GE_Wayland_SteamOverlay_Back PRIVATE
    Threads::Threads
    ${CMAKE_DL_LIBS}
)

set_target_properties(
    VkLayer_GE_Wayland_SteamOverlay_Front
    VkLayer_GE_Wayland_SteamOverlay_Back
    PROPERTIES
    C_VISIBILITY_PRESET hidden
    INSTALL_RPATH "$ORIGIN"
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES
    LINK_OPTIONS "-Wl,-Bsymbolic"
)

# library_path in the manifests is relative to the manifest
set(LAYER_MANIFEST_DIR "${CMAKE_INSTALL_DATADIR}/steam-overlay-wayland")
file(RELATIVE_PATH LAYER_LIBRARY_DIR
    "${CMAKE_INSTALL_PREFIX}/${LAYER_MANIFEST_DIR}/explicit_layer.d"
    "${CMAKE_INSTALL_FULL_LIBDIR}/steam-overlay-wayland")

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/VkLayer_GE_wayland_steam_overlay.json.in
    ${CMAKE_CURRENT_BINARY_DIR}/VkLayer_GE_wayland_steam_overlay_${LAYER_ARCH}.json
    @ONLY
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/VkLayer_GE_wayland_steam_overlay_front.json.in
    ${CMAKE_CURRENT_BINARY_DIR}/VkLayer_GE_wayland_steam_overlay_front_${LAYER_ARCH}.json
    @ONLY
)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/VkLayer_GE_wayland_steam_overlay_back.json.in
    ${CMAKE_CURRENT_BINARY_DIR}/VkLayer_GE_wayland_steam_overlay_back_${LAYER_ARCH}.json
    @ONLY
)
install(TARGETS
    VkLayer_GE_Wayland_SteamOverlay_Front
    VkLayer_GE_Wayland_SteamOverlay_Back
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/steam-overlay-wayland
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/VkLayer_GE_wayland_steam_overlay_${LAYER_ARCH}.json
    DESTINATION ${LAYER_MANIFEST_DIR}/implicit_layer.d
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/VkLayer_GE_wayland_steam_overlay_front_${LAYER_ARCH}.json
    ${CMAKE_CURRENT_BINARY_DIR}/VkLayer_GE_wayland_steam_overlay_back_${LAYER_ARCH}.json
    DESTINATION ${LAYER_MANIFEST_DIR}/explicit_layer.d
)
