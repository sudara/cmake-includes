file(GLOB_RECURSE BenchmarkFiles CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/benchmarks/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/benchmarks/*.h")

# Organize the test source in the Tests/ folder in the IDE
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/benchmarks PREFIX "" FILES ${BenchmarkFiles})

add_executable(Benchmarks ${BenchmarkFiles})
target_compile_features(Benchmarks PRIVATE cxx_std_20)
catch_discover_tests(Benchmarks)

# Our benchmark executable also wants to know about our plugin code...
target_include_directories(Benchmarks PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/source
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_artefacts/JuceLibraryCode/$<CONFIG>>")

add_dependencies(Benchmarks "${PROJECT_NAME}")

# Copy over compile definitions from our plugin target so it has all the JUCEy goodness
target_compile_definitions(Benchmarks PRIVATE $<TARGET_PROPERTY:${PROJECT_NAME},COMPILE_DEFINITIONS>)

# And give tests access to our shared code
set(_WVG_BENCH_LIBS SharedCode Catch2::Catch2)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_package(PkgConfig REQUIRED)
    find_package(CURL REQUIRED)
    pkg_check_modules(WVG_BENCH_WEB IMPORTED_TARGET webkit2gtk-4.1 gtk+-x11-3.0)
    if(NOT WVG_BENCH_WEB_FOUND)
        pkg_check_modules(WVG_BENCH_WEB REQUIRED IMPORTED_TARGET webkit2gtk-4.0 gtk+-x11-3.0)
    endif()
    list(APPEND _WVG_BENCH_LIBS PkgConfig::WVG_BENCH_WEB CURL::libcurl)
    target_sources(Benchmarks PRIVATE
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_artefacts/JuceLibraryCode/$<CONFIG>/juce_LinuxSubprocessHelperBinaryData.cpp>")
endif()
target_link_libraries(Benchmarks PRIVATE ${_WVG_BENCH_LIBS})

if(WIN32)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/JUCE/extras/Build/CMake")
    find_package(WebView2 REQUIRED)
    target_link_libraries(Benchmarks PRIVATE juce::juce_webview2)
endif()

# Make an Xcode Scheme for the test executable so we can run tests in the IDE
set_target_properties(Benchmarks PROPERTIES XCODE_GENERATE_SCHEME ON)

# When running Tests we have specific needs
target_compile_definitions(Benchmarks PUBLIC
    JUCE_MODAL_LOOPS_PERMITTED=1 # let us run Message Manager in tests
    RUN_PAMPLEJUCE_TESTS=1 # also run tests in module .cpp files guarded by RUN_PAMPLEJUCE_TESTS
)
