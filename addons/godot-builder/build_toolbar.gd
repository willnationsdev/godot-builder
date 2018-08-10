tool
extends HBoxContainer

var download = ToolButton.new()
var json = ToolButton.new()
var bindings = ToolButton.new()
var build = ToolButton.new()
var clean = ToolButton.new()

func _init():
	add_child(download)
	download.icon = preload("res://addons/godot-builder/icons/icon_download.svg")
	add_child(json)
	json.icon = preload("res://addons/godot-builder/icons/icon_json.svg")
	add_child(bindings)
	bindings.icon = preload("res://addons/godot-builder/icons/icon_plug.svg")
	add_child(build)
	build.icon = preload("res://addons/godot-builder/icons/icon_wrench.svg")
	add_child(clean)
	clean.icon = preload("res://addons/godot-builder/icons/icon_clear.svg")

func connect_buttons(p_res):
	var fname = "_on_execute"
	var sig = "pressed"
	download.connect(sig, p_res, fname, [p_res, "download"])
	json.connect(sig, p_res, fname, [p_res, "generate_json_api"])
	bindings.connect(sig, p_res, fname, [p_res, "generate_bindings"])
	build.connect(sig, p_res, fname, [p_res, "build"])
	clean.connect(sig, p_res, fname, [p_res, "clean"])