tool
extends HBoxContainer

signal plugins_tree_reloaded(tree)
signal plugin_selected(plugin_item)
signal plugin_activated(plugin_item)

const Data = preload("res://addons/godot-builder/data.gd")

const GOOD_ICON = preload("res://addons/godot-builder/icons/icon_import_check.svg")
const BAD_ICON = preload("res://addons/godot-builder/icons/icon_import_fail.svg")
const PATH_ICON = preload("res://addons/godot-builder/icons/icon_path.svg")

onready var plugins_tree = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/ScrollContainer/PluginsTree
onready var config_edits = $VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/ScrollContainer2/PanelContainer/ConfigEdits

onready var template_option = $VBoxContainer/HBoxContainer/VBoxContainer/PluginToolbar/TemplateActions/TemplateOption
onready var template_create_button = $VBoxContainer/HBoxContainer/VBoxContainer/PluginToolbar/TemplateActions/CreateTemplateClassButton

var display_paths = true
var current_template_files = []

var file_mode = ""
var file_edit_property = ""

var undoredo = null setget set_undoredo, get_undoredo
var language = ""

func _ready():
	var cf = Data.get_config()
	if not cf:
		return
	_reload_plugins_tree()
	visible = cf.get_value("editor", "expanded", false)
	var option = get_tree().get_nodes_in_group("godot_builder_language_option")[0]
	var lang = option.get_item_text(option.selected)
	reload_language_templates(lang)

func _reload_plugins_tree():
	var sel = Data.get_config("selections")
	if not sel:
		return
	var dict = sel.get_value("editor", "plugins", {})
	
	plugins_tree.clear()
	var root = plugins_tree.create_item(null)
	
	var f = File.new()
	
	for a_name in dict:
		var plugin = plugins_tree.create_item(root)
		var text = a_name + (": " + dict[a_name].path if display_paths else "")
		var data = dict[a_name]
		data.name = a_name
		data.valid_gdnlib = f.file_exists(data.gdnlib)
		plugin.set_text(0, a_name + " : " + data.gdnlib)
		plugin.set_icon(0, GOOD_ICON if data.valid_gdnlib else BAD_ICON)
		plugin.set_metadata(0, data)
		plugin.set_tooltip(0, data.path)
	
	emit_signal("plugins_tree_reloaded", plugins_tree)

func _on_HidePluginButton_pressed():
	var sel = Data.get_config("selections")
	if not sel:
		return
	var dict = sel.get_value("editor", "plugins", {})
	var plugin_name = plugins_tree.get_selected().get_metadata(0).name
	if not dict.has(plugin_name):
		return
	dict.erase(plugin_name)
	sel.set_value("editor", "plugins", dict)
	Data.save_config(sel, "selections")
	_reload_plugins_tree()

func _on_DeletePluginButton_pressed():
	$DeletePluginConfirmationDialog.popup_centered()

func _on_PluginsTree_item_activated():
	emit_signal("plugin_activated", plugins_tree.get_selected())

func _on_PluginsTree_cell_selected():
	emit_signal("plugin_selected", plugins_tree.get_selected())

func _on_PluginsEditor_plugin_selected(p_plugin_item):
	for a_child in $VBoxContainer/HBoxContainer/VBoxContainer/PluginToolbar/PluginActions.get_children():
		if a_child.has_method("set_selected_plugin"):
			a_child.set_selected_plugin(p_plugin_item)

func _on_DeletePluginConfirmationDialog_confirmed():
	var plugin_data = plugins_tree.get_selected().get_metadata(0)
	_on_HidePluginButton_pressed()
	var dir = Directory.new()
	if not dir.dir_exists(plugin_data.path):
		print("Failed to find the plugin directory at: ", plugin_data.path)
		return
	
	var command = ""
	var args = PoolStringArray()
	match OS.get_name():
		"Windows":
			command = "rd"
			args.append("/s")
			args.append("/q")
			args.append(plugin_data.path)
		"OSX", "X11":
			command = "rm"
			args.append("-rf")
			args.append(plugin_data.path)
	OS.execute(command, args, true)

func _on_language_selected(p_language):
	reload_language_templates(p_language)

func reload_language_templates(p_language):
	var dir = Directory.new()
	if not dir.change_dir("res://addons/godot-builder/templates/" + p_language) == OK:
		return
	dir.list_dir_begin(true, true)
	var templates = {}
	var file_name = dir.get_next()
	template_option.clear()
	while file_name:
		if dir.file_exists(file_name):
			var basename = file_name.get_file().get_basename()
			var filepath = "res://addons/godot-builder/templates/" + p_language.plus_file(file_name)
			if templates.has(basename):
				templates[basename].append(filepath)
			else:
				templates[basename] = [filepath]
				template_option.add_item(basename)
		file_name = dir.get_next()
	var template_name = template_option.get_item_text(template_option.selected)
	
	current_template_files.clear()
	current_template_files = templates[template_name]
	
	var template_parameters = {}
	var regex = RegEx.new()
	regex.compile("@@([A-Z_]+)")
	for a_filepath in templates[template_name]:
		var f = File.new()
		if f.open(a_filepath, File.READ) != OK:
			continue
		var text = f.get_as_text()
		var result_list = regex.search_all(text)
		for a_result in result_list:
			for i in a_result.get_group_count():
				template_parameters[a_result.get_string(i + 1)] = null
		f.close()
	
	if config_edits.has_node("Grid"):
		config_edits.get_node("Grid").free()
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.name = "Grid"
	config_edits.add_child(grid)
	if not template_parameters.has("FILENAME"):
		template_parameters.FILENAME = ""
	if not template_parameters.has("AUTHOR"):
		template_parameters.AUTHOR = ""
	
	for a_property in template_parameters.keys():
		var label = Label.new()
		label.text = a_property.capitalize()
		grid.add_child(label)
		var line_edit = LineEdit.new()
		line_edit.rect_min_size.x = 280
		grid.add_child(line_edit)
	
	var last_child = grid.get_child(grid.get_child_count() - 1)
	last_child.focus_next = last_child.get_path_to(template_create_button)
	template_create_button.focus_previous = template_create_button.get_path_to(last_child)
	template_create_button.focus_next = template_create_button.get_path_to(grid.get_child(1))
	grid.get_child(1).focus_previous = grid.get_child(1).get_path_to(template_create_button)

func _on_CreateTemplateClassButton_pressed():
	# acquire the path of the new file to copy to
	var grid = config_edits.get_node("Grid")
	if not grid:
		return
	
	var params = {}
	var param_name = ""
	for a_child in grid.get_children():
		if a_child is Label:
			param_name = a_child.text.to_upper().replace(" ", "_")
		if a_child is LineEdit:
			params[param_name] = a_child.text
	
	var sel = Data.get_config("selections")
	var current_plugin = sel.get_value("editor", "selected_plugin", null)
	if not current_plugin:
		return
	var plugins = sel.get_value("editor", "plugins", null)
	if not plugins or not plugins.has(current_plugin) or not plugins[current_plugin].has("path"):
		return
	var plugin_path = plugins[current_plugin].path
	var path = plugin_path.plus_file(params.FILENAME)
	
	# sift through its regex matches and inject template parameters
	# before creating the new file(s)
	var regex = RegEx.new()
	for a_file in current_template_files:
		var fo = File.new()
		var fi = File.new()
		var fo_path = path + "." + a_file.get_extension()
		if not fo.open(fo_path, File.WRITE) == OK:
			print("Failed to open output file for template: ", fo_path)
			return
		if not fi.open(a_file, File.READ) == OK:
			print("Failed to open output file for template: ", a_file)
			return
		
		var text = fi.get_as_text()
		for a_param in params:
			regex.compile("@@" + a_param)
			text = regex.sub(text, params[a_param], true)
		
		fo.store_string(text)
		
		fi.close()
		fo.close()
	
	for a_child in grid.get_children():
		if a_child is LineEdit:
			a_child.text = ""

func set_undoredo(p_value):
	undoredo = p_value

func get_undoredo():
	return undoredo
