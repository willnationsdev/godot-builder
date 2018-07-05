tool
extends VBoxContainer

func _on_BuildToolbar_request_toggle_gdnative_plugins(p_pressed):
	$HSeparator.visible = p_pressed
	$PluginsEditor.visible = p_pressed
