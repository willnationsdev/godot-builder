tool
static func run(p_params):
	var language = p_params.language
	var version = p_params.version
	var platform = p_params.platform
	var bits = p_params.bits
	var target = p_params.target
	var op = p_params.op
	
	match language:
		"C++":
			match str(version):
				"1.0":
					pass
				"1.1":
					match op:
						"generate_json_api":
							pass
						"generate_bindings":
							pass
						"build_bindings":
							pass
						"build":
							pass
						"clean":
							pass