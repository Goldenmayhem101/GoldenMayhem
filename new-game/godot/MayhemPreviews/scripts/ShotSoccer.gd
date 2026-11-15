## HQ still: Brawl Ball, a crunching slide tackle in front of a packed stand.
extends Node3D
signal finished
var crowd: Array = []
func setup(_d: bool) -> void:
	var env := WorldEnvironment.new(); var e := Environment.new()
	var sky := Sky.new(); var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.18, 0.4, 0.82); sm.sky_horizon_color = Color(0.68, 0.8, 0.95); sm.ground_horizon_color = Color(0.55, 0.62, 0.55); sm.sun_angle_max = 30
	sky.sky_material = sm; e.sky = sky; e.background_mode = Environment.BG_SKY
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; e.ambient_light_energy = 0.7
	e.tonemap_mode = Environment.TONE_MAPPER_ACES; e.tonemap_exposure = 0.95
	e.glow_enabled = true; e.glow_intensity = 0.4; e.glow_hdr_threshold = 1.3
	Kit.hq(e, Color(0.9, 0.92, 1.0), 0.004)
	env.environment = e; add_child(env)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-42, 35, 0); sun.light_energy = 1.6; sun.light_color = Color(1, 0.95, 0.85); sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 40; add_child(sun)
	var cam := Camera3D.new(); cam.fov = 40; add_child(cam); cam.current = true
	cam.position = Vector3(-2.3, 0.9, 3.6)
	cam.look_at(Vector3(0.6, 0.75, -0.4), Vector3.UP)
	Kit.dof(cam, 9.0)
	# grass with mowing stripes
	for i in 16:
		var g := Kit.tex(Color(0.11, 0.3, 0.09) if i % 2 == 0 else Color(0.14, 0.36, 0.11), 0.9, 0.0, 40.0, 0.5, 0.25, 30 + i % 2)
		Kit.part(self, "box", Vector3(2.0, 0.1, 30), g, Vector3(-16 + i * 2.0, -0.05, -6))
	var white := Kit.pbr(Color(0.95, 0.95, 0.92), 0, 0.7)
	Kit.part(self, "box", Vector3(32, 0.012, 0.1), white, Vector3(0, 0.006, -3.4))
	Kit.part(self, "box", Vector3(0.1, 0.012, 9), white, Vector3(4.6, 0.006, -3))
	Kit.part(self, "box", Vector3(0.1, 0.012, 9), white, Vector3(6.4, 0.006, -3))
	# goal with net
	var post := Kit.pbr(Color(0.97, 0.97, 0.97), 0.3, 0.25)
	for z in [-3.0, 0.6]:
		Kit.part(self, "cyl", Vector3(0.06, 0.06, 2.3), post, Vector3(6.5, 1.15, z))
	Kit.part(self, "cyl", Vector3(0.06, 0.06, 3.7), post, Vector3(6.5, 2.3, -1.2), Vector3(90, 0, 0))
	var net := StandardMaterial3D.new(); net.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; net.albedo_color = Color(1, 1, 1, 0.22); net.cull_mode = BaseMaterial3D.CULL_DISABLED
	Kit.part(self, "box", Vector3(0.02, 2.3, 3.7), net, Vector3(7.7, 1.15, -1.2))
	Kit.part(self, "box", Vector3(1.2, 0.02, 3.7), net, Vector3(7.1, 2.3, -1.2))
	# advertising boards
	var ads := [["GOLDENMAYHEM", Color(0.95, 0.72, 0.12)], ["BRAWL BALL", Color(0.15, 0.2, 0.35)], ["MAYHEM CUP", Color(0.85, 0.2, 0.18)], ["GOLDENMAYHEM", Color(0.2, 0.5, 0.9)]]
	for i in 10:
		var ad = ads[i % 4]
		var board := Kit.part(self, "box", Vector3(3.0, 0.75, 0.15), Kit.pbr(ad[1], 0.1, 0.35), Vector3(-14 + i * 3.05, 0.38, -7.6))
		var l := Label3D.new(); l.text = ad[0]; l.font_size = 64; l.outline_size = 0; l.modulate = Color(1, 1, 1) if ad[1].get_luminance() < 0.5 else Color(0.08, 0.08, 0.1); l.position = Vector3(0, 0, 0.08); board.add_child(l)
	# stands with a roof, packed with a cheering crowd in team colours
	var concrete := Kit.tex(Color(0.5, 0.5, 0.52), 0.85, 0.0, 10.0, 0.4, 0.15, 5)
	for row in 5:
		Kit.part(self, "box", Vector3(40, 0.55, 1.15), concrete, Vector3(0, 0.27 + row * 0.62, -9.0 - row * 1.15))
		Kit.part(self, "box", Vector3(40, 0.12, 0.4), Kit.pbr(Color(0.75, 0.1, 0.1) if row % 2 else Color(0.1, 0.25, 0.7), 0.1, 0.4), Vector3(0, 0.6 + row * 0.62, -8.75 - row * 1.15))
	var roof := Kit.part(self, "box", Vector3(40, 0.2, 8), Kit.pbr(Color(0.85, 0.86, 0.9), 0.6, 0.3), Vector3(0, 6.2, -12.5), Vector3(-8, 0, 0))
	for i in 6:
		Kit.part(self, "cyl", Vector3(0.12, 0.12, 6.0), Kit.pbr(Color(0.8, 0.8, 0.85), 0.7, 0.3), Vector3(-15 + i * 6, 3.0, -15.5))
	var team_cols := [Color(0.85, 0.1, 0.08), Color(0.85, 0.1, 0.08), Color(0.1, 0.28, 0.85), Color(0.1, 0.28, 0.85), Color(0.95, 0.95, 0.95), Color(0.95, 0.75, 0.1)]
	for row in 5:
		crowd += Kit.crowd(self, Vector3(-11.5, 0.55 + row * 0.62, -9.1 - row * 1.15), 1, 30, Vector2(0.78, 1.15), 0.0, team_cols, 0.0, ["f_victory", "b_celebrate", "f_taunt", "b_celebrate"])
	# players: red slides in, blue is sent flying, ball pops loose
	var redm := Kit.pbr(Color(0.75, 0.08, 0.06), 0.05, 0.42); var bluem := Kit.pbr(Color(0.08, 0.24, 0.8), 0.05, 0.42)
	var shorts := Kit.pbr(Color(0.95, 0.95, 0.95), 0.0, 0.55)
	var t1 := Actor.new(); add_child(t1); t1.setup(redm, shorts); t1.position = Vector3(-0.4, 0, 0); t1.yaw_target = 75; t1.yaw = 75; t1.play("b_tackle", 1, 0, true)
	var v := Actor.new(); add_child(v); v.setup(bluem, shorts); v.position = Vector3(0.75, 0, -0.1); v.yaw_target = -95; v.yaw = -95; v.play("b_trip", 1, 0, true)
	var m2 := Actor.new(); add_child(m2); m2.setup(bluem, shorts); m2.position = Vector3(3.0, 0, -2.4); m2.yaw_target = -120; m2.yaw = -120; m2.play("b_jog", 1, 0, true)
	var m3 := Actor.new(); add_child(m3); m3.setup(redm, shorts); m3.position = Vector3(-2.6, 0, -2.8); m3.yaw_target = 60; m3.yaw = 60; m3.play("b_jog", 1, 0, true)
	var gk := Actor.new(); add_child(gk); gk.setup(Kit.pbr(Color(0.15, 0.75, 0.3), 0.05, 0.45), Kit.pbr(Color(0.08, 0.08, 0.08), 0, 0.6)); gk.position = Vector3(6.0, 0, -1.2); gk.yaw_target = -90; gk.yaw = -90; gk.play("b_gkidle", 1, 0, true)
	var ball := Kit.part(self, "sphere", Vector3(0.11, 0, 0), Kit.pbr(Color(0.97, 0.97, 0.95), 0, 0.35), Vector3(1.15, 0.55, 0.35))
	var dirs := [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 1, 0), Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 1, 1), Vector3(-1, -1, 1), Vector3(1, -1, -1), Vector3(-1, 1, -1), Vector3(1, 1, -1), Vector3(-1, -1, -1)]
	for d in dirs:
		var pt := Kit.part(ball, "cyl", Vector3(0.028, 0.028, 0.01), Kit.pbr(Color(0.05, 0.05, 0.05), 0, 0.4), d.normalized() * 0.105)
		pt.look_at_from_position(d.normalized() * 0.105, d.normalized() * 0.3, Vector3.UP if absf(d.normalized().y) < 0.9 else Vector3.RIGHT)
		pt.rotate_object_local(Vector3.RIGHT, PI / 2)
	# turf spray from the slide
	var spray := GPUParticles3D.new(); spray.amount = 45; spray.lifetime = 0.6; spray.preprocess = 0.25; spray.explosiveness = 0.6
	var pm := ParticleProcessMaterial.new(); pm.direction = Vector3(-0.4, 1, 0.3); pm.spread = 35; pm.initial_velocity_min = 1.5; pm.initial_velocity_max = 3.2; pm.gravity = Vector3(0, -9, 0)
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX; pm.emission_box_extents = Vector3(0.25, 0.02, 0.15)
	spray.process_material = pm
	var bm := BoxMesh.new(); bm.size = Vector3(0.016, 0.012, 0.016); bm.material = Kit.pbr(Color(0.2, 0.32, 0.12), 0, 0.9); spray.draw_pass_1 = bm
	spray.position = Vector3(0.0, 0.05, 0.05); add_child(spray)
	await get_tree().process_frame
	await get_tree().process_frame
	t1.ap.seek(Kit.lengths["b_tackle"] * 0.32, true); t1.ap.pause()
	v.ap.seek(Kit.lengths["b_trip"] * 0.28, true); v.ap.pause()
	m2.ap.seek(0.3, true); m2.ap.pause(); m3.ap.seek(0.1, true); m3.ap.pause()
	Kit.freeze(crowd)
