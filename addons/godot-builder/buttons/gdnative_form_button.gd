tool
extends Button

signal request_refresh_plugins()

enum FormButtonMode {
	FORM_MODE_ADD,
	FORM_MODE_EDIT,
	FORM_MODE_CREATE
}

const Data = preload("res://addons/godot-builder/data.gd")

export(int, "Add", "Edit", "Create") var mode = FormButtonMode.FORM_MODE_ADD setget set_mode, get_mode

onready var path_file_dialog = $PathFileDialog
onready var gdnlib_file_dialog = $GDNLibFileDialog
onready var confirm_dialog = $GDNativePluginDialog

var selected_plugin = null setget set_selected_plugin

func _on_GDNativeFormButton_pressed(p_name = "", p_path = "", p_output = ""):
	match mode:
		FormButtonMode.FORM_MODE_ADD:
			if p_name:
				confirm_dialog.name_edit.text = p_name
			if p_path:
				confirm_dialog.path_edit.text = p_path
			if p_output:
				confirm_dialog.output_edit.text = p_output
			confirm_dialog.popup_centered()
		FormButtonMode.FORM_MODE_EDIT:
			if not selected_plugin:
				print("No plugin has been selected! Cannot edit!")
				return
			var data = selected_plugin.get_metadata(0)
			confirm_dialog.name_edit.text = data.name
			confirm_dialog.path_edit.text = data.path
			confirm_dialog.gdnlib_edit.text = data.gdnlib
			confirm_dialog.popup_centered()
		FormButtonMode.FORM_MODE_CREATE:
			confirm_dialog.name_edit.text = ""
			confirm_dialog.path_edit.text = ""
			confirm_dialog.gdnlib_edit.text = ""
			confirm_dialog.popup_centered()
	confirm_dialog.window_title = text + " a GDNative Plugin"

func _on_PathFileDialog_dir_selected(p_dir):
	confirm_dialog.path_edit.text = p_dir

func _on_GDNLibFileDialog_file_selected(p_path):
	confirm_dialog.gdnlib_edit.text = p_path

func _on_GDNativePluginDialog_request_browse_directory():
	path_file_dialog.popup_centered_ratio(.75)

func _on_GDNativePluginDialog_request_browse_file():
	gdnlib_file_dialog.popup_centered_ratio(.75)

func _on_GDNativePluginDialog_confirmed():
	match mode:
		FormButtonMode.FORM_MODE_ADD, FormButtonMode.FORM_MODE_EDIT:
			var sel = Data.get_config("selections")
			if not sel:
				return
			var dir = Directory.new()
			if not dir.dir_exists(confirm_dialog.path_edit.text):
				print("The given plugin directory path doesn't exist! Failed to add plugin to Godot Builder.")
				return
			var dict = sel.get_value("editor", "plugins", {})
			dict[confirm_dialog.name_edit.text] = {
				"path": confirm_dialog.path_edit.text,
				"output": confirm_dialog.gdnlib_edit.text
			}
			sel.set_value("editor", "plugins", dict)
			Data.save_config(sel, "selections")
			emit_signal("request_refresh_plugins")
		FormButtonMode.FORM_MODE_CREATE:
			var sel = Data.get_config("selections")
			if not sel:
				return
			
			var option = get_tree().get_nodes_in_group("godot_builder_language_option")[0]
			var lang = option.get_item_text(option.selected)
			var source_dir = "res://addons/godot-builder/templates/" + lang + "/plugin"
			var destination_dir = confirm_dialog.path_edit.text
			
			var dir = Directory.new()
			if not dir.dir_exists(source_dir):
				print("The stored plugin template doesn't exist! Failed to create plugin for Godot Builder.")
				return
			if not dir.dir_exists(destination_dir):
				print("The given plugin directory path doesn't exist! Failed to create plugin for Godot Builder.")
				return
			
			var fi = File.new()
			var fo = File.new()
			
			dir.change_dir(source_dir)
			dir.list_dir_begin(true, true)
			var file = dir.get_next()
			
			while file:
				print("looking at: ", file)
				if not fi.open(source_dir.plus_file(file), File.READ) == OK:
					print("Could not open file to read")
					print(source_dir.plus_file(file))
					file = dir.get_next()
					continue
				if not fo.open(destination_dir.plus_file(file), File.WRITE) == OK:
					print("Could not open file to write")
					print(destination_dir.plus_file(file))
					file = dir.get_next()
					continue
				print("transferring")
				fo.store_string(fi.get_as_text())
				fi.close()
				fo.close()
				print("closing")
				file = dir.get_next()
			
			var dict = sel.get_value("editor", "plugins", {})
			dict[confirm_dialog.name_edit.text] = {
				"path": confirm_dialog.path_edit.text,
				"gdnlib": confirm_dialog.gdnlib_edit.text
			}
			sel.set_value("editor", "plugins", dict)
			Data.save_config(sel, "selections")
			emit_signal("request_refresh_plugins")

func set_mode(p_value):
	mode = p_value
	match mode:
		FormButtonMode.FORM_MODE_ADD:
			#flat = false
			#icon = null
			text = "Add"
			
		FormButtonMode.FORM_MODE_EDIT:
			#flat = true
			#icon = load("res://addons/godot-builder/icons/icon_edit.svg")
			text = "Edit"
		FormButtonMode.FORM_MODE_CREATE:
			#flat = false
			#icon = null
			text = "Create"

func get_mode():
	return mode

func set_selected_plugin(p_value):
	selected_plugin = p_value