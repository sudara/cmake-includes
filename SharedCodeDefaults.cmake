# fast math and better simd support in RELEASE and RELWITHDEBINFO
if (MSVC)
    target_compile_options(SharedCode INTERFACE $<$<CONFIG:RELEASE>:/fp:fast>)
else ()
    target_compile_options(SharedCode INTERFACE $<$<CONFIG:RELEASE>:-Ofast>)
    target_compile_options(SharedCode INTERFACE $<$<CONFIG:RelWithDebInfo>:-Ofast>)
endif ()

# Tell MSVC to properly report what c++ version is being used
if (MSVC)
    target_compile_options(SharedCode INTERFACE /Zc:__cplusplus)
endif ()

# C++20, please
# Use cxx_std_23 for C++23 (as of CMake v 3.20)
target_compile_features(SharedCode INTERFACE cxx_std_20)
