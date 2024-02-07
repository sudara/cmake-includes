include_guard()

#
# Define a binary data target for a JUCE application using the given ASSETS
# pjuce_add_assets(target [ASSETS glob1 glob2 ...])
#
# e.g.
# pjuce_add_assets(Assets ASSETS assets/*)
#
# By default, if no ASSETS are provided, we assume that all the files in the `assets` folder should be included in your binary!
# This makes life easy, but will bloat your binary needlessly if you include unused files
#
function(pjuce_add_assets target)
    cmake_parse_arguments(_PJ "" "" "ASSETS" ${ARGN})

    # If no files are provided, we assume the assets folder is where we want to look
    if(NOT _PJ_ASSETS)
        set(_PJ_ASSETS "${CMAKE_CURRENT_SOURCE_DIR}/assets/*")
    endif()

    file(GLOB_RECURSE AssetFiles CONFIGURE_DEPENDS ${_PJ_ASSETS})

    # Setup our binary data as a target called Assets
    juce_add_binary_data(${target} SOURCES ${AssetFiles})

    # Required for Linux happiness:
    # See https://forum.juce.com/t/loading-pytorch-model-using-binarydata/39997/2
    set_target_properties(${target} PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
endfunction()
