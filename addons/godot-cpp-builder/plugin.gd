tool
extends EditorPlugin

var button

func _enter_tree():
	button = Button.new()
	button.text = "Test"
	button.connect("pressed", self, "_on_click")
	add_control_to_container(CONTAINER_TOOLBAR, button)
	button.get_parent().move_child(button, 2)

func _on_click():
	var dir = Directory.new()
	if not dir.dir_exists("user://bindings/"):
		var confirm = ConfirmationDialog.new()
		confirm.text = "A bindings directory was not found in your user settings. Would you like to create one now?"


func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, button)
	button.free()