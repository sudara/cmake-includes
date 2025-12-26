# When present, use Intel IPP for performance on Windows, Linux, and macOS (x86_64 only)
if(WIN32)
    set(IPP_ROOT "$ENV{USERPROFILE}/.nuget/packages/intelipp.static.win-x64/2022.3.0.387")
    set(IPP_INC "${IPP_ROOT}/build/native/include/ipp")
    set(IPP_LIB "${IPP_ROOT}/build/native/win-x64/")
    set(IPP_LIBS ippsmt ippcoremt ippimt ippcvmt ippvmmt)
elseif(APPLE)
    # Enable IPP for Intel builds (not ARM), it's often faster than vdsp (on Intel)
    if(CMAKE_OSX_ARCHITECTURES MATCHES "x86_64" OR
       (NOT CMAKE_OSX_ARCHITECTURES AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64"))
        # Downloaded from pip: ipp-include and ipp-static wheels (version 2021.9.1)
        set(IPP_ROOT "${CMAKE_SOURCE_DIR}/ipp-macos")
        set(IPP_INC "${IPP_ROOT}/ipp_include-2021.9.1.data/data/include")
        set(IPP_LIB "${IPP_ROOT}/ipp_static-2021.9.1.data/data/lib")
        set(IPP_MACOS TRUE)
    endif()
elseif(UNIX)
    # Installed via intel-oneapi-ipp-devel package
    set(IPP_ROOT "/opt/intel/oneapi/ipp/latest")
    set(IPP_INC "${IPP_ROOT}/include")
    set(IPP_LIB "${IPP_ROOT}/lib")
    set(IPP_LIBS ipps ippcore ippi ippcv ippvm)
endif()

if (DEFINED IPP_ROOT)
    if (IS_DIRECTORY "${IPP_ROOT}")
        message(STATUS "INTEL IPP FOUND at ${IPP_ROOT}")
        target_include_directories(SharedCode INTERFACE "${IPP_INC}")

        if (IPP_MACOS)
            # Use -Xarch_x86_64 to only apply IPP flags to x86_64 slice of universal binary
            target_compile_options(SharedCode INTERFACE "SHELL:-Xarch_x86_64 -DPAMPLEJUCE_IPP=1")
            target_link_options(SharedCode INTERFACE
                "SHELL:-Xarch_x86_64 -L${IPP_LIB}"
                "SHELL:-Xarch_x86_64 -lipps"
                "SHELL:-Xarch_x86_64 -lippcore"
                "SHELL:-Xarch_x86_64 -lippi"
                "SHELL:-Xarch_x86_64 -lippcv"
                "SHELL:-Xarch_x86_64 -lippvm"
            )
        else()
            target_link_directories(SharedCode INTERFACE "${IPP_LIB}")
            target_link_libraries(SharedCode INTERFACE ${IPP_LIBS})
            target_compile_definitions(SharedCode INTERFACE PAMPLEJUCE_IPP=1)
        endif()
    else ()
        message(STATUS "INTEL IPP NOT LOADED: ${IPP_ROOT} was not found")
    endif ()
endif ()
