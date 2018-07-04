tool
extends ConfirmationDialog

onready var name_edit = $GridContainer/LineEdit
onready var path_edit = $GridContainer/LineEdit2

signal request_browse

func _on_ToolButton_pressed():
	print("HI")
	emit_signal("request_browse")
