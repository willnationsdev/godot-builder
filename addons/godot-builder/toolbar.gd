tool
extends HBoxContainer

signal request_toggle_gdnative_plugins(p_pressed)
signal language_selected(p_language)

const ADD_NEW_PLUGIN = 9827315

const Data = preload("res://addons/godot-builder/data.gd")

onready var language_option = $Options/LanguageOption

onready var version_option = $Options/DynamicOptions/VersionOption
onready var platform_option = $Options/DynamicOptions/PlatformOption
onready var bits_option = $Options/DynamicOptions/BitsOption
onready var target_option = $Options/DynamicOptions/TargetOption

onready var toggle_editor_button = $PluginSettings/GDNativePluginsToggleButton

var undoredo = null setget set_undoredo, get_undoredo

func _ready():
	var config = Data.get_config()
	var selections = Data.get_config("selections")
	toggle_editor_button.pressed = config.get_value("editor", "expanded", false)
	$PluginSettings/Label.text = config.get_value("editor", "selected_plugin", "None")
	
	var languages = config.get_value("builder", "languages", [])
	if not len(languages):
		return
	
	language_option.clear()
	for a_lang in languages:
		language_option.add_item(a_lang)
	language_option.selected = selections.get_value("builder", "language", 0)
	
	for an_option in $Options/DynamicOptions.get_children():
		an_option.connect("item_selected", self, "_on_dynamic_option_item_selected")
	language_option.connect("item_selected", self, "_on_language_option_item_selected")
	
	_update_items()
	_update_selections()
	
	emit_signal("language_selected", _get_option("language"))
	
#	var dir = Directory.new()
#	var version = version_option.get_item_text(version_option.selected)
#	var lang = lang_dir_map[language_option.get_item_text(language_option.selected)]
#	var platform = platform_option.get_item_text(platform_option.selected)
#	var file = "godot-cpp"
#	var path = "user://bindings".plus_file(version).plus_file(lang).plus_file("bin/godot-cpp.bindings." + _get_library_ext(false))
#	print("path: ", path)
#	if dir.file_exists(path):
#		found_check.pressed = true
#		found_button.text = "Found"
#		if found_button.is_connected("pressed", self, "_find_clicked"):
#			found_button.disconnect("pressed", self, "_find_clicked")
#	else:
#		found_check.pressed = false
#		found_button.text = "Find"
#		found_button.connect("pressed", self, "_find_clicked")

func _language_selected(p_id):
	var selections = Data.get_config("selections")
	var lang = language_option.get_item_text(p_id)
	selections.set_value("builder", "language", lang)
	Data.save_config("selections")
	emit_signal("language_selected", lang)

func _on_confirmed():
	print("test")
	var a = PoolStringArray()
	#a.append("$PWD")
	OS.execute("cd", a, true)
#	var dir = Directory.new()
#	var dest = "user://bindings/" + _version
#	if dir.make_dir_recursive(dest) != OK:
#		print("Failed to create \"", dest, "\" directory. Stopping early.")
#		return
#
#	var args = PoolStringArrray()
#
#	args.append("clone")
#	args.append("https://github.com/GodotNativeTools/godot-cpp")
#	args.append(dest)
#	if OS.execute("git", args, true) == -1:
#		print("Failed to execute [git clone https://GodotNativeTools/godot-cpp\" \"", dest, "\"]. Stopping early.")
#		return
#
#	args.resize(1)
#	args.append("https://github.com/GodotNativeTools/godot_headers")
#	if OS.execute("git", args, true) == -1:
#		print("Failed to execute \"git clone https://GodotNativeTools/godot_headers\". Stopping early.")
#		return
#
#	args.resize(0)
#	if dir.change_dir("user://bindings/cpp-bindings") != OK:
#		print("Failed to open cpp-bindings! Stopping early.")
#		return

func _on_language_option_item_selected(p_id):
	_update_items()
	_update_selections()

func _on_dynamic_option_item_selected(p_id):
	_serialize_selections()
	_update_selections()

func _update_items():
	var lang = _get_option("language")
	var config = Data.get_config()
	_reload_option_subitems(config, lang, version_option, "versions")
	_reload_option_subitems(config, lang, platform_option, "platforms")
	_reload_option_subitems(config, lang, bits_option, "bits")
	_reload_option_subitems(config, lang, target_option, "targets")
	version_option.add_item("Custom")

func _reload_option_subitems(p_config, p_lang, p_option, p_config_key):
	p_option.clear()
	var data = p_config.get_value(p_lang, p_config_key, [])
	var list = []
	match typeof(data):
		TYPE_ARRAY:
			list = data
		TYPE_DICTIONARY:
			var keys = data.keys()
			for a_key in keys:
				if TYPE_DICTIONARY == typeof(data[a_key]):
					list.append(a_key)
		_: return
	for a_label in list:
		p_option.add_item(a_label)

func _serialize_selections(p_zero_fill = false):
	var selections = Data.get_config("selections")
	for an_opt in $Options/DynamicOptions.get_children():
		var opt_name = an_opt.get_name().replace("Option", "").to_lower()
		selections.set_value(_get_option("language"), opt_name, 0 if p_zero_fill else get(opt_name + "_option").selected)
	Data.save_config(selections, "selections")

func _update_selections():
	var lang = _get_option("language")
	var selections = Data.get_config("selections")
	_update_item_selection(selections, lang, version_option, "version")
	_update_item_selection(selections, lang, platform_option, "platform")
	_update_item_selection(selections, lang, bits_option, "bits")
	_update_item_selection(selections, lang, target_option, "target")

func _update_item_selection(p_config, p_lang, p_option, p_config_key):
	p_option.selected = p_config.get_value(p_lang, p_config_key, 0 if p_option.get_item_count() else -1)

func _get_option(p_prefix):
	var opt = get(p_prefix + "_option")
	return opt.get_item_text(opt.selected)

func _on_execute(p_command):
	match p_command:
		"generate_bindings": pass
		"clean": pass
		"build": pass
		_: pass

func _on_CleanButton_pressed():
	$CleanupConfirmationDialog.popup_centered()

func _on_GDNativePluginsToggleButton_toggled(p_pressed):
	var config = Data.get_config()
	config.set_value("editor", "expanded", p_pressed)
	Data.save_config(config)
	emit_signal("request_toggle_gdnative_plugins", p_pressed)

func _on_PluginsEditor_plugin_selected(p_item):
	var plugin_name = _get_item_plugin_label_text(p_item)
	var config = Data.get_config()
	config.set_value("editor", "selected_plugin", plugin_name)
	Data.save_config(config)
	$PluginSettings/Label.text = plugin_name

func _get_item_plugin_label_text(p_item):
	return "None" if not p_item or not p_item.get_metadata(0) or not p_item.get_metadata(0).has("name") else p_item.get_metadata(0).name

func _on_PluginsEditor_plugins_tree_reloaded(p_tree):
	var root = p_tree.get_root()
	var an_item = root.get_children()
	while an_item:
		var item_name = _get_item_plugin_label_text(an_item)
		if $PluginSettings/Label.text == item_name:
			_on_PluginsEditor_plugin_selected(an_item)
			break
		an_item = an_item.get_next()
	if not an_item:
		_on_PluginsEditor_plugin_selected(null)

func set_undoredo(p_value):
	undoredo = p_value

func get_undoredo():
	return undoredo