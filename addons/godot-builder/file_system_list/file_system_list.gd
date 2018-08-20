tool
extends VBoxItemList
class_name FileSystemList

const DEFAULT_HINT: int = PROPERTY_HINT_GLOBAL_FILE

class FileSystemListItem:
	extends HBoxContainer
	
	var fd_btn: Button
	
	func _init():
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
var fd := FileDialog.new()

func _init(p_title: String = "", p_item_prefix: String = ""):
	set_title(p_title)
	set_item_prefix(p_item_prefix)
	_update_hint()

#warning-ignore:unused_argument
func _item_inserted(p_index: int, p_control: Control):
	if p_control is FileSystemListItem:
		_reset_fd_btn_connections(p_control.fd_btn)

#warning-ignore:return_value_discarded
func _reset_fd_btn_connections(p_btn: BaseButton):
	p_btn.connect("pressed", fd, "popup_centered_ratio", [0.75])

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
					fd.mode = FileDialog.MODE_OPEN_FILE
					fd.access = FileDialog.ACCESS_FILESYSTEM
				false:
					hint = PROPERTY_HINT_FILE
					fd.mode = FileDialog.MODE_OPEN_FILE
					fd.access = FileDialog.ACCESS_RESOURCES
		TYPE_DIRECTORY:
			match global:
				true:
					hint = PROPERTY_HINT_GLOBAL_DIR
					fd.mode = FileDialog.MODE_OPEN_DIR
					fd.access = FileDialog.ACCESS_FILESYSTEM
				false:
					hint = PROPERTY_HINT_DIR
					fd.mode = FileDialog.MODE_OPEN_DIR
					fd.access = FileDialog.ACCESS_RESOURCES
