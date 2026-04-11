find_program(BASH_EXECUTABLE bash REQUIRED)

set(WVG_BRIDGE_BIN "${CMAKE_CURRENT_SOURCE_DIR}/bridge/wavgang-bridge${CMAKE_EXECUTABLE_SUFFIX}")
set(WVG_FRIENDNET_BIN "${CMAKE_CURRENT_SOURCE_DIR}/bridge/friendnet-server${CMAKE_EXECUTABLE_SUFFIX}")

function(wvg_enable_local_helpers shared_code_target)
    if(NOT TARGET wavgang_agpl_helpers)
        add_custom_command(
            OUTPUT "${WVG_BRIDGE_BIN}" "${WVG_FRIENDNET_BIN}"
            COMMAND "${BASH_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/scripts/build-go-binaries.sh"
            DEPENDS
                "${CMAKE_CURRENT_SOURCE_DIR}/scripts/build-go-binaries.sh"
                "${CMAKE_CURRENT_SOURCE_DIR}/bridge/go.mod"
                "${CMAKE_CURRENT_SOURCE_DIR}/bridge/main.go"
                "${CMAKE_CURRENT_SOURCE_DIR}/bridge/status.go"
                "${CMAKE_CURRENT_SOURCE_DIR}/bridge/launcher.go"
                "${CMAKE_CURRENT_SOURCE_DIR}/third_party/friendnet/adminui/package.json"
                "${CMAKE_CURRENT_SOURCE_DIR}/third_party/friendnet/adminui/package-lock.json"
                "${CMAKE_CURRENT_SOURCE_DIR}/third_party/friendnet/server/go.mod"
                "${CMAKE_CURRENT_SOURCE_DIR}/third_party/friendnet/server/cmd/server/main.go"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            USES_TERMINAL
            VERBATIM)

        add_custom_target(wavgang_agpl_helpers DEPENDS "${WVG_BRIDGE_BIN}" "${WVG_FRIENDNET_BIN}")
    endif()

    get_target_property(active_targets "${shared_code_target}" JUCE_ACTIVE_PLUGIN_TARGETS)

    foreach(target IN LISTS active_targets)
        if(NOT TARGET "${target}")
            continue()
        endif()

        get_target_property(copy_root "${target}" JUCE_PLUGIN_COPY_DIR)
        get_target_property(bundle_root "${target}" JUCE_PLUGIN_ARTEFACT_FILE)

        add_dependencies("${target}" wavgang_agpl_helpers)

        add_custom_command(TARGET "${target}" POST_BUILD
            COMMAND "${CMAKE_COMMAND}"
                -Dsrc=${WVG_BRIDGE_BIN}
                -Ddst=$<TARGET_FILE_DIR:${target}>
                -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CopyFileIfExists.cmake"
            COMMAND "${CMAKE_COMMAND}"
                -Dsrc=${WVG_FRIENDNET_BIN}
                -Ddst=$<TARGET_FILE_DIR:${target}>
                -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CopyFileIfExists.cmake"
            VERBATIM)

        if(copy_root AND bundle_root)
            add_custom_command(TARGET "${target}" POST_BUILD
                COMMAND "${CMAKE_COMMAND}"
                    -Dsrc=${WVG_BRIDGE_BIN}
                    -Dbuild_bundle=${bundle_root}
                    -Dbuild_file_dir=$<TARGET_FILE_DIR:${target}>
                    -Dcopy_root=$<GENEX_EVAL:${copy_root}>
                    -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CopyHelperToJuceCopyDir.cmake"
                COMMAND "${CMAKE_COMMAND}"
                    -Dsrc=${WVG_FRIENDNET_BIN}
                    -Dbuild_bundle=${bundle_root}
                    -Dbuild_file_dir=$<TARGET_FILE_DIR:${target}>
                    -Dcopy_root=$<GENEX_EVAL:${copy_root}>
                    -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CopyHelperToJuceCopyDir.cmake"
                VERBATIM)
        endif()
    endforeach()
endfunction()
