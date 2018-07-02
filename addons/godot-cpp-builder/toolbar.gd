extends HBoxContainer

const CONFIG_PATH = "builder.cfg"
const SELECTIONS_PATH = "user://selections.cfg"

var config = ConfigFile.new()
var selections = ConfigFile.new()

onready var language_option = $LanguageOptions
onready var version_option = $VersionOptions
onready var os_option = $OSOptions
onready var bits_option = $BitsOptions
onready var target_option = $TargetOptions

onready var found_check = $FoundCheck
onready var found_button = $FoundButton
onready var compiled_check = $CompiledCheck
onready var compiled_button = $CompiledButton

func _ready():
	config.load(CONFIG_PATH)
	if selections.load(SELECTIONS_PATH) != OK:
		_init_selections()
	
	var languages = config.get_value("builder", "languages", [])
	
	for lang in languages:
		language_option.add_item(lang)
	language_option.selected = 0
	
	
	
	version_option.add_item("1.0")
	version_option.add_item("1.1")
	version_option.add_item("custom")
	version_option.selected = 0
		
	var dir = Directory.new()
	var version = version_option.get_item_text(version_option.selected)
	var lang = lang_dir_map[language_option.get_item_text(language_option.selected)]
	var os = os_option.get_item_text(os_option.selected)
	var file = "godot-cpp"
	var path = "user://bindings".plus_file(version).plus_file(lang).plus_file("bin/godot-cpp.bindings." + _get_library_ext(false))
	print("path: ", path)
	if dir.file_exists(path):
		found_check.pressed = true
		found_button.text = "Found"
		if found_button.is_connected("pressed", self, "_find_clicked"):
			found_button.disconnect("pressed", self, "_find_clicked")
	else:
		found_check.pressed = false
		found_button.text = "Find"
		found_button.connect("pressed", self, "_find_clicked")

func _get_library_ext(p_dynamic):
	match OS.get_name():
		"Windows":
			return "dll" if p_dynamic else "lib"
		"OSX": 
			return "dylib" if p_dynamic else "a"
		"X11":
			return "so" if p_dynamic else "a"

func _language_selected(p_id):
	var lang = language_options.get_item_text(p_id)
	config.set_value("builder", "selected_language", lang)
	config.save(CONFIG_PATH)

func _update_bindings():
	var lang = language_options

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

func _init_selections():
	selections

"test"
"test"
"test"
"test"