tool
extends Resource
class_name GDNativeBuildSettings

##### SIGNALS #####

##### CONSTANTS #####

enum Language {
	CPP
}
const LanguageText = {
	CPP: "C++"
}
enum Version {
	ONE,
	ONE_ONE,
	CUSTOM
}
const VersionText = {
	ONE: "1.0",
	ONE_ONE: "1.1",
	CUSTOM: "Custom"
}
enum Platform {
	WINDOWS,
	OSX,
	X11,
	ANDROID,
	IOS,
	HTML5,
	HAIKU,
	SERVER,
	UWP
}
const PlatformText = {
	WINDOWS: "Windows",
	OSX: "OSX",
	X11: "Linux",
	ANDROID: "Android",
	IOS: "iOS",
	HTML5: "HTML5",
	HAIKU: "Haiku",
	SERVER: "Server",
	UWP: "UWP"
}
enum Bits {
	SIXTY_FOUR,
	THIRTY_TWO
}
const BitsText = {
	SIXTY_FOUR: "64",
	THIRTY_TWO: "32"
}
enum Target {
	DEBUG,
	RELEASE
}
const TargetText = {
	DEBUG: "Debug",
	RELEASE: "Release"
}

##### EXPORTS #####

# project_settings_
var project_name = "lib"+ProjectSettings.get_setting("application/config/name") setget set_project_name
var output_dir = ""
var source_dirs = []
var include_dirs = []
var libs = []
var bindings_directory = ""
var bindings_lib_name = "" setget set_bindings_lib_name

# build_options_
var language = Language.CPP setget set_language
var version = Version.ONE_ONE
var platform = Platform.WINDOWS
var bits = Bits.SIXTY_FOUR
var target = Target.DEBUG

##### PROPERTIES #####
var execute
var templates = {
	"classes": {},
	"projects": {},
}
var template_parameters = {}
var template_parameter_names = []

##### NOTIFICATIONS #####

func _get(p_property):
	match p_property:
		"project_settings/name": return project_name
		"project_settings/output_dir": return output_dir
		"project_settings/source_dirs": return source_dirs
		"project_settings/include_dirs": return include_dirs
		"project_settings/libs": return libs
		"project_settings/bindings_dir": return bindings_directory
		"project_settings/bindings_lib_name": return bindings_lib_name
		
		"build_options/language": return language
		"build_options/version": return version
		"build_options/platform": return platform
		"build_options/bits": return bits
		"build_options/target": return target
	var pretemplate_name = p_property.replace("template/", "")
	if template_parameters.has(pretemplate_name):
		return template_parameters[pretemplate_name]

func _set(p_property, p_value):
	match p_property:
		"project_settings/name": project_name = p_value
		"project_settings/output_dir": output_dir = p_value
		"project_settings/source_dirs": source_dirs = p_value
		"project_settings/include_dirs": include_dirs = p_value
		"project_settings/libs": libs = p_value
		"project_settings/bindings_dir": bindings_directory = p_value
		"project_settings/bindings_lib_name": bindings_lib_name = p_value
		
		"build_options/language": language = p_value
		"build_options/version": version = p_value
		"build_options/platform": platform = p_value
		"build_options/bits": bits = p_value
		"build_options/target": target = p_value
	var pretemplate_name = p_property.replace("template/", "")
	if template_parameters.has(pretemplate_name):
		template_parameters[pretemplate_name] = p_value

func _get_property_list():
	var list = [
		{
			"name": "project_settings/project_name",
			"type": TYPE_STRING,
		},
		{
			"name": "project_settings/output_dir",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_GLOBAL_DIR,
		},
		{
			"name": "project_settings/source_dirs",
			"type": TYPE_ARRAY,
			"hint": TYPE_STRING_ARRAY,
			"hint_string": str(TYPE_STRING)+"/"+str(PROPERTY_HINT_GLOBAL_DIR)+":"
		},
		{
			"name": "project_settings/include_dirs",
			"type": TYPE_ARRAY,
			"hint": TYPE_STRING_ARRAY,
			"hint_string": str(TYPE_STRING)+"/"+str(PROPERTY_HINT_GLOBAL_DIR)+":"
		},
		{
			"name": "project_settings/libs",
			"type": TYPE_ARRAY,
			"hint": TYPE_STRING_ARRAY,
			"hint_string": str(TYPE_STRING)+"/"+str(PROPERTY_HINT_GLOBAL_FILE)+":*.lib,*.a,*.dll,*.dylib,*.so"
		},
		{
			"name": "project_settings/bindings_dir",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_GLOBAL_DIR,
		},
		{
			"name": "project_settings/bindings_lib_name",
			"type": TYPE_STRING,
		},
		{
			"name": "build_options/language",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "C++"
		},
		{
			"name": "build_options/version",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "1.0,1.1,Custom"
		},
		{
			"name": "build_options/platform",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Windows, OSX, Linux, Android, iOS, HTML5, Haiku, Server, UWP"
		},
		{
			"name": "build_options/bits",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "64,32"
		},
		{
			"name": "build_options/target",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Debug,Release"
		},
		{
			"name": "template/name"
		}
	]
	for a_template in template_parameter_names:
		list.append({
			"name": "template/" + a_template,
			"type": TYPE_STRING
		})
	return list

##### CONNECTIONS #####

func _on_execute(p_settings, p_op):
	if not execute:
		print("There's no execute node!")
		return
	execute.run(p_settings, p_op)

##### PRIVATE METHODS #####

func _reload_language_templates():
	var dir = Directory.new()
	if not dir.change_dir("res://addons/godot-builder/templates/" + LanguageText[language]) == OK:
		return
	dir.list_dir_begin(true, true)
	templates.classes.clear()
	templates.projects.clear()
	var file_name = dir.get_next()
	while file_name:
		if dir.file_exists(file_name):
			var basename = file_name.get_file().get_basename()
			var filepath = "res://addons/godot-builder/templates/" + LanguageText[language].plus_file(file_name)
			if templates.has(basename):
				templates[basename].append(filepath)
			else:
				templates[basename] = [filepath]
#				template_option.add_item(basename)
#		file_name = dir.get_next()
#	var template_name = template_option.get_item_text(template_option.selected)
#	
#	current_template_files.clear()
#	current_template_files = templates[template_name]
#	
#	var template_parameters = {}
#	var regex = RegEx.new()
#	regex.compile("@@([A-Z_]+)")
#	for a_filepath in templates[template_name]:
#		var f = File.new()
#		if f.open(a_filepath, File.READ) != OK:
#			continue
#		var text = f.get_as_text()
#		var result_list = regex.search_all(text)
#		for a_result in result_list:
#			for i in a_result.get_group_count():
#				template_parameters[a_result.get_string(i + 1)] = null
#		f.close()
#	
#	if config_edits.has_node("Grid"):
#		config_edits.get_node("Grid").free()
#	
#	var grid = GridContainer.new()
#	grid.columns = 2
#	grid.name = "Grid"
#	config_edits.add_child(grid)
#	if not template_parameters.has("FILENAME"):
#		template_parameters.FILENAME = ""
#	if not template_parameters.has("AUTHOR"):
#		template_parameters.AUTHOR = ""
#
#	for a_property in template_parameters.keys():
#		var label = Label.new()
#		label.text = a_property.capitalize()
#		grid.add_child(label)
#		var line_edit = LineEdit.new()
#		line_edit.rect_min_size.x = 280
#		grid.add_child(line_edit)
#
#	var last_child = grid.get_child(grid.get_child_count() - 1)
#	last_child.focus_next = last_child.get_path_to(template_create_button)
#	template_create_button.focus_previous = template_create_button.get_path_to(last_child)
#	template_create_button.focus_next = template_create_button.get_path_to(grid.get_child(1))
#	grid.get_child(1).focus_previous = grid.get_child(1).get_path_to(template_create_button)
#
#func _on_CreateTemplateClassButton_pressed():
#	# acquire the path of the new file to copy to
#	var grid = config_edits.get_node("Grid")
#	if not grid:
#		return
#	
#	var params = {}
#	var param_name = ""
#	for a_child in grid.get_children():
#		if a_child is Label:
#			param_name = a_child.text.to_upper().replace(" ", "_")
#		if a_child is LineEdit:
#			params[param_name] = a_child.text
#	
#	var sel = Data.get_config("selections")
#	var current_plugin = sel.get_value("editor", "selected_plugin", null)
#	if not current_plugin:
#		return
#	var plugins = sel.get_value("editor", "plugins", null)
#	if not plugins or not plugins.has(current_plugin) or not plugins[current_plugin].has("path"):
#		return
#	var plugin_path = plugins[current_plugin].path
#	var path = plugin_path.plus_file(params.FILENAME)
#	
#	# sift through its regex matches and inject template parameters
#	# before creating the new file(s)
#	var regex = RegEx.new()
#	for a_file in current_template_files:
#		var fo = File.new()
#		var fi = File.new()
#		var fo_path = path + "." + a_file.get_extension()
#		if not fo.open(fo_path, File.WRITE) == OK:
#			print("Failed to open output file for template: ", fo_path)
#			return
#		if not fi.open(a_file, File.READ) == OK:
#			print("Failed to open output file for template: ", a_file)
#			return
#		
#		var text = fi.get_as_text()
#		for a_param in params:
#			regex.compile("@@" + a_param)
#			text = regex.sub(text, params[a_param], true)
#		
#		fo.store_string(text)
#		
#		fi.close()
#		fo.close()
#	
#	for a_child in grid.get_children():
#		if a_child is LineEdit:
#			a_child.text = ""

##### PUBLIC METHODS #####

func get_language_text():
	return LanguageText[language]

func get_version_text():
	return VersionText[version]

func get_platform_text():
	return PlatformText[platform]

func get_bits_text():
	return BitsText[bits]

func get_target_text():
	return TargetText[target]

##### SETTERS AND GETTERS #####

func set_language(p_value):
	_reload_language_templates()

func set_project_name(p_value):
	project_name = p_value
	self.bindings_lib_name = "" # hack to trigger reset based on project_name

func set_bindings_lib_name(p_value):
	var default_dir = OS.get_user_data_dir().plus_file("bindings").plus_file(get_language_text()).plus_file(get_version_text())
	if not p_value:
		bindings_lib_name = default_dir.plus_file("lib"+project_name)