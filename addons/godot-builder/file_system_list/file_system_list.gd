tool
extends Container
class_name FileSystemList

enum FileType {
	TYPE_FILE,
	TYPE_DIRECTORY
}

export(String) var title = "" setget set_title
export(int, "File", "Directory") var file_type = TYPE_FILE setget set_file_type
export(bool) var global = true setget set_global

onready var label = $VBoxContainer/Title/Label
onready var add_button = $VBoxContainer/Title/AddButton

var hint = PROPERTY_HINT_GLOBAL_FILE

func _update_list():
	_update_hint()

func set_file_type(p_value):
	file_type = p_value
	_update_list()

func set_global(p_value):
	global = p_value
	_update_list()

func _update_hint():
	match file_type:
		TYPE_FILE:
			match global:
				true:
					hint = PROPERTY_HINT_GLOBAL_FILE
				false:
					hint = PROPERTY_HINT_FILE
		TYPE_DIRECTORY:
			match global:
				true:
					hint = PROPERTY_HINT_GLOBAL_DIR
				false:
					hint = PROPERTY_HINT_DIR

func set_title(p_value):
	title = p_value
	label.text = title