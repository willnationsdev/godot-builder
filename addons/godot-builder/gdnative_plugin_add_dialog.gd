tool
extends ConfirmationDialog

onready var name_edit = $GridContainer/NameEdit
onready var path_edit = $GridContainer/PathEdit

signal request_browse

func _on_BrowseButton_pressed():
		emit_signal("request_browse")
