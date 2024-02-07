include_guard()

# Add the defaults for the shared code target
# It enables C++20, fast math and better simd support in RELEASE and RELWITHDEBINFO
#
# pjuce_add_shared_target_defaults(target)
#
# e.g.
# pjuce_add_shared_target_defaults(SharedCode)
#
function(pjuce_add_shared_target_defaults target)
    # fast math and better simd support in RELEASE and RELWITHDEBINFO
    if (MSVC)
        # https://learn.microsoft.com/en-us/cpp/build/reference/fp-specify-floating-point-behavior?view=msvc-170#fast
        target_compile_options(${target} INTERFACE $<$<CONFIG:RELEASE>:/fp:fast>)
    else ()
        # See the implications here:
        # https://stackoverflow.com/q/45685487
        target_compile_options(${target} INTERFACE $<$<CONFIG:RELEASE>:-Ofast>)
        target_compile_options(${target} INTERFACE $<$<CONFIG:RelWithDebInfo>:-Ofast>)
    endif ()

    # Tell MSVC to properly report what c++ version is being used
    if (MSVC)
        target_compile_options(${target} INTERFACE /Zc:__cplusplus)
    endif ()

    # C++20, please
    # Use cxx_std_23 for C++23 (as of CMake v 3.20)
    target_compile_features(${target} INTERFACE cxx_std_20)
endfunction()
