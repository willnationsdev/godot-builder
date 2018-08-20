tool
extends VBoxItemList
class_name FileSystemList

const DEFAULT_HINT = PROPERTY_HINT_GLOBAL_FILE

class FileSystemListItem:
	extends HBoxContainer
	
	var fd_btn: Button
	
	func _init(p_hint = DEFAULT_HINT):
		fd_btn = Button.new()
		fd_btn.text = "Null"
		fd_btn.size_flags_horizontal = SIZE_EXPAND_FILL
		add_child(fd_btn)

enum FileType {
	TYPE_FILE,
	TYPE_DIRECTORY
}

export(int, "File", "Directory") var file_type: int = TYPE_FILE setget set_file_type
export(bool) var global: bool = true setget set_global

var hint: int = DEFAULT_HINT

func _init():
	item_script = FileSystemListItem

func _update_list():
	_update_hint()

func set_file_type(p_value: int):
	file_type = p_value
	_update_list()

func set_global(p_value: bool):
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

