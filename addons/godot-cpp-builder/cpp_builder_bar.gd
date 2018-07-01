extends HBoxContainer

onready var version_option = $VersionOptions

func _ready():
	version_option.add_item("1.0")
	version_option.add_item("1.1")
	version_option.selected = 0