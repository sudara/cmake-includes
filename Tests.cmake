include_guard()

# Define a test target with the given sources and Catch2
#
# pjuce_add_tests(
#     target
#     [DIR dir]
#     SOURCES <sources...>
#     INCLUDES <includes...>
#     DEPENDS <depends...>
# )
#
# e.g.
# pjuce_add_tests(
#     Tests
#     DIR ./tests
#     SOURCES ./tests/*.cpp ./tests/*.h
#     INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/../Source
#     DEPENDS SharedCode
# )
macro(pjuce_add_tests target)
    set(_oneValueArgs DIR)
    set(_multiValueArgs SOURCES INCLUDES DEPENDS)
    cmake_parse_arguments(_PJ "" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN})

    if (NOT _PJ_DIR)
        set(_PJ_DIR ${CMAKE_CURRENT_SOURCE_DIR}/tests)
    endif()

    # Required for ctest (which is just an easier way to run in cross-platform CI)
    # include(CTest) could be used too, but adds additional targets we don't care about
    # See: https://github.com/catchorg/Catch2/issues/2026
    # You can also forgo ctest entirely and call ./Tests directly from the build dir
    enable_testing()

    # Go into detail when there's a CTest failure
    set(CTEST_OUTPUT_ON_FAILURE ON)
    set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)

    # "GLOBS ARE BAD" is brittle and silly dev UX, sorry CMake!
    file(GLOB_RECURSE TestFiles CONFIGURE_DEPENDS ${_PJ_SOURCES})

    # Organize the test source in the Tests/ folder in Xcode
    source_group(TREE ${_PJ_DIR} PREFIX "" FILES ${TestFiles})

    # Use Catch2 v3 on the devel branch
    Include(FetchContent)
    FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_PROGRESS TRUE
        GIT_SHALLOW TRUE
        GIT_TAG v3.4.0)
    FetchContent_MakeAvailable(Catch2) # find_package equivalent

    # Setup the test executable, again C++20 please
    add_executable(${target} ${TestFiles})
    target_compile_features(${target} PRIVATE cxx_std_20)

    # Our test executable also wants to know about our plugin code...
    target_include_directories(${target} PRIVATE ${_PJ_INCLUDES})

    # Copy over compile definitions from our plugin target so it has all the JUCEy goodness
    target_compile_definitions(${target} PRIVATE $<TARGET_PROPERTY:${PROJECT_NAME},COMPILE_DEFINITIONS>)

    # And give tests access to our shared code
    target_link_libraries(${target} PRIVATE ${_PJ_DEPENDS} Catch2::Catch2WithMain)

    # Make an Xcode Scheme for the test executable so we can run tests in the IDE
    set_target_properties(${target} PROPERTIES XCODE_GENERATE_SCHEME ON)

    # When running tests we have specific needs
    target_compile_definitions(${target} PUBLIC
        JUCE_MODAL_LOOPS_PERMITTED=1 # let us run Message Manager in tests
        RUN_PAMPLEJUCE_TESTS=1 # also run tests in other module .cpp files guarded by RUN_PAMPLEJUCE_TESTS
    )

    # Load and use the .cmake file provided by Catch2
    # https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md
    # We have to manually provide the source directory here for now
    include(${Catch2_SOURCE_DIR}/extras/Catch.cmake)
    catch_discover_tests(${target})
endmacro()
