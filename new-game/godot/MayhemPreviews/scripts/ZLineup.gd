## Lineup of the uploaded Mixamo zombie characters, each playing its own idle.
extends Node3D
signal finished
var t := 0.0
func setup(_d: bool) -> void:
	var env := WorldEnvironment.new(); var e := Environment.new()
	e.background_mode = Environment.BG_COLOR; e.background_color = Color(0.16, 0.17, 0.2)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color = Color(0.7, 0.7, 0.75); e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.environment = e; add_child(env)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-35, 25, 0); sun.light_energy = 1.3; sun.shadow_enabled = true; add_child(sun)
	Kit.part(self, "box", Vector3(20, 0.1, 6), Kit.pbr(Color(0.35, 0.36, 0.38), 0, 0.8), Vector3(0, -0.05, 0))
	var names := ["yaku", "cop", "girl", "war", "clown", "skeleton", "pumpkin"]
	var lib := Kit.library()
	for i in names.size():
		var m: Node3D = load("res://zc/%s.fbx" % names[i]).instantiate(); add_child(m)
		m.position = Vector3(-6.0 + i * 2.0, 0, 0)
		var ap: AnimationPlayer = m.find_children("*", "AnimationPlayer", true, false)[0] if not m.find_children("*", "AnimationPlayer", true, false).is_empty() else null
		if ap:
			ap.add_animation_library("m", lib); ap.play("m/z_idle" if lib.has_animation("z_idle") else "m/f_idle")
		var l := Label3D.new(); l.text = names[i]; l.font_size = 72; l.pixel_size = 0.004; l.position = m.position + Vector3(0, 2.3, 0); add_child(l)
	var cam := Camera3D.new(); add_child(cam); cam.current = true; cam.fov = 45
	cam.position = Vector3(0, 1.6, 9.5); cam.look_at(Vector3(0, 1.0, 0))
func _process(d: float) -> void:
	t += d
	if t > 1.0:
		finished.emit()
