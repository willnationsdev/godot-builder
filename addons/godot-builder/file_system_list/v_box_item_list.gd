tool
extends VBoxContainer
class_name VBoxItemList

signal item_inserted(p_index, p_control)
signal item_removed(p_index, p_data)

const ICON_ADD: Texture = preload("../icons/icon_add.svg")
const ICON_DELETE: Texture = preload("../icons/icon_import_fail.svg")

export var title: String = "" setget set_title
export var item_prefix: String = "" setget set_item_prefix
export var item_script: Script = null setget set_item_script
export var item_scene: PackedScene = null setget set_item_scene

var label: Label
var add_button: ToolButton
var content: VBoxContainer

func _init(p_title: String = "", p_item_prefix: String = "", p_type: Resource = null):
	
	if p_type:
		if p_type is Script:
			item_script = p_type
		elif p_type is PackedScene:
			item_scene = p_type
		else:
			printerr("'p_type' in VBoxItemList.new() is not a Script or PackedScene")
	
	var main_toolbar := HBoxContainer.new()
	main_toolbar.name = "Toolbar"
	add_child(main_toolbar)
	
	label = Label.new()
	label.name = "Title"
	label.text = p_title
	main_toolbar.add_child(label)
	
	add_button = ToolButton.new()
	add_button.icon = ICON_ADD
	add_button.name = "AddButton"
	#warning-ignore:return_value_discarded
	add_button.connect("pressed", self, "append_item")
	main_toolbar.add_child(add_button)
	
	content = VBoxContainer.new()
	content.name = "Content"
	add_child(content)
	
	item_prefix = p_item_prefix

func insert_item(p_index: int) -> Control:
	
	var node: Control = _get_node_from_type()
	if not node:
		return null
	
	node.name = "Item"
	
	var hbox := HBoxContainer.new()
	
	var item_label := Label.new()
	item_label.name = "ItemLabel"
	hbox.add_child(item_label)
	
	hbox.add_child(node)
	
	var del_btn := ToolButton.new()
	del_btn.icon = ICON_DELETE
	hbox.add_child(del_btn)
	
	content.add_child(hbox)
	if p_index >= 0:
		content.move_child(node, p_index)
	else:
		p_index = len(content.get_children())-1
	
	_reset_prefix_on_label(item_label, p_index)
	#warning-ignore:return_value_discarded
	del_btn.connect("pressed", self, "remove_item", [p_index])
	_item_inserted(p_index, node)
	
	emit_signal("item_inserted", p_index, node)
	
	return node

func get_item(p_index: int) -> Control:
	if p_index < 0:
		return null
	return content.get_child(p_index).get_node("Item") as Control

func append_item():
	return insert_item(-1)

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _item_inserted(p_index: int, p_control: Control):
	pass

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _item_removed(p_index: int, p_data: Dictionary):
	pass

func remove_item(p_idx: int):
	var node := content.get_child(p_idx) as HBoxContainer
	var data := node._get_data() as Dictionary if node.has_method("_get_data") else {}
	node.free()
	_reset_prefixes()
	_item_removed(p_idx, data)
	emit_signal("item_removed", p_idx, data)

func _get_node_from_type() -> Control:
	var node: Control = null
	if item_script:
		node = item_script.new() as Control
	elif item_scene:
		node = item_scene.instance() as Control
	else:
		return null
	return node

func set_title(p_value: String):
	title = p_value
	label.text = title

func set_item_prefix(p_value: String):
	item_prefix = p_value
	_reset_prefixes()

func _reset_prefixes():
	var index: int = 0
	for hbox in content.get_children():
		var a_label := (hbox as HBoxContainer).get_node("ItemLabel") as Label
		_reset_prefix_on_label(a_label, index)
		index += 1

func _reset_prefix_on_label(p_label: Label, p_index: int = -1):
	if not p_label:
		return
	if item_prefix:
		p_label.text = "%s %d" % [item_prefix, len(content.get_children())-1 if p_index < 0 else p_index]
		p_label.show()
	else:
		p_label.hide()

func set_item_script(p_value: Script):
	if _validate_item_type(p_value):
		item_script = p_value

func set_item_scene(p_value: PackedScene):
	if _validate_item_type(p_value):
		item_scene = p_value

func _validate_item_type(p_res: Resource) -> bool:
	if not p_res:
		return true
	var node: Node = null
	if p_res is Script:
		node = p_res.new() as Control
	elif p_res is PackedScene:
		node = p_res.instance() as Control
	else:
		printerr("Item Resource is unassigned.")
		return false
	
	if not node:
		printerr("An error occurred in creating a node from the Item Resource.")
		return false
	elif not node is Control:
		printerr("Item Resource does not create a Control.")
		return false
	
	if not node.has_method("_get_data"):
		printerr("Item  does not implement '_get_data'")
		return false
	if node is Node:
		node.queue_free()
	
	return true

