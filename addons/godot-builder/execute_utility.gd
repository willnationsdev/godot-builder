tool
extends Node

signal thread_finished(p_params)

const Data = preload("res://addons/godot-builder/data.gd")

# The types of Tasks we can perform
enum Tasks {
	TASK_DOWNLOAD,
	TASK_GENERATE_JSON,
	TASK_GENERATE_BINDINGS,
	TASK_BUILD,
	TASK_CLEAN
}

# Setup some threads for asynchronous tasks.
# Assuming we won't ever need more than 3 tasks for a single operation.
# Can update if that changes.
var t1 = Thread.new()
var t2 = Thread.new()
var t3 = Thread.new()

func run(p_res, p_op):
	print(p_res)
	print(p_op)
	return
	var p_params = {}
	# Formally give names to passed in parameters
	var language = p_params.language
	var version = p_params.version
	var platform = p_params.platform
	var bits = p_params.bits
	var target = p_params.target
	var op = p_params.op
	var selected_plugin = p_params.selected_plugin
	
	# Initialize config-dependent standardized inputs
	var config = Data.get_config()
	assert(config)
	var platforms = config.get_value(language, "platforms", {})
	assert(platforms.has(platform))
	var platform_nickname = platforms[platform].nickname if platforms[platform].has("nickname") else platform
	var static_suffix = platforms[platform]["static"]
	p_params.static_suffix = static_suffix
	var dynamic_suffix = platforms[platform]["dynamic"]
	p_params.dynamic_suffix = dynamic_suffix
	
	# Initialize config-dependent user-preferred inputs
	var sel = Data.get_config("selections")
	assert(sel)
	
	var plugin_data = null
	if true:
		var data = sel.get_value("editor", "plugins", {})
		if data.has(selected_plugin):
			plugin_data = data[selected_plugin]
		assert(plugin_data)
	
	p_params.plugin_path = plugin_data.path
	p_params.gdnlib_path = plugin_data.gdnlib
	
	# Won't use this whole thing for scons C++, but if other languages want it, it'll be available.
	# If you have a GDNative plugin at res://libs/test/test.gdnlib for Windows 64bit, then this will make:
	# res://libs/test/libtest.windows.64.dll
	p_params.output_dynamic_lib = p_params.gdnlib_path.get_base_dir().plus_file("lib%s.%s.%s.%s" % [selected_plugin, platform, bits, p_params.dynamic_suffix])
	
	# This is where we expect to find the bindings for the language/version we are working with
	var language_bindings_dir = OS.get_user_data_dir().plus_file("bindings").plus_file(language).plus_file(version)
	
	# These are the parameters we will ultimately be supplying to our OS.execute instructions.
	# The whole purpose of this plugin is to provide a GUI wrapper around THESE operations.
	p_params.command = ""
	p_params.args = PoolStringArray()
	
	# Use `where [build command]` on Windows or `which [build command]` on Linux/OSX to find this path
	# Then set it by clicking the Pth button in the Godot Builder toolbar.
	var build_command_path = sel.get_value(language, "build_tool_path", "")
	if not build_command_path:
		print("Could not find build command. Exiting...")
		return
	
	match language:
		"C++":
			# These are the intended final locations of our C++ bindings repositories.
			var godot_cpp_dir = language_bindings_dir.plus_file("godot-cpp")
			var godot_headers_dir = language_bindings_dir.plus_file("godot_headers")
			p_params.godot_cpp_dir = godot_cpp_dir
			p_params.godot_headers_dir = godot_headers_dir
			p_params.bindings_lib = godot_cpp_dir.plus_file("bin").plus_file("lib%s.%s.%s.%s" % [selected_plugin, platform, bits, p_params.static_suffix])
			
			match op:
				"download":
					var dir = Directory.new()
					if not dir.dir_exists(language_bindings_dir):
						print("Creating bindings directory at: ", language_bindings_dir)
						dir.make_dir_recursive(language_bindings_dir)
					
					if not dir.dir_exists(godot_cpp_dir):
						p_params.task = TASK_DOWNLOAD
						p_params.task_hint = "godot-cpp"
						p_params.command = "git"
						p_params.args = PoolStringArray(["clone", "https://github.com/GodotNativeTools/godot-cpp.git", godot_cpp_dir])
						p_params.thread = t1
						t1.start(self, "task", p_params.duplicate())
					
					if not dir.dir_exists(godot_headers_dir):
						p_params.task = TASK_DOWNLOAD
						p_params.task_hint = "godot_headers"
						p_params.command = "git"
						p_params.args = PoolStringArray(["clone", "https://github.com/GodotNativeTools/godot_headers.git", p_params.godot_headers_dir])
						p_params.thread = t2
						t2.start(self, "task", p_params.duplicate())

				"generate_json_api":
					p_params.task = TASK_GENERATE_JSON
					p_params.task_hint = ""
					p_params.command = sel.get_value("builder", "godot_path", OS.get_executable_path())
					p_params.args = PoolStringArray(["--gdnative-generate-json-api", godot_cpp_dir.plus_file("godot_api.json")])
					p_params.thread = t1
					t1.start(self, "task", p_params.duplicate())
					t1.wait_to_finish()

				"generate_bindings":
					p_params.task = TASK_GENERATE_BINDINGS
					p_params.task_hint = ""
					p_params.command_path = build_command_path
					if _path_to_command(build_command_path) == "scons":
						p_params.args = PoolStringArray(["-C", godot_cpp_dir, "platform=" + platform_nickname.to_lower(), "headers=../godot_headers", "generate_bindings=yes"])
					p_params.thread = t1
					t1.start(self, "task", p_params.duplicate())

				"build":
					p_params.task = TASK_BUILD
					p_params.task_hint = ""
					
					p_params.command_path = build_command_path
					if _path_to_command(build_command_path) == "scons":
						p_params.args = PoolStringArray(["-C", p_params.plugin_path])
						p_params.args.append("target=" + target)
						p_params.args.append("platform=" + platform_nickname)
						p_params.args.append("bits=" + bits)
						p_params.args.append("name=" + "lib" + selected_plugin)
						p_params.args.append("lib=" + p_params.output_dynamic_lib.get_base_dir())
						p_params.args.append("cpp_bindings_library=" + godot_cpp_dir.plus_file("bin/godot-cpp"))
					p_params.thread = t1
					t1.start(self, "task", p_params.duplicate())

				"clean":
					p_params.task = TASK_CLEAN
					p_params.task_hint = ""
					p_params.command_path = build_command_path
					if _path_to_command(build_command_path) == "scons":
						p_params.args = PoolStringArray(["-C", p_params.plugin_path, "-c"])
					p_params.thread = t1
					t1.start(self, "task", p_params.duplicate())

# This executes in a separate thread so that OS.execute doesn't stall the main thread.
# We could use the false flag, but doing it in a wrapper thread method like this allows
# us to emit a signal upon completion and let us know when we are done.
func task(p_params):
	print("Executing: ", p_params.command_path, " ", p_params.args.join(" "))
	var output = []
	OS.execute(p_params.command_path, p_params.args, true, output)
	match p_params.task:
		TASK_CLEAN:
			var dir = Directory.new()
			dir.remove(p_params.output_dynamic_lib)
	emit_signal("thread_finished", p_params.duplicate())

func _path_to_command(p_command_path):
	return p_command_path.get_file().get_basename()