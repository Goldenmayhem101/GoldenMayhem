extends Node3D
## Turf War Mayhem (working title) - realistic zombie lane battler.
## Drag left/right to steer the squad. Squad auto-runs, auto-fires, passes through gates,
## rescues survivors, fights zombies and a boss. Everything is built from code + the GLB files in assets/.

const LANE_HALF := 3.3
const SQUAD_SHOW := 9
const RUN_SPEED := 4.4
const MAX_SQUAD := 400
const SPAWN_AHEAD := 75.0
const WAKE_DIST := 38.0
const LEVEL_LEN := 270.0
const LOOP_ANIMS := ["r_idle_aim", "r_run", "r_sprint", "r_walk", "r_crouch_aim", "z_walk", "z_run", "z_idle", "z_crawl", "z_runcrawl", "z_attack"]

const WEAPONS := [
	{"name": "PISTOL", "glb": "pistol", "dmg": 6.0, "rate": 0.42, "range": 24.0, "col": Color(1, 0.92, 0.55)},
	{"name": "SMG", "glb": "smg", "dmg": 4.0, "rate": 0.16, "range": 26.0, "col": Color(1, 0.8, 0.3)},
	{"name": "RIFLE", "glb": "rifle", "dmg": 7.0, "rate": 0.18, "range": 30.0, "col": Color(1, 0.65, 0.2)},
	{"name": "BULLPUP", "glb": "bullpup", "dmg": 9.0, "rate": 0.13, "range": 32.0, "col": Color(0.55, 0.9, 1.0)},
]

const SOLDIERS := ["ww2_soldier", "swat_camo", "operator_black", "trooper_armor", "cop_vest", "merc_woman", "stealth_suit"]
const WALKERS := ["cop", "girl", "clown", "skeleton", "yaku", "ragged", "tribal", "dark_ghoul", "skinless", "stalker"]
const RUNNERS := ["girl", "skinless", "stalker", "ragged"]
const CIVILIANS := ["scientist_a", "scientist_b", "hazmat_white", "survivor_woman"]

const ZONES := [
	{"name": "DOWNTOWN", "sky_top": Color(0.22, 0.52, 0.95), "sky_hor": Color(0.78, 0.9, 1.0), "fog": Color(0.78, 0.89, 1.0), "fog_d": 0.004,
	 "amb": Color(1.0, 1.0, 1.0), "bld": Color(1.0, 1.0, 1.0), "grass": Color(0.36, 0.72, 0.26), "road": Color(0.22, 0.22, 0.27),
	 "boss": "bosses/warrok", "boss_name": "WARROK", "boss_h": 5.4, "boss_hp": 30000.0,
	 "elite": "elites/mutant_brute", "hpm": 1.0, "nm": 1.0, "bombers": false},
	{"name": "DUSK DISTRICT", "sky_top": Color(0.35, 0.25, 0.65), "sky_hor": Color(1.0, 0.62, 0.42), "fog": Color(0.85, 0.58, 0.55), "fog_d": 0.004,
	 "amb": Color(1.0, 0.88, 0.92), "bld": Color(1.0, 0.88, 0.88), "grass": Color(0.3, 0.55, 0.32), "road": Color(0.2, 0.18, 0.24),
	 "boss": "bosses/pumpkin_hulk", "boss_name": "PUMPKIN HULK", "boss_h": 5.6, "boss_hp": 80000.0,
	 "elite": "elites/alien", "hpm": 1.4, "nm": 1.3, "bombers": true},
	{"name": "THE FOG", "sky_top": Color(0.55, 0.64, 0.74), "sky_hor": Color(0.88, 0.9, 0.92), "fog": Color(0.86, 0.89, 0.92), "fog_d": 0.016,
	 "amb": Color(0.95, 0.98, 1.0), "bld": Color(0.9, 0.96, 1.0), "grass": Color(0.5, 0.64, 0.5), "road": Color(0.34, 0.36, 0.4),
	 "boss": "bosses/moose_beast", "boss_name": "MOOSE BEAST", "boss_h": 6.0, "boss_hp": 120000.0,
	 "elite": "elites/war_zombie", "hpm": 1.9, "nm": 1.6, "bombers": true},
]
const HEROES := {
	"hazmat_armor": {"name": "HAZMAT", "perk": "+15% damage", "cost": 250},
	"captain_suit": {"name": "CAPTAIN", "perk": "+4 starting squad", "cost": 300},
	"red_agent": {"name": "RED AGENT", "perk": "+12% fire rate", "cost": 300},
	"brawler": {"name": "BRAWLER", "perk": "bosses hurt 30% less", "cost": 400},
}
const UPGRADES := {
	"dmg": {"name": "DAMAGE", "desc": "+12% bullet damage"},
	"squad": {"name": "START SQUAD", "desc": "+2 soldiers at the start"},
	"rate": {"name": "FIRE RATE", "desc": "+8% shooting speed"},
}
const SAVE_PATH := "user://turf_war_mayhem.json"

# Level script: "d" = distance along the road. Gate sides: add / sub / mul / weapon.
const LEVEL := [
	{"d": 28, "t": "gate", "l": {"k": "add", "v": 6}, "r": {"k": "sub", "v": 4}},
	{"d": 52, "t": "horde", "n": 10, "kind": "walker"},
	{"d": 78, "t": "gate", "l": {"k": "mul", "v": 2}, "r": {"k": "add", "v": 10}},
	{"d": 98, "t": "rescue", "x": -2.4},
	{"d": 112, "t": "horde", "n": 16, "kind": "walker"},
	{"d": 138, "t": "gate", "l": {"k": "weapon", "v": 1}, "r": {"k": "add", "v": 12}},
	{"d": 156, "t": "horde", "n": 14, "kind": "runner"},
	{"d": 178, "t": "gate", "l": {"k": "sub", "v": 6}, "r": {"k": "mul", "v": 2}},
	{"d": 196, "t": "rescue", "x": 2.4},
	{"d": 210, "t": "horde", "n": 20, "kind": "mixed"},
	{"d": 226, "t": "elite"},
	{"d": 244, "t": "gate", "l": {"k": "weapon", "v": 1}, "r": {"k": "add", "v": 15}},
	{"d": 262, "t": "boss"},
]

var save := {"coins": 0, "up": {"dmg": 0, "squad": 0, "rate": 0}, "zone": 0, "unlocked": 0, "hero": "", "heroes": [], "quality": 1, "fps": false}
var zone: Dictionary = {}
var run_coins := 0
var bld_mats: Array = []
var env: Environment
var road_mat: StandardMaterial3D
var grass_mat: StandardMaterial3D
var sky_mat: ProceduralSkyMaterial
var sfx_players: Array = []
var sfx_streams := {}
var sfx_i := 0
var menu: Control
var menu_main: Control
var menu_up: Control
var menu_hero: Control
var lbl_menu_coins: Label
var lbl_zone: Label
var lbl_fps: Label
var boss_name_lbl: Label
var sun: DirectionalLight3D
var level: Array = []
var dmg_mult := 1.0
var rate_mult := 1.0
var boss_resist := 1.0
var perf_acc := 0.0
var font: Font
var anims: AnimationLibrary
var lib_cache := {}
var scene_cache := {}

var state := "menu"          # menu / play / win / lose
var squad_count := 8
var weapon_idx := 0
var kills := 0
var dist := 0.0              # distance travelled along the road
var squad_x := 0.0
var target_x := 0.0
var fire_t := 0.0
var speed_factor := 1.0
var shake := 0.0
var elapsed := 0.0

var squad_root: Node3D
var soldiers: Array = []     # {logic, ap, gun, skel, prefix, off}
var count_label: Label3D
var cam: Camera3D
var zombies: Array = []
var gates: Array = []
var cages: Array = []
var spawn_queue: Array = []
var next_event := 0
var tracers: Array = []
var boss: Dictionary = {}

# HUD
var hud: CanvasLayer
var lbl_coins: Label
var lbl_weapon: Label
var lbl_level: Label
var boss_bar: ProgressBar
var boss_box: Control
var center_msg: Label
var overlay: Control
var overlay_title: Label
var overlay_sub: Label
var progress: ProgressBar

# test harness (set DZM_SHOTS=/path to auto-play and screenshot)
var shots_dir := ""
var shot_times: Array = []
var shot_i := 0
var auto_play := false

func _ready() -> void:
	font = load("res://assets/fonts/LilitaOne.ttf")
	anims = load("res://assets/anims/anims.res")
	shots_dir = OS.get_environment("DZM_SHOTS")
	auto_play = shots_dir != ""
	load_save()
	if OS.get_environment("DZM_COINS") != "":
		save["coins"] = int(OS.get_environment("DZM_COINS"))
		save["unlocked"] = 2
	if OS.get_environment("DZM_ZONE") != "":
		save["zone"] = int(OS.get_environment("DZM_ZONE"))
	zone = ZONES[clampi(int(save["zone"]), 0, ZONES.size() - 1)]
	compute_stats()
	apply_quality()
	_setup_audio()
	_build_environment()
	_build_road()
	_build_squad()
	_build_hud()
	_build_menu()
	level = build_level()
	apply_zone_look()
	if auto_play:
		var times := OS.get_environment("DZM_TIMES")
		for t in times.split(","):
			if t.strip_edges() != "":
				shot_times.append(float(t))
		if OS.get_environment("DZM_MENU") != "":
			show_menu()
			show_page(OS.get_environment("DZM_MENU"))
		else:
			start_game()
	elif Engine.has_meta("autostart") and Engine.get_meta("autostart"):
		Engine.set_meta("autostart", false)
		start_game()
	else:
		show_menu()

# ---------------------------------------------------------------- save, stats, quality, audio
func load_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var d = JSON.parse_string(f.get_as_text())
		if d is Dictionary:
			for k in d.keys():
				save[k] = d[k]
	for k in ["dmg", "squad", "rate"]:
		if not save["up"].has(k):
			save["up"][k] = 0

func write_save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(save))

func upgrade_cost(k: String) -> int:
	return int(50.0 * pow(float(save["up"][k]) + 1.0, 1.6))

func compute_stats() -> void:
	dmg_mult = 1.0 + 0.12 * float(save["up"]["dmg"])
	rate_mult = 1.0 + 0.08 * float(save["up"]["rate"])
	squad_count = 8 + 2 * int(save["up"]["squad"])
	boss_resist = 1.0
	match str(save["hero"]):
		"hazmat_armor": dmg_mult *= 1.15
		"captain_suit": squad_count += 4
		"red_agent": rate_mult *= 1.12
		"brawler": boss_resist = 0.7

func apply_quality() -> void:
	# quality 1 = high (3D drawn up to ~1440p), 0 = balanced (up to ~1080p). Saves battery on weak phones.
	var sz := DisplayServer.window_get_size()
	var long_side := float(maxi(sz.x, sz.y))
	var cap := 2560.0 if int(save["quality"]) == 1 else 1920.0
	var sc := 1.0
	if long_side > cap:
		sc = cap / long_side
	get_viewport().scaling_3d_scale = sc

func _setup_audio() -> void:
	for n in ["shot1", "shot2", "shot3", "zdie", "boom", "roar"]:
		sfx_streams[n] = load("res://assets/audio/%s.wav" % n)
	for n in ["hit", "gate", "click", "bad", "win", "lose"]:
		sfx_streams[n] = load("res://assets/audio/%s.ogg" % n)
	for i in range(10):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

func snd(n: String, vol := -6.0, pitch := 1.0) -> void:
	if not sfx_streams.has(n):
		return
	var p: AudioStreamPlayer = sfx_players[sfx_i % sfx_players.size()]
	sfx_i += 1
	p.stream = sfx_streams[n]
	p.volume_db = vol
	p.pitch_scale = pitch
	p.play()

func build_level() -> Array:
	var out: Array = []
	for ev in LEVEL:
		var e: Dictionary = ev.duplicate(true)
		if e["t"] == "horde":
			e["n"] = int(round(float(e["n"]) * float(zone["nm"])))
			if bool(zone["bombers"]) and e["kind"] == "mixed":
				e["kind"] = "mixed_bomb"
		out.append(e)
	return out

# ---------------------------------------------------------------- helpers
func load_scene(path: String) -> PackedScene:
	if not scene_cache.has(path):
		scene_cache[path] = load(path)
	return scene_cache[path]

func model_bounds(model: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for mi in model.find_children("*", "MeshInstance3D", true, false):
		var xf := Transform3D.IDENTITY
		var n: Node = mi
		while n != null:
			if n is Node3D:
				xf = (n as Node3D).transform * xf
			if n == model:
				break
			n = n.get_parent()
		var a: AABB = xf * (mi as MeshInstance3D).get_aabb()
		if first:
			out = a
			first = false
		else:
			out = out.merge(a)
	return out

func lib_for(skel_path: String, prefix: String) -> AnimationLibrary:
	var key := skel_path + "|" + prefix
	if lib_cache.has(key):
		return lib_cache[key]
	var out := AnimationLibrary.new()
	for nm in anims.get_animation_list():
		var a: Animation = anims.get_animation(nm).duplicate()
		for i in range(a.get_track_count()):
			var p := str(a.track_get_path(i))
			var parts := p.split(":")
			var bone: String = parts[1] if parts.size() > 1 else ""
			if prefix != "mixamorig_":
				bone = bone.replace("mixamorig_", prefix)
			a.track_set_path(i, NodePath(skel_path + ":" + bone))
		if str(nm) in LOOP_ANIMS:
			a.loop_mode = Animation.LOOP_LINEAR
		out.add_animation(nm, a)
	lib_cache[key] = out
	return out

var bright_done := {}
func brighten_once(path: String, model: Node3D) -> void:
	if bright_done.has(path):
		return
	bright_done[path] = true
	var f := 1.55 if not path.contains("/bosses/") else 1.35
	for mi in model.find_children("*", "MeshInstance3D", true, false):
		var m: MeshInstance3D = mi
		if m.mesh == null:
			continue
		for i in range(m.mesh.get_surface_count()):
			var sm := m.mesh.surface_get_material(i)
			if sm is BaseMaterial3D:
				(sm as BaseMaterial3D).albedo_color = Color(f, f, f)

## Builds a character: returns {logic, model, ap, skel, prefix, h}
func make_char(path: String, height: float) -> Dictionary:
	var model: Node3D = load_scene(path).instantiate()
	var logic := Node3D.new()
	var holder := Node3D.new()
	logic.add_child(holder)
	holder.add_child(model)
	holder.rotation.y = PI  # mixamo models face +Z, our "forward" is -Z
	brighten_once(path, model)
	var b := model_bounds(model)
	var s: float = height / maxf(b.size.y, 0.01)
	holder.scale = Vector3.ONE * s
	holder.position.y = -b.position.y * s
	var skel: Skeleton3D = null
	var sk := model.find_children("*", "Skeleton3D", true, false)
	if sk.size() > 0:
		skel = sk[0]
	var prefix := "mixamorig_"
	if skel != null and skel.get_bone_count() > 0 and skel.get_bone_name(0).begins_with("mixamorig1_"):
		prefix = "mixamorig1_"
	var ap := AnimationPlayer.new()
	model.add_child(ap)
	if skel != null:
		var sp := str(model.get_path_to(skel))
		ap.add_animation_library("", lib_for(sp, prefix))
	return {"logic": logic, "model": model, "holder": holder, "ap": ap, "skel": skel, "prefix": prefix, "scale": s}

func play(ap: AnimationPlayer, nm: String, speed := 1.0, blend := 0.15) -> void:
	if ap == null or not ap.has_animation(nm):
		return
	if ap.current_animation != nm:
		ap.play(nm, blend)
	ap.speed_scale = speed

func attach_gun(c: Dictionary, weapon_i: int) -> void:
	var skel: Skeleton3D = c["skel"]
	if skel == null:
		return
	if c.get("gun") != null and is_instance_valid(c["gun"]):
		c["gun"].queue_free()
	var ba := BoneAttachment3D.new()
	ba.bone_name = str(c["prefix"]) + "RightHand"
	skel.add_child(ba)
	var gun: Node3D = load_scene("res://assets/weapons/%s.glb" % WEAPONS[weapon_i]["glb"]).instantiate()
	ba.add_child(gun)
	var gb := model_bounds(gun)
	var glen: float = maxf(gb.size.x, maxf(gb.size.y, gb.size.z))
	var world_scale: float = float(c["scale"]) * skel.get_parent().global_transform.basis.get_scale().x
	var want := 0.85 if weapon_i >= 2 else (0.55 if weapon_i == 1 else 0.3)
	# Assumes skeleton units are model units; correct by actual global scale at runtime.
	var gs: float = want / maxf(glen, 0.001)
	gun.scale = Vector3.ONE * gs / maxf(skel.global_transform.basis.get_scale().x, 0.0001)
	gun.position = Vector3(0, 0, 0)
	c["gun"] = ba
	c["gun_node"] = gun
	c["gun_len"] = glen

# ---------------------------------------------------------------- world
func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sky_mat = sm
	sm.sky_top_color = Color(0.07, 0.06, 0.2)
	sm.sky_horizon_color = Color(0.95, 0.5, 0.28)
	sm.ground_horizon_color = Color(0.6, 0.3, 0.25)
	sm.ground_bottom_color = Color(0.08, 0.06, 0.1)
	sky.sky_material = sm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.46, 0.6)
	env.ambient_light_energy = 0.8
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 1.0
	env.fog_enabled = true
	env.fog_light_color = Color(0.32, 0.2, 0.26)
	env.fog_density = 0.009
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.1
	we.environment = env
	self.env = env
	add_child(we)
	sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, 150, 0)
	sun.light_color = Color(1, 0.95, 0.85)
	sun.light_energy = 1.7
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 26.0
	add_child(sun)
	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30, -30, 0)
	fill.light_color = Color(0.5, 0.6, 1.0)
	fill.light_energy = 0.35
	add_child(fill)
	cam = Camera3D.new()
	cam.fov = 62
	cam.far = 220
	add_child(cam)
	cam.current = true

func apply_zone_look() -> void:
	sky_mat.sky_top_color = zone["sky_top"]
	sky_mat.sky_horizon_color = zone["sky_hor"]
	sky_mat.ground_horizon_color = zone["sky_hor"].darkened(0.3)
	env.fog_light_color = zone["fog"]
	env.fog_density = zone["fog_d"]
	env.ambient_light_color = zone["amb"]
	road_mat.albedo_color = zone["road"]
	grass_mat.albedo_color = zone["grass"]
	for m in bld_mats:
		(m as BaseMaterial3D).albedo_color = zone["bld"]
	if lbl_zone:
		lbl_zone.text = "ZONE %d: %s" % [int(save["zone"]) + 1, zone["name"]]
	if boss_name_lbl:
		boss_name_lbl.text = zone["boss_name"]
	if lbl_level:
		lbl_level.text = "ZONE %d" % (int(save["zone"]) + 1)

func mat(c: Color, rough := 0.9, emit := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit
	return m

func darken(node: Node, tint: Color, track := false) -> void:
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		var m: MeshInstance3D = mi
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for i in range(m.mesh.get_surface_count()):
			var sm := m.get_active_material(i)
			if sm is BaseMaterial3D:
				var d: BaseMaterial3D = sm.duplicate()
				d.albedo_color = tint
				m.set_surface_override_material(i, d)
				if track:
					bld_mats.append(d)

func _build_road() -> void:
	var road := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(LANE_HALF * 2 + 3.0, LEVEL_LEN + 160.0)
	road.mesh = pm
	road_mat = mat(Color(0.3, 0.3, 0.35), 0.8)
	road.material_override = road_mat
	road.position = Vector3(0, 0, -LEVEL_LEN / 2.0 + 30.0)
	add_child(road)
	var ground := MeshInstance3D.new()
	var gm := PlaneMesh.new()
	gm.size = Vector2(160, LEVEL_LEN + 200.0)
	ground.mesh = gm
	grass_mat = mat(Color(0.36, 0.72, 0.26), 0.9)
	ground.material_override = grass_mat
	ground.position = Vector3(0, -0.04, -LEVEL_LEN / 2.0 + 30.0)
	add_child(ground)
	# sidewalks
	for sx in [-1, 1]:
		var sw := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(2.6, 0.25, LEVEL_LEN + 160.0)
		sw.mesh = bm
		sw.material_override = mat(Color(0.82, 0.8, 0.74))
		sw.position = Vector3(sx * (LANE_HALF + 2.3), 0.1, -LEVEL_LEN / 2.0 + 30.0)
		add_child(sw)
	# dashed centre line
	var dash_mat := mat(Color(0.97, 0.97, 0.9))
	var z := 20.0
	while z > -LEVEL_LEN - 40.0:
		var d := MeshInstance3D.new()
		var dm := BoxMesh.new()
		dm.size = Vector3(0.3, 0.02, 2.6)
		d.mesh = dm
		d.material_override = dash_mat
		d.position = Vector3(0, 0.02, z)
		add_child(d)
		z -= 6.0
	# buildings
	var names := ["building-a", "building-b", "building-c", "building-d", "building-e", "building-f", "building-skyscraper-a", "building-skyscraper-b", "building-skyscraper-c"]
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for side in [-1, 1]:
		var zz := 25.0
		while zz > -LEVEL_LEN - 70.0:
			var nm: String = names[rng.randi() % names.size()]
			var bld: Node3D = load_scene("res://assets/city/%s.glb" % nm).instantiate()
			var bb := model_bounds(bld)
			var w: float = maxf(bb.size.x, bb.size.z)
			var s: float = rng.randf_range(7.5, 10.5) / maxf(w, 0.01)
			bld.scale = Vector3.ONE * s
			bld.rotation.y = (PI / 2.0) if side < 0 else (-PI / 2.0)
			bld.position = Vector3(side * (LANE_HALF + 3.6 + rng.randf_range(2.2, 3.4) + bb.size.z * s * 0.35), -bb.position.y * s, zz)
			darken(bld, zone["bld"], true)
			add_child(bld)
			zz -= rng.randf_range(8.5, 10.5)
	# wrecked cars on the edges
	var cars := ["taxi", "police", "van", "ambulance", "suv", "delivery", "firetruck"]
	var cz := 8.0
	while cz > -LEVEL_LEN - 20.0:
		var cn: String = cars[rng.randi() % cars.size()]
		var car: Node3D = load_scene("res://assets/cars/%s.glb" % cn).instantiate()
		var cb := model_bounds(car)
		var cs: float = 3.4 / maxf(cb.size.z, 0.01)
		car.scale = Vector3.ONE * cs
		var side2 := -1 if rng.randf() < 0.5 else 1
		car.position = Vector3(side2 * (LANE_HALF + 0.2), -cb.position.y * cs, cz)
		car.rotation.y = rng.randf_range(-0.5, 0.5) + (PI if rng.randf() < 0.5 else 0.0)
		darken(car, Color(0.6, 0.55, 0.55))
		add_child(car)
		cz -= rng.randf_range(22.0, 38.0)

# ---------------------------------------------------------------- squad
func _build_squad() -> void:
	squad_root = Node3D.new()
	add_child(squad_root)
	count_label = Label3D.new()
	count_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	count_label.font = font
	count_label.font_size = 140
	count_label.pixel_size = 0.0075
	count_label.outline_size = 36
	count_label.outline_modulate = Color(0.09, 0.06, 0.27)
	count_label.modulate = Color(1, 0.95, 0.4)
	count_label.no_depth_test = true
	count_label.position = Vector3(0, 3.6, 0.6)
	squad_root.add_child(count_label)
	var offs := [Vector2(0, 0), Vector2(-1.15, 1.0), Vector2(1.15, 1.0), Vector2(0, 2.0), Vector2(-2.2, 2.0), Vector2(2.2, 2.0), Vector2(-1.15, 3.0), Vector2(1.15, 3.0), Vector2(0, 4.0)]
	for i in range(SQUAD_SHOW):
		var nm: String = SOLDIERS[i % SOLDIERS.size()]
		var c := make_char("res://assets/soldiers/%s.glb" % nm, 2.15)
		if i == 0 and str(save["hero"]) != "":
			c = make_char("res://assets/heroes/%s.glb" % str(save["hero"]), 2.35)
		c["off"] = Vector3(offs[i].x, 0, offs[i].y)
		c["logic"].position = c["off"]
		squad_root.add_child(c["logic"])
		attach_gun(c, weapon_idx)
		play(c["ap"], "r_run", randf_range(0.95, 1.1), 0.0)
		soldiers.append(c)
	update_squad_visibility()

func update_squad_visibility() -> void:
	var shown := mini(squad_count, SQUAD_SHOW)
	for i in range(soldiers.size()):
		soldiers[i]["logic"].visible = i < shown
	count_label.text = str(squad_count)
	count_label.visible = squad_count > 0

func set_weapon(i: int) -> void:
	weapon_idx = clampi(i, 0, WEAPONS.size() - 1)
	for c in soldiers:
		attach_gun(c, weapon_idx)
	lbl_weapon.text = WEAPONS[weapon_idx]["name"]

# ---------------------------------------------------------------- hud
func label(txt: String, size: int, col := Color.WHITE) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.09, 0.06, 0.27))
	l.add_theme_constant_override("outline_size", int(size * 0.28))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func panel_style(c: Color, r := 24) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.set_corner_radius_all(r)
	s.border_color = Color(0.09, 0.06, 0.27)
	s.set_border_width_all(5)
	return s

func _build_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)
	var top := Panel.new()
	top.add_theme_stylebox_override("panel", panel_style(Color(0.15, 0.12, 0.3, 0.85), 30))
	top.position = Vector2(30, 30)
	top.size = Vector2(1020, 120)
	hud.add_child(top)
	lbl_level = label("ZONE 1", 60, Color(1, 0.9, 0.4))
	lbl_level.position = Vector2(30, 30)
	lbl_level.size = Vector2(330, 120)
	lbl_level.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud.add_child(lbl_level)
	progress = ProgressBar.new()
	progress.position = Vector2(370, 76)
	progress.size = Vector2(380, 28)
	progress.show_percentage = false
	progress.max_value = LEVEL_LEN
	var fg := panel_style(Color(1, 0.75, 0.2), 14)
	fg.set_border_width_all(0)
	var bg := panel_style(Color(0.05, 0.04, 0.12), 14)
	bg.set_border_width_all(3)
	progress.add_theme_stylebox_override("fill", fg)
	progress.add_theme_stylebox_override("background", bg)
	hud.add_child(progress)
	lbl_coins = label("0", 60, Color(1, 0.88, 0.3))
	lbl_coins.position = Vector2(780, 30)
	lbl_coins.size = Vector2(250, 120)
	lbl_coins.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud.add_child(lbl_coins)
	lbl_weapon = label(WEAPONS[0]["name"], 56, Color(0.7, 1, 0.7))
	lbl_weapon.position = Vector2(0, 1760)
	lbl_weapon.size = Vector2(1080, 80)
	hud.add_child(lbl_weapon)
	center_msg = label("", 110, Color(1, 0.95, 0.4))
	center_msg.position = Vector2(0, 640)
	center_msg.size = Vector2(1080, 160)
	hud.add_child(center_msg)
	boss_box = Control.new()
	boss_box.visible = false
	hud.add_child(boss_box)
	boss_name_lbl = label("WARROK", 54, Color(1, 0.5, 0.45))
	boss_name_lbl.position = Vector2(0, 165)
	boss_name_lbl.size = Vector2(1080, 70)
	boss_box.add_child(boss_name_lbl)
	lbl_fps = label("", 36, Color(0.7, 1, 0.7))
	lbl_fps.position = Vector2(20, 1840)
	lbl_fps.size = Vector2(300, 60)
	hud.add_child(lbl_fps)
	boss_bar = ProgressBar.new()
	boss_bar.position = Vector2(140, 240)
	boss_bar.size = Vector2(800, 44)
	boss_bar.show_percentage = false
	var bfg := panel_style(Color(0.9, 0.15, 0.15), 18)
	bfg.set_border_width_all(0)
	boss_bar.add_theme_stylebox_override("fill", bfg)
	boss_bar.add_theme_stylebox_override("background", panel_style(Color(0.1, 0.03, 0.05), 18))
	boss_box.add_child(boss_bar)
	# overlay
	overlay = Control.new()
	overlay.visible = false
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.1, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	overlay_title = label("", 120, Color(1, 0.9, 0.35))
	overlay_title.position = Vector2(0, 560)
	overlay_title.size = Vector2(1080, 300)
	overlay_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay.add_child(overlay_title)
	overlay_sub = label("", 50, Color.WHITE)
	overlay_sub.position = Vector2(60, 900)
	overlay_sub.size = Vector2(960, 260)
	overlay_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay.add_child(overlay_sub)
	var btn := make_button("PLAY", Vector2(290, 1180), Vector2(500, 170), Color(0.2, 0.7, 0.25), 84, _on_btn)
	btn.name = "Btn"
	overlay.add_child(btn)
	var btn2 := make_button("MENU", Vector2(340, 1390), Vector2(400, 130), Color(0.3, 0.35, 0.6), 64, _on_menu_btn)
	btn2.name = "Btn2"
	overlay.add_child(btn2)

func make_button(txt: String, pos: Vector2, sz: Vector2, col: Color, fsize: int, cb: Callable) -> Button:
	var b := Button.new()
	b.text = txt
	b.position = pos
	b.size = sz
	b.add_theme_font_override("font", font)
	b.add_theme_font_size_override("font_size", fsize)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_color_hover", Color.WHITE)
	b.add_theme_color_override("font_color_pressed", Color.WHITE)
	b.add_theme_color_override("font_color_disabled", Color(0.7, 0.7, 0.75))
	b.add_theme_color_override("font_outline_color", Color(0.09, 0.06, 0.27))
	b.add_theme_constant_override("outline_size", int(fsize * 0.26))
	for st in ["normal", "hover", "pressed", "focus"]:
		b.add_theme_stylebox_override(st, panel_style(col, int(sz.y * 0.3)))
	b.add_theme_stylebox_override("disabled", panel_style(Color(0.25, 0.25, 0.32), int(sz.y * 0.3)))
	b.pressed.connect(func(): snd("click", -8.0))
	b.pressed.connect(cb)
	return b

func show_overlay(title: String, sub: String, btn: String) -> void:
	overlay_title.text = title
	overlay_sub.text = sub
	(overlay.get_node("Btn") as Button).text = btn
	overlay.visible = true

func _on_btn() -> void:
	overlay.visible = false
	if state == "menu":
		start_game()
	else:
		if state == "win" and btn_is_next:
			save["zone"] = int(save["zone"]) + 1
			write_save()
		Engine.set_meta("autostart", true)
		get_tree().reload_current_scene()

var btn_is_next := false

func _on_menu_btn() -> void:
	Engine.set_meta("autostart", false)
	get_tree().reload_current_scene()

# ---------------------------------------------------------------- menu screens
func _build_menu() -> void:
	menu = Control.new()
	menu.visible = false
	menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud.add_child(menu)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.02, 0.1, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(dim)
	menu_main = Control.new()
	menu.add_child(menu_main)
	var t1 := label("TURF WAR", 150, Color(1, 0.9, 0.35))
	t1.position = Vector2(0, 230)
	t1.size = Vector2(1080, 170)
	menu_main.add_child(t1)
	var t2 := label("MAYHEM", 150, Color(1, 0.45, 0.35))
	t2.position = Vector2(0, 380)
	t2.size = Vector2(1080, 170)
	menu_main.add_child(t2)
	lbl_menu_coins = label("", 70, Color(1, 0.88, 0.3))
	lbl_menu_coins.position = Vector2(0, 620)
	lbl_menu_coins.size = Vector2(1080, 90)
	menu_main.add_child(lbl_menu_coins)
	menu_main.add_child(make_button("<", Vector2(60, 930), Vector2(130, 130), Color(0.3, 0.35, 0.6), 80, func(): change_zone(-1)))
	menu_main.add_child(make_button(">", Vector2(890, 930), Vector2(130, 130), Color(0.3, 0.35, 0.6), 80, func(): change_zone(1)))
	lbl_zone = label("", 58, Color.WHITE)
	lbl_zone.position = Vector2(200, 945)
	lbl_zone.size = Vector2(680, 100)
	menu_main.add_child(lbl_zone)
	menu_main.add_child(make_button("PLAY", Vector2(240, 1110), Vector2(600, 190), Color(0.2, 0.7, 0.25), 100, func(): menu.visible = false; start_game()))
	menu_main.add_child(make_button("UPGRADES", Vector2(80, 1350), Vector2(450, 140), Color(0.85, 0.55, 0.12), 56, func(): show_page("up")))
	menu_main.add_child(make_button("HEROES", Vector2(550, 1350), Vector2(450, 140), Color(0.55, 0.3, 0.8), 56, func(): show_page("hero")))
	var qb := make_button("", Vector2(80, 1560), Vector2(450, 100), Color(0.3, 0.35, 0.6), 40, func(): pass)
	qb.name = "QBtn"
	qb.pressed.connect(func(): save["quality"] = 1 - int(save["quality"]); write_save(); apply_quality(); refresh_menu())
	menu_main.add_child(qb)
	var fb := make_button("", Vector2(550, 1560), Vector2(450, 100), Color(0.3, 0.35, 0.6), 40, func(): pass)
	fb.name = "FBtn"
	fb.pressed.connect(func(): save["fps"] = not bool(save["fps"]); write_save(); refresh_menu())
	menu_main.add_child(fb)
	menu_up = Control.new()
	menu_up.visible = false
	menu.add_child(menu_up)
	var ut := label("UPGRADES", 110, Color(1, 0.9, 0.35))
	ut.position = Vector2(0, 220)
	ut.size = Vector2(1080, 140)
	menu_up.add_child(ut)
	var uc := label("", 66, Color(1, 0.88, 0.3))
	uc.name = "Coins"
	uc.position = Vector2(0, 370)
	uc.size = Vector2(1080, 90)
	menu_up.add_child(uc)
	var yy := 520
	for k in UPGRADES.keys():
		var card := Panel.new()
		card.add_theme_stylebox_override("panel", panel_style(Color(0.15, 0.12, 0.3, 0.92), 30))
		card.position = Vector2(60, yy)
		card.size = Vector2(960, 250)
		menu_up.add_child(card)
		var nl := label("", 60, Color.WHITE)
		nl.name = "N_" + k
		nl.position = Vector2(90, yy + 20)
		nl.size = Vector2(560, 90)
		nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_up.add_child(nl)
		var dl := label(str(UPGRADES[k]["desc"]), 42, Color(0.8, 0.85, 1))
		dl.position = Vector2(90, yy + 130)
		dl.size = Vector2(560, 70)
		dl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_up.add_child(dl)
		var bb := make_button("", Vector2(690, yy + 45), Vector2(300, 160), Color(0.2, 0.7, 0.25), 56, func(): buy_upgrade(k))
		bb.name = "B_" + k
		menu_up.add_child(bb)
		yy += 290
	menu_up.add_child(make_button("BACK", Vector2(340, 1500), Vector2(400, 130), Color(0.3, 0.35, 0.6), 64, func(): show_page("main")))
	menu_hero = Control.new()
	menu_hero.visible = false
	menu.add_child(menu_hero)
	var ht := label("HEROES", 110, Color(1, 0.9, 0.35))
	ht.position = Vector2(0, 220)
	ht.size = Vector2(1080, 140)
	menu_hero.add_child(ht)
	var hc := label("", 66, Color(1, 0.88, 0.3))
	hc.name = "Coins"
	hc.position = Vector2(0, 370)
	hc.size = Vector2(1080, 90)
	menu_hero.add_child(hc)
	yy = 500
	for k in HEROES.keys():
		var card2 := Panel.new()
		card2.add_theme_stylebox_override("panel", panel_style(Color(0.15, 0.12, 0.3, 0.92), 30))
		card2.position = Vector2(60, yy)
		card2.size = Vector2(960, 200)
		menu_hero.add_child(card2)
		var hn := label(str(HEROES[k]["name"]), 56, Color.WHITE)
		hn.position = Vector2(90, yy + 20)
		hn.size = Vector2(560, 80)
		hn.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_hero.add_child(hn)
		var hp := label(str(HEROES[k]["perk"]), 40, Color(0.8, 0.85, 1))
		hp.position = Vector2(90, yy + 110)
		hp.size = Vector2(560, 70)
		hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		menu_hero.add_child(hp)
		var hb := make_button("", Vector2(690, yy + 30), Vector2(300, 140), Color(0.2, 0.7, 0.25), 50, func(): pick_hero(k))
		hb.name = "H_" + k
		menu_hero.add_child(hb)
		yy += 225
	menu_hero.add_child(make_button("NO HERO", Vector2(60, 1420), Vector2(440, 120), Color(0.4, 0.3, 0.3), 52, func(): pick_hero("")))
	menu_hero.add_child(make_button("BACK", Vector2(580, 1420), Vector2(440, 120), Color(0.3, 0.35, 0.6), 60, func(): show_page("main")))

func show_menu() -> void:
	state = "menu"
	menu.visible = true
	count_label.visible = false
	lbl_weapon.visible = false
	show_page("main")

func show_page(p: String) -> void:
	menu_main.visible = p == "main"
	menu_up.visible = p == "up"
	menu_hero.visible = p == "hero"
	refresh_menu()

func refresh_menu() -> void:
	var c := "COINS: %d" % int(save["coins"])
	lbl_menu_coins.text = c
	menu_up.get_node("Coins").text = c
	menu_hero.get_node("Coins").text = c
	(menu_main.get_node("QBtn") as Button).text = "QUALITY: " + ("HIGH" if int(save["quality"]) == 1 else "BALANCED")
	(menu_main.get_node("FBtn") as Button).text = "FPS: " + ("ON" if bool(save["fps"]) else "OFF")
	for k in UPGRADES.keys():
		var lv := int(save["up"][k])
		(menu_up.get_node("N_" + k) as Label).text = "%s  LV %d" % [UPGRADES[k]["name"], lv]
		var b := menu_up.get_node("B_" + k) as Button
		b.text = str(upgrade_cost(k))
		b.disabled = int(save["coins"]) < upgrade_cost(k)
	for k in HEROES.keys():
		var hb := menu_hero.get_node("H_" + k) as Button
		if k in save["heroes"]:
			hb.text = "ACTIVE" if str(save["hero"]) == k else "SELECT"
			hb.disabled = str(save["hero"]) == k
		else:
			hb.text = str(HEROES[k]["cost"])
			hb.disabled = int(save["coins"]) < int(HEROES[k]["cost"])
	lbl_zone.text = "ZONE %d: %s" % [int(save["zone"]) + 1, zone["name"]]

func change_zone(d: int) -> void:
	var z := clampi(int(save["zone"]) + d, 0, mini(int(save["unlocked"]), ZONES.size() - 1))
	if z == int(save["zone"]):
		snd("bad", -6.0)
		return
	save["zone"] = z
	write_save()
	zone = ZONES[z]
	apply_zone_look()
	level = build_level()
	refresh_menu()

func buy_upgrade(k: String) -> void:
	var cost := upgrade_cost(k)
	if int(save["coins"]) < cost:
		return
	save["coins"] = int(save["coins"]) - cost
	save["up"][k] = int(save["up"][k]) + 1
	write_save()
	compute_stats()
	update_squad_visibility()
	snd("gate", -4.0)
	refresh_menu()

func pick_hero(k: String) -> void:
	if k != "" and not (k in save["heroes"]):
		var cost := int(HEROES[k]["cost"])
		if int(save["coins"]) < cost:
			return
		save["coins"] = int(save["coins"]) - cost
		save["heroes"].append(k)
		snd("gate", -4.0)
	save["hero"] = k
	write_save()
	Engine.set_meta("autostart", false)
	get_tree().reload_current_scene()

func popup(txt: String, col := Color(1, 0.95, 0.4)) -> void:
	center_msg.text = txt
	center_msg.add_theme_color_override("font_color", col)
	center_msg.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(center_msg, "modulate:a", 0.0, 0.5)

# ---------------------------------------------------------------- game flow
func start_game() -> void:
	state = "play"
	lbl_weapon.visible = true
	dist = 0.0
	next_event = 0
	run_coins = 0
	lbl_coins.text = "0"
	lbl_weapon.text = WEAPONS[weapon_idx]["name"]
	update_squad_visibility()
	if auto_play and OS.get_environment("DZM_START") != "":
		dist = float(OS.get_environment("DZM_START"))
		squad_count = int(OS.get_environment("DZM_SQUAD")) if OS.get_environment("DZM_SQUAD") != "" else squad_count
		while next_event < level.size() and float(level[next_event]["d"]) < dist:
			next_event += 1
		update_squad_visibility()
		set_weapon(int(OS.get_environment("DZM_WEAPON")) if OS.get_environment("DZM_WEAPON") != "" else 0)
	popup("GO!", Color(0.6, 1, 0.6))

func end_game(won: bool) -> void:
	if state != "play":
		return
	state = "win" if won else "lose"
	for c in soldiers:
		play(c["ap"], "r_idle_aim", 1.0, 0.2)
	var bonus := 0
	btn_is_next = false
	if won:
		bonus = 80 + 60 * int(save["zone"])
		if int(save["zone"]) >= int(save["unlocked"]) and int(save["zone"]) < ZONES.size() - 1:
			save["unlocked"] = int(save["zone"]) + 1
		btn_is_next = int(save["zone"]) < int(save["unlocked"])
	save["coins"] = int(save["coins"]) + run_coins + bonus
	write_save()
	snd("win" if won else "lose", -4.0)
	var btn_txt := "NEXT ZONE" if btn_is_next else ("REPLAY" if won else "RETRY")
	if won:
		show_overlay("ZONE CLEARED!", "Kills: %d     Coins: %d  +%d bonus\nSquad left: %d" % [kills, run_coins, bonus, squad_count], btn_txt)
	else:
		show_overlay("SQUAD DOWN", "Kills: %d     Coins: %d\nThe horde got through. Try again!" % [kills, run_coins], btn_txt)

# ---------------------------------------------------------------- input
func _unhandled_input(event: InputEvent) -> void:
	if state != "play":
		return
	if event is InputEventScreenDrag:
		target_x += event.relative.x / get_viewport().get_visible_rect().size.x * 12.0
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0 and not auto_play:
		target_x += event.relative.x / get_viewport().get_visible_rect().size.x * 12.0
	target_x = clampf(target_x, -LANE_HALF + 0.8, LANE_HALF - 0.8)

# ---------------------------------------------------------------- spawning
func queue_event(ev: Dictionary) -> void:
	var d: float = ev["d"]
	var z := -d
	match ev["t"]:
		"gate":
			spawn_gate(d, ev["l"], ev["r"])
		"rescue":
			spawn_queue.append({"fn": "rescue", "z": z, "x": ev["x"]})
		"horde":
			var n: int = ev["n"]
			for i in range(n):
				var kind: String = ev["kind"]
				if kind == "mixed":
					kind = "runner" if i % 3 == 0 else "walker"
				elif kind == "mixed_bomb":
					kind = "bomber" if i % 5 == 0 else ("runner" if i % 3 == 0 else "walker")
				spawn_queue.append({"fn": "zombie", "kind": kind, "z": z - randf_range(0, 9), "x": randf_range(-LANE_HALF + 0.6, LANE_HALF - 0.6), "d": d})
		"elite":
			spawn_queue.append({"fn": "zombie", "kind": "elite", "z": z, "x": 0.0, "d": d})
			for i in range(6):
				spawn_queue.append({"fn": "zombie", "kind": "walker", "z": z + randf_range(2, 10) * -1.0, "x": randf_range(-2.8, 2.8), "d": d})
		"boss":
			spawn_queue.append({"fn": "zombie", "kind": "boss", "z": z, "x": 0.0, "d": d})

func spawn_gate(d: float, l: Dictionary, r: Dictionary) -> void:
	var g := {"d": d, "used": false, "sides": [l, r], "nodes": []}
	for si in range(2):
		var side: Dictionary = g["sides"][si]
		var good: bool = side["k"] in ["add", "mul", "weapon"]
		var col := Color(0.2, 0.55, 1.0) if good else Color(0.95, 0.2, 0.2)
		if side["k"] == "weapon":
			col = Color(1.0, 0.75, 0.15)
		var panel := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(LANE_HALF - 0.15, 3.4, 0.25)
		panel.mesh = bm
		var m := mat(col, 0.4, 0.5)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.albedo_color = Color(col.r, col.g, col.b, 0.7)
		panel.material_override = m
		panel.position = Vector3((-1 if si == 0 else 1) * LANE_HALF / 2.0, 1.5, -d)
		add_child(panel)
		var lb := Label3D.new()
		lb.font = font
		lb.font_size = 150
		lb.pixel_size = 0.012
		lb.outline_size = 40
		lb.outline_modulate = Color(0.09, 0.06, 0.27)
		match side["k"]:
			"add": lb.text = "+%d" % side["v"]
			"sub": lb.text = "-%d" % side["v"]
			"mul": lb.text = "x%d" % side["v"]
			"weapon": lb.text = "WEAPON\nUPGRADE"
		if side["k"] == "weapon":
			lb.text = "NEW\nGUN"
			lb.font_size = 120
		lb.position = Vector3(0, 0, 0.16)
		panel.add_child(lb)
		g["nodes"].append(panel)
	gates.append(g)

func spawn_zombie(job: Dictionary) -> void:
	var kind: String = job["kind"]
	var path := ""
	var h := 1.85
	var hp := 55.0
	var spd := 1.7
	var anim := "z_walk"
	var anim_speed := 1.4
	var dmg := 1.0
	match kind:
		"walker":
			path = "res://assets/zombies/%s.glb" % WALKERS[randi() % WALKERS.size()]
			h = randf_range(2.35, 2.7)
			hp = 90.0
			spd = randf_range(1.5, 2.1)
		"runner":
			path = "res://assets/zombies/%s.glb" % RUNNERS[randi() % RUNNERS.size()]
			h = randf_range(2.2, 2.5)
			hp = 60.0
			spd = randf_range(3.4, 4.2)
			anim = "z_run"
			anim_speed = 1.0
		"bomber":
			path = "res://assets/zombies/skinless.glb"
			h = 2.4
			hp = 45.0
			spd = 3.0
			anim = "z_run"
			anim_speed = 1.0
		"elite":
			path = "res://assets/%s.glb" % zone["elite"]
			h = 3.7
			hp = 3000.0
			spd = 1.5
			dmg = 3.0
		"boss":
			path = "res://assets/%s.glb" % zone["boss"]
			h = float(zone["boss_h"])
			hp = float(zone["boss_hp"])
			spd = 2.4
			dmg = 6.0
	if kind != "boss":
		hp *= float(zone["hpm"])
	var c := make_char(path, h)
	if kind == "bomber":
		darken(c["model"], Color(2.4, 0.8, 0.6))
	else:
		for mi in (c["model"] as Node).find_children("*", "MeshInstance3D", true, false):
			(mi as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	(c["ap"] as AnimationPlayer).callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var logic: Node3D = c["logic"]
	add_child(logic)
	logic.position = Vector3(job["x"], 0, job["z"])
	logic.rotation.y = 0.0
	var z := {"c": c, "logic": logic, "ap": c["ap"], "hp": hp, "maxhp": hp, "spd": spd, "anim": anim, "anim_speed": anim_speed, "dmg": dmg, "kind": kind,
		"state": "idle", "atk_t": 0.0, "dead_t": 0.0, "acc": 0.0, "radius": 0.9 if kind != "boss" else 2.4, "h": h, "off": randf() * 6.0}
	play(c["ap"], "z_idle", randf_range(0.8, 1.2), 0.0)
	if c["ap"].has_animation("z_idle"):
		c["ap"].seek(randf() * 3.0, true)
	if kind == "boss":
		boss = z
		boss_bar.max_value = hp
		boss_bar.value = hp
	zombies.append(z)

func spawn_rescue(job: Dictionary) -> void:
	var nm: String = CIVILIANS[randi() % CIVILIANS.size()]
	var c := make_char("res://assets/civilians/%s.glb" % nm, 1.7)
	var logic: Node3D = c["logic"]
	add_child(logic)
	logic.position = Vector3(job["x"], 0, job["z"])
	logic.rotation.y = PI if job["x"] > 0 else PI  # face the road
	play(c["ap"], "r_crouch_aim", 1.0, 0.0)
	var cage := Node3D.new()
	cage.position = logic.position
	add_child(cage)
	var barm := mat(Color(0.5, 0.52, 0.58), 0.4)
	for bx in [-0.8, -0.4, 0.0, 0.4, 0.8]:
		for bz in [-0.8, 0.8]:
			var bar := MeshInstance3D.new()
			var bm := BoxMesh.new()
			bm.size = Vector3(0.07, 2.2, 0.07)
			bar.mesh = bm
			bar.material_override = barm
			bar.position = Vector3(bx, 1.1, bz)
			cage.add_child(bar)
	for ty in [0.05, 2.2]:
		var top := MeshInstance3D.new()
		var tm := BoxMesh.new()
		tm.size = Vector3(1.8, 0.1, 1.8)
		top.mesh = tm
		top.material_override = barm
		top.position = Vector3(0, ty, 0)
		cage.add_child(top)
	var lb := Label3D.new()
	lb.text = "HELP!"
	lb.font = font
	lb.font_size = 100
	lb.pixel_size = 0.01
	lb.outline_size = 30
	lb.outline_modulate = Color(0.09, 0.06, 0.27)
	lb.modulate = Color(1, 0.4, 0.3)
	lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lb.position = Vector3(0, 3.0, 0)
	cage.add_child(lb)
	cages.append({"logic": logic, "cage": cage, "x": job["x"], "z": job["z"], "c": c, "done": false, "lb": lb})

# ---------------------------------------------------------------- effects
func add_tracer(from: Vector3, to: Vector3, col: Color) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	var len := from.distance_to(to)
	bm.size = Vector3(0.07, 0.07, minf(len, 1.1))
	mi.mesh = bm
	var m := mat(col, 0.3, 3.0)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mi.material_override = m
	add_child(mi)
	mi.look_at_from_position(from, to, Vector3.UP)
	tracers.append({"n": mi, "from": from, "to": to, "t": 0.0})

func update_tracers(delta: float) -> void:
	var i := tracers.size() - 1
	while i >= 0:
		var t: Dictionary = tracers[i]
		t["t"] += delta / 0.09
		var p: Vector3 = t["from"].lerp(t["to"], clampf(t["t"], 0.0, 1.0))
		(t["n"] as Node3D).global_position = p
		if t["t"] >= 1.0:
			(t["n"] as Node).queue_free()
			tracers.remove_at(i)
		i -= 1

func flash(pos: Vector3, col: Color) -> void:
	var mi := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.13
	sm.height = 0.26
	mi.mesh = sm
	var m := mat(col, 0.3, 4.0)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	mi.global_position = pos
	get_tree().create_timer(0.05).timeout.connect(mi.queue_free)

func explode_at(pos: Vector3, self_z: Dictionary) -> void:
	snd("boom", -4.0, randf_range(0.9, 1.1))
	blood(pos + Vector3(0, 1.0, 0), true)
	float_text(pos + Vector3(0, 2.4, 0), "BOOM!", Color(1, 0.6, 0.2))
	for z in zombies:
		if z != self_z and z["state"] != "dead":
			var dp: Vector3 = (z["logic"] as Node3D).global_position - pos
			if dp.length() < 3.4:
				damage_zombie(z, 80.0)

func blood(pos: Vector3, big := false) -> void:
	var p := CPUParticles3D.new()
	p.emitting = true
	p.one_shot = true
	p.amount = 18 if big else 8
	p.lifetime = 0.5
	p.explosiveness = 1.0
	p.direction = Vector3(0, 1, 0.5)
	p.spread = 70
	p.initial_velocity_min = 2.0
	p.initial_velocity_max = 4.5
	p.gravity = Vector3(0, -9, 0)
	var sm := SphereMesh.new()
	sm.radius = 0.06
	sm.height = 0.12
	p.mesh = sm
	p.material_override = mat(Color(0.65, 0.05, 0.08), 0.5, 0.6)
	add_child(p)
	p.global_position = pos
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func float_text(pos: Vector3, txt: String, col: Color) -> void:
	var lb := Label3D.new()
	lb.text = txt
	lb.font = font
	lb.font_size = 100
	lb.pixel_size = 0.0075
	lb.outline_size = 28
	lb.outline_modulate = Color(0.09, 0.06, 0.27)
	lb.modulate = col
	lb.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lb.no_depth_test = true
	add_child(lb)
	lb.global_position = pos
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(lb, "global_position", pos + Vector3(0, 2.0, 0), 0.9)
	tw.tween_property(lb, "modulate:a", 0.0, 0.9)
	tw.chain().tween_callback(lb.queue_free)

# ---------------------------------------------------------------- squad logic
func change_squad(delta_n: int, pos: Vector3, txt := "", col := Color(1, 0.9, 0.3)) -> void:
	squad_count = clampi(squad_count + delta_n, 0, MAX_SQUAD)
	update_squad_visibility()
	if txt != "":
		float_text(pos, txt, col)
	if squad_count <= 0:
		end_game(false)

func apply_gate(side: Dictionary) -> void:
	var p := squad_root.global_position + Vector3(0, 3.6, 0)
	snd("bad" if side["k"] == "sub" else "gate", -4.0)
	match side["k"]:
		"add":
			change_squad(side["v"], p, "+%d" % side["v"], Color(0.5, 0.8, 1))
		"sub":
			change_squad(-side["v"], p, "-%d" % side["v"], Color(1, 0.4, 0.4))
			shake = 0.3
		"mul":
			var extra: int = squad_count * (int(side["v"]) - 1)
			change_squad(extra, p, "x%d" % side["v"], Color(0.5, 0.8, 1))
		"weapon":
			if weapon_idx < WEAPONS.size() - 1:
				set_weapon(weapon_idx + 1)
				float_text(p, WEAPONS[weapon_idx]["name"] + "!", Color(1, 0.8, 0.2))
			else:
				change_squad(5, p, "+5", Color(0.5, 0.8, 1))

func nearest_zombie(range_: float) -> Dictionary:
	var best: Dictionary = {}
	var bd := range_
	for z in zombies:
		if z["state"] == "dead":
			continue
		var zp: Vector3 = (z["logic"] as Node3D).position
		var dz: float = squad_root.position.z - zp.z   # positive if zombie is ahead (more negative z)
		if dz < -1.0:
			continue
		var d := Vector2(zp.x - squad_root.position.x, zp.z - squad_root.position.z).length()
		if d < bd:
			bd = d
			best = z
	return best

func damage_zombie(z: Dictionary, amount: float) -> void:
	if z["state"] == "dead":
		return
	z["hp"] -= amount
	if z == boss:
		boss_bar.max_value = z["maxhp"]
		boss_bar.value = maxf(z["hp"], 0.0)
	if z["hp"] <= 0.0:
		z["state"] = "dead"
		kills += 1
		var pts: int = 1 if z["kind"] in ["walker", "runner"] else (15 if z["kind"] == "elite" else 100)
		run_coins += pts
		lbl_coins.text = str(run_coins)
		var lp := (z["logic"] as Node3D).global_position
		blood(lp + Vector3(0, 1.2, 0), z["kind"] in ["elite", "boss"])
		snd("zdie", -10.0, randf_range(0.85, 1.15))
		play(z["ap"], "z_death" if randf() < 0.5 else "z_dying", 1.0, 0.1)
		if z["kind"] == "bomber":
			explode_at(lp, z)
		z["dead_t"] = 0.0
		if z == boss:
			boss_box.visible = false
			snd("boom", -2.0, 0.7)
			popup("BOSS DOWN!", Color(1, 0.6, 0.3))
			get_tree().create_timer(2.2).timeout.connect(func(): end_game(true))
		elif pts > 1:
			float_text(lp + Vector3(0, 2.5, 0), "+%d" % pts, Color(1, 0.88, 0.3))

# ---------------------------------------------------------------- main loop
func _process(delta: float) -> void:
	elapsed += delta
	perf_acc += delta
	if perf_acc > 0.5:
		perf_acc = 0.0
		lbl_fps.text = ("FPS %d" % int(Engine.get_frames_per_second())) if bool(save["fps"]) else ""
	if auto_play:
		_autoplay_step(delta)
	# camera follow (also in menu)
	var cz: float = squad_root.position.z
	var want := Vector3(squad_x * 0.45, 6.4 + shake * 0.5 * sin(elapsed * 60.0), cz + 8.6)
	cam.position = cam.position.lerp(want, clampf(delta * 6.0, 0.0, 1.0))
	if cam.position.distance_to(want) > 30.0:
		cam.position = want
	cam.look_at(Vector3(squad_x * 0.35, 1.0, cz - 7.5), Vector3.UP)
	shake = maxf(0.0, shake - delta)
	update_tracers(delta)
	if state != "play":
		return

	# spawn queue + events
	while next_event < level.size() and float(level[next_event]["d"]) - dist < SPAWN_AHEAD:
		queue_event(level[next_event])
		next_event += 1
	var budget := 3
	while budget > 0 and spawn_queue.size() > 0:
		var job: Dictionary = spawn_queue.pop_front()
		if job["fn"] == "zombie":
			spawn_zombie(job)
		else:
			spawn_rescue(job)
		budget -= 1

	# targets and speed
	var w: Dictionary = WEAPONS[weapon_idx]
	var tgt := nearest_zombie(float(w["range"]))
	var close_threat := false
	for z in zombies:
		if z["state"] == "dead":
			continue
		var zp: Vector3 = (z["logic"] as Node3D).position
		var dd: float = squad_root.position.z - zp.z
		if dd > 0.0 and dd < 15.0:
			close_threat = true
			break
	var want_speed := 0.3 if close_threat else 1.0
	if not boss.is_empty() and boss["state"] != "dead" and boss["state"] != "idle":
		want_speed = 0.0
	speed_factor = lerpf(speed_factor, want_speed, clampf(delta * 5.0, 0.0, 1.0))

	# move squad
	var step := RUN_SPEED * speed_factor * delta
	var boss_wall := LEVEL_LEN
	dist += step
	if not boss.is_empty():
		pass
	squad_x = lerpf(squad_x, target_x, clampf(delta * 9.0, 0.0, 1.0))
	squad_root.position = Vector3(squad_x, 0, -dist)
	progress.value = dist

	# soldiers' animation + follow wobble
	var moving := speed_factor > 0.55
	for i in range(soldiers.size()):
		var c: Dictionary = soldiers[i]
		if not c["logic"].visible:
			continue
		play(c["ap"], "r_run" if moving else "r_idle_aim", 1.0, 0.2)
		var lp: Vector3 = c["off"] + Vector3(sin(elapsed * 2.0 + i) * 0.08, 0, 0)
		c["logic"].position = c["logic"].position.lerp(lp, clampf(delta * 8.0, 0.0, 1.0))

	# firing
	fire_t -= delta
	if fire_t <= 0.0 and not tgt.is_empty():
		fire_t = float(w["rate"]) / rate_mult
		var shown := mini(squad_count, SQUAD_SHOW)
		var per_shot: float = float(w["dmg"]) * dmg_mult * (float(squad_count) / float(maxi(shown, 1)))
		snd("shot%d" % (1 + randi() % 3), -9.0, randf_range(0.92, 1.1) * (1.1 if weapon_idx == 1 else (0.9 if weapon_idx == 3 else 1.0)))
		var tp: Vector3 = (tgt["logic"] as Node3D).global_position + Vector3(0, tgt["h"] * 0.6, 0)
		var hit_n := 0
		for i in range(shown):
			var c: Dictionary = soldiers[i]
			var from: Vector3 = (c["logic"] as Node3D).global_position + Vector3(0.25, 1.35, -0.9)
			add_tracer(from, tp + Vector3(randf_range(-0.2, 0.2), randf_range(-0.2, 0.2), 0), w["col"])
			if i < 4:
				flash(from + Vector3(0, 0, -0.1), w["col"])
			hit_n += 1
		damage_zombie(tgt, per_shot * float(hit_n))
		# splash so hordes thin out (squad is a crowd, bullets spray)
		if per_shot * hit_n > 120.0:
			for z in zombies:
				if z != tgt and z["state"] != "dead":
					var dp := ((z["logic"] as Node3D).position - (tgt["logic"] as Node3D).position)
					if dp.length() < 1.6:
						damage_zombie(z, per_shot * float(hit_n) * 0.25)
		if randf() < 0.35:
			blood(tp, false)

	# gates
	for g in gates:
		if g["used"]:
			continue
		if dist >= g["d"]:
			g["used"] = true
			var si := 0 if squad_x < 0.0 else 1
			apply_gate(g["sides"][si])
			var other: MeshInstance3D = g["nodes"][si]
			other.visible = false
	# rescues
	for cg in cages:
		if cg["done"]:
			continue
		if dist >= -float(cg["z"]) - 0.5 and absf(squad_x - float(cg["x"])) < 2.4:
			cg["done"] = true
			(cg["cage"] as Node3D).queue_free()
			change_squad(6, squad_root.global_position)
			popup("RESCUED +6", Color(0.5, 1, 0.6))
			play(cg["c"]["ap"], "r_run", 1.0, 0.1)
			var lg: Node3D = cg["logic"]
			var tw := create_tween()
			tw.tween_property(lg, "position", lg.position + Vector3(0, 0, 14), 2.0)
			tw.tween_callback(lg.queue_free)

	# zombies
	var squad_p := squad_root.position
	var i2 := zombies.size() - 1
	while i2 >= 0:
		var z: Dictionary = zombies[i2]
		var lg: Node3D = z["logic"]
		if z["state"] == "dead":
			z["dead_t"] += delta
			(z["ap"] as AnimationPlayer).advance(delta)
			if z["dead_t"] > 3.0:
				lg.queue_free()
				zombies.remove_at(i2)
			i2 -= 1
			continue
		var to := Vector3(squad_p.x - lg.position.x, 0, squad_p.z - lg.position.z)
		var dlen := to.length()
		if z["state"] == "idle":
			if dlen < WAKE_DIST or lg.position.z > squad_p.z - 2.0:
				z["state"] = "chase"
				play(z["ap"], z["anim"], float(z["anim_speed"]) * randf_range(0.9, 1.1), 0.2)
			else:
				i2 -= 1
				continue
		if z["state"] == "chase" or z["state"] == "attack":
			z["acc"] += delta
			var far_z: bool = dlen > 22.0
			if not far_z or z["acc"] >= 0.07:
				(z["ap"] as AnimationPlayer).advance(z["acc"])
				z["acc"] = 0.0
			var reach: float = 1.3 + float(z["radius"])
			if dlen > reach and not (z["kind"] == "boss" and lg.position.z > squad_p.z + 1.0):
				var dirv := to / maxf(dlen, 0.001)
				lg.position += dirv * float(z["spd"]) * delta
				lg.position.x = clampf(lg.position.x, -LANE_HALF - 1.0, LANE_HALF + 1.0)
				if z["state"] == "attack":
					z["state"] = "chase"
					play(z["ap"], z["anim"], float(z["anim_speed"]), 0.2)
			elif dlen <= reach and z["kind"] == "bomber":
				z["state"] = "dead"
				z["dead_t"] = 99.0
				lg.visible = false
				explode_at(lg.global_position, z)
				shake = 0.35
				change_squad(-6, squad_root.global_position + Vector3(0, 3.8, 0), "-6", Color(1, 0.35, 0.35))
			elif dlen <= reach:
				if z["state"] != "attack":
					z["state"] = "attack"
					play(z["ap"], "z_attack", 1.2, 0.15)
				z["atk_t"] += delta
				if z["atk_t"] >= 1.0:
					z["atk_t"] = 0.0
					var loss := int(z["dmg"]) if squad_count > 12 else 1
					if z["kind"] == "boss":
						loss = maxi(3, int(float(squad_count) * 0.08 * boss_resist))
						shake = 0.35
					blood(squad_root.global_position + Vector3(randf_range(-1, 1), 1.2, 0), false)
					change_squad(-loss, squad_root.global_position + Vector3(0, 3.8, 0), "-%d" % loss, Color(1, 0.35, 0.35))
			# face the squad (model child is rotated PI already, so look_at -Z toward target)
			if dlen > 0.5:
				lg.look_at(lg.global_position + Vector3(to.x, 0, to.z), Vector3.UP)
		i2 -= 1

	# boss gets triggered by distance and keeps the squad from running past
	if not boss.is_empty() and boss["state"] == "idle" and dist > LEVEL_LEN - 62.0:
		boss["state"] = "chase"
		play(boss["ap"], "z_scream", 1.0, 0.1)
		snd("roar", -2.0, 0.8)
		popup(str(zone["boss_name"]) + "!", Color(1, 0.4, 0.35))
		get_tree().create_timer(2.4).timeout.connect(func(): if not boss.is_empty() and boss["state"] == "chase": play(boss["ap"], "z_walk", 0.9, 0.3))
		boss_box.visible = true
		boss_bar.max_value = boss["maxhp"]
		boss_bar.value = boss["hp"]

# ---------------------------------------------------------------- test autopilot (DZM_SHOTS)
func _autoplay_step(delta: float) -> void:
	# crude steering: pick the better gate side, otherwise stay mid-lane
	var best_x := 0.0
	for g in gates:
		if g["used"]:
			continue
		var dd: float = float(g["d"]) - dist
		if dd < 30.0 and dd > 0.0:
			var sc: Array = []
			for s in g["sides"]:
				var v := 0.0
				match s["k"]:
					"add": v = float(s["v"])
					"mul": v = float(squad_count)
					"weapon": v = 50.0
					"sub": v = -float(s["v"])
				sc.append(v)
			best_x = -1.6 if sc[0] >= sc[1] else 1.6
			break
	for cg in cages:
		if not cg["done"] and absf(-float(cg["z"]) - dist) < 18.0:
			best_x = float(cg["x"])
	target_x = best_x
	if shot_i < shot_times.size() and elapsed >= shot_times[shot_i]:
		var img := get_viewport().get_texture().get_image()
		img.save_png("%s/shot_%02d.png" % [shots_dir, shot_i])
		print("SHOT ", shot_i, " t=", elapsed, " dist=", dist, " squad=", squad_count, " weapon=", WEAPONS[weapon_idx]["name"], " zombies=", zombies.size(), " state=", state)
		shot_i += 1
		if shot_i >= shot_times.size():
			get_tree().quit()
