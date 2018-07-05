extends HBoxContainer

onready var plugin_dialog = $AddGDNativePluginDialog
onready var file_dialog = $FileDialog

func _on_AddPluginButton_pressed():
	plugin_dialog.popup_centered()

func _on_FileDialog_dir_selected(p_dir):
	plugin_dialog.path_edit.text = p_dir

func _on_AddGDNativePluginDialog_confirmed():
	pass
	#plugin_option.add_item(plugin_dialog.name_edit.text)
	#plugin_option.get_popup().set_item_tooltip(plugin_option.get_item_count() - 1, plugin_dialog.path_edit.text)

func _on_AddGDNativePluginDialog_request_browse():
	file_dialog.popup_centered_ratio(.75)