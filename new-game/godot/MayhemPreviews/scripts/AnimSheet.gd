## Contact sheet: plays a list of animations side by side on robots, with labels. --anims=a,b,c
extends Node3D
signal finished
var actors: Array = []
var t := 0.0
var at := -1.0
func setup(_d: bool) -> void:
	var names: PackedStringArray = []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--anims="):
			names = a.split("=")[1].split(",")
		if a.begins_with("--at="):
			at = float(a.split("=")[1])
	var env := WorldEnvironment.new(); var e := Environment.new()
	e.background_mode = Environment.BG_COLOR; e.background_color = Color(0.13, 0.14, 0.18)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color = Color(0.6, 0.62, 0.7); e.ambient_light_energy = 0.6
	e.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.environment = e; add_child(env)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-45, 30, 0); sun.shadow_enabled = true; add_child(sun)
	var cols := 5
	var rows := int(ceil(names.size() / float(cols)))
	Kit.part(self, "box", Vector3(cols * 2.6 + 2, 0.1, rows * 2.6 + 2), Kit.pbr(Color(0.3, 0.32, 0.36), 0.1, 0.8), Vector3((cols - 1) * 1.3, -0.05, -(rows - 1) * 1.3))
	for i in names.size():
		var a := Actor.new(); add_child(a)
		a.setup(Kit.pbr(Color(0.7, 0.08, 0.05), 0.8, 0.3), Kit.pbr(Color(0.1, 0.1, 0.12), 0.8, 0.3))
		a.position = Vector3((i % cols) * 2.6, 0, -(i / cols) * 2.6)
		a.yaw_target = 90; a.yaw = 90
		a.play(names[i], 1.0, 0.0, true)
		var l := Label3D.new(); l.text = names[i]; l.font_size = 64; l.pixel_size = 0.004; l.position = a.position + Vector3(0, 2.0, 0.6); l.billboard = BaseMaterial3D.BILLBOARD_ENABLED; add_child(l)
		actors.append(a)
	var cam := Camera3D.new(); add_child(cam); cam.current = true; cam.fov = 50
	var c := Vector3((cols - 1) * 1.3, 0.9, -(rows - 1) * 1.3)
	cam.position = c + Vector3(0, 1.0 + rows * 1.0, 3.5 + rows * 2.6); cam.look_at(c)
	if at >= 0.0:
		await get_tree().process_frame
		for a in actors:
			a.ap.seek(minf(at, Kit.lengths[a.cur] - 0.01), true); a.ap.pause()
func _process(d: float) -> void:
	t += d
	for a in actors:
		if at < 0.0 and not a.ap.is_playing():
			a.play(a.cur, 1.0, 0.0, true)
	if t > 6.0:
		finished.emit()
