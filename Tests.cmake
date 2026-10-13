# Once-only test harness setup (ctest config + Catch2). Guarded so a second include() is a no-op.
if (NOT DEFINED _PAMPLEJUCE_TESTS_SETUP_DONE)
    set(_PAMPLEJUCE_TESTS_SETUP_DONE ON)

    # Required for ctest (which is just an easier way to run in cross-platform CI)
    # include(CTest) could be used too, but adds additional targets we don't care about
    # See: https://github.com/catchorg/Catch2/issues/2026
    # You can also forgo ctest entirely and call ./Tests directly from the build dir
    enable_testing()

    include (CPM)

    # Go into detail when there's a CTest failure
    set(CTEST_OUTPUT_ON_FAILURE ON)
    set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)

    # Workaround for CLion
    # See https://www.jetbrains.com/help/clion/catch-tests-support.html#long-testnames-bug
    # and https://github.com/catchorg/Catch2/issues/2751
    if (DEFINED ENV{CLION_IDE})
        set(CATCH_CONFIG_CONSOLE_WIDTH 200 CACHE STRING "CLion Workaround" FORCE)
    endif ()

    # Use Catch2 v3 on the devel branch
    CPMAddPackage("gh:catchorg/Catch2@3.8.1")

    # Load and use the .cmake file provided by Catch2
    # https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md
    # We have to manually provide the source directory here for now
    include(${Catch2_SOURCE_DIR}/extras/Catch.cmake)
endif ()

function(pamplejuce_add_tests)
    set(oneValueArgs TARGET DIRECTORY PLUGIN_TARGET SHARED_CODE SOURCE_INCLUDE_DIR)
    cmake_parse_arguments(PAMP_TESTS "" "${oneValueArgs}" "" ${ARGN})

    # iOS does not support console test runners.
    if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
        return()
    endif ()

    if (NOT PAMP_TESTS_TARGET)
        set(PAMP_TESTS_TARGET Tests)
    endif ()
    if (NOT PAMP_TESTS_DIRECTORY)
        set(PAMP_TESTS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/tests")
    endif ()
    if (NOT PAMP_TESTS_PLUGIN_TARGET)
        set(PAMP_TESTS_PLUGIN_TARGET "${PROJECT_NAME}")
    endif ()
    if (NOT PAMP_TESTS_SHARED_CODE)
        set(PAMP_TESTS_SHARED_CODE SharedCode)
    endif ()
    if (NOT PAMP_TESTS_SOURCE_INCLUDE_DIR)
        set(PAMP_TESTS_SOURCE_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/source")
    endif ()

    # "GLOBS ARE BAD" is brittle and silly dev UX, sorry CMake!
    file(GLOB_RECURSE TestFiles CONFIGURE_DEPENDS "${PAMP_TESTS_DIRECTORY}/*.cpp" "${PAMP_TESTS_DIRECTORY}/*.h")

    # Organize the test source in the Tests/ folder in Xcode
    source_group(TREE ${PAMP_TESTS_DIRECTORY} PREFIX "" FILES ${TestFiles})

    # Setup the test executable, again C++20 please
    add_executable(${PAMP_TESTS_TARGET} ${TestFiles})
    target_compile_features(${PAMP_TESTS_TARGET} PRIVATE cxx_std_20)

    # Our test executable also wants to know about our plugin code...
    target_include_directories(${PAMP_TESTS_TARGET} PRIVATE ${PAMP_TESTS_SOURCE_INCLUDE_DIR})

    # Copy over compile definitions from our plugin target so it has all the JUCEy goodness
    target_compile_definitions(${PAMP_TESTS_TARGET} PRIVATE $<TARGET_PROPERTY:${PAMP_TESTS_PLUGIN_TARGET},COMPILE_DEFINITIONS>)

    # And give tests access to our shared code
    target_link_libraries(${PAMP_TESTS_TARGET} PRIVATE ${PAMP_TESTS_SHARED_CODE} Catch2::Catch2)

    # Make an Xcode Scheme for the test executable so we can run tests in the IDE
    set_target_properties(${PAMP_TESTS_TARGET} PROPERTIES XCODE_GENERATE_SCHEME ON)

    # When running Tests we have specific needs
    target_compile_definitions(${PAMP_TESTS_TARGET} PUBLIC
        JUCE_MODAL_LOOPS_PERMITTED=1 # let us run Message Manager in tests
        RUN_PAMPLEJUCE_TESTS=1 # also run tests in other module .cpp files guarded by RUN_PAMPLEJUCE_TESTS
    )

    # Let our tests target know we are running in CI
    if ((DEFINED ENV{CI}))
        target_compile_definitions(${PAMP_TESTS_TARGET} PUBLIC CI=1)
    endif ()

    # ${DISCOVERY_MODE} set to "PRE_TEST" for MacOS arm64 / Xcode development
    # fixes error when Xcode attempts to run test executable
    catch_discover_tests(${PAMP_TESTS_TARGET} DISCOVERY_MODE PRE_TEST)
endfunction()

# Legacy single-product consumers get today's exact behavior at include time.
if (NOT _PAMPLEJUCE_USE_FUNCTIONS)
    pamplejuce_add_tests()
endif ()
