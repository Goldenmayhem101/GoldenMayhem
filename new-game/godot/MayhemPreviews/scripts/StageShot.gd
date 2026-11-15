## Real-world stage stills: --demo=stage_tokyo | stage_egypt | stage_nyc
extends "res://scripts/RobotClip2.gd"

var stage := "tokyo"
var posed: Array = []
var crowd_all: Array = []
var env_e: Environment

func setup(_d: bool) -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--demo=stage_"):
			stage = a.replace("--demo=stage_", "")
	cam = Camera3D.new(); cam.fov = 40; add_child(cam); cam.current = true
	var env := WorldEnvironment.new(); env_e = Environment.new(); env.environment = env_e; add_child(env)
	env_e.tonemap_mode = Environment.TONE_MAPPER_ACES
	env_e.glow_enabled = true; env_e.glow_intensity = 0.6; env_e.glow_hdr_threshold = 1.1; env_e.glow_bloom = 0.03
	env_e.ssao_enabled = true; env_e.ssil_enabled = true; env_e.ssr_enabled = true
	match stage:
		"tokyo": _tokyo()
		"egypt": _egypt()
		"nyc": _nyc()
	make_fighters()
	_armor(red, Color(0.75, 0.08, 0.05), Color(1, 0.5, 0.15))
	_armor(blue, Color(0.82, 0.85, 0.9), Color(0.3, 0.85, 1.0))
	var stocky: Dictionary = load("res://scripts/ShapeCompare.gd").STOCKY.duplicate()
	stocky.erase("mixamorig_UpLeg")
	for a in [red, blue]:
		a.set_shape(stocky)
		for ba in a.sk.get_children():
			if ba is BoneAttachment3D and ba.bone_name != "mixamorig_Head":
				var sc: Vector3 = stocky.get(ba.bone_name, Vector3.ONE)
				for ch in ba.get_children():
					ch.scale = Vector3(1.0 / sc.x, 1.0 / sc.y, 1.0 / sc.z)
	red.position = Vector3(-0.8, 0, 0); red.yaw_target = 90; red.yaw = 90
	blue.position = Vector3(0.8, 0, 0); blue.yaw_target = -90; blue.yaw = -90
	fill = OmniLight3D.new(); fill.light_color = Color(0.9, 0.9, 1.0); fill.light_energy = 1.4; fill.omni_range = 10; add_child(fill)
	fill.position = cam.position + Vector3(0.5, 1.0, -0.5)
	await get_tree().process_frame
	for p in [[red, "Unarmed_Melee_Attack_Kick", 0.42], [blue, "Block", 0.5]]:
		var rt := Retarget.new(); add_child(rt); rt.setup(p[0])
		rt.play(p[1], 1.0); rt.weight = 1.0; rt.fade = 1.0
		rt.step(rt.sap.get_animation(p[1]).length * p[2]); rt.fade = 1.0; rt.step(0.0)
		posed.append([p[0], rt])
	for c in crowd_all:
		c.ap.seek(c.get_meta("seek"), true); c.ap.pause()
	var hit := (red.bone_pos("mixamorig_RightFoot") + blue.bone_pos("mixamorig_LeftHand")) * 0.5
	Kit.sparks(self, hit, Color(1, 0.75, 0.3), 70, 4.0, 0.35, 0.05)
	Kit.sparks(self, hit, Color(0.4, 0.9, 1.0), 40, 3.0, 0.3, 0.04)

func _process(_d: float) -> void:
	for p in posed:
		var a: Actor = p[0]
		a.ap.stop()
		(p[1] as Retarget).step(0.0)
		a.apply_shape()
		a.ground_lock()

func _physics_process(_d: float) -> void:
	pass

# ---------------------------------------------------------------- helpers
func _box(sz: Vector3, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	return Kit.part(self, "box", sz, mat, pos, rot)

func _sign(text: String, pos: Vector3, col: Color, size := 120, yaw := 0.0) -> void:
	var back := _box(Vector3(text.length() * size * 0.0062 + 0.4, size * 0.011, 0.12), Kit.pbr(Color(0.02, 0.02, 0.03), 0.4, 0.4), pos, Vector3(0, yaw, 0))
	var l := Label3D.new(); l.text = text; l.font_size = size; l.outline_size = 0; l.modulate = Color(col.r * 3, col.g * 3, col.b * 3)
	l.position = Vector3(0, 0, 0.07); back.add_child(l)
	var o := OmniLight3D.new(); o.light_color = col; o.light_energy = 2.0; o.omni_range = 5; o.position = Vector3(0, 0, 1.0); back.add_child(o)

func _tower(pos: Vector3, w: float, h: float, base: Color, lit: Color, chance := 0.35, seed_v := 1) -> void:
	var b := _box(Vector3(w, h, w), Kit.pbr(base, 0.3, 0.5), pos + Vector3(0, h * 0.5, 0))
	var r := RandomNumberGenerator.new(); r.seed = seed_v
	var rows := int(h / 0.75); var cols := int(w / 0.6)
	var on := Kit.pbr(Color(0.02, 0.02, 0.03), 0.3, 0.2, lit, 2.2)
	var off := Kit.pbr(Color(0.03, 0.04, 0.06), 0.6, 0.15)
	for yy in rows:
		for xx in cols:
			Kit.part(b, "box", Vector3(0.3, 0.42, 0.04), on if r.randf() < chance else off, Vector3(-w * 0.5 + 0.35 + xx * (w - 0.7) / maxf(cols - 1, 1), -h * 0.5 + 0.8 + yy * 0.75, w * 0.5 + 0.02))

func _crowd_row(origin: Vector3, n: int, step: float, yaw: float, cols: Array, dark := false) -> void:
	for k in n:
		var a := Actor.new(); add_child(a)
		var c: Color = cols[k % cols.size()]
		var skin := Kit.pbr(c, 0.2, 0.55) if not dark else Kit.pbr(Color(0.05, 0.05, 0.07), 0.7, 0.35)
		var j := Kit.pbr(Color(0.15, 0.15, 0.18), 0.5, 0.4, c, 1.5 if dark else 0.0)
		a.setup(skin, j, randf_range(0.92, 1.04))
		a.position = origin + Vector3(k * step + randf_range(-0.1, 0.1), 0, randf_range(-0.15, 0.15))
		a.yaw_target = yaw + randf_range(-25, 25); a.yaw = a.yaw_target
		var an: String = ["f_victory", "b_celebrate", "f_taunt", "b_celebrate"][randi() % 4]
		a.play(an, 1.0, 0.0, true); a.set_meta("seek", randf() * Kit.lengths[an])
		crowd_all.append(a)

# ---------------------------------------------------------------- shared landmark builders
func _p(kind: String, d: Vector3, m: Material, pos: Vector3, rot := Vector3.ZERO, parent: Node3D = null) -> MeshInstance3D:
	return Kit.part(parent if parent else self, kind, d, m, pos, rot)

func _cone(r0: float, r1: float, h: float, m: Material, pos: Vector3, segs := 24, parent: Node3D = null) -> MeshInstance3D:
	var cm := CylinderMesh.new(); cm.top_radius = r1; cm.bottom_radius = r0; cm.height = h; cm.radial_segments = segs; cm.rings = 1
	var mi := MeshInstance3D.new(); mi.mesh = cm; mi.material_override = m; mi.position = pos
	(parent if parent else self).add_child(mi)
	return mi

func _water(y: float, col: Color, size := 400.0) -> void:
	var w := Kit.pbr(col, 0.4, 0.04)
	var n := FastNoiseLite.new(); n.frequency = 0.06
	var nt := NoiseTexture2D.new(); nt.seamless = true; nt.as_normal_map = true; nt.bump_strength = 2.0; nt.noise = n; nt.width = 512; nt.height = 512
	w.normal_enabled = true; w.normal_texture = nt; w.uv1_scale = Vector3(60, 60, 60)
	_p("box", Vector3(size, 0.2, size), w, Vector3(0, y, -size * 0.45))

func _skyline(x0: float, x1: float, z0: float, z1: float, hmin: float, hmax: float, seed_v: int, lit: Color, chance: float) -> void:
	var r := RandomNumberGenerator.new(); r.seed = seed_v
	var x := x0
	while x < x1:
		var w := r.randf_range(2.5, 4.5)
		var h := r.randf_range(hmin, hmax)
		var z := r.randf_range(z0, z1)
		var base := Color(0.25, 0.27, 0.33).lerp(Color(0.5, 0.45, 0.42), r.randf())
		_tower(Vector3(x, 0, z), w, h, base, lit, chance, r.randi())
		if r.randf() < 0.5:   # setback crown
			_p("box", Vector3(w * 0.6, h * 0.12, w * 0.6), Kit.pbr(base.lightened(0.1), 0.4, 0.4), Vector3(x, h + h * 0.06, z))
		if r.randf() < 0.3:
			_p("cyl", Vector3(0.05, 0.08, 3.0), Kit.pbr(Color(0.6, 0.6, 0.65), 0.9, 0.3), Vector3(x, h + 1.5, z))
		x += w + r.randf_range(0.3, 1.2)

func _liberty(pos: Vector3, s: float) -> void:
	var root := Node3D.new(); root.position = pos; root.scale = Vector3.ONE * s; root.rotation_degrees.y = 25; add_child(root)
	var granite := Kit.pbr(Color(0.72, 0.68, 0.6), 0.0, 0.8)
	var copper := Kit.pbr(Color(0.42, 0.68, 0.58), 0.55, 0.45)
	# star fort + pedestal
	_cone(3.2, 3.2, 0.8, granite, Vector3(0, 0.4, 0), 11, root)
	_p("box", Vector3(2.4, 1.6, 2.4), granite, Vector3(0, 1.6, 0), Vector3.ZERO, root)
	_p("box", Vector3(1.9, 1.8, 1.9), granite, Vector3(0, 3.3, 0), Vector3.ZERO, root)
	_p("box", Vector3(2.1, 0.25, 2.1), granite, Vector3(0, 4.3, 0), Vector3.ZERO, root)
	# robed figure
	_cone(0.75, 0.42, 3.0, copper, Vector3(0, 5.95, 0), 16, root)
	_cone(0.45, 0.36, 1.0, copper, Vector3(0, 7.9, 0), 16, root)
	_p("sphere", Vector3(0.3, 0, 0), copper, Vector3(0, 8.7, 0), Vector3.ZERO, root)
	var crown := TorusMesh.new(); crown.inner_radius = 0.26; crown.outer_radius = 0.34
	var cr := MeshInstance3D.new(); cr.mesh = crown; cr.material_override = copper; cr.position = Vector3(0, 8.85, 0); root.add_child(cr)
	for k in 7:
		var ang := deg_to_rad(-80 + k * 26.0)
		var sp := _p("prism", Vector3(0.12, 0.55, 0.06), copper, Vector3(sin(ang) * 0.33, 9.1, cos(ang) * 0.33), Vector3(0, rad_to_deg(ang), 0), root)
		sp.rotate_object_local(Vector3.RIGHT, deg_to_rad(-25))
	# raised right arm + torch
	var arm := _p("cyl", Vector3(0.11, 0.14, 1.8), copper, Vector3(0.35, 9.2, 0), Vector3(0, 0, -12), root)
	_p("cyl", Vector3(0.16, 0.08, 0.35), Kit.pbr(Color(0.85, 0.7, 0.3), 0.9, 0.3), Vector3(0.55, 10.2, 0), Vector3.ZERO, root)
	var flame := _p("sphere", Vector3(0.18, 0, 0), Kit.pbr(Color(1, 0.8, 0.4), 0, 0.3, Color(1, 0.7, 0.25), 6.0), Vector3(0.55, 10.45, 0), Vector3.ZERO, root)
	flame.scale = Vector3(1, 1.5, 1)
	var fl := OmniLight3D.new(); fl.light_color = Color(1, 0.7, 0.3); fl.light_energy = 3; fl.omni_range = 6; fl.position = Vector3(0.55, 10.6, 0); root.add_child(fl)
	# left arm with tablet
	_p("cyl", Vector3(0.1, 0.12, 0.9), copper, Vector3(-0.4, 7.7, 0.15), Vector3(-30, 0, 20), root)
	_p("box", Vector3(0.35, 0.6, 0.1), copper, Vector3(-0.55, 7.5, 0.3), Vector3(-15, 10, 10), root)

func _brooklyn(pos: Vector3, length: float, s: float) -> void:
	var root := Node3D.new(); root.position = pos; root.scale = Vector3.ONE * s; root.rotation_degrees.y = -12; add_child(root)
	var stone := Kit.tex(Color(0.68, 0.58, 0.48), 0.85, 0.0, 6.0, 0.6, 0.2, 21)
	var dark := Kit.pbr(Color(0.08, 0.08, 0.1), 0, 0.9)
	var steel := Kit.pbr(Color(0.3, 0.3, 0.33), 0.8, 0.4)
	_p("box", Vector3(length, 0.5, 2.0), steel, Vector3(0, 4.0, 0), Vector3.ZERO, root)
	for tx in [-length * 0.25, length * 0.25]:
		_p("box", Vector3(2.0, 10.0, 2.6), stone, Vector3(tx, 5.0, 0), Vector3.ZERO, root)
		for zz in [-0.6, 0.6]:
			_p("box", Vector3(2.05, 3.2, 0.7), dark, Vector3(tx, 6.0, zz), Vector3.ZERO, root)
			_p("prism", Vector3(2.05, 0.8, 0.7), dark, Vector3(tx, 8.0, zz), Vector3.ZERO, root)
		_p("box", Vector3(2.4, 0.5, 3.0), stone, Vector3(tx, 10.2, 0), Vector3.ZERO, root)
	# suspension cables (parabolas made of short segments)
	var cab := Kit.pbr(Color(0.55, 0.55, 0.58), 0.8, 0.3)
	for zz in [-0.9, 0.9]:
		var pts: Array = []
		var n := 40
		for i in n + 1:
			var x := -length * 0.5 + length * float(i) / n
			var tw := length * 0.25
			var y: float
			if absf(x) <= tw:
				var u := x / tw
				y = 4.4 + 5.6 * u * u
			else:
				y = 10.0 - (absf(x) - tw) / (length * 0.25) * 5.6
			pts.append(Vector3(x, y, zz))
		for i in n:
			var a: Vector3 = pts[i]; var b: Vector3 = pts[i + 1]
			var seg := _p("cyl", Vector3(0.05, 0.05, a.distance_to(b)), cab, (a + b) * 0.5, Vector3.ZERO, root)
			seg.look_at(root.to_global(b), Vector3.UP); seg.rotate_object_local(Vector3.RIGHT, PI / 2)
			if i % 2 == 0:
				_p("cyl", Vector3(0.015, 0.015, a.y - 4.2), cab, Vector3(a.x, (a.y + 4.2) * 0.5, zz), Vector3.ZERO, root)

func _empire(pos: Vector3, s: float) -> void:
	var root := Node3D.new(); root.position = pos; root.scale = Vector3.ONE * s; add_child(root)
	var lime := Kit.pbr(Color(0.78, 0.74, 0.66), 0.2, 0.5)
	var lit := Kit.pbr(Color(0.05, 0.05, 0.06), 0.3, 0.2, Color(1, 0.85, 0.6), 1.6)
	var tiers := [[7.0, 12.0], [5.6, 14.0], [4.6, 6.0], [3.6, 4.0], [2.8, 3.0], [2.0, 2.0]]
	var y := 0.0
	for t in tiers:
		var b := _p("box", Vector3(t[0], t[1], t[0]), lime, Vector3(0, y + t[1] * 0.5, 0), Vector3.ZERO, root)
		for k in int(t[0] / 0.6):
			_p("box", Vector3(0.12, t[1] * 0.92, 0.04), lit, Vector3(-t[0] * 0.5 + 0.3 + k * 0.6, 0, t[0] * 0.5 + 0.02), Vector3.ZERO, b)
		y += t[1]
	_p("cyl", Vector3(0.7, 1.0, 3.0), lime, Vector3(0, y + 1.5, 0), Vector3.ZERO, root)
	_p("cyl", Vector3(0.12, 0.35, 5.0), Kit.pbr(Color(0.8, 0.8, 0.85), 0.9, 0.3), Vector3(0, y + 5.5, 0), Vector3.ZERO, root)
	_p("sphere", Vector3(0.3, 0, 0), Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.3, 0.3), 5.0), Vector3(0, y + 8.2, 0), Vector3.ZERO, root)

# ---------------------------------------------------------------- NEW YORK: harbour pier at sunset
func _nyc() -> void:
	var sky := Sky.new(); var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.18, 0.28, 0.6); sm.sky_horizon_color = Color(1.0, 0.62, 0.42); sm.ground_horizon_color = Color(0.4, 0.35, 0.4); sm.sun_angle_max = 20
	sky.sky_material = sm; env_e.sky = sky; env_e.background_mode = Environment.BG_SKY
	env_e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; env_e.ambient_light_energy = 0.8
	env_e.volumetric_fog_enabled = true; env_e.volumetric_fog_density = 0.004; env_e.volumetric_fog_albedo = Color(1, 0.8, 0.75)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-12, 35, 0); sun.light_color = Color(1, 0.68, 0.5); sun.light_energy = 1.6; sun.shadow_enabled = true; sun.directional_shadow_max_distance = 60; add_child(sun)
	cam.fov = 46
	cam.position = Vector3(-1.0, 1.35, 5.8); cam.look_at(Vector3(0.3, 1.6, -4))
	_water(-1.2, Color(0.12, 0.2, 0.3))
	# wooden pier deck with railings
	var wood := Kit.tex(Color(0.45, 0.32, 0.22), 0.8, 0.0, 20.0, 0.8, 0.25, 14)
	_p("box", Vector3(16, 0.4, 9), wood, Vector3(0, -0.2, -1))
	for i in 17: _p("box", Vector3(0.04, 0.02, 9), Kit.pbr(Color(0.2, 0.14, 0.1), 0, 0.9), Vector3(-8 + i, 0.01, -1))
	var rail := Kit.pbr(Color(0.15, 0.2, 0.18), 0.8, 0.4)
	_p("box", Vector3(16, 0.06, 0.06), rail, Vector3(0, 1.0, -5.4))
	for i in 17: _p("box", Vector3(0.06, 1.0, 0.06), rail, Vector3(-8 + i, 0.5, -5.4))
	# crowd on stands at both sides of the pier (keeps the view to the harbour open)
	for side in [-1, 1]:
		for row in 3:
			_p("box", Vector3(0.9, 0.4 + row * 0.4, 4.2), Kit.pbr(Color(0.25, 0.27, 0.32), 0.3, 0.5), Vector3(side * (6.0 + row * 0.9), (0.4 + row * 0.4) * 0.5, -2.5))
			_crowd_row(Vector3(side * (6.0 + row * 0.9) - 0.15, 0.4 + row * 0.4, -4.0), 5, 0.72, -90.0 * side, [Color(0.95, 0.75, 0.2), Color(0.2, 0.35, 0.75), Color(0.85, 0.2, 0.2), Color(0.95, 0.95, 0.95)])
	for i in crowd_all.size():
		var c: Actor = crowd_all[i]
		var sd := -1.0 if i < 15 else 1.0
		var rw := (i % 15) / 5
		c.position = Vector3(sd * (6.0 + rw * 0.9), 0.4 + rw * 0.4, -4.2 + (i % 5) * 0.8)
		c.yaw_target = -90.0 * sd + randf_range(-20, 20); c.yaw = c.yaw_target
	# the landmarks
	_liberty(Vector3(-11, -1.2, -38), 1.55)
	_skyline(2.0, 40.0, -48, -60, 10, 30, 5, Color(1, 0.85, 0.6), 0.25)
	_empire(Vector3(16, -1.2, -66), 2.1)
	_brooklyn(Vector3(28, -1.2, -34), 48.0, 0.9)
	var island := Kit.pbr(Color(0.3, 0.38, 0.25), 0, 0.9)
	_cone(9, 7, 1.0, island, Vector3(-11, -1.4, -38), 24)

# ---------------------------------------------------------------- TOKYO: shrine plaza at dusk, Fuji and the tower
func _tokyo() -> void:
	var sky := Sky.new(); var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.2, 0.18, 0.45); sm.sky_horizon_color = Color(1.0, 0.55, 0.6); sm.ground_horizon_color = Color(0.4, 0.3, 0.4)
	sky.sky_material = sm; env_e.sky = sky; env_e.background_mode = Environment.BG_SKY
	env_e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; env_e.ambient_light_energy = 0.75
	env_e.volumetric_fog_enabled = true; env_e.volumetric_fog_density = 0.005; env_e.volumetric_fog_albedo = Color(1, 0.75, 0.85)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-10, -40, 0); sun.light_color = Color(1, 0.6, 0.6); sun.light_energy = 1.3; sun.shadow_enabled = true; sun.directional_shadow_max_distance = 60; add_child(sun)
	cam.fov = 46
	cam.position = Vector3(-0.8, 1.35, 5.8); cam.look_at(Vector3(0.3, 1.8, -4))
	# stone plaza
	_p("box", Vector3(18, 0.4, 10), Kit.tex(Color(0.6, 0.58, 0.55), 0.7, 0.0, 10.0, 0.5, 0.2, 31), Vector3(0, -0.2, -1))
	# torii gate framing the background
	var verm := Kit.pbr(Color(0.85, 0.18, 0.1), 0.1, 0.5)
	var blk := Kit.pbr(Color(0.08, 0.08, 0.08), 0.1, 0.6)
	for x in [-3.2, 3.2]:
		_p("cyl", Vector3(0.28, 0.32, 6.2), verm, Vector3(x, 3.1, -6.2))
		_p("cyl", Vector3(0.36, 0.36, 0.5), blk, Vector3(x, 0.25, -6.2))
	_p("box", Vector3(9.0, 0.45, 0.6), blk, Vector3(0, 6.6, -6.2))
	_p("box", Vector3(8.4, 0.35, 0.5), verm, Vector3(0, 6.15, -6.2))
	_p("box", Vector3(7.6, 0.3, 0.4), verm, Vector3(0, 5.2, -6.2))
	# stone lanterns + paper lanterns with warm light
	for x in [-6.0, -4.6, 4.6, 6.0]:
		_p("box", Vector3(0.5, 1.2, 0.5), Kit.pbr(Color(0.55, 0.53, 0.5), 0, 0.9), Vector3(x, 0.6, -4.8))
		_p("box", Vector3(0.5, 0.4, 0.5), Kit.pbr(Color(1, 0.85, 0.6), 0, 0.5, Color(1, 0.7, 0.35), 3.0), Vector3(x, 1.4, -4.8))
		_p("prism", Vector3(0.8, 0.35, 0.8), Kit.pbr(Color(0.45, 0.43, 0.4), 0, 0.9), Vector3(x, 1.8, -4.8))
	for x in [-2.0, 0.0, 2.0]:
		var pl := _p("sphere", Vector3(0.28, 0, 0), Kit.pbr(Color(1, 0.4, 0.3), 0, 0.5, Color(1, 0.45, 0.25), 3.0), Vector3(x, 4.6, -6.2))
		pl.scale = Vector3(1, 1.3, 1)
	# cherry blossom trees with falling petals
	var trunk := Kit.pbr(Color(0.25, 0.17, 0.14), 0, 0.9)
	var bloom := Kit.pbr(Color(1, 0.72, 0.82), 0, 0.7)
	for t in [Vector3(-7.5, 0, -6), Vector3(7.5, 0, -6.5), Vector3(-10, 0, -9), Vector3(10.5, 0, -9)]:
		_p("cyl", Vector3(0.18, 0.3, 3.0), trunk, t + Vector3(0, 1.5, 0))
		for k in 9:
			var b := _p("sphere", Vector3(0.9, 0, 0), bloom, t + Vector3(randf_range(-1.4, 1.4), 3.2 + randf_range(-0.3, 0.9), randf_range(-1.0, 1.0)))
			b.scale = Vector3.ONE * randf_range(0.8, 1.3)
	var pet := GPUParticles3D.new(); pet.amount = 400; pet.lifetime = 4.0; pet.preprocess = 4.0
	var pm := ParticleProcessMaterial.new(); pm.direction = Vector3(0.4, -1, 0); pm.spread = 30; pm.initial_velocity_min = 0.4; pm.initial_velocity_max = 0.9; pm.gravity = Vector3(0, -0.3, 0)
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX; pm.emission_box_extents = Vector3(10, 1, 5); pm.angular_velocity_min = -200; pm.angular_velocity_max = 200
	pet.process_material = pm
	var pq := QuadMesh.new(); pq.size = Vector2(0.06, 0.04)
	var pmat := StandardMaterial3D.new(); pmat.albedo_color = Color(1, 0.75, 0.85); pmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	pq.material = pmat; pet.draw_pass_1 = pq; pet.position = Vector3(0, 5, -2); add_child(pet)
	# crowd on both sides
	for side in [-1, 1]:
		for row in 2:
			_crowd_row(Vector3(side * (5.6 + row * 0.8) - 1.5, 0, -3.6 + row * 0.0), 4, 0.75, -90.0 * side, [Color(0.95, 0.3, 0.45), Color(0.95, 0.95, 0.95), Color(0.25, 0.3, 0.6), Color(0.95, 0.75, 0.2)])
	var i := 0
	for c in crowd_all:
		var side := -1.0 if i < 8 else 1.0
		c.position = Vector3(side * (5.4 + (i % 8) / 4 * 0.8), 0, -4.4 + (i % 4) * 0.8)
		c.yaw_target = -90.0 * side + randf_range(-20, 20); c.yaw = c.yaw_target
		i += 1
	# the city below, Tokyo Tower, and Mount Fuji
	_skyline(-40, 40, -45, -55, 4, 11, 9, Color(1, 0.85, 0.65), 0.3)
	var tw := Node3D.new(); tw.position = Vector3(19, 0, -58); tw.scale = Vector3.ONE * 1.25; add_child(tw)
	var orange := Kit.pbr(Color(0.95, 0.35, 0.12), 0.4, 0.45, Color(1, 0.35, 0.1), 0.6)
	var white := Kit.pbr(Color(0.95, 0.95, 0.95), 0.3, 0.5)
	var lvls := 12
	for k in lvls:
		var w0 := 9.0 * pow(1.0 - float(k) / lvls, 1.6) + 0.6
		var w1 := 9.0 * pow(1.0 - float(k + 1) / lvls, 1.6) + 0.6
		var y0 := k * 3.0
		var m := white if (k % 4 == 3) else orange
		for sx in [-1, 1]:
			for sz in [-1, 1]:
				var a := Vector3(sx * w0 * 0.5, y0, sz * w0 * 0.5); var b := Vector3(sx * w1 * 0.5, y0 + 3.0, sz * w1 * 0.5)
				var leg := _p("box", Vector3(0.25, a.distance_to(b), 0.25), m, (a + b) * 0.5, Vector3.ZERO, tw)
				leg.look_at(tw.to_global(b), Vector3.FORWARD); leg.rotate_object_local(Vector3.RIGHT, PI / 2)
		_p("box", Vector3(w1 + 0.3, 0.2, w1 + 0.3), m, Vector3(0, y0 + 3.0, 0), Vector3.ZERO, tw)
		if k % 2 == 0:
			for d in 2:
				var x := _p("box", Vector3(w0 * 1.3, 0.12, 0.12), m, Vector3(0, y0 + 1.5, (w0 + w1) * 0.25 * (1 if d == 0 else -1)), Vector3(0, 0, 40), tw)
	_p("box", Vector3(3.0, 1.2, 3.0), white, Vector3(0, 13.5, 0), Vector3.ZERO, tw)
	_p("box", Vector3(1.6, 0.8, 1.6), white, Vector3(0, 25.5, 0), Vector3.ZERO, tw)
	_p("cyl", Vector3(0.1, 0.3, 8.0), orange, Vector3(0, 40, 0), Vector3.ZERO, tw)
	var fuji := Node3D.new(); fuji.position = Vector3(-38, -2, -170); fuji.scale = Vector3(1.3, 1.7, 1.3); add_child(fuji)
	_cone(70, 6, 40, Kit.pbr(Color(0.38, 0.38, 0.55), 0, 0.9), Vector3(0, 20, 0), 48, fuji)
	_cone(22.5, 6, 13, Kit.pbr(Color(0.98, 0.97, 1.0), 0, 0.6), Vector3(0, 33.6, 0), 48, fuji)

# ---------------------------------------------------------------- EGYPT: Giza at sunset, Sphinx and pyramids
func _egypt() -> void:
	var sky := Sky.new(); var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color(0.22, 0.32, 0.62); sm.sky_horizon_color = Color(1.0, 0.65, 0.35); sm.ground_horizon_color = Color(0.85, 0.6, 0.4); sm.sun_angle_max = 25
	sky.sky_material = sm; env_e.sky = sky; env_e.background_mode = Environment.BG_SKY
	env_e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY; env_e.ambient_light_energy = 0.7
	env_e.volumetric_fog_enabled = true; env_e.volumetric_fog_density = 0.004; env_e.volumetric_fog_albedo = Color(1, 0.78, 0.55)
	var sun := DirectionalLight3D.new(); sun.rotation_degrees = Vector3(-14, -50, 0); sun.light_color = Color(1, 0.72, 0.45); sun.light_energy = 1.8; sun.shadow_enabled = true; sun.directional_shadow_max_distance = 80; add_child(sun)
	cam.fov = 46
	cam.position = Vector3(-0.8, 1.3, 5.8); cam.look_at(Vector3(0.3, 1.9, -4))
	var sand := Kit.tex(Color(0.86, 0.67, 0.43), 0.9, 0.0, 5.0, 0.8, 0.2, 9)
	_p("box", Vector3(400, 1, 400), sand, Vector3(0, -0.52, -150))
	var stone := Kit.tex(Color(0.8, 0.68, 0.5), 0.85, 0.0, 12.0, 1.0, 0.25, 4)
	_p("box", Vector3(14, 0.3, 8), stone, Vector3(0, -0.12, -1))
	# columns with hieroglyph bands either side, crowd on stone steps at the sides
	var band := Kit.pbr(Color(0.2, 0.35, 0.6), 0, 0.7)
	var gold := Kit.pbr(Color(0.9, 0.7, 0.3), 0.8, 0.35)
	for x in [-6.5, 6.5]:
		_p("cyl", Vector3(0.55, 0.6, 5.0), stone, Vector3(x, 2.5, -4.6))
		_p("cyl", Vector3(0.62, 0.62, 0.3), band, Vector3(x, 4.0, -4.6))
		_p("cyl", Vector3(0.8, 0.55, 0.6), gold, Vector3(x, 5.2, -4.6))
	for side in [-1, 1]:
		for row in 3:
			_p("box", Vector3(1.0, 0.5 + row * 0.5, 6.0), stone, Vector3(side * (5.6 + row * 1.0), (0.5 + row * 0.5) * 0.5, -2.2))
	var i := 0
	for side in [-1, 1]:
		for row in 3:
			for k in 6:
				var a := Actor.new(); add_child(a)
				var c: Color = [Color(0.95, 0.88, 0.7), Color(0.85, 0.2, 0.15), Color(0.2, 0.45, 0.85), Color(0.95, 0.7, 0.2)][(k + row) % 4]
				a.setup(Kit.pbr(c, 0.2, 0.55), Kit.pbr(Color(0.15, 0.15, 0.18), 0.5, 0.4), randf_range(0.92, 1.04))
				a.position = Vector3(side * (5.6 + row * 1.0), 0.5 + row * 0.5, -4.6 + k * 0.85)
				a.yaw_target = -90.0 * side + randf_range(-20, 20); a.yaw = a.yaw_target
				var an: String = ["f_victory", "b_celebrate", "f_taunt"][(i * 7) % 3]
				a.play(an, 1.0, 0.0, true); a.set_meta("seek", randf() * Kit.lengths[an]); crowd_all.append(a)
				i += 1
	# the Great Sphinx
	var sph := Node3D.new(); sph.position = Vector3(-6, 0, -34); sph.rotation_degrees.y = 25; add_child(sph)
	var lime := Kit.tex(Color(0.86, 0.7, 0.48), 0.9, 0.0, 4.0, 1.2, 0.25, 41)
	_p("box", Vector3(5, 3.2, 14), lime, Vector3(0, 1.6, -3), Vector3.ZERO, sph)
	_p("box", Vector3(5.6, 1.5, 3.2), lime, Vector3(0, 3.0, -0.2), Vector3.ZERO, sph)
	for px in [-1.6, 1.6]:
		_p("box", Vector3(1.3, 0.9, 6.5), lime, Vector3(px, 0.45, 6.5), Vector3.ZERO, sph)
	_p("box", Vector3(3.4, 3.2, 2.8), lime, Vector3(0, 5.8, 1.4), Vector3.ZERO, sph)
	var nemes := Kit.tex(Color(0.8, 0.64, 0.42), 0.9, 0.0, 4.0, 1.0, 0.25, 42)
	_p("prism", Vector3(5.2, 3.4, 2.4), nemes, Vector3(0, 6.6, 0.9), Vector3.ZERO, sph)
	for nx in [-1.9, 1.9]:
		_p("box", Vector3(1.0, 3.0, 1.2), nemes, Vector3(nx, 4.6, 1.6), Vector3.ZERO, sph)
	_p("box", Vector3(0.7, 1.2, 0.6), lime, Vector3(0, 5.6, 2.95), Vector3.ZERO, sph)
	# stepped pyramids
	var py := Kit.tex(Color(0.9, 0.72, 0.46), 0.9, 0.0, 2.0, 1.2, 0.2, 11)
	for p in [[Vector3(-26, 0, -95), 60.0], [Vector3(20, 0, -115), 66.0], [Vector3(55, 0, -85), 34.0]]:
		var base: float = p[1]
		var steps := 22
		for k in steps:
			var w: float = base * (1.0 - float(k) / steps)
			var h: float = base * 0.62 / steps
			_p("box", Vector3(w, h, w), py, p[0] + Vector3(0, h * (k + 0.5), 0), Vector3(0, 30, 0))
	# palms along the Nile
	_water(-0.45, Color(0.2, 0.35, 0.45), 30.0)
	for x in [-12.0, -10.0, 10.5, 13.0, 15.5]:
		Kit.part(self, "cyl", Vector3(0.14, 0.2, 7), Kit.pbr(Color(0.45, 0.32, 0.2), 0, 0.9), Vector3(x, 3.5, -12))
		for k in 8:
			var lf := Kit.part(self, "box", Vector3(0.4, 0.04, 2.6), Kit.pbr(Color(0.25, 0.45, 0.15), 0, 0.8), Vector3(x, 7, -12))
			lf.rotation_degrees = Vector3(28, k * 45, 0); lf.translate_object_local(Vector3(0, 0, 1.2))
