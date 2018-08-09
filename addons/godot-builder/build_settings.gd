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
var libs = []
var source_dirs = []
var include_dirs = []

# build_options_
var language = Language.CPP setget set_language
var version = Version.ONE_ONE
var platform = Platform.WINDOWS
var bits = Bits.SIXTY_FOUR
var target = Target.DEBUG

# bindings_
var bindings_directory = ""
var bindings_lib_name = "" setget set_bindings_lib_name

var execute

##### PROPERTIES #####

##### NOTIFICATIONS #####

func _get(property):
	match property:
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

func _set(property, value):
	match property:
		"project_settings/name": project_name = value
		"project_settings/output_dir": output_dir = value
		"project_settings/source_dirs": source_dirs = value
		"project_settings/include_dirs": include_dirs = value
		"project_settings/libs": libs = value
		"project_settings/bindings_dir": bindings_directory = value
		"project_settings/bindings_lib_name": bindings_lib_name = value
		
		"build_options/language": language = value
		"build_options/version": version = value
		"build_options/platform": platform = value
		"build_options/bits": bits = value
		"build_options/target": target = value

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
	]
	return list

##### CONNECTIONS #####

func _on_execute(p_settings, p_op):
	if not execute:
		print("There's no execute node!")
		return
	execute.run(p_settings, p_op)

##### PRIVATE METHODS #####

func _reload_language_templates():
	pass

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