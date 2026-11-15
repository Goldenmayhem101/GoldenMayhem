extends Node
func _ready() -> void:
	var which := "shot"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--demo="):
			which = a.split("=")[1]
	var s := Node3D.new()
	s.set_script(load("res://scripts/%s.gd" % {"shot": "Shot", "game": "Game"}[which]))
	add_child(s)
	s.setup()
