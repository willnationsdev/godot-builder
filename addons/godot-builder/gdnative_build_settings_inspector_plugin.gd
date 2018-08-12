extends EditorInspectorPlugin
var execute

func can_handle(object):
	if object is GDNativeBuildSettings:
		return true
func parse_begin(object):
	object.execute = execute
	var node = BuildToolbar.new()
	node.connect_buttons(object)
	add_custom_control(node)
func parse_category(object, category):
	if not category == "Resource":
		return
	var button = Button.new()
	button.text = "Generate"
	add_custom_control(button)

#var grid = GridContainer.new()
#grid.columns = 2
#grid.name = "Grid"
#config_edits.add_child(grid)
#if not template_parameters.has("FILENAME"):
#	template_parameters.FILENAME = ""
#if not template_parameters.has("AUTHOR"):
#	template_parameters.AUTHOR = ""

#for a_property in template_parameters.keys():
#	var label = Label.new()
#	label.text = a_property.capitalize()
#	grid.add_child(label)
#	var line_edit = LineEdit.new()
#	line_edit.rect_min_size.x = 280
#	grid.add_child(line_edit)

#var last_child = grid.get_child(grid.get_child_count() - 1)
#last_child.focus_next = last_child.get_path_to(template_create_button)
#template_create_button.focus_previous = template_create_button.get_path_to(last_child)
#template_create_button.focus_next = template_create_button.get_path_to(grid.get_child(1))
#grid.get_child(1).focus_previous = grid.get_child(1).get_path_to(template_create_button)

func _on_CreateTemplateClassButton_pressed():
    # acquire the path of the new file to copy to
    var grid = config_edits.get_node("Grid")
    if not grid:
        return
    
    var params = {}
    var param_name = ""
    for a_child in grid.get_children():
        if a_child is Label:
            param_name = a_child.text.to_upper().replace(" ", "_")
        if a_child is LineEdit:
            params[param_name] = a_child.text
    
    var sel = Data.get_config("selections")
    var current_plugin = sel.get_value("editor", "selected_plugin", null)
    if not current_plugin:
        return
    var plugins = sel.get_value("editor", "plugins", null)
    if not plugins or not plugins.has(current_plugin) or not plugins[current_plugin].has("path"):
        return
    var plugin_path = plugins[current_plugin].path
    var path = plugin_path.plus_file(params.FILENAME)
    
    # sift through its regex matches and inject template parameters
    # before creating the new file(s)
    var regex = RegEx.new()
    for a_file in current_template_files:
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
        for a_param in params:
            regex.compile("@@" + a_param)
            text = regex.sub(text, params[a_param], true)
        
        fo.store_string(text)
        
        fi.close()
        fo.close()
    
    for a_child in grid.get_children():
        if a_child is LineEdit:
            a_child.text = ""
