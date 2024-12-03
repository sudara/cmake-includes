add_subdirectory("modules/pluginval")

# Use our version of JUCE, not pluginval's
# This is brittle, the string has to match perfectly
set(PLUGINVAL_FETCH_JUCE OFF CACHE BOOL "Fetch JUCE along with PluginVal" FORCE)

get_target_property(artefact ${PROJECT_NAME}_VST3 JUCE_PLUGIN_ARTEFACT_FILE)

add_custom_target(${PROJECT_NAME}_Pluginval
#        COMMAND
#        pluginval
#        --strictness-level 10
#        --validate
#        ${artefact}
        DEPENDS ${PROJECT_NAME}_VST3 pluginval
        VERBATIM)
