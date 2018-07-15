tool
extends EditorPlugin

const BuilderScn = preload("builder.tscn")

var builder
var builder_button

func _enter_tree():
	builder = BuilderScn.instance()
	builder.undoredo = get_undo_redo()
	builder_button = add_control_to_bottom_panel(builder, "Builder")
	
	var efs = get_editor_interface().get_resource_filesystem()
	efs.connect("filesystem_changed", self, "_on_filesystem_changed")

func _exit_tree():
	remove_control_from_bottom_panel(builder)
	builder.free()

func _on_filesystem_changed():
	var f = File.new()
	if f.open("res://__tmp__.txt", File.READ) != OK:
		return
	var text = f.get_line()
	var err = int(text.strip_edges())
	if err == OK:
		print("Success!")
	else:
		print("Failure!")
	var dir = Directory.new()
	dir.remove(f.get_path())
	f.close()