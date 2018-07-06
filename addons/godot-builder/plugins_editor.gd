tool
extends HBoxContainer

signal plugins_tree_reloaded(tree)
signal plugin_selected(plugin_item)

const PLUGINS_PATH = "res://addons/godot-builder/builder.cfg"
const PLUGINS_LOAD_ERR_MSG = "Failed to load Godot Builder plugins file at \"" + PLUGINS_PATH + "\"."

onready var plugin_dialog = $AddGDNativePluginDialog
onready var file_dialog = $FileDialog

onready var plugins_tree = $VBoxContainer/HBoxContainer/VBoxContainer/PluginsTree

var plugins = ConfigFile.new() setget set_plugins_config, get_plugins_config
var display_paths = true

var undoredo = null

func _ready():
	var p = self.plugins
	if not p:
		return
	_reload_plugins_tree()
	visible = plugins.get_value("editor", "expanded", false)
	$VBoxContainer/HBoxContainer/VBoxContainer/PluginToolbar/DisplayPathsButton.pressed = plugins.get_value("editor", "display_paths", false)

func _on_AddPluginButton_pressed(p_name = "", p_path = ""):
	if p_name:
		plugin_dialog.name_edit.text = p_name
	if p_path:
		plugin_dialog.path_edit.text = p_path
	plugin_dialog.popup_centered()

func _on_FileDialog_dir_selected(p_dir):
	plugin_dialog.path_edit.text = p_dir

func _on_AddGDNativePluginDialog_confirmed():
	var p = self.plugins
	if not p:
		return
	var dir = Directory.new()
	if not dir.dir_exists(plugin_dialog.path_edit.text):
		print("The given plugin directory path doesn't exist! Failed to add plugin to Godot Builder.")
		return
	var dict = p.get_value("editor", "plugins", {})
	dict[plugin_dialog.name_edit.text] = {
		"path": plugin_dialog.path_edit.text
	}
	p.set_value("editor", "plugins", dict)
	p.save(PLUGINS_PATH)
	_reload_plugins_tree()

func _reload_plugins_tree():
	var p = self.plugins
	if not p:
		return
	var dict = p.get_value("editor", "plugins", {})
	
	plugins_tree.clear()
	var root = plugins_tree.create_item(null)
	
	for a_name in dict:
		var plugin = plugins_tree.create_item(root)
		var text = a_name + (": " + dict[a_name].path if display_paths else "")
		plugin.set_text(0, text)
		plugin.set_metadata(0, {"name": a_name, "path": dict[a_name].path})
	
	emit_signal("plugins_tree_reloaded", plugins_tree)

func _on_CreatePluginButton_pressed():
	pass # Replace with function body.

func _on_AddGDNativePluginDialog_request_browse():
	file_dialog.popup_centered_ratio(.75)

func _on_HidePluginButton_pressed():
	var p = self.plugins
	if not p:
		return
	var dict = p.get_value("editor", "plugins", {})
	var plugin_name = plugins_tree.get_selected().get_metadata(0).name
	if not dict.has(plugin_name):
		return
	dict.erase(plugin_name)
	p.set_value("editor", "plugins", dict)
	p.save(PLUGINS_PATH)
	_reload_plugins_tree()

func _on_DeletePluginButton_pressed():
	$DeletePluginConfirmationDialog.popup_centered()
	
func get_plugins_config():
	if not plugins:
		print("'plugins' is empty!")
		return null
	if plugins.load(PLUGINS_PATH) != OK:
		print(PLUGINS_LOAD_ERR_MSG)
		return null
	return plugins

func set_plugins_config(p_value):
	return null

func _on_DisplayPathsButton_toggled(p_pressed):
	var p = self.plugins
	if p:
		p.set_value("editor", "display_paths", p_pressed)
		p.save(PLUGINS_PATH)
	display_paths = p_pressed
	_reload_plugins_tree()

func _on_PluginsTree_item_activated():
	emit_signal("plugin_selected", plugins_tree.get_selected())

func _on_DeletePluginConfirmationDialog_confirmed():
	var plugin_data = plugins_tree.get_selected().get_metadata(0)
	_on_HidePluginButton_pressed()
	var dir = Directory.new()
	if not dir.dir_exists(plugin_data.path):
		print("Failed to find the plugin directory at: ", plugin_data.path)
		return
	if dir.remove(plugin_data.path) != OK:
		print("Failed to remove the plugin directory at: ", plugin_data.path)
		return
