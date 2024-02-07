include_guard()

# Add IPP support to a target
#
# pjuce_link_ipp(target)
#
function(pjuce_link_ipp target)
    # When present, use Intel IPP for performance on Windows
    if (WIN32) # Can't use MSVC here, as it won't catch Clang on Windows
        find_package(IPP)
        if (IPP_FOUND)
            target_link_libraries(${target} INTERFACE IPP::ipps IPP::ippcore IPP::ippi IPP::ippcv)
            message("IPP LIBRARIES FOUND")
            target_compile_definitions(${target} INTERFACE PAMPLEJUCE_IPP=1)
        else ()
            message("IPP LIBRARIES *NOT* FOUND")
        endif ()
    endif ()
endfunction()
