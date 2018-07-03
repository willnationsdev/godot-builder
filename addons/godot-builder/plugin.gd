tool
extends EditorPlugin

const BuilderScn = preload("builder.tscn")

var builder
var builder_button

func _enter_tree():
	builder = BuilderScn.instance()
	builder_button = add_control_to_bottom_panel(builder, "Builder")

func _exit_tree():
	remove_control_from_bottom_panel(builder)
	builder.free()