include_guard()

# Define a benchmark target with the given sources and Catch2
#
# pjuce_add_benchmark(
#     target
#     [DIR dir]
#     SOURCES <sources...>
#     INCLUDES <includes...>
#     DEPENDS <depends...>
# )
#
# e.g.
# pjuce_add_benchmark(
#     Benchmarks
#     DIR ./benchmarks
#     SOURCES ./benchmarks/*.cpp ./benchmarks/*.h
#     INCLUDES ${CMAKE_CURRENT_SOURCE_DIR}/../Source
#     DEPENDS SharedCode
# )
function(pjuce_add_benchmark target)
    set(_oneValueArgs DIR)
    set(_multiValueArgs SOURCES INCLUDES DEPENDS)
    cmake_parse_arguments(_PJ "" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN})

    if (NOT _PJ_DIR)
        set(_PJ_DIR ${CMAKE_CURRENT_SOURCE_DIR}/benchmarks)
    endif()


    file(GLOB_RECURSE BenchmarkFiles CONFIGURE_DEPENDS ${_PJ_SOURCES})

    # Organize the test source in the Tests/ folder in the IDE
    source_group(TREE ${_PJ_DIR}  PREFIX "" FILES ${BenchmarkFiles})

    add_executable(${target} ${BenchmarkFiles})
    target_compile_features(${target} PRIVATE cxx_std_20)
    catch_discover_tests(${target})

    # Our benchmark executable also wants to know about our plugin code...
    target_include_directories(${target} PRIVATE ${_PJ_INCLUDES})

    # Copy over compile definitions from our plugin target so it has all the JUCEy goodness
    target_compile_definitions(${target} PRIVATE $<TARGET_PROPERTY:${PROJECT_NAME},COMPILE_DEFINITIONS>)

    # And give tests access to our shared code
    target_link_libraries(${target} PRIVATE ${_PJ_DEPENDS} Catch2::Catch2WithMain)

    # Make an Xcode Scheme for the test executable so we can run tests in the IDE
    set_target_properties(${target} PROPERTIES XCODE_GENERATE_SCHEME ON)

    # When running Tests we have specific needs
    target_compile_definitions(${target} PUBLIC
        JUCE_MODAL_LOOPS_PERMITTED=1 # let us run Message Manager in tests
        RUN_PAMPLEJUCE_TESTS=1 # also run tests in module .cpp files guarded by RUN_PAMPLEJUCE_TESTS
    )
endfunction()
