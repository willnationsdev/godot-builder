tool
extends EditorPlugin

const BuilderScn = preload("builder.tscn")

var builder

func _enter_tree():
	builder = BuilderScn.instance()
	add_control_to_container(CONTAINER_TOOLBAR, builder)

func _exit_tree():
	builder.free()