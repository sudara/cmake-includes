# Reads in our VERSION file and sticks in it CURRENT_VERSION variable
# Be sure the file has no newlines!
# This exposes CURRENT_VERSION to the build system
# And it's later fed to JUCE so it shows up as VERSION in your IDE

# Make sure changing VERSION breaks cache and reconfigures
# This is done by copying the file into the build directory
configure_file(VERSION VERSION COPYONLY)
file(STRINGS ${CMAKE_CURRENT_BINARY_DIR}/VERSION CURRENT_VERSION)

# Figure out the major version to append to our PROJECT_NAME
string(REGEX MATCH "([0-9]+)" MAJOR_VERSION ${CURRENT_VERSION})
message(STATUS "Version: ${CURRENT_VERSION}")
