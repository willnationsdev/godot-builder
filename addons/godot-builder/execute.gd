tool

const Data = preload("res://addons/godot-builder/data.gd")

static func run(p_params):
	var language = p_params.language
	var version = p_params.version
	var platform = p_params.platform
	var bits = p_params.bits
	var target = p_params.target
	var op = p_params.op

	var command = ""
	var args = PoolStringArray()

	match language:
		"C++":
			match str(version):
				"1.0":
					pass
				"1.1":
					match op:
						"generate_json_api":
							var sel = Data.get_config("selections")
							
							command = sel.get_value("builder", "godot_path")
							args.append("--gdnative-generate-json-api")
							args.append("godot_api.json")

							OS.execute(command, args, true)
						"generate_bindings":
							var dir = Directory.new()
							var language_bindings_dir = "user://bindings/" + language
							if not dir.dir_exists(language_bindings_dir):
								print("Creating bindings directory at: ", ProjectSettings.globalize_path(language_bindings_dir))
								dir.make_dir_recursive(language_bindings_dir)
							var godot_cpp_dir = language_bindings_dir.plus_file("godot-cpp/")
							if not dir.dir_exists(godot_cpp_dir):
								print("Cloning godot-cpp repository to: ", ProjectSettings.globalize_path(godot_cpp_dir))
								command = "git"
								args.append("clone")
								args.append("https://github.com/GodotNativeTools/godot-cpp.git")
								args.append(language_bindings_dir)
								OS.execute(command, args, true)
								args.resize(0)
							var godot_headers_dir = language_bindings_dir.plus_file("godot_headers/")
							if not dir.dir_exists(godot_headers_dir):
								print("Cloning godot_headers repository to: ", ProjectSettings.globalize_path(godot_headers_dir))
								command = "git"
								args.append("clone")
								args.append("https://github.com/GodotNativeTools/godot-cpp.git")
								args.append(language_bindings_dir)
								OS.execute(command, args, true)
								args.resize(0)

							command = "scons"
							args.append(ProjectSettings.globalize_path(godot_cpp_dir))
							args.append("platform=" + platform)
							args.append("headers=../godot_headers")
							args.append("generate_bindings=yes")
							OS.execute(command, args, true)
							args.resize(0)
						"build_bindings":
							command = "scons"
							args.append(ProjectSettings.globalize_path("user://bindings/" + language + "/godot-cpp"))
							args.append("platform=" + platform)
							OS.execute(command, args, true)
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
							var 

							var output_dynamic_lib = language_bindings_dir.plus_file("godot-cpp/bin/libgodot-cpp.windows.64." + static_suffix)
							pass
						"clean":
							pass