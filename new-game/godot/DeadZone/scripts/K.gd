## KayKit helpers: place props, spawn animated characters, lights and effects.
class_name K

static func place(parent: Node3D, path: String, pos: Vector3, yaw := 0.0, s := 1.0) -> Node3D:
	var p := "res://kk/%s.gltf" % path
	if not ResourceLoader.exists(p):
		p = "res://kk/%s.glb" % path
	var n: Node3D = load(p).instantiate()
	n.position = pos
	n.rotation_degrees.y = yaw
	n.scale = Vector3.ONE * s
	parent.add_child(n)
	return n

static func char(parent: Node3D, file: String, pos: Vector3, yaw: float, anim: String, at := 0.0, s := 1.0) -> Node3D:
	var n := place(parent, "chars/" + file, pos, yaw, s)
	var ap: AnimationPlayer = n.find_children("*", "AnimationPlayer", true, false)[0]
	ap.play(anim)
	n.set_meta("ap", ap)
	n.set_meta("anim", anim)
	n.set_meta("at", at)
	return n

static func freeze(n: Node3D) -> void:
	var ap: AnimationPlayer = n.get_meta("ap")
	ap.seek(ap.get_animation(n.get_meta("anim")).length * n.get_meta("at"), true)
	ap.pause()

static func mesh(n: Node, name: String) -> MeshInstance3D:
	for m in n.find_children("*", "MeshInstance3D", true, false):
		if m.name == name:
			return m
	return null

static func glow_mat(c: Color, e := 4.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.emission_enabled = true
	m.emission = c
	m.emission_energy_multiplier = e
	return m

static func omni(parent: Node3D, pos: Vector3, c: Color, e: float, r: float, shadow := false) -> OmniLight3D:
	var o := OmniLight3D.new()
	o.position = pos; o.light_color = c; o.light_energy = e; o.omni_range = r; o.shadow_enabled = shadow
	o.light_volumetric_fog_energy = 1.5
	parent.add_child(o)
	return o

static func spot(parent: Node3D, pos: Vector3, look: Vector3, c: Color, e: float, ang: float, r: float) -> SpotLight3D:
	var s := SpotLight3D.new()
	s.position = pos
	parent.add_child(s)
	s.look_at(look, Vector3.UP if absf((look - pos).normalized().y) < 0.99 else Vector3.FORWARD)
	s.light_color = c; s.light_energy = e; s.spot_angle = ang; s.spot_range = r; s.shadow_enabled = true
	s.light_volumetric_fog_energy = 2.5
	return s
