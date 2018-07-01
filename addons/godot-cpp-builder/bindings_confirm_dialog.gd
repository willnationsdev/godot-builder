extends ConfirmationDialog

func _ready():
	confirm.connect("confirmed", self, "_on_confirmed")

func _on_confirmed():
	var dir = Directory.new()
	dir.make_dir_recursive("user://bindings")
	