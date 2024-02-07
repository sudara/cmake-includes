# CMake Includes for Pamplejuce

Hi there!

## What is this?

It's most of the actual CMake functionality used by [Pamplejuce](https://github.com/sudara/pamplejuce), my template repository for plugins in the JUCE framework.

## How to include in your project

```cmake
cmake_minimum_required(VERSION 3.20)

include(FetchContent)
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

# Add pj_cmake_includes from https://github.com/sudara/cmake-includes
# Change the version in the following URL to update the package (watch the releases of the repository for future updates)
set(PJ_CMAKE_INCLUDES_VERSION "e4cb35e39b1ee0bb0060105ab1be959cff22d1c8")
FetchContent_Declare(
  _pamblejuce_cmake
  URL https://github.com/aminya/cmake-includes/archive/${PJ_CMAKE_INCLUDES_VERSION}.zip)
FetchContent_MakeAvailable(_pj_cmake_includes)
include(${_pj_cmake_includes_SOURCE_DIR}/Index.cmake)
```

## List Of Functions/Macros

Here are the functions/macros you can use. For full documentation of each see the respective files.

- `pjuce_add_assets`
- `pjuce_add_benchmark`
- `pjuce_ci_write_env_file`
- `pjuce_add_defaults`
- `pjuce_link_ipp`
- `pjuce_add_macos_defaults`
- `pjuce_read_version_file`
- `pjuce_add_shared_target_defaults`
- `pjuce_add_tests`
- `pjuce_xcode_pretty`


## Why is this its own CMake library

It's to help projects built by the template in the lastest changes.

[Pamplejuce](https://github.com/sudara/pamplejuce) is a template repository. Unlike most "dependencies," when you hit "Create Template" you are literally copying and pasting the code. Which sorta sucks, as people can't get fixes or updates.

## Why would I want updates?

For at least the gritty CMake details, there are fixes, improvements and additional functionality being added.

In the best case, as a library, you can update in the fixes and improvements.

In the worst case, this seperate repo will help you see what exactly changed in Pamplejuce.

## Is it risky?

It could be!

As of 2023, Pamplejuce is still being changed around a bunch, with the goal of being a better and better ecosystem for developers.

That means there could be breakage when you update.

## What changed recently tho?

See [CHANGELOG.md](CHANGELOG.md).
