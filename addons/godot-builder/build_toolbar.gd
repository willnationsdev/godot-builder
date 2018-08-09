tool
extends HBoxContainer

func connect_buttons(p_res):
	var fname = "_on_execute"
	var sig = "pressed"
	$DownloadButton.connect(sig, p_res, fname, [p_res, "download"])
	$JsonButton.connect(sig, p_res, fname, [p_res, "generate_json_api"])
	$BindingsButton.connect(sig, p_res, fname, [p_res, "generate_bindings"])
	$BuildButton.connect(sig, p_res, fname, [p_res, "build"])
	$CleanButton.connect(sig, p_res, fname, [p_res, "clean"])