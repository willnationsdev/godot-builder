extends EditorInspectorPlugin

const BuildToolbar = preload("build_toolbar.gd")

var execute
var list
var last_name

func can_handle(object):
	if object is GDNativeBuildSettings:
		return true
func parse_begin(object):
	list = object.get_property_list()
	last_name = list[len(list)-1].name
	object.execute = execute
	var node = BuildToolbar.new()
	node.connect_buttons(object)
	add_custom_control(node)
func parse_property(object, type, path, hint, hint_text, usage):
	pass
#	print("'", last_name, "' == '", path, "'?")
#	if last_name != path:
#		return
#	var button = Button.new()
#	button.text = "Generate"
#	button.connect("pressed", self, "_on_generated_pressed", [object])
#	add_custom_control(button)

func _on_generate_pressed(p_res):
	var gdnLibName = p_res.library_name
	var template_data = p_res.templates[p_res.template_type.to_upper()]
	
	var library_path = p_res.library_root_dir
	var path = library_path.plus_file(template_data.parameters.FILENAME)
	
	# sift through its regex matches and inject template parameters
	# before creating the new file(s)
	var regex = RegEx.new()
	for a_file in template_data.files:
		var fo = File.new()
		var fi = File.new()
		var fo_path = path + "." + a_file.get_extension()
		if not fo.open(fo_path, File.WRITE) == OK:
			print("Failed to open output file for template: ", fo_path)
			return
		if not fi.open(a_file, File.READ) == OK:
			print("Failed to open output file for template: ", a_file)
			return
		
		var text = fi.get_as_text()
		for a_param in template_data.parameter_names:
			regex.compile("@@" + a_param)
			text = regex.sub(text, template_data.parameters[a_param], true)
		
		fo.store_string(text)
		
		fi.close()
		fo.close()
	
