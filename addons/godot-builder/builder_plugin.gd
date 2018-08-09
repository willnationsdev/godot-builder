tool
extends EditorPlugin

const BuildToolbar = preload("res://addons/godot-builder/build_toolbar.tscn")

class EditButton:
	extends Button
	func _init():
		text = "Test"
	func _pressed():
		print("test edit button")

class GDNativeBuildSettingsPlugin:
	extends EditorInspectorPlugin
	var execute
	
	func can_handle(object):
		if object is GDNativeBuildSettings:
			return true
	func parse_begin(object):
		object.execute = execute
		var node = BuildToolbar.instance()
		node.connect_buttons(object)
		add_custom_control(node)
	func parse_property(object, type, path, hint, hint_text, usage):
		if path == "project_settings/bindings_lib_name":
			add_custom_control(EditButton.new())

const BuilderScn = preload("builder.tscn")
const Execute = preload("res://addons/godot-builder/execute_utility.gd")

var builder
var builder_button
var build_settings_plugin
var execute

func _enter_tree():
	execute = Execute.new()
	add_child(execute)
	#builder = BuilderScn.instance()
	#builder.undoredo = get_undo_redo()
	#builder_button = add_control_to_bottom_panel(builder, "Builder")
	
	build_settings_plugin = GDNativeBuildSettingsPlugin.new()
	build_settings_plugin.execute = execute
	add_inspector_plugin(build_settings_plugin)

func _exit_tree():
	build_settings_plugin.execute = null
	remove_inspector_plugin(build_settings_plugin)
	remove_child(execute)
	#remove_control_from_bottom_panel(builder)
	#builder.free()