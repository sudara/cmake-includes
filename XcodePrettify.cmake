include_guard()

# Make the target pretty in Xcode
#
# pjuce_xcode_pretty(
#     source_target
#     ASSET_TARGET asset_target
#     DIR dir
#     SOURCES source1 source2 ...
#     AudioPluginHostPath path
# )
#
# e.g.
# pjuce_xcode_pretty(
#     SharedCode
#     DIR ${CMAKE_CURRENT_SOURCE_DIR}/Source
#     SOURCES
#         ${CMAKE_CURRENT_SOURCE_DIR}/Source/*.cpp
#         ${CMAKE_CURRENT_SOURCE_DIR}/Source/*.h
# )
#
# AudioPluginHostPath defaults to ${CMAKE_CURRENT_SOURCE_DIR}/JUCE/extras/AudioPluginHost/Builds/MacOSX/build/Debug/AudioPluginHost.app"
function(pjuce_xcode_pretty source_target)
    set(_oneValueArgs DIR ASSET_TARGET _PJ_AUDIOPLUGINHOSTPATH)
    set(_multiValueArgs SOURCES)
    cmake_parse_arguments(_PJ "" "${_oneValueArgs}" "${_multiValueArgs}" ${ARGN})

    if (NOT _PJ_AUDIOPLUGINHOSTPATH)
        set(_PJ_AUDIOPLUGINHOSTPATH "${CMAKE_CURRENT_SOURCE_DIR}/JUCE/extras/AudioPluginHost/Builds/MacOSX/build/Debug/AudioPluginHost.app")
    endif ()

    if (NOT _PJ_ASSET_TARGET AND TARGET Assets)
        set(_PJ_ASSET_TARGET "Assets")
    endif ()

    # No, we don't want our source buried in extra nested folders
    set_target_properties(${source_target} PROPERTIES FOLDER "")

    # The Xcode source tree should uhhh, still look like the source tree, yo
    source_group(TREE ${_PJ_DIR} PREFIX "" FILES ${_PJ_SOURCES})

    # It tucks the Plugin varieties into a "Targets" folder and generate an Xcode Scheme manually
    # Xcode scheme generation is turned off globally to limit noise from other targets
    # The non-hacky way of doing this is via the global PREDEFINED_TARGETS_FOLDER property
    # However that doesn't seem to be working in Xcode
    # Not all plugin types (au, vst) available on each build type (win, macos, linux)
    foreach (target ${FORMATS} "All")
        if (TARGET ${PROJECT_NAME}_${target})
            set_target_properties(${PROJECT_NAME}_${target} PROPERTIES
                # Tuck the actual plugin targets into a folder where they won't bother us
                FOLDER "Targets"
                # Let us build the target in Xcode
                XCODE_GENERATE_SCHEME ON)

            # Set the default executable that Xcode will open on build
            # Note: you must manually build the AudioPluginHost.xcodeproj in the JUCE subdir
            if ((NOT target STREQUAL "All") AND (NOT target STREQUAL "Standalone"))
                set_target_properties(${PROJECT_NAME}_${target} PROPERTIES
                    XCODE_SCHEME_EXECUTABLE ${_PJ_AUDIOPLUGINHOSTPATH})
            endif ()
        endif ()
    endforeach ()

    set_target_properties(${_PJ_ASSET_TARGET} PROPERTIES FOLDER "Targets")
endfunction()
