
# This must be set before the project() call
# see: https://cmake.org/cmake/help/latest/variable/CMAKE_OSX_DEPLOYMENT_TARGET.html
# FORCE must be set, see https://stackoverflow.com/a/44340246
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Support macOS down to High Sierra" FORCE)

# Building universal binaries on macOS increases build time
# This is set on CI but not during local dev
if ((DEFINED ENV{CI} OR DEFINED FORCE_UNIVERSAL_BINARY) AND NOT (CMAKE_SYSTEM_NAME STREQUAL "iOS"))
    # For multi-config generators, set architectures for Release config
    if(CMAKE_CONFIGURATION_TYPES)
        set(CMAKE_OSX_ARCHITECTURES_RELEASE "arm64;x86_64" CACHE STRING "Architecture for Release builds" FORCE)
        message("Universal binary will be built for Release configuration")
    elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
        message("Building for Apple Silicon and x86_64")
        set(CMAKE_OSX_ARCHITECTURES arm64 x86_64)
    endif()
endif ()

# By default we don't want Xcode schemes to be made for modules, etc
set(CMAKE_XCODE_GENERATE_SCHEME OFF)
