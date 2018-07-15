tool

const Data = preload("res://addons/godot-builder/data.gd")

static func run(p_params):
	#print("execute params: ", p_params)
	var language = p_params.language
	var version = p_params.version
	var platform = p_params.platform
	var platform_nickname = p_params.platform_nickname
	var bits = p_params.bits
	var target = p_params.target
	var op = p_params.op
	var plugin_path = p_params.plugin_path
	var gdnlib_path = p_params.gdnlib_path
	
	var language_bindings_dir = OS.get_user_data_dir().plus_file("bindings").plus_file(language).plus_file(version)
	var out_file = ProjectSettings.globalize_path("res://__tmp__.txt")

	var command = ""
	var args = PoolStringArray()

	match language:
		"C++":
			var godot_cpp_dir = language_bindings_dir.plus_file("godot-cpp")
			var godot_headers_dir = language_bindings_dir.plus_file("godot_headers")
			match str(version):
				"1.0", "1.1":
					match op:
						"download":
							var dir = Directory.new()
							if not dir.dir_exists(language_bindings_dir):
								print("Creating bindings directory at: ", "\"" + ProjectSettings.globalize_path(language_bindings_dir) + "\"")
								dir.make_dir_recursive(language_bindings_dir)
							
							if not dir.dir_exists(godot_cpp_dir):
								print("Cloning godot-cpp repository to: ", "\"" + ProjectSettings.globalize_path(godot_cpp_dir) + "\"")
								command = "cd"
								args.append_array(PoolStringArray(str(language_bindings_dir + " && git clone https://github.com/GodotNativeTools/godot-cpp.git").split(" ")))
								match platform:
									"Windows":
										pass
									"OSX", "X11":
										args.append_array(PoolStringArray(str("&& echo $? > " + out_file).split(" ")))
								print("Executing: ", command, " ", args.join(" "))
								if OS.execute(command, args, false) == -1:
									print("Operation failed. Exiting...")
									return
								args.resize(0)
							
							if not dir.dir_exists(godot_headers_dir):
								print("Cloning godot_headers repository to: ", "\"" + ProjectSettings.globalize_path(godot_headers_dir) + "\"")
								command = "cd"
								args.append_array(PoolStringArray(str(language_bindings_dir + " && git clone https://github.com/GodotNativeTools/godot_headers.git").split(" ")))
								match platform:
									"Windows":
										pass
									"OSX", "X11":
										args.append_array(PoolStringArray(str("&& echo $? > " + out_file).split(" ")))
								print("Executing: ", command, " ", args.join(" "))
								if OS.execute(command, args, false) == -1:
									print("Operation failed. Exiting...")
									return
								args.resize(0)

						"generate_json_api":
							var sel = Data.get_config("selections")
							
							command = sel.get_value("builder", "godot_path")
							args.append("--gdnative-generate-json-api")
							args.append("godot_api.json")
							
							print("Executing: ", command, " ", args.join(" "))
							if OS.execute(command, args, false) == -1:
								print("Operation failed. Exiting...")
								return

						"generate_bindings":
							print("Generating bindings...")
							command = "scons"
							args.append(ProjectSettings.globalize_path(godot_cpp_dir))
							args.append("platform=" + platform_nickname.to_lower())
							args.append("headers=../godot_headers")
							args.append("generate_bindings=yes")
							print("Executing: ", command, " ", args.join(" "))
							if OS.execute(command, args, true) == -1:
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
							
							var sel = Data.get_config("selections")
							var selected_plugin = sel.get_value("editor", "selected_plugin", "")
							if not selected_plugin:
								return
							
							var output_dynamic_lib = language_bindings_dir.plus_file("godot-cpp/bin/libgodot-cpp.windows.64." + static_suffix)
						"clean":
							pass