tool
extends Reference

enum {
	ERR_BUILDER_NO_BUILD_TOOL = 1,
	ERR_BUILDER_NO_LIBRARY_SELECTED = 2
}

static func get_config(p_type = "builder"):
	var cf = ConfigFile.new()
	var path = "res://addons/godot-builder/" + p_type + ".cfg"
	if cf.load(path) != OK:
		print("Failed to load Godot Builder config file at ", path)
		return null
	return cf

static func save_config(p_config, p_type = "builder"):
	var path = "res://addons/godot-builder/" + p_type + ".cfg"
	if p_config.save(path) != OK:
		print("Failed to save Godot Builder config file at ", path)
		return false
	return true
