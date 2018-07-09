tool
extends VBoxContainer

var undoredo = null

func _on_BuildToolbar_request_toggle_gdnative_plugins(p_pressed):
	$PluginsEditor.visible = p_pressed

func _ready():
	$BuildToolbar.connect("language_selected", $PluginsEditor, "_on_language_selected")

func _enter_tree():
	if $PluginsEditor.has_method("set_undoredo"):
		$PluginsEditor.set_undoredo(undoredo)
	if $BuildToolbar.has_method("set_undoredo"):
		$BuildToolbar.set_undoredo(undoredo)