# Relies on Tests.cmake having been included first (Catch2 package + catch_discover_tests).

function(pamplejuce_add_benchmarks)
    set(oneValueArgs TARGET DIRECTORY PLUGIN_TARGET SHARED_CODE SOURCE_INCLUDE_DIR)
    cmake_parse_arguments(PAMP_BENCH "" "${oneValueArgs}" "" ${ARGN})

    # iOS does not support console benchmark runners.
    if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
        return()
    endif ()

    if (NOT PAMP_BENCH_TARGET)
        set(PAMP_BENCH_TARGET Benchmarks)
    endif ()
    if (NOT PAMP_BENCH_DIRECTORY)
        set(PAMP_BENCH_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/benchmarks")
    endif ()
    if (NOT PAMP_BENCH_PLUGIN_TARGET)
        set(PAMP_BENCH_PLUGIN_TARGET "${PROJECT_NAME}")
    endif ()
    if (NOT PAMP_BENCH_SHARED_CODE)
        set(PAMP_BENCH_SHARED_CODE SharedCode)
    endif ()
    if (NOT PAMP_BENCH_SOURCE_INCLUDE_DIR)
        set(PAMP_BENCH_SOURCE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source")
    endif ()

    file(GLOB_RECURSE BenchmarkFiles CONFIGURE_DEPENDS "${PAMP_BENCH_DIRECTORY}/Catch2Main.cpp" "${PAMP_BENCH_DIRECTORY}/*.h")

    # Organize the test source in the Tests/ folder in the IDE
    source_group(TREE ${PAMP_BENCH_DIRECTORY} PREFIX "" FILES ${BenchmarkFiles})

    add_executable(${PAMP_BENCH_TARGET} ${BenchmarkFiles})
    target_compile_features(${PAMP_BENCH_TARGET} PRIVATE cxx_std_20)
    catch_discover_tests(${PAMP_BENCH_TARGET})

    # Our benchmark executable also wants to know about our plugin code...
    target_include_directories(${PAMP_BENCH_TARGET} PRIVATE ${PAMP_BENCH_SOURCE_INCLUDE_DIR})

    # Copy over compile definitions from our plugin target so it has all the JUCEy goodness
    target_compile_definitions(${PAMP_BENCH_TARGET} PRIVATE $<TARGET_PROPERTY:${PAMP_BENCH_PLUGIN_TARGET},COMPILE_DEFINITIONS>)

    # And give tests access to our shared code
    target_link_libraries(${PAMP_BENCH_TARGET} PRIVATE ${PAMP_BENCH_SHARED_CODE} Catch2::Catch2)

    # Make an Xcode Scheme for the test executable so we can run tests in the IDE
    set_target_properties(${PAMP_BENCH_TARGET} PROPERTIES XCODE_GENERATE_SCHEME ON)

    # When running Tests we have specific needs
    target_compile_definitions(${PAMP_BENCH_TARGET} PUBLIC
        JUCE_MODAL_LOOPS_PERMITTED=1 # let us run Message Manager in tests
        RUN_PAMPLEJUCE_TESTS=1 # also run tests in module .cpp files guarded by RUN_PAMPLEJUCE_TESTS
    )
endfunction()

# Legacy single-product consumers get today's exact behavior at include time.
if (NOT _PAMPLEJUCE_USE_FUNCTIONS)
    pamplejuce_add_benchmarks()
endif ()
