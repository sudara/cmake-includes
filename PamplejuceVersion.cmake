include_guard()

# Read the version file and sets the version to the CURRENT_VERSION argument
#
# pjuce_read_version_file(FILE <file> CURRENT_VERSION)
#
# e.g.
# pjuce_read_version_file(FILE "VERSION" CURRENT_VERSION)
#
# pjuce_read_version_file(CURRENT_VERSION) # defaults to "VERSION" file
#
function(pjuce_read_version_file CURRENT_VERSION)
    cmake_parse_arguments(_PJ "" "FILE" "" ${ARGN})

    if(NOT _PJ_FILE)
        set(_PJ_FILE "VERSION")
    endif()

    # Reads in our VERSION file and sticks in it CURRENT_VERSION variable
    # Be sure the file has no newlines!
    # This exposes CURRENT_VERSION to the build system
    # And it's later fed to JUCE so it shows up as VERSION in your IDE
    file(STRINGS ${_PJ_FILE} _CURRENT_VERSION)

    # Figure out the major version to append to our PROJECT_NAME
    string(REGEX MATCH "([0-9]+)" MAJOR_VERSION ${_CURRENT_VERSION})
    message(STATUS "Major version: ${MAJOR_VERSION}")

    set(${CURRENT_VERSION} ${_CURRENT_VERSION} PARENT_SCOPE)
endfunction()
