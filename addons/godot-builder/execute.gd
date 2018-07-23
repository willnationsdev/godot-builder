tool

const Data = preload("res://addons/godot-builder/data.gd")

static func run(p_params):
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
	
	# Initialize config-dependent user-preferred inputs
	var sel = Data.get_config("selections")
	assert(sel)
	
	var plugin_data = null
	if true:
		var data = sel.get_value("editor", "plugins", {})
		plugin_data = data[selected_plugin] if data.has(selected_plugin) else {}
		assert(plugin_data)
	
	var plugin_path = plugin_data.path
	var gdnlib_path = plugin_data.gdnlib
	
	# Setup assist variables...
	
	# This is where we expect to find the bindings for the language/version we are working with
	var language_bindings_dir = OS.get_user_data_dir().plus_file("bindings").plus_file(language).plus_file(version)
	
	# These are the parameters we will ultimately be supplying to our OS.execute instructions.
	# The whole purpose of this plugin is to provide a GUI wrapper around THESE operations.
	var command = ""
	var args = PoolStringArray()
	
	match language:
		"C++":
			# This file is a hack that we can generate (touch / create) in our project to trigger a
			# 'filesystem_changed' callback and let us know when our async command line operations are finished.
			# Without creating/detecting this file, we have no way of knowing when to move to the next step or
			# display visual feedback to the user about what step we are on / if we've completed.
			var out_file = ProjectSettings.globalize_path("res://__tmp__.txt")
			
			# These are the intended final locations of our C++ bindings repositories.
			var godot_cpp_dir = language_bindings_dir.plus_file("godot-cpp")
			var godot_headers_dir = language_bindings_dir.plus_file("godot_headers")
			
			match str(version):
				"1.0", "1.1":
					match op:
						"download":
							var dir = Directory.new()
							if not dir.dir_exists(language_bindings_dir):
								print("Creating bindings directory at: ", language_bindings_dir)
								dir.make_dir_recursive(language_bindings_dir)
							
							if not dir.dir_exists(godot_cpp_dir):
								print("Cloning godot-cpp repository to: ", godot_cpp_dir)
								command = "git"
								args.append_array(PoolStringArray(["clone", "https://github.com/GodotNativeTools/godot-cpp.git", godot_cpp_dir]))
#								match platform:
#									"Windows":
#										pass
#									"OSX", "X11":
#										args += "&& echo $? > " + out_file + "\""
								print("Executing: ", command, " ", args)
								if OS.execute(command, args, false) == -1:
									print("Operation failed. Exiting...")
									return
								args.resize(0)
							
							if not dir.dir_exists(godot_headers_dir):
								print("Cloning godot_headers repository to: ", godot_headers_dir)
								command = "git"
								args.append_array(PoolStringArray(["clone", "https://github.com/GodotNativeTools/godot_headers.git", godot_headers_dir]))
#								match platform:
#									"Windows":
#										pass
#									"OSX", "X11":
#										args += "&& echo $? > " + out_file + "\""
								print("Executing: ", command, " ", args.join(" "))
								if OS.execute(command, args, false) == -1:
									print("Operation failed. Exiting...")
									return
								args.resize(0)

						"generate_json_api":
							command = sel.get_value("builder", "godot_path", OS.get_executable_path())
							args.append_array(PoolStringArray(["--gdnative-generate-json-api", godot_cpp_dir.plus_file("godot_api.json")]))
							match platform:
								"Windows":
									pass
								"OSX", "X11":
									args.append_array(PoolStringArray(["&&", "echo", "$?", ">", out_file]))
							print("Executing: ", command, " ", args.join(" "))
							if OS.execute(command, args, false) == -1:
								print("Operation failed. Exiting...")
								return
							args.resize(0)

						"generate_bindings":
							print("Generating bindings...")
							command = "scons"
							args.append_array(PoolStringArray(["-C", godot_cpp_dir, "platform=" + platform_nickname.to_lower(), "headers=../godot_headers", "generate_bindings=yes"]))
							print("Executing: ", command, " ", args.join(" "))
							if OS.execute(command, args, false) == -1:
								print("Operation failed. Exiting...")
								return
							args.resize(0)

						"build_bindings":
							command = "scons"
							args.append(ProjectSettings.globalize_path("user://bindings/" + language + "/godot-cpp"))
							args.append("platform=" + platform)
							print("Executing: ", command, " ", args.join(" "))
							#if OS.execute(command, args, true) == -1:
							#	print("Operation failed. Exiting...")
							#	return
							args.resize(0)

						"build":
							var cf = Data.get_config()
							var platform_data = cf.get_value(language, "platforms")[platform]
							var static_suffix = platform_data.static
							var dynamic_suffix = platform_data.dynamic
							var godot_cpp_bindings_lib = language_bindings_dir.plus_file("godot-cpp/bin/libgodot-cpp.windows.64." + static_suffix)
							
							var output_dynamic_lib = language_bindings_dir.plus_file("godot-cpp/bin/libgodot-cpp.windows.64." + static_suffix)
						"clean":
							pass