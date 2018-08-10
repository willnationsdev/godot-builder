tool
extends EditorPlugin

const BuildToolbar = preload("res://addons/godot-builder/build_toolbar.gd")

class GDNativeBuildSettingsPlugin:
	extends EditorInspectorPlugin
	var execute
	
	func can_handle(object):
		if object is GDNativeBuildSettings:
			return true
	func parse_begin(object):
		object.execute = execute
		var node = BuildToolbar.new()
		node.connect_buttons(object)
		add_custom_control(node)
	func parse_property(object, type, path, hint, hint_text, usage):
		var paramN = object.template_parameters[object.template_parameter_names[len(object.template_parameter_names)-1]]
		if path.begins_with("template/"+paramN):
			var button = Button.new()
			button.text = "Generate"
			add_custom_control(button)

const Execute = preload("res://addons/godot-builder/execute_utility.gd")

var build_settings_plugin
var execute

func _enter_tree():
	execute = Execute.new()
	add_child(execute)

	build_settings_plugin = GDNativeBuildSettingsPlugin.new()
	build_settings_plugin.execute = execute
	add_inspector_plugin(build_settings_plugin)

func _exit_tree():
	remove_child(execute)