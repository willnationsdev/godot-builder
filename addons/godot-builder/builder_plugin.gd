tool
extends EditorPlugin

const BuildToolbar = preload("build_toolbar.gd")
const GDNativeBuildSettingsInspectorPlugin = preload("gdnative_build_settings_inspector_plugin.gd")
const Execute = preload("execute_utility.gd")

var build_settings_plugin
var execute

func _enter_tree():
	execute = Execute.new()
	add_child(execute)

	build_settings_plugin = GDNativeBuildSettingsInspectorPlugin.new()
	build_settings_plugin.execute = execute
	add_inspector_plugin(build_settings_plugin)

func _exit_tree():
	remove_child(execute)