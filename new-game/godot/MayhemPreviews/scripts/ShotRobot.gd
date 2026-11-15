## HQ still: Mech Mayhem arena, mid-exchange.
extends Node3D
signal finished
var crowd: Array = []
var fighters: Array = []
var cam: Camera3D
var red: Actor
var blue: Actor
func setup(_d: bool) -> void:
	arena()
	make_fighters()
	_pose_still()

func arena() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.01, 0.012, 0.03)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.2, 0.22, 0.35)
	e.ambient_light_energy = 0.35
	e.tonemap_mode = Environment.TONE_MAPPER_ACES
	e.tonemap_exposure = 1.15
	e.glow_enabled = true
	e.glow_intensity = 0.7
	e.glow_bloom = 0.05
	e.glow_hdr_threshold = 1.1
	Kit.hq(e, Color(0.4, 0.35, 0.7), 0.03)
	e.sdfgi_enabled = false
	env.environment = e
	add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-60, 25, 0)
	key.light_energy = 0.5
	key.light_color = Color(0.7, 0.8, 1.0)
	key.shadow_enabled = true
	add_child(key)
	cam = Camera3D.new()
	cam.fov = 34
	add_child(cam)
	cam.current = true
	cam.position = Vector3(-0.9, 0.75, 4.1)
	cam.look_at(Vector3(0.15, 1.05, 0), Vector3.UP)
	cam.rotate_object_local(Vector3.FORWARD, deg_to_rad(-3))
	Kit.dof(cam, 6.5)
	# polished black arena floor with a glowing ring
	var floor := Kit.tex(Color(0.05, 0.055, 0.075), 0.12, 0.6, 3.0, 0.15, 0.3, 4)
	Kit.part(self, "cyl", Vector3(9, 9, 0.3), floor, Vector3(0, -0.15, -1))
	Kit.part(self, "cyl", Vector3(40, 40, 0.2), Kit.pbr(Color(0.02, 0.02, 0.03), 0.3, 0.5), Vector3(0, -0.4, -1))
	var ring_c := Kit.pbr(Color.WHITE, 0, 0.3, Color(0.25, 0.8, 1.0), 4.0)
	var ring2 := Kit.pbr(Color.WHITE, 0, 0.3, Color(1.0, 0.25, 0.65), 4.0)
	var t := TorusMesh.new(); t.inner_radius = 8.85; t.outer_radius = 9.0; t.rings = 96
	var ring := MeshInstance3D.new(); ring.mesh = t; ring.material_override = ring_c; ring.position = Vector3(0, 0.01, -1); add_child(ring)
	var t2 := TorusMesh.new(); t2.inner_radius = 3.0; t2.outer_radius = 3.06; t2.rings = 64
	var ri2 := MeshInstance3D.new(); ri2.mesh = t2; ri2.material_override = ring2; ri2.position = Vector3(0, 0.01, -1); add_child(ri2)
	for i in 12:
		var a := i * TAU / 12.0
		Kit.part(self, "box", Vector3(0.05, 0.012, 5.8), ring_c if i % 2 else ring2, Vector3(cos(a) * 6.0, 0.006, -1 + sin(a) * 6.0), Vector3(0, -a * 180 / PI + 90, 0))
	# tiered stands in a ring, packed with a cheering robot crowd
	var stand := Kit.tex(Color(0.12, 0.13, 0.18), 0.5, 0.6, 2.0, 0.3, 0.2, 2)
	for tier in 4:
		var r := 10.6 + tier * 1.4
		for k in 44:
			var ang := deg_to_rad(-178 + k * 4.0)
			var seg := Kit.part(self, "box", Vector3(1.05, 0.9, 1.4), stand, Vector3(cos(ang) * r, 0.45 + tier * 0.9, -1 + sin(ang) * r))
			seg.rotation.y = -ang
			if k % 2 == 0:
				var lip := Kit.part(self, "box", Vector3(1.0, 0.04, 0.05), ring_c if tier % 2 else ring2, Vector3(cos(ang) * (r - 0.7), 0.91 + tier * 0.9, -1 + sin(ang) * (r - 0.7)))
				lip.rotation.y = -ang + PI / 2
	var cols := [Color(0.25, 0.8, 1.0), Color(1, 0.3, 0.65), Color(1, 0.75, 0.2), Color(0.6, 0.4, 1)]
	for tier in 3:
		for k in 26:
			var ang := deg_to_rad(-160 + k * 5.4 + tier * 2.0)
			var rr := 10.6 + tier * 1.4 + 0.1
			var a := Actor.new(); add_child(a)
			var c: Color = cols[(k + tier) % 4]
			a.setup(Kit.pbr(Color(0.04, 0.045, 0.06), 0.8, 0.35), Kit.pbr(Color(0.02, 0.02, 0.03), 0.5, 0.4, c, 2.2), randf_range(0.9, 1.05))
			a.position = Vector3(cos(ang) * rr, 0.9 + tier * 0.9, -1 + sin(ang) * rr)
			a.yaw_target = rad_to_deg(atan2(-a.position.x, -(a.position.z + 1))); a.yaw = a.yaw_target
			var an: String = ["f_victory", "b_celebrate", "f_taunt"][(k * 7 + tier) % 3]
			a.play(an, 1.0, 0.0, true)
			a.set_meta("seek", randf() * Kit.lengths[an])
			crowd.append(a)
	# giant holo screens and a ceiling truss with spotlights cutting through the haze
	for sx in [-1, 1]:
		var scr := Kit.part(self, "box", Vector3(6.0, 3.2, 0.12), Kit.pbr(Color(0, 0, 0), 0.2, 0.2, Color(0.05, 0.12, 0.3) if sx < 0 else Color(0.3, 0.05, 0.15), 1.4), Vector3(sx * 6.5, 7.2, -13), Vector3(0, -sx * 18, 0))
		var lab := Label3D.new(); lab.text = "BRAWLER-7" if sx < 0 else "AEGIS-X"; lab.font_size = 180; lab.outline_size = 0
		lab.modulate = Color(3, 1.2, 0.6) if sx < 0 else Color(0.6, 2.2, 3); lab.position = Vector3(0, 0.3, 0.08); scr.add_child(lab)
		var vs := Label3D.new(); vs.text = "SEMI-FINAL"; vs.font_size = 70; vs.modulate = Color(2, 2, 2); vs.position = Vector3(0, -0.9, 0.08); vs.outline_size = 0; scr.add_child(vs)
	var truss := Kit.pbr(Color(0.15, 0.16, 0.2), 0.9, 0.4)
	Kit.part(self, "box", Vector3(22, 0.25, 0.25), truss, Vector3(0, 9.5, -1))
	Kit.part(self, "box", Vector3(0.25, 0.25, 18), truss, Vector3(0, 9.5, -1))
	Kit.spot(self, Vector3(-4.5, 9.2, 1.5), Vector3(-0.4, 0, 0), Color(1, 0.35, 0.65), 22, 16, 18)
	Kit.spot(self, Vector3(4.5, 9.2, 1.5), Vector3(0.6, 0, 0), Color(0.3, 0.8, 1), 22, 16, 18)
	Kit.spot(self, Vector3(0, 9.4, -4), Vector3(0, 0, 0), Color(0.9, 0.9, 1), 14, 26, 18)
	for i in 6:
		Kit.spot(self, Vector3(-10 + i * 4, 9.4, -9), Vector3(-6 + i * 2.4, 0, -3), [Color(1, 0.3, 0.65), Color(0.3, 0.8, 1)][i % 2], 6, 9, 16)

func make_fighters() -> void:
	red = Actor.new(); add_child(red)
	red.setup(Kit.pbr(Color(0.7, 0.06, 0.04), 0.9, 0.22), Kit.pbr(Color(0.08, 0.08, 0.1), 0.9, 0.3, Color(1, 0.4, 0.08), 0.6))
	red.position = Vector3(-0.55, 0, 0); red.yaw_target = 80; red.yaw = 80
	blue = Actor.new(); add_child(blue)
	blue.setup(Kit.pbr(Color(0.82, 0.85, 0.9), 1.0, 0.15), Kit.pbr(Color(0.06, 0.07, 0.1), 0.9, 0.3, Color(0.2, 0.7, 1), 0.6))
	blue.position = Vector3(0.6, 0, 0.1); blue.yaw_target = -100; blue.yaw = -100
	var sword := Node3D.new(); blue.attach("mixamorig_RightHand", sword)
	Kit.part(sword, "box", Vector3(0.045, 1.0, 0.012), Kit.pbr(Color(0.7, 0.95, 1), 0.5, 0.1, Color(0.3, 0.9, 1), 3.5), Vector3(0, 0.6, 0.03))
	Kit.part(sword, "box", Vector3(0.22, 0.05, 0.06), Kit.pbr(Color(0.15, 0.15, 0.2), 1, 0.3), Vector3(0, 0.08, 0.03))
	var shield := Node3D.new(); blue.attach("mixamorig_LeftForeArm", shield)
	var sh := Kit.part(shield, "cyl", Vector3(0.26, 0.26, 0.05), Kit.pbr(Color(0.1, 0.25, 0.6), 1.0, 0.25), Vector3(0, 0.18, -0.08), Vector3(90, 0, 0))
	var rimm := TorusMesh.new(); rimm.inner_radius = 0.24; rimm.outer_radius = 0.27
	var rim := MeshInstance3D.new(); rim.mesh = rimm; rim.material_override = Kit.pbr(Color.WHITE, 0, 0.3, Color(0.3, 0.85, 1), 1.8); sh.add_child(rim)
	Kit.part(sh, "cyl", Vector3(0.08, 0.08, 0.07), Kit.pbr(Color.WHITE, 0, 0.3, Color(0.3, 0.85, 1), 1.5))
	for a in [red, blue]:
		var visor := Node3D.new(); a.attach("mixamorig_Head", visor)
		Kit.part(visor, "box", Vector3(0.18, 0.045, 0.06), Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.5, 0.15) if a == red else Color(0.3, 0.9, 1), 6.0), Vector3(0, 0.1, 0.1))
	fighters = [red, blue]

func _pose_still() -> void:
	red.play("f_round", 1.0, 0.0, true)
	blue.play("s_block", 1.0, 0.0, true)
	await get_tree().process_frame
	await get_tree().process_frame
	red.ap.seek(Kit.lengths["f_round"] * 0.42, true); red.ap.pause()
	blue.ap.seek(Kit.lengths["s_block"] * 0.5, true); blue.ap.pause()
	for a in crowd:
		a.ap.seek(a.get_meta("seek"), true); a.ap.pause()
	# impact: sparks + flash where the shin meets the shield
	var hit := (red.bone_pos("mixamorig_RightFoot") + blue.bone_pos("mixamorig_LeftHand")) * 0.5
	Kit.sparks(self, hit, Color(1, 0.75, 0.3), 70, 4.5, 0.35, 0.05)
	Kit.sparks(self, hit, Color(0.4, 0.9, 1.0), 40, 3.5, 0.3, 0.04)
	var fl := OmniLight3D.new(); fl.position = hit; fl.light_color = Color(1, 0.8, 0.5); fl.light_energy = 2.5; fl.omni_range = 2.2; add_child(fl)
	var flash := Kit.part(self, "sphere", Vector3(0.08, 0, 0), Kit.pbr(Color.WHITE, 0, 0.2, Color(1, 0.95, 0.8), 3.0), hit)
	var sw := TorusMesh.new(); sw.inner_radius = 0.22; sw.outer_radius = 0.25
	var shock := MeshInstance3D.new(); shock.mesh = sw; shock.material_override = Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.85, 0.5), 2.0); shock.position = hit; shock.rotation_degrees = Vector3(0, 0, 90); add_child(shock)
