tool
extends HBoxContainer

func _enter_tree():
	print("wrapper ready")
	$ToggleButton.connect("toggled", self, "_on_toggled")
	$ToggleButton.pressed = $Toolbar.visible

func _on_toggled(p_active):
	$Toolbar.toggle_expansion(p_active)