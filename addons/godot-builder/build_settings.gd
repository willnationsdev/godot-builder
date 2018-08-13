tool
extends Resource
class_name GDNativeBuildSettings

##### SIGNALS #####

##### CONSTANTS #####

# These would otherwise be enums, but strings aren't allowed, so...
var Language = {
	CPP: "C++"
}
var Version = {
	ONE: "1.0",
	ONE_ONE: "1.1",
	CUSTOM: "Custom"
}
var Platform = {
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
var Bits = {
	SIXTY_FOUR: "64",
	THIRTY_TWO: "32"
}
var Target = {
	DEBUG: "Debug",
	RELEASE: "Release"
}
var TemplateType = {
	TEMPLATE_TYPE_CLASS: "Class",
	TEMPLATE_TYPE_LIBRARY: "Library"
}

const MINIMAL_PARAMS = {
	"CLASSES": ["FILENAME", "AUTHOR"],
	"LIBRARIES": ["AUTHOR"],
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

# template_
var template_type = TemplateType.TEMPLATE_TYPE_LIBRARY
var templates = {
	"classes": {
		"names": [],
		"files": {},
		"parameter_names": [],
		"parameters": {},
	},
	"libraries": {
		"names": [],
		"files": {},
		"parameter_names": [],
		"parameters": {},
	},
}
var template_class setget set_template_class
var template_library setget set_template_library

##### PROPERTIES #####
var execute

##### NOTIFICATIONS #####

func _init():
	for a_param in MINIMAL_PARAMS.LIBRARIES:
		templates.libraries.parameter_names.append(a_param)
		templates.libraries.parameters[a_param] = null

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
	var param_name = p_property.replace("template/", "")
	if templates.classes.parameters.has(param_name):
		return templates.classes.parameters[param_name]
	if templates.libraries.parameters.has(param_name):
		return templates.libraries.parameters[param_name]

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
	var param_name = p_property.replace("template/", "")
	if templates.classes.parameters.has(param_name):
		templates.classes.parameters[param_name] = p_value
	if templates.libraries.parameters.has(param_name):
		templates.libraries.parameters[param_name] = p_value

func _get_property_list():
	var dir = Directory.new()
	var libs = []
	if dir.dir_exists("res://libs"):
		dir.change_dir("res://libs")
		dir.list_dir_begin(true, true)
		var filename = dir.get_next()
		while filename:
			if filename.get_extension() in ["dll", "dylib", "so"]:
				libs.append(filename)
			filename = dir.get_next()
		dir.list_dir_end()
	
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
			"hint_string": PoolStringArray(Language.values()).join(",")
		},
		{
			"name": "build_options/version",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(Version.values()).join(",")
		},
		{
			"name": "build_options/platform",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(Platform.values()).join(",")
		},
		{
			"name": "build_options/bits",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(Bits.values()).join(",")
		},
		{
			"name": "build_options/target",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(Target.values()).join(",")
		},
		{
			"name": "template/type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": PoolStringArray(TemplateType.values()).join(",")
		},
	]
	match template_type:
		TemplateType.TEMPLATE_TYPE_CLASS:
			list += [
				{
					"name": "template/template",
					"type": TYPE_INT,
					"hint": PROPERTY_HINT_ENUM,
					"hint_string": PoolStringArray(template_names.classes).join(",")
				},
				{
					"name": "template/for_library",
					"type": TYPE_INT,
					"hint": PROPERTY_HINT_ENUM,
					"hint_string": PoolStringArray(libs).join(",")
				},
			]
			for a_name in templates.classes.parameter_names:
				list.append({
					"name": "template/" + a_name,
					"type": TYPE_STRING
				})
		TemplateType.TEMPLATE_TYPE_LIBRARY:
			list += [
				{
					"name": "template/template",
					"type": TYPE_STRING,
					"hint": PROPERTY_HINT_ENUM,
					"hint_string": PoolStringArray(template_names.libraries).join(",")
				}
			]
		
	#for a_template in template_parameter_names:
	#	list.append({
	#		"name": "template/" + a_template,
	#		"type": TYPE_STRING
	#	})
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
	var templates_path = "res://addons/godot-builder/templates/" + language
	if not dir.change_dir(templates_path) == OK:
		return

	templates.classes.clear()
	templates.libraries.clear()

	dir.list_dir_begin(true, true)
	var file_name = dir.get_next()
	while file_name:
		if dir.file_exists(file_name):
			var basename = file_name.get_file().get_basename()
			while basename.get_basename() != basename:
				basename = basename.get_basename()
			var filepath = templates_path.plus_file(file_name)
			if templates.classes.has(basename):
				templates.classes[basename].append(filepath)
			else:
				templates.classes[basename] = [filepath]
		elif dir.dir_exists(file_name):
			var filepath = templates_path.plus_file(file_name)
			templates.libraries.files[filepath] = filepath
		file_name = dir.get_next()

#	var template_class_name = ""
#	if template_class_idx > 0 and template_class_idx < len(template_names.classes):
#		template_class_name = templates_names.classes[template_class_idx]
#	
#	current_template_files.clear()
#	current_template_files = templates.classes[template_name]
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

##### SETTERS AND GETTERS #####

func set_language(p_value):
	_reload_language_templates()

func set_project_name(p_value):
	project_name = p_value
	self.bindings_lib_name = "" # hack to trigger reset based on project_name

func set_bindings_lib_name(p_value):
	var default_dir = OS.get_user_data_dir().plus_file("bindings").plus_file(language).plus_file(version)
	if not p_value:
		bindings_lib_name = default_dir.plus_file("lib"+project_name)

func set_template_class(p_value):
	template_class = p_value

	var files = templates.classes.files[template_class]
	
	templates.classes.parameters.clear()
	templates.classes.parameter_names.clear()
	var regex = RegEx.new()
	regex.compile("@@([A-Z_]+)")
	for a_filepath in files:
		var f = File.new()
		if f.open(a_filepath, File.READ) != OK:
			continue
		var text = f.get_as_text()
		var result_list = regex.search_all(text)
		for a_result in result_list:
			for i in a_result.get_group_count():
				var name = a_result.get_string(i + 1)
				if not templates.classes.parameters.has(name):
					templates.classes.parameter_names.append(name)
				templates.classes.parameters[name] = null
		f.close()

	for a_param in MINIMAL_PARAMS.CLASSES:
		if not templates.classes.parameters.has(a_param):
			templates.classes.parameter_names.append(a_param)
			templates.classes.parameters[a_param] = ""
	
func set_template_library(p_value):
	template_library = p_value