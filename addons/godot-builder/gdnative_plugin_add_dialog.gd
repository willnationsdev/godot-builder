tool
extends ConfirmationDialog

onready var name_edit = $VBoxContainer/GridContainer/NameEdit
onready var path_edit = $VBoxContainer/GridContainer/PathEdit

signal request_browse

func _on_BrowseButton_pressed():
	emit_signal("request_browse")
