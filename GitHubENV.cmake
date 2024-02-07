include_guard()

# Write .env file is written to the root of the project inside CI for easier packaging
# It uses the PROJECT_NAME, PRODUCT_NAME, VERSION, BUNDLE_ID, and COMPANY_NAME.
#
# pjuce_ci_write_env_file(
#   PRODUCT_NAME "Your Product Name"
#   BUNDLE_ID "com.yourcompany.${PROJECT_NAME}"
#   COMPANY_NAME "Your Company Name"
# )
#
function(pjuce_ci_write_env_file)
    set(_oneValueArgs PRODUCT_NAME BUNDLE_ID COMPANY_NAME)
    cmake_parse_arguments(_PJ "" "${_oneValueArgs}" "" ${ARGN})

    if ((DEFINED ENV{CI}))
        set (env_file "${PROJECT_SOURCE_DIR}/.env")
        message ("Writing ENV file for CI: ${env_file}")

        # the first call truncates, the rest append
        file(WRITE  "${env_file}" "PROJECT_NAME=${PROJECT_NAME}\n")
        file(APPEND "${env_file}" "PRODUCT_NAME=${_PJ_PRODUCT_NAME}\n")
        file(APPEND "${env_file}" "VERSION=${PROJECT_VERSION}\n")
        file(APPEND "${env_file}" "BUNDLE_ID=${_PJ_BUNDLE_ID}\n")
        file(APPEND "${env_file}" "COMPANY_NAME=${_PJ_COMPANY_NAME}\n")
    endif ()
endfunction()
