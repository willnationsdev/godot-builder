tool
extends VBoxContainer

var undoredo = null setget set_undoredo

func _on_BuildToolbar_request_toggle_gdnative_plugins(p_pressed):
	$PluginsEditor.visible = p_pressed

func set_undoredo(p_undoredo):
	undoredo = p_undoredo
	$BuildToolbar.undoredo = p_undoredo
	$PluginsEditor.undoredo = p_undoredo