## HQ still: Dead Zone, a soldier holding a foggy, rain-slick street at night.
extends Node3D
signal finished
var actors: Array = []
func setup(_d: bool) -> void:
	var env := WorldEnvironment.new(); var e := Environment.new()
	e.background_mode = Environment.BG_COLOR; e.background_color = Color(0.015, 0.02, 0.04)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color = Color(0.25, 0.3, 0.45); e.ambient_light_energy = 0.35
	e.tonemap_mode = Environment.TONE_MAPPER_ACES; e.tonemap_exposure = 1.2
	e.glow_enabled = true; e.glow_intensity = 0.7; e.glow_hdr_threshold = 1.1
	Kit.hq(e, Color(0.55, 0.6, 0.75), 0.05)
	env.environment = e; add_child(env)
	var moon := DirectionalLight3D.new(); moon.rotation_degrees = Vector3(-30, -50, 0); moon.light_color = Color(0.5, 0.6, 1.0); moon.light_energy = 0.5; moon.shadow_enabled = true; add_child(moon)
	var cam := Camera3D.new(); cam.fov = 42; add_child(cam); cam.current = true
	cam.position = Vector3(-3.1, 1.35, 2.9)
	cam.look_at(Vector3(0.7, 1.15, -0.5), Vector3.UP)
	Kit.dof(cam, 9.0)
	# wet asphalt: dark, very smooth so the lights reflect like puddles
	var asphalt := Kit.tex(Color(0.07, 0.07, 0.08), 0.08, 0.0, 6.0, 0.6, 0.35, 7)
	Kit.part(self, "box", Vector3(70, 1, 24), asphalt, Vector3(0, -0.5, -3))
	for i in range(-6, 9):
		Kit.part(self, "box", Vector3(1.2, 0.005, 0.12), Kit.pbr(Color(0.75, 0.62, 0.25), 0, 0.5), Vector3(i * 2.6, 0.003, -1.2))
	var curb := Kit.tex(Color(0.3, 0.3, 0.32), 0.85, 0.0, 10.0, 1.0, 0.3, 2)
	Kit.part(self, "box", Vector3(70, 0.22, 3.2), curb, Vector3(0, 0.11, -4.8))
	# brick / concrete buildings with lit and broken windows
	var r := RandomNumberGenerator.new(); r.seed = 3
	var x := -16.0
	while x < 22.0:
		var w := r.randf_range(3.5, 6.5); var h := r.randf_range(7, 14)
		var wall := Kit.tex(Color(0.28, 0.2, 0.17).lerp(Color(0.25, 0.25, 0.27), r.randf()), 0.9, 0.0, 14.0, 1.4, 0.3, r.randi())
		var b := Kit.part(self, "box", Vector3(w, h, 3), wall, Vector3(x + w * 0.5, h * 0.5, -7.9))
		for wy in range(int(h / 1.6) - 1):
			for wx in range(int(w / 1.3)):
				var lit := r.randf() < 0.12
				var wp := Vector3(-w * 0.5 + 0.75 + wx * 1.3, -h * 0.5 + 1.6 + wy * 1.6, 1.52)
				Kit.part(b, "box", Vector3(0.62, 0.9, 0.06), Kit.pbr(Color(0.02, 0.02, 0.03), 0.4, 0.1, Color(1, 0.62, 0.3), 2.5 if lit else 0.0), wp)
				Kit.part(b, "box", Vector3(0.72, 0.06, 0.12), Kit.pbr(Color(0.2, 0.2, 0.2), 0, 0.8), wp + Vector3(0, -0.48, 0.02))
		x += w + 0.3
	# street lamps with volumetric cones
	for lx in [-1.5, 6.5, 14.0]:
		var pole := Kit.pbr(Color(0.12, 0.13, 0.14), 0.8, 0.4)
		Kit.part(self, "cyl", Vector3(0.06, 0.08, 5.2), pole, Vector3(lx, 2.6, -3.6))
		Kit.part(self, "box", Vector3(0.9, 0.08, 0.12), pole, Vector3(lx + 0.4, 5.15, -3.6))
		Kit.part(self, "box", Vector3(0.5, 0.06, 0.24), Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.72, 0.4), 6.0), Vector3(lx + 0.7, 5.08, -3.6))
		Kit.spot(self, Vector3(lx + 0.7, 5.0, -3.6), Vector3(lx + 1.2, 0, -2.4), Color(1, 0.7, 0.4), 12, 38, 10)
	# wrecked car, on fire, with smoke and embers
	var paint := Kit.pbr(Color(0.25, 0.05, 0.04), 0.6, 0.45)
	var car := Kit.part(self, "box", Vector3(3.5, 0.85, 1.75), paint, Vector3(5.6, 0.62, -2.6), Vector3(0, 18, 7))
	Kit.part(car, "box", Vector3(1.9, 0.65, 1.6), paint, Vector3(-0.2, 0.72, 0))
	Kit.part(car, "box", Vector3(1.8, 0.55, 1.62), Kit.pbr(Color(0.02, 0.02, 0.03), 0.5, 0.1), Vector3(-0.2, 0.74, 0))
	for wx in [-1.2, 1.2]:
		Kit.part(car, "cyl", Vector3(0.36, 0.36, 1.85), Kit.pbr(Color(0.03, 0.03, 0.03), 0, 0.9), Vector3(wx, -0.45, 0), Vector3(90, 0, 0))
	_fire(Vector3(5.4, 1.4, -2.6))
	var fire := OmniLight3D.new(); fire.position = Vector3(5.3, 1.9, -2.3); fire.light_color = Color(1, 0.45, 0.12); fire.light_energy = 7; fire.omni_range = 10; fire.shadow_enabled = true; fire.light_volumetric_fog_energy = 2.0; add_child(fire)
	# soldier
	var s := Actor.new(); add_child(s)
	s.setup(Kit.pbr(Color(0.2, 0.23, 0.13), 0.0, 0.7), Kit.pbr(Color(0.06, 0.055, 0.05), 0.4, 0.5))
	s.position = Vector3(-1.6, 0, 0.3); s.yaw_target = 80; s.yaw = 80
	var helm := Node3D.new(); s.attach("mixamorig_Head", helm)
	Kit.part(helm, "sphere", Vector3(0.145, 0, 0), Kit.pbr(Color(0.18, 0.2, 0.12), 0.1, 0.6), Vector3(0, 0.13, -0.01))
	Kit.part(helm, "box", Vector3(0.13, 0.035, 0.05), Kit.pbr(Color.WHITE, 0, 0.3, Color(0.3, 1, 0.45), 4.0), Vector3(0, 0.17, 0.115))
	s.play("r_aim", 1.0, 0.0, true)
	actors.append(s)
	# the horde
	var zs := []
	for z in [[Vector3(0.95, 0, 0.15), "z_run", 0.3], [Vector3(2.1, 0, -0.7), "z_walk", 0.6], [Vector3(3.3, 0, 0.6), "z_walk", 0.1], [Vector3(1.7, 0, 1.0), "z_crawl", 0.5], [Vector3(4.4, 0, -1.4), "z_walk", 0.85], [Vector3(5.6, 0, 0.2), "z_run", 0.7], [Vector3(7.2, 0, -0.6), "z_walk", 0.3]]:
		var a := Actor.new(); add_child(a)
		var skin := Kit.pbr(Color(0.16, 0.21, 0.13).lerp(Color(0.22, 0.19, 0.15), randf()), 0.0, 0.55)
		a.setup(skin, Kit.pbr(Color(0.22, 0.03, 0.02), 0.0, 0.35), randf_range(0.95, 1.05))
		a.position = z[0]; a.yaw_target = -100 + randf_range(-15, 15); a.yaw = a.yaw_target
		var eyes := Node3D.new(); a.attach("mixamorig_Head", eyes)
		for ex in [-0.04, 0.04]:
			Kit.part(eyes, "sphere", Vector3(0.018, 0, 0), Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.85, 0.2), 5.0), Vector3(ex, 0.1, 0.1))
		a.play(z[1], 1.0, 0.0, true)
		zs.append([a, z[1], z[2]])
	await get_tree().process_frame
	await get_tree().process_frame
	s.ap.pause()
	for z in zs:
		z[0].ap.seek(Kit.lengths[z[1]] * z[2], true); z[0].ap.pause()
	# rifle in the hands, muzzle flash, tracer, hit on the lead zombie
	var rh := s.bone_pos("mixamorig_RightHand"); var lh := s.bone_pos("mixamorig_LeftHand")
	var dir := (lh - rh).normalized().lerp(Vector3(1, 0, 0), 0.5).normalized()
	var rifle := Node3D.new(); add_child(rifle)
	rifle.global_transform = Transform3D(Basis.looking_at(-dir, Vector3.UP), rh)
	var gun := Kit.pbr(Color(0.08, 0.08, 0.09), 0.7, 0.35)
	Kit.part(rifle, "box", Vector3(0.06, 0.09, 0.62), gun, Vector3(0, 0, 0.18))
	Kit.part(rifle, "box", Vector3(0.045, 0.045, 0.32), gun, Vector3(0, 0.01, 0.6))
	Kit.part(rifle, "box", Vector3(0.05, 0.16, 0.06), gun, Vector3(0, -0.11, 0.05))
	Kit.part(rifle, "box", Vector3(0.05, 0.06, 0.18), gun, Vector3(0, 0.08, 0.15))
	var muzzle := rifle.global_transform * Vector3(0, 0.01, 0.8)
	var fl := Kit.part(self, "prism", Vector3(0.12, 0.25, 0.12), Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.75, 0.3), 6.0), muzzle)
	fl.look_at(muzzle + dir, Vector3.UP); fl.rotate_object_local(Vector3.RIGHT, -PI / 2)
	var ml := OmniLight3D.new(); ml.position = muzzle; ml.light_color = Color(1, 0.75, 0.35); ml.light_energy = 4; ml.omni_range = 4; add_child(ml)
	Kit.sparks(self, muzzle, Color(1, 0.8, 0.4), 25, 2.5, 0.2, 0.04)
	var target: Actor = zs[0][0]
	var hit := target.bone_pos("mixamorig_Spine2")
	var mid := (muzzle + hit) * 0.5
	var tr := Kit.part(self, "box", Vector3(0.012, 0.012, muzzle.distance_to(hit) * 0.8), Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.9, 0.55), 6.0), mid)
	tr.look_at(hit, Vector3.UP)
	Kit.sparks(self, hit, Color(0.4, 0.55, 0.12), 50, 3.0, 0.4, 0.06)

func _fire(at: Vector3) -> void:
	var p := GPUParticles3D.new()
	p.amount = 70; p.lifetime = 0.8; p.preprocess = 1.0
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0); pm.spread = 18; pm.initial_velocity_min = 1.0; pm.initial_velocity_max = 2.2
	pm.gravity = Vector3(0.3, 1.0, 0); pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX; pm.emission_box_extents = Vector3(0.9, 0.1, 0.5)
	pm.scale_min = 0.6; pm.scale_max = 1.4
	var cr := Curve.new(); cr.add_point(Vector2(0, 1)); cr.add_point(Vector2(1, 0.1)); var ct := CurveTexture.new(); ct.curve = cr; pm.scale_curve = ct
	var g := Gradient.new(); g.set_color(0, Color(1, 0.6, 0.2, 0.55)); g.add_point(0.4, Color(0.9, 0.3, 0.05, 0.4)); g.set_color(1, Color(0.3, 0.03, 0.01, 0.0)); var gt := GradientTexture1D.new(); gt.gradient = g; pm.color_ramp = gt
	p.process_material = pm
	var q := QuadMesh.new(); q.size = Vector2(0.28, 0.42)
	var m := StandardMaterial3D.new(); m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES; m.vertex_color_use_as_albedo = false; m.albedo_color = Color(1.0, 0.42, 0.1, 0.5); m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	var rt := GradientTexture2D.new(); var rg := Gradient.new(); rg.set_color(0, Color(1, 1, 1, 1)); rg.set_color(1, Color(1, 1, 1, 0)); rt.gradient = rg; rt.fill = GradientTexture2D.FILL_RADIAL; rt.fill_from = Vector2(0.5, 0.5); rt.fill_to = Vector2(1, 0.5)
	m.albedo_texture = rt
	q.material = m; p.draw_pass_1 = q; p.position = at; add_child(p)
	# smoke column
	var sm := GPUParticles3D.new(); sm.amount = 60; sm.lifetime = 4.0; sm.preprocess = 4.0
	var spm := ParticleProcessMaterial.new(); spm.direction = Vector3(0.2, 1, 0); spm.spread = 12; spm.initial_velocity_min = 0.6; spm.initial_velocity_max = 1.0; spm.gravity = Vector3(0.25, 0.2, 0)
	spm.scale_min = 1.0; spm.scale_max = 2.0
	var c2 := Curve.new(); c2.add_point(Vector2(0, 0.4)); c2.add_point(Vector2(1, 2.0)); var ct2 := CurveTexture.new(); ct2.curve = c2; spm.scale_curve = ct2
	sm.process_material = spm
	var q2 := QuadMesh.new(); q2.size = Vector2(1.0, 1.0)
	var m2 := StandardMaterial3D.new(); m2.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES; m2.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; m2.albedo_color = Color(0.08, 0.07, 0.07, 0.55); m2.albedo_texture = rt; m2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	q2.material = m2; sm.draw_pass_1 = q2; sm.position = at + Vector3(0, 0.8, 0); add_child(sm)
