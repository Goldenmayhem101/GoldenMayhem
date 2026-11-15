## Shared helpers: comic materials, the shared Mixamo animation library, primitive props.
class_name Kit

const INK := Color(0.08, 0.06, 0.05)
static var _toon: Shader
static var _outline: Shader
static var lib: AnimationLibrary
static var lengths := {}

const LOOPS := ["f_idle", "f_run", "s_idle", "s_run", "f_air", "f_launch", "r_aim", "r_back", "r_run", "z_walk", "z_run", "z_crawl", "b_jog", "b_idle", "b_gkidle", "b_fallen", "f_block", "ss_idle", "ss_run", "ss_block_idle", "ss_walk", "ss_strafe"]

static func toon(base: Color, shade: Color, outline_w := 0.012, ink := INK) -> ShaderMaterial:
	if _toon == null:
		_toon = load("res://shaders/toon.gdshader")
		_outline = load("res://shaders/outline.gdshader")
	var m := ShaderMaterial.new()
	m.shader = _toon
	m.set_shader_parameter("base_color", Vector3(base.r, base.g, base.b))
	m.set_shader_parameter("shade_color", Vector3(shade.r, shade.g, shade.b))
	m.set_shader_parameter("deep_color", Vector3(shade.r * 0.75, shade.g * 0.7, shade.b * 0.7))
	m.set_shader_parameter("rim", 0.35)
	if outline_w > 0.0:
		var o := ShaderMaterial.new()
		o.shader = _outline
		o.set_shader_parameter("width", outline_w)
		o.set_shader_parameter("ink", Vector3(ink.r, ink.g, ink.b))
		m.next_pass = o
	return m

static func glow(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = c
	return m

## builds one library from every FBX in res://a (except the body), with root motion removed
static func library() -> AnimationLibrary:
	if lib != null:
		return lib
	lib = AnimationLibrary.new()
	var d := DirAccess.open("res://a")
	for f in d.get_files():
		if not f.ends_with(".fbx") or f == "xbot.fbx":
			continue
		var key := f.get_basename()
		var s: Node = load("res://a/" + f).instantiate()
		var ap: AnimationPlayer = s.find_children("*", "AnimationPlayer", true, false)[0]
		var a: Animation = ap.get_animation("mixamo_com").duplicate(true)
		for i in a.get_track_count():
			if a.track_get_type(i) == Animation.TYPE_POSITION_3D and str(a.track_get_path(i)).ends_with("mixamorig_Hips"):
				var v0: Vector3 = a.track_get_key_value(i, 0)
				for k in a.track_get_key_count(i):
					var v: Vector3 = a.track_get_key_value(i, k)
					a.track_set_key_value(i, k, Vector3(v0.x, v.y, v0.z))
		a.loop_mode = Animation.LOOP_LINEAR if LOOPS.has(key) else Animation.LOOP_NONE
		lib.add_animation(key, a)
		lengths[key] = a.length
		s.free()
	# retargeted extras (CMU mocap, free CC0 packs) baked by Bake.gd
	var ad := DirAccess.open("res://anim")
	if ad:
		for f in ad.get_files():
			if f.ends_with(".res"):
				var an: Animation = load("res://anim/" + f)
				lib.add_animation(f.get_basename(), an)
				lengths[f.get_basename()] = an.length
	return lib

static func mesh(kind: String, a: float, b := 0.0, c := 0.0) -> Mesh:
	match kind:
		"box":
			var m := BoxMesh.new(); m.size = Vector3(a, b, c); return m
		"cyl":
			var m2 := CylinderMesh.new(); m2.top_radius = a; m2.bottom_radius = b; m2.height = c; m2.radial_segments = 16; return m2
		"sphere":
			var m3 := SphereMesh.new(); m3.radius = a; m3.height = a * 2.0; m3.radial_segments = 20; m3.rings = 10; return m3
		"prism":
			var m4 := PrismMesh.new(); m4.size = Vector3(a, b, c); return m4
		"plane":
			var m5 := PlaneMesh.new(); m5.size = Vector2(a, b); return m5
	return null

static func part(parent: Node3D, kind: String, dims: Vector3, mat: Material, pos := Vector3.ZERO, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh(kind, dims.x, dims.y, dims.z)
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi

## real lit material (metal / plastic / emissive)
static func pbr(c: Color, metal := 0.0, rough := 0.5, emit := Color.BLACK, emit_e := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = metal
	m.roughness = rough
	m.metallic_specular = 0.6
	if emit_e > 0.0:
		m.emission_enabled = true
		m.emission = emit
		m.emission_energy_multiplier = emit_e
	m.rim_enabled = true
	m.rim = 0.25
	return m

## high-end renderer extras (Forward+): bounce light, reflections, contact shadows, volumetric fog
static func hq(e: Environment, fog_col := Color(0.2, 0.2, 0.3), fog_d := 0.02) -> void:
	if RenderingServer.get_current_rendering_method() != "forward_plus":
		return
	e.ssao_enabled = true
	e.ssao_radius = 1.2
	e.ssao_intensity = 2.0
	e.ssr_enabled = true
	e.ssr_max_steps = 64
	e.ssil_enabled = true
	e.sdfgi_enabled = true
	e.sdfgi_use_occlusion = true
	e.volumetric_fog_enabled = true
	e.volumetric_fog_density = fog_d
	e.volumetric_fog_albedo = fog_col
	e.fog_enabled = false

## textured material from noise (concrete, asphalt, grass, skin), with a bump map
static func tex(c: Color, rough := 0.8, metal := 0.0, scale := 8.0, bump := 1.0, contrast := 0.25, seed_v := 1) -> StandardMaterial3D:
	var m := pbr(c, metal, rough)
	var n := FastNoiseLite.new()
	n.seed = seed_v
	n.frequency = 0.02 * scale
	n.fractal_octaves = 5
	var alb := NoiseTexture2D.new()
	alb.width = 512; alb.height = 512; alb.seamless = true; alb.noise = n
	var g := Gradient.new()
	g.set_color(0, c.darkened(contrast))
	g.set_color(1, c.lightened(contrast * 0.6))
	alb.color_ramp = g
	m.albedo_color = Color.WHITE
	m.albedo_texture = alb
	var nm := NoiseTexture2D.new()
	nm.width = 512; nm.height = 512; nm.seamless = true; nm.noise = n; nm.as_normal_map = true; nm.bump_strength = 1.6 * bump
	m.normal_enabled = true
	m.normal_texture = nm
	m.uv1_triplanar = true
	m.uv1_scale = Vector3.ONE * 0.5
	return m

## a crowd of animated Mixamo people (cheering), arranged in rows
static func crowd(parent: Node3D, origin: Vector3, rows: int, per_row: int, spacing: Vector2, row_rise: float, cols: Array, face_yaw: float, anims: Array, dark := false) -> Array:
	var out: Array = []
	var r := RandomNumberGenerator.new()
	r.seed = int(origin.x * 13 + origin.z * 7) + 99
	for row in rows:
		for k in per_row:
			var a := Actor.new()
			parent.add_child(a)
			var c: Color = cols[r.randi() % cols.size()]
			var skin := pbr(c, 0.0, 0.7) if not dark else pbr(Color(0.03, 0.03, 0.05), 0.4, 0.4)
			var j := pbr(Color(0.85, 0.7, 0.55).lerp(Color(0.3, 0.2, 0.15), r.randf()), 0, 0.6) if not dark else pbr(Color(0.02, 0.02, 0.03), 0.4, 0.4, c, 2.5)
			a.setup(skin, j, r.randf_range(0.92, 1.05))
			a.position = origin + Vector3(k * spacing.x + r.randf_range(-0.12, 0.12) + (0.5 * spacing.x if row % 2 else 0.0), row * row_rise, -row * spacing.y)
			a.yaw_target = face_yaw + r.randf_range(-20, 20)
			a.yaw = a.yaw_target
			var an: String = anims[r.randi() % anims.size()]
			a.play(an, r.randf_range(0.8, 1.2), 0.0, true)
			a.set_meta("seek", r.randf() * Kit.lengths.get(an, 1.0))
			out.append(a)
	return out

static func freeze(actors: Array) -> void:
	for a in actors:
		a.ap.seek(a.get_meta("seek", 0.0), true)
		a.ap.pause()

## a burst of glowing sparks (pre-simulated so it shows in a still)
static func sparks(parent: Node3D, at: Vector3, c: Color, amount := 120, speed := 6.0, life := 0.5, pre := 0.08) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = amount
	p.lifetime = life
	p.explosiveness = 1.0
	p.one_shot = false
	p.preprocess = pre
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 0.3, 1)
	pm.spread = 180
	pm.initial_velocity_min = speed * 0.4
	pm.initial_velocity_max = speed
	pm.gravity = Vector3(0, -9, 0)
	pm.scale_min = 0.5
	pm.scale_max = 1.2
	p.process_material = pm
	var q := BoxMesh.new()
	q.size = Vector3(0.008, 0.008, 0.06)
	var m := pbr(c, 0, 0.3, c, 3.0)
	q.material = m
	p.draw_pass_1 = q
	pm.particle_flag_align_y = true
	p.position = at
	parent.add_child(p)
	return p

static func spot(parent: Node3D, at: Vector3, look: Vector3, c: Color, energy := 8.0, angle := 22.0, rng := 25.0) -> SpotLight3D:
	var s := SpotLight3D.new()
	s.position = at
	parent.add_child(s)
	s.look_at(look, Vector3.UP)
	s.light_color = c
	s.light_energy = energy
	s.spot_angle = angle
	s.spot_range = rng
	s.light_volumetric_fog_energy = 3.0
	s.shadow_enabled = true
	return s

static func dof(cam: Camera3D, far_dist: float, near_dist := 0.0) -> void:
	var ca := CameraAttributesPractical.new()
	ca.dof_blur_far_enabled = true
	ca.dof_blur_far_distance = far_dist
	ca.dof_blur_far_transition = far_dist * 0.6
	ca.dof_blur_amount = 0.08
	if near_dist > 0.0:
		ca.dof_blur_near_enabled = true
		ca.dof_blur_near_distance = near_dist
	cam.attributes = ca
