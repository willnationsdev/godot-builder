tool
extends ConfirmationDialog

onready var name_edit = $VBoxContainer/GridContainer/NameEdit
onready var path_edit = $VBoxContainer/GridContainer/PathEdit
onready var gdnlib_edit = $VBoxContainer/GridContainer/GDNLibEdit

signal request_browse_directory
signal request_browse_file

func _on_PathBrowseButton_pressed():
	emit_signal("request_browse_directory")

func _on_GDNLibBrowseButton_pressed():
	emit_signal("request_browse_file")
