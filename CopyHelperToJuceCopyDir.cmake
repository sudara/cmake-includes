if(NOT DEFINED src)
    message(FATAL_ERROR "CopyHelperToJuceCopyDir.cmake requires -Dsrc=<path>")
endif()

if(NOT DEFINED build_bundle)
    message(FATAL_ERROR "CopyHelperToJuceCopyDir.cmake requires -Dbuild_bundle=<path>")
endif()

if(NOT DEFINED build_file_dir)
    message(FATAL_ERROR "CopyHelperToJuceCopyDir.cmake requires -Dbuild_file_dir=<path>")
endif()

if(NOT DEFINED copy_root OR copy_root STREQUAL "")
    return()
endif()

if(NOT EXISTS "${src}")
    return()
endif()

get_filename_component(bundle_name "${build_bundle}" NAME)
file(RELATIVE_PATH relative_dir "${build_bundle}" "${build_file_dir}")

set(dest_dir "${copy_root}/${bundle_name}")
if(NOT relative_dir STREQUAL ".")
    set(dest_dir "${dest_dir}/${relative_dir}")
endif()

get_filename_component(name "${src}" NAME)
file(MAKE_DIRECTORY "${dest_dir}")
file(COPY_FILE "${src}" "${dest_dir}/${name}" ONLY_IF_DIFFERENT)
