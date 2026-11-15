## 3D warrior: same rules as the 2D test (positions in "game units", 1 unit = 1.2 cm),
## drawn as a skinned 3D model with real animations + procedural moves layered on the skeleton.
class_name Fighter3D
extends Node3D

const U := 0.012          # game units -> metres
const GRAV := 2700.0
const MAX_FALL := 1150.0
const FAST_FALL := 1700.0
const W := 56.0
const H := 150.0

var id := ""
var team := 0
var slot := 0
var game: Node
var ctrl: Object
var data: Dictionary
var look: Dictionary

var pos := Vector2.ZERO
var vel := Vector2.ZERO
var facing := 1
var on_ground := true
var jumps := 2
var dmg := 0.0
var stocks := 3
var state := "free"
var st_time := 0.0
var atk: Dictionary = {}
var atk_done := {}
var keys_done := 0
var hitstun := 0.0
var invuln := 0.0
var dodge_cd := 0.0
var air_dodged := false
var weapon := ""
var charge := 0.0
var charging := false
var hitstop := 0.0
var tumble := false
var alive := true
var eliminated := false
var respawn_t := 0.0
var flash := 0.0
var last_hit_by = null
var stats := {"kos": 0, "falls": 0, "dmg_done": 0.0, "dmg_taken": 0.0}
var inp: Dictionary = {}
var ghost_t := 0.0
var trail_t := 0.0
var spin := 0.0
var squash := 1.0
var cur_anim := ""
var victory := false

# visual nodes
var pivot: Node3D          # spins for tumbles / flips
var model: Node3D
var sk: Skeleton3D
var ap: AnimationPlayer
var mats: Array[ShaderMaterial] = []
var bones := {}            # name -> idx
var over_target := {}      # bone idx -> Quaternion
var over_cur := {}         # bone idx -> Quaternion
var over_speed := 14.0
var base_saved := {}
var tail_nodes: Array = []
var model_yaw := 90.0

func setup(char_id: String, g: Node, controller: Object, team_id: int, slot_id: int, look_data: Dictionary) -> void:
	id = char_id
	game = g
	ctrl = controller
	team = team_id
	slot = slot_id
	data = Chars.DATA[id]
	look = look_data
	pivot = Node3D.new()
	add_child(pivot)
	model = load("res://models/mannequin.glb").instantiate()
	pivot.add_child(model)
	pivot.position.y = 0.9
	model.position.y = -0.9
	sk = model.get_node("root/Skeleton3D")
	ap = model.get_node("AnimationPlayer")
	ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for a in ["fight_idle", "run", "idle"]:
		ap.get_animation(a).loop_mode = Animation.LOOP_LINEAR
	for i in sk.get_bone_count():
		bones[sk.get_bone_name(i)] = i
	var body: MeshInstance3D = sk.get_node("body_001")
	var skin := Look.toon(look.skin, look.shade, look.get("pattern", 0), look.get("pattern_color", Color.BLACK), look.get("pattern_scale", 14.0))
	mats.append(skin)
	body.material_override = skin
	play("fight_idle", 1.0, 0.0)
	ap.advance(0.0)

func dress() -> void:
	Look.dress(self)

func center() -> Vector2:
	return pos + Vector2(0, -H * 0.5)

func hurt_rect() -> Rect2:
	return Rect2(pos.x - W * 0.5, pos.y - H, W, H)

func world3(p: Vector2) -> Vector3:
	return Vector3(p.x * U, -p.y * U, 0.0)

func bone_point(b: String) -> Vector2:
	var g: Vector3 = sk.global_transform * sk.get_bone_global_pose(bones[b]).origin
	return Vector2(g.x / U, -g.y / U)

# ------------------------------------------------------------------ animation layer
func play(name: String, speed: float = 1.0, blend: float = 0.1, restart := false) -> void:
	if cur_anim == name and not restart:
		ap.speed_scale = speed
		return
	cur_anim = name
	ap.play(name, blend)
	ap.speed_scale = speed
	if restart:
		ap.seek(0.0, true)

## procedural bone offsets layered on top of the animation (degrees around the bone's local X/Y/Z)
func pose(p: Dictionary, speed: float = 14.0) -> void:
	over_speed = speed
	var new_t := {}
	for b in p:
		if bones.has(b):
			var e: Vector3 = p[b]
			new_t[bones[b]] = Quaternion.from_euler(e * (PI / 180.0))
	for i in over_cur.keys():
		if not new_t.has(i):
			new_t[i] = Quaternion.IDENTITY
	over_target = new_t

func _process(delta: float) -> void:
	if sk == null:
		return
	var dt := 0.0 if hitstop > 0.0 else delta
	for i in base_saved:
		sk.set_bone_pose_rotation(i, base_saved[i])
	ap.advance(dt)
	base_saved.clear()
	for bn in BULK:
		if bones.has(bn):
			sk.set_bone_pose_scale(bones[bn], BULK[bn])
	var a := 1.0 - exp(-over_speed * delta)
	for i in over_target:
		var cur: Quaternion = over_cur.get(i, Quaternion.IDENTITY)
		cur = cur.slerp(over_target[i], a)
		over_cur[i] = cur
		var base := sk.get_bone_pose_rotation(i)
		base_saved[i] = base
		sk.set_bone_pose_rotation(i, base * cur)
	# tail sway (kangaroo): springy follow of the body motion
	for k in tail_nodes.size():
		var tn: Node3D = tail_nodes[k]
		var sway := sin(Time.get_ticks_msec() * 0.004 + k * 0.7) * 6.0 - clampf(vel.x * facing * 0.01, -10, 10) * (k + 1) * 0.5
		tn.rotation_degrees.x = tn.get_meta("base_x") + sway
	_visual(delta)

## bone scale (x/z thicken a limb; children get the inverse so hands and feet keep their size)
const BULK := {
	"spine_02": Vector3(1.3, 1.0, 1.25), "neck_01": Vector3(1.05, 1.0, 1.0), "head": Vector3(1.0, 1.05, 1.0),
	"clavicle.l": Vector3(0.77, 1.12, 0.8), "clavicle.r": Vector3(0.77, 1.12, 0.8),
	"upperarm.l": Vector3(1.45, 1.0, 1.45), "upperarm.r": Vector3(1.45, 1.0, 1.45),
	"lowerarm.l": Vector3(0.95, 1.0, 0.95), "lowerarm.r": Vector3(0.95, 1.0, 0.95),
	"hand.l": Vector3(0.9, 1.1, 0.9), "hand.r": Vector3(0.9, 1.1, 0.9),
	"spine_01": Vector3(1.2, 1.0, 1.15),
	"thigh.l": Vector3(1.35, 1.0, 1.35), "thigh.r": Vector3(1.35, 1.0, 1.35),
	"calf.l": Vector3(0.92, 1.0, 0.92), "calf.r": Vector3(0.92, 1.0, 0.92),
	"foot.l": Vector3(0.85, 1.0, 0.85), "foot.r": Vector3(0.85, 1.0, 0.85),
}

# ------------------------------------------------------------------ moves
const ARM_UP := Vector3(0, 0, -1)     # rotation axis signs for the right arm raise found in the axis test
func _atk(name: String, total: float, anim: Array, keys: Array, hits: Array, extra := {}) -> Dictionary:
	var d := {"name": name, "total": total, "anim": anim, "keys": keys, "hits": hits, "lunge": [], "sfx": [], "charge_at": -1.0}
	d.merge(extra, true)
	return d

func attack_for(kind: String) -> Dictionary:
	var air := not on_ground
	var up: bool = inp.get("my", 0.0) < -0.5
	var down: bool = inp.get("my", 0.0) > 0.5
	if weapon == "axe":
		return A_AXE(kind, up)
	if kind == "light":
		if air:
			if up: return A_AIR_UP()
			return A_AIR_KICK()
		if up: return A_UPPERCUT()
		if down: return A_LOW_KICK()
		return A_JAB()
	if air and down: return A_POUND()
	if up: return A_LAUNCHER()
	if down and not air: return A_SLAM()
	return A_SIGNATURE()

func A_JAB() -> Dictionary:
	return _atk("Jab", 0.34, ["fight_punch", 1.5], [[0.0, {"spine_01": Vector3(8, 0, 0)}, 20.0]],
		[{"t0": 0.07, "t1": 0.2, "bones": ["hand.r"], "r": 28.0, "dmg": 6.0, "base": 240.0, "growth": 3.0, "angle": 28.0}],
		{"lunge": [[0.06, Vector2(260, 0)]], "sfx": [[0.05, "whoosh"]]})

func A_UPPERCUT() -> Dictionary:
	return _atk("Uppercut", 0.46, ["fight_punch", 1.2],
		[[0.0, {"spine_01": Vector3(18, 0, 0), "upperarm.r": Vector3(0, 0, 20)}, 20.0],
		[0.1, {"spine_01": Vector3(-22, 0, 0), "spine_02": Vector3(-10, 0, 0), "upperarm.r": Vector3(0, 0, -95), "lowerarm.r": Vector3(0, 0, -20)}, 40.0],
		[0.32, {}, 10.0]],
		[{"t0": 0.11, "t1": 0.24, "bones": ["hand.r"], "r": 32.0, "dmg": 8.0, "base": 300.0, "growth": 3.4, "angle": 84.0}],
		{"lunge": [[0.1, Vector2(80, -160)]], "sfx": [[0.09, "whoosh"]]})

func A_LOW_KICK() -> Dictionary:
	return _atk("Low Kick", 0.48, ["fight_kick", 2.3], [[0.0, {"spine_01": Vector3(-12, 0, 0)}, 20.0]],
		[{"t0": 0.12, "t1": 0.3, "bones": ["ball.r", "foot.r"], "r": 30.0, "dmg": 7.0, "base": 260.0, "growth": 3.0, "angle": 20.0}],
		{"lunge": [[0.1, Vector2(160, 0)]], "sfx": [[0.1, "whoosh"]]})

func A_AIR_KICK() -> Dictionary:
	return _atk("Flying Kick", 0.44, ["fight_kick", 2.4], [[0.0, {"spine_01": Vector3(-15, 0, 0)}, 25.0]],
		[{"t0": 0.1, "t1": 0.3, "bones": ["ball.r", "foot.r"], "r": 32.0, "dmg": 7.0, "base": 260.0, "growth": 3.2, "angle": 36.0}],
		{"lunge": [[0.08, Vector2(150, -80)]], "sfx": [[0.07, "whoosh"]]})

func A_AIR_UP() -> Dictionary:
	return _atk("Flip Kick", 0.5, ["fight_kick", 2.2], [[0.0, {"spine_01": Vector3(-35, 0, 0), "spine_02": Vector3(-20, 0, 0)}, 25.0]],
		[{"t0": 0.1, "t1": 0.3, "bones": ["ball.r", "foot.r"], "r": 34.0, "dmg": 7.0, "base": 280.0, "growth": 3.3, "angle": 86.0}],
		{"lunge": [[0.08, Vector2(0, -260)]], "sfx": [[0.07, "whoosh"]], "flip": true})

func A_LAUNCHER() -> Dictionary:
	return _atk("Sky Launcher", 0.72, ["fight_punch", 0.9],
		[[0.0, {"spine_01": Vector3(30, 0, 0), "thigh.r": Vector3(0, 0, 25), "upperarm.r": Vector3(0, 0, 30), "upperarm.l": Vector3(0, 0, -30)}, 16.0],
		[0.24, {"spine_01": Vector3(-25, 0, 0), "spine_02": Vector3(-12, 0, 0), "upperarm.r": Vector3(0, 0, -150), "upperarm.l": Vector3(0, 0, 150), "lowerarm.r": Vector3(0, 0, -10), "lowerarm.l": Vector3(0, 0, 10)}, 40.0],
		[0.52, {}, 8.0]],
		[{"t0": 0.25, "t1": 0.38, "bones": ["hand.r", "hand.l"], "r": 40.0, "dmg": 13.0, "base": 420.0, "growth": 7.0, "angle": 86.0, "heavy": true}],
		{"lunge": [[0.24, Vector2(60, -420)]], "sfx": [[0.22, "whoosh_heavy"]], "charge_at": 0.2})

func A_SLAM() -> Dictionary:
	return _atk("Ground Slam", 0.78, ["fight_idle", 1.0],
		[[0.0, {"spine_01": Vector3(-25, 0, 0), "upperarm.r": Vector3(0, 0, -150), "upperarm.l": Vector3(0, 0, 150)}, 16.0],
		[0.26, {"spine_01": Vector3(40, 0, 0), "spine_02": Vector3(20, 0, 0), "upperarm.r": Vector3(0, 0, -20), "upperarm.l": Vector3(0, 0, 20), "thigh.r": Vector3(0, 0, 30), "calf.r": Vector3(0, 0, -40)}, 45.0],
		[0.56, {}, 8.0]],
		[{"t0": 0.27, "t1": 0.36, "bones": ["hand.r", "hand.l"], "r": 46.0, "dmg": 14.0, "base": 400.0, "growth": 6.6, "angle": 58.0, "heavy": true}],
		{"sfx": [[0.24, "whoosh_heavy"]], "charge_at": 0.22, "quake_at": 0.28})

func A_POUND() -> Dictionary:
	return _atk("Meteor Pound", 0.8, ["air_jump", 0.5],
		[[0.0, {"spine_01": Vector3(-20, 0, 0), "upperarm.r": Vector3(0, 0, -150), "upperarm.l": Vector3(0, 0, 150)}, 24.0],
		[0.16, {"spine_01": Vector3(10, 0, 0), "upperarm.r": Vector3(0, 0, -170), "upperarm.l": Vector3(0, 0, 170)}, 30.0]],
		[{"t0": 0.17, "t1": 0.8, "bones": ["ball.r", "ball.l"], "r": 38.0, "dmg": 12.0, "base": 330.0, "growth": 5.0, "angle": -70.0, "heavy": true}],
		{"lunge": [[0.16, Vector2(0, 1500)]], "sfx": [[0.14, "whoosh_heavy"]], "pound": true})

func A_SIGNATURE() -> Dictionary:
	if id == "kangaroo":
		# leans back on the tail and drives both feet forward
		return _atk("Tail Kick", 0.86, ["fight_kick", 1.4],
			[[0.0, {"spine_01": Vector3(-30, 0, 0), "spine_02": Vector3(-15, 0, 0)}, 16.0],
			[0.3, {"spine_01": Vector3(-45, 0, 0), "spine_02": Vector3(-20, 0, 0), "thigh.l": Vector3(0, 0, -70), "calf.l": Vector3(0, 0, 30)}, 45.0],
			[0.62, {}, 8.0]],
			[{"t0": 0.3, "t1": 0.46, "bones": ["ball.r", "ball.l", "foot.r"], "r": 44.0, "dmg": 16.0, "base": 440.0, "growth": 7.6, "angle": 36.0, "heavy": true}],
			{"lunge": [[0.28, Vector2(460, -140)]], "sfx": [[0.26, "whoosh_heavy"]], "charge_at": 0.22})
	# Hyena Frenzy: three fast jabs then a launching haymaker
	return _atk("Frenzy", 1.0, ["fight_punch", 2.6],
		[[0.0, {"spine_01": Vector3(12, 0, 0)}, 30.0], [0.62, {"spine_01": Vector3(28, 0, 0), "spine_02": Vector3(10, 0, 0), "upperarm.r": Vector3(0, 0, -25)}, 40.0], [0.85, {}, 10.0]],
		[{"t0": 0.06, "t1": 0.14, "bones": ["hand.r"], "r": 30.0, "dmg": 3.0, "base": 110.0, "growth": 0.4, "angle": 15.0},
		{"t0": 0.25, "t1": 0.33, "bones": ["hand.r"], "r": 30.0, "dmg": 3.0, "base": 110.0, "growth": 0.4, "angle": 15.0},
		{"t0": 0.44, "t1": 0.52, "bones": ["hand.r"], "r": 30.0, "dmg": 3.0, "base": 110.0, "growth": 0.4, "angle": 15.0},
		{"t0": 0.66, "t1": 0.78, "bones": ["hand.r", "hand.l"], "r": 40.0, "dmg": 9.0, "base": 430.0, "growth": 7.2, "angle": 34.0, "heavy": true}],
		{"lunge": [[0.05, Vector2(170, 0)], [0.24, Vector2(170, 0)], [0.43, Vector2(170, 0)], [0.64, Vector2(380, 0)]],
		"sfx": [[0.04, "whoosh"], [0.23, "whoosh"], [0.42, "whoosh"], [0.62, "whoosh_heavy"]], "charge_at": 0.0, "replay": [0.0, 0.19, 0.38, 0.6]})

func A_AXE(kind: String, up: bool) -> Dictionary:
	if up:
		return _atk("Axe Riser", 0.62, ["fight_punch", 1.0],
			[[0.0, {"spine_01": Vector3(20, 0, 0), "upperarm.r": Vector3(0, 0, 30)}, 20.0],
			[0.16, {"spine_01": Vector3(-25, 0, 0), "upperarm.r": Vector3(0, 0, -165)}, 40.0], [0.44, {}, 10.0]],
			[{"t0": 0.17, "t1": 0.3, "bones": ["weapon"], "r": 46.0, "dmg": 13.0, "base": 360.0, "growth": 5.4, "angle": 85.0, "heavy": kind == "heavy", "metal": true}],
			{"lunge": [[0.16, Vector2(60, -200)]], "sfx": [[0.14, "whoosh_heavy"]]})
	var heavy := kind == "heavy"
	return _atk("Axe Cleave" if heavy else "Axe Chop", 0.86 if heavy else 0.54, ["fight_punch", 0.9],
		[[0.0, {"spine_01": Vector3(-20, 0, 0), "upperarm.r": Vector3(0, 0, -170)}, 18.0 if heavy else 26.0],
		[0.3 if heavy else 0.15, {"spine_01": Vector3(30, 0, 0), "spine_02": Vector3(12, 0, 0), "upperarm.r": Vector3(0, 0, -30)}, 45.0],
		[0.6 if heavy else 0.36, {}, 10.0]],
		[{"t0": 0.3 if heavy else 0.15, "t1": 0.44 if heavy else 0.27, "bones": ["weapon"], "r": 50.0 if heavy else 42.0, "dmg": 18.0 if heavy else 11.0, "base": 480.0 if heavy else 300.0, "growth": 8.2 if heavy else 4.4, "angle": 34.0, "heavy": heavy, "metal": true}],
		{"lunge": [[0.3 if heavy else 0.15, Vector2(300 if heavy else 200, 0)]], "sfx": [[0.27 if heavy else 0.13, "whoosh_heavy"]], "charge_at": 0.24 if heavy else -1.0})

func hit_point(b: String) -> Vector2:
	if b == "weapon" and has_meta("axe_tip"):
		var g: Vector3 = get_meta("axe_tip").global_position
		return Vector2(g.x / U, -g.y / U)
	return bone_point(b)

func equip(kind: String) -> void:
	weapon = kind
	if has_meta("axe"):
		get_meta("axe").visible = kind == "axe"

# ------------------------------------------------------------------ step
func step(delta: float) -> void:
	if eliminated:
		return
	if not alive:
		respawn_t -= delta
		if respawn_t <= 0.0:
			game.respawn(self)
		return
	flash = maxf(0.0, flash - delta)
	if hitstop > 0.0:
		hitstop -= delta
		return
	inp = ctrl.read(self, delta) if game.inputs_enabled else {}
	if game.demo and slot == 0 and not inp.is_empty():
		game.touch.show_bot_input(inp)
	st_time += delta
	invuln = maxf(0.0, invuln - delta)
	dodge_cd = maxf(0.0, dodge_cd - delta)
	var mx: float = inp.get("mx", 0.0)
	var my: float = inp.get("my", 0.0)
	match state:
		"free":
			_free(delta, mx)
		"attack":
			_attack_step(delta, mx)
		"hitstun":
			hitstun -= delta
			vel.x += mx * 500.0 * delta
			vel.x = move_toward(vel.x, 0.0, 120.0 * delta)
			if hitstun <= 0.0:
				state = "free"
				tumble = false
		"dodge":
			if st_time > 0.32:
				state = "free"
				vel *= 0.4
	var g := GRAV
	if state == "dodge" and not on_ground and st_time < 0.26:
		g = 0.0
	if atk.get("pound", false) and st_time > 0.16:
		g = GRAV * 1.6
	vel.y += g * delta
	var cap := FAST_FALL if (my > 0.6 and state == "free") or atk.get("pound", false) else MAX_FALL
	if state == "hitstun":
		cap = 2400.0
	vel.y = minf(vel.y, cap)
	_move(delta)
	if state != "hitstun":
		pos.x = clampf(pos.x, game.blast.position.x + 160.0, game.blast.end.x - 160.0)
		pos.y = maxf(pos.y, game.blast.position.y + 200.0)
	_animate(delta, mx)
	if not game.blast.has_point(center()):
		game.ko(self)

func _free(delta: float, mx: float) -> void:
	if absf(mx) > 0.2:
		facing = 1 if mx > 0.0 else -1
	var target := mx * float(data.run)
	vel.x = move_toward(vel.x, target if on_ground else target * 0.92, (4200.0 if on_ground else 2200.0) * delta)
	if inp.get("jump", false):
		_jump()
	if inp.get("dodge", false) and dodge_cd <= 0.0 and not (air_dodged and not on_ground):
		state = "dodge"
		st_time = 0.0
		invuln = 0.32
		dodge_cd = 0.85
		var d := Vector2(mx, inp.get("my", 0.0))
		if on_ground:
			vel.x = signf(mx) * 640.0 if absf(mx) > 0.3 else 0.0
		else:
			vel = d.normalized() * 660.0 if d.length() > 0.3 else Vector2.ZERO
			air_dodged = true
		play("dash", 1.6, 0.05, true)
		Sfx.play("dodge", -2.0)
		return
	if inp.get("pickup", false):
		if weapon == "":
			game.try_pickup(self)
		else:
			game.throw_weapon(self)
			return
	if inp.get("light", false):
		_start(attack_for("light"), mx)
	elif inp.get("heavy", false):
		_start(attack_for("heavy"), mx)

func _jump() -> void:
	if on_ground:
		vel.y = -float(data.jump)
		on_ground = false
		jumps = 2
		squash = 0.85
		game.fx_dust(pos, 6)
		Sfx.play("jump", -4.0)
		play("air_jump", 1.4, 0.05, true)
	elif jumps > 0:
		jumps -= 1
		vel.y = -float(data.jump) * 0.86
		spin = TAU
		game.fx_dust(pos, 4)
		Sfx.play("jump", -4.0, 0.12)
		play("air_jump", 1.6, 0.05, true)

func _start(a: Dictionary, mx: float) -> void:
	if absf(mx) > 0.3:
		facing = 1 if mx > 0.0 else -1
	atk = a
	atk_done = {}
	keys_done = 0
	charge = 0.0
	charging = false
	state = "attack"
	st_time = 0.0
	play(a.anim[0], a.anim[1], 0.05, true)
	if a.get("flip", false):
		spin = TAU

func _attack_step(delta: float, mx: float) -> void:
	var ca: float = atk.get("charge_at", -1.0)
	if ca >= 0.0 and st_time >= ca and charge < 0.6 and inp.get("heavy_held", false) and not atk_done.has("charged"):
		if not charging:
			charging = true
			Sfx.play("charge", -8.0)
		charge += delta
		st_time = ca
		ap.speed_scale = 0.05
		if charge >= 0.6:
			atk_done["charged"] = true
		return
	elif charging:
		charging = false
		atk_done["charged"] = true
		ap.speed_scale = atk.anim[1]
	var t := st_time
	var keys: Array = atk.keys
	while keys_done < keys.size() and t >= keys[keys_done][0]:
		pose(keys[keys_done][1], keys[keys_done][2])
		keys_done += 1
	for r in atk.get("replay", []):
		var k := "r%s" % str(r)
		if t >= r and not atk_done.has(k):
			atk_done[k] = true
			play(atk.anim[0], atk.anim[1], 0.03, true)
	for l in atk.lunge:
		var key := "l%s" % str(l[0])
		if t >= l[0] and not atk_done.has(key):
			atk_done[key] = true
			var v: Vector2 = l[1]
			vel.x = v.x * facing
			if v.y != 0.0:
				vel.y = v.y
				on_ground = false
	for s in atk.sfx:
		var key2 := "s%s" % str(s[0])
		if t >= s[0] and not atk_done.has(key2):
			atk_done[key2] = true
			Sfx.play(s[1], -3.0)
	if atk.has("quake_at") and t >= atk.quake_at and not atk_done.has("quake"):
		atk_done["quake"] = true
		game.quake(self, pos + Vector2(facing * 60, 0), 1.0 + charge)
	for i in atk.hits.size():
		var h: Dictionary = atk.hits[i]
		if t >= h.t0 and t <= h.t1:
			for b in h.bones:
				game.check_hit(self, i, h, hit_point(b))
	if on_ground:
		vel.x = move_toward(vel.x, 0.0, 2600.0 * delta)
	else:
		vel.x = move_toward(vel.x, mx * float(data.run) * 0.6, 900.0 * delta)
	if atk.get("pound", false) and on_ground and not atk_done.has("landed"):
		atk_done["landed"] = true
		game.quake(self, pos, 1.0 + charge)
		st_time = atk.total - 0.25
	if t >= atk.total:
		state = "free"
		atk = {}
		pose({}, 10.0)

func take_hit(by, h: Dictionary, at: Vector2, power: float) -> bool:
	if invuln > 0.0 or state == "dodge" or not alive:
		return false
	var d: float = h.dmg * power
	dmg += d
	stats.dmg_taken += d
	by.stats.dmg_done += d
	last_hit_by = by
	var kb: float = (h.base + h.growth * dmg) * power / float(data.weight)
	var ang := deg_to_rad(h.angle)
	var dir := Vector2(cos(ang) * by.facing, -sin(ang))
	if h.get("radial", false):
		dir.x = absf(dir.x) * signf(pos.x - by.pos.x + 0.01)
	vel = dir * kb
	if on_ground and vel.y > 0.0:
		vel.y = -vel.y * 0.6
	on_ground = false
	state = "hitstun"
	atk = {}
	hitstun = 0.1 + kb * 0.00043
	tumble = kb > 820.0
	facing = 1 if dir.x < 0.0 else -1
	var stop := clampf(0.035 + kb * 0.00009, 0.04, 0.17)
	hitstop = stop
	by.hitstop = stop
	flash = 0.14
	jumps = maxi(jumps, 1)
	air_dodged = false
	pose({"spine_01": Vector3(-35, 0, 0), "spine_02": Vector3(-15, 0, 0), "neck_01": Vector3(-25, 0, 0), "upperarm.r": Vector3(0, 0, -60), "upperarm.l": Vector3(0, 0, 60), "thigh.r": Vector3(0, 0, 30)}, 40.0)
	play("fight_idle", 0.0, 0.05)
	game.on_hit(by, self, at, dir, kb, h)
	return true

# ------------------------------------------------------------------ world collision: one flat endless floor (nothing to fall off)
func _move(delta: float) -> void:
	var was_ground := on_ground
	pos += vel * delta
	if pos.y >= 0.0:
		pos.y = 0.0
		if was_ground:
			vel.y = 0.0
			on_ground = true
		else:
			_land(vel.y)
	else:
		on_ground = false

func _land(impact: float) -> void:
	on_ground = true
	jumps = 2
	air_dodged = false
	spin = 0.0
	pivot.rotation.z = 0.0
	if impact > 400.0:
		squash = 0.8
		game.fx_dust(pos, 7 if impact > 900.0 else 4)
		Sfx.play("land", -6.0 if impact < 900.0 else 0.0)
	if state == "hitstun" and impact > 900.0:
		vel.y = -impact * 0.35
		on_ground = false
		return
	vel.y = 0.0
	if state == "free":
		play("air_land", 3.0, 0.04, true)

func _animate(delta: float, _mx: float) -> void:
	match state:
		"free":
			if victory:
				pose({"upperarm.r": Vector3(0, 0, -160), "upperarm.l": Vector3(0, 0, 160), "spine_01": Vector3(-10, 0, 0)}, 8.0)
				play("fight_idle", 1.0)
			elif on_ground:
				if absf(vel.x) > 60.0:
					play("run", clampf(absf(vel.x) / 420.0, 0.6, 1.5), 0.12)
					trail_t -= delta
					if trail_t <= 0.0:
						trail_t = 0.2
						game.fx_dust(pos + Vector2(-facing * 20, 0), 1)
				elif cur_anim != "air_land" or not ap.is_playing():
					play("fight_idle", 1.0, 0.15)
				pose({}, 10.0)
			else:
				if cur_anim != "air_jump":
					play("air_jump", 1.0, 0.1)
				pose({"thigh.r": Vector3(0, 0, 25), "calf.r": Vector3(0, 0, -30)} if vel.y > 0 else {}, 6.0)
		"hitstun":
			if tumble:
				trail_t -= delta
				if trail_t <= 0.0 and vel.length() > 500.0:
					trail_t = 0.025
					game.fx_smoke(center())

func _visual(delta: float) -> void:
	position = world3(pos)
	var want := 90.0 if facing == 1 else -90.0
	model_yaw = lerpf(model_yaw, want, 1.0 - exp(-16.0 * delta))
	model.rotation_degrees.y = model_yaw
	if tumble and state == "hitstun":
		pivot.rotation.z += delta * 13.0 * facing
	elif absf(spin) > 0.01:
		var s := move_toward(spin, 0.0, delta * 16.0)
		pivot.rotation.z -= (s - spin) * facing
		spin = s
		if absf(spin) <= 0.01:
			pivot.rotation.z = 0.0
	else:
		pivot.rotation.z = lerp_angle(pivot.rotation.z, 0.0, 1.0 - exp(-14.0 * delta))
	squash = lerpf(squash, 1.0, 1.0 - exp(-12.0 * delta))
	pivot.scale = Vector3(1.0 / sqrt(squash), squash, 1.0 / sqrt(squash))
	# flashes: hit = white, charging = violet pulse, invulnerable = blink, dodge = ghosts
	var f := 0.0
	var fc := Color(1, 1, 1)
	if flash > 0.0:
		f = 0.85
	if charging:
		f = 0.35 + 0.3 * sin(Time.get_ticks_msec() * 0.04)
		fc = Color(0.7, 0.5, 1.0)
	for m in mats:
		m.set_shader_parameter("flash", f)
		m.set_shader_parameter("flash_color", Vector3(fc.r, fc.g, fc.b))
	visible = alive and not (invuln > 0.0 and state != "dodge" and int(invuln * 16.0) % 2 == 0)
	if state == "dodge":
		ghost_t -= delta
		if ghost_t <= 0.0:
			ghost_t = 0.045
			game.ghost(self)
