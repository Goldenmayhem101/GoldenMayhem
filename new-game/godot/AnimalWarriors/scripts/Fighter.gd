## One warrior: movement, jumps, dodges, attacks, knockback and procedural animation.
class_name Fighter
extends Node2D

const GRAV := 2700.0
const MAX_FALL := 1150.0
const FAST_FALL := 1700.0
const W := 56.0
const H := 140.0

var id := ""
var team := 0
var slot := 0
var game: Node
var rig: Rig
var ctrl: Object
var data: Dictionary

var vel := Vector2.ZERO
var facing := 1
var on_ground := false
var jumps := 2
var wall := 0
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
var drop_timer := 0.0
var down_hold := 0.0
var weapon := ""
var weapon_node: Sprite2D
var weapon_tip: Node2D
var charge := 0.0
var charging := false
var hitstop := 0.0
var run_phase := 0.0
var step_flip := false
var tumble := false
var ghost_t := 0.0
var trail_t := 0.0
var alive := true
var eliminated := false
var squash := Vector2.ONE
var spin := 0.0
var last_hit_by: Fighter = null
var stats := {"kos": 0, "falls": 0, "dmg_done": 0.0, "dmg_taken": 0.0}
var respawn_t := 0.0
var flash := 0.0
var inp: Dictionary = {}

func setup(char_id: String, g: Node, controller: Object, team_id: int, slot_id: int) -> void:
	id = char_id
	game = g
	ctrl = controller
	team = team_id
	slot = slot_id
	data = Chars.DATA[id]
	rig = Rig.new()
	rig.height_world = 150.0
	rig.build(id)
	add_child(rig)
	rig.pose(P_IDLE)
	rig.snap()
	_make_weapon_node()

func run_speed() -> float:
	return data.run
func weight() -> float:
	return data.weight

func hurt_rect() -> Rect2:
	return Rect2(position.x - W * 0.5, position.y - H, W, H)

func center() -> Vector2:
	return position + Vector2(0, -H * 0.5)

# ------------------------------------------------------------------ poses (degrees; art faces left, + swings a limb forward)
const P_IDLE := {"arm_f_up": 38, "arm_f_lo": 72, "arm_b_up": 28, "arm_b_lo": 84, "leg_f_up": 10, "leg_f_lo": -8, "leg_b_up": -10, "leg_b_lo": 6, "body": -4, "tail": 0}
const P_JUMP := {"arm_f_up": -25, "arm_f_lo": 50, "arm_b_up": 50, "arm_b_lo": 60, "leg_f_up": 55, "leg_f_lo": -80, "leg_b_up": -10, "leg_b_lo": -50, "body": -8, "tail": -12}
const P_FALL := {"arm_f_up": 70, "arm_f_lo": 30, "arm_b_up": -45, "arm_b_lo": 35, "leg_f_up": 18, "leg_f_lo": -25, "leg_b_up": -14, "leg_b_lo": -14, "body": -2, "tail": 10}
const P_HURT := {"arm_f_up": -60, "arm_f_lo": -25, "arm_b_up": -80, "arm_b_lo": -30, "leg_f_up": 35, "leg_f_lo": -45, "leg_b_up": -25, "leg_b_lo": -20, "body": 20, "tail": 18}
const P_GUARD := {"arm_f_up": 72, "arm_f_lo": 95, "arm_b_up": 62, "arm_b_lo": 100, "leg_f_up": 20, "leg_f_lo": -30, "leg_b_up": -15, "leg_b_lo": -15, "body": -12, "y": 8}
const P_WALL := {"arm_f_up": 150, "arm_f_lo": 10, "arm_b_up": 130, "arm_b_lo": 20, "leg_f_up": 40, "leg_f_lo": -60, "leg_b_up": 20, "leg_b_lo": -40, "body": -6}
const P_LAND := {"arm_f_up": 45, "arm_f_lo": 80, "arm_b_up": 35, "arm_b_lo": 90, "leg_f_up": 30, "leg_f_lo": -45, "leg_b_up": -25, "leg_b_lo": -25, "body": -10, "y": 14}

func run_pose(ph: float) -> Dictionary:
	var s := sin(ph)
	return {
		"leg_f_up": 40.0 * s, "leg_f_lo": -minf(0.0, 0.0) - (28.0 + 30.0 * cos(ph + 0.7)),
		"leg_b_up": -40.0 * s, "leg_b_lo": -(28.0 + 30.0 * cos(ph + PI + 0.7)),
		"arm_f_up": 22.0 - 34.0 * s, "arm_f_lo": 80.0, "arm_b_up": 22.0 + 34.0 * s, "arm_b_lo": 80.0,
		"body": -11.0, "y": -absf(s) * 7.0, "tail": 8.0 * s,
	}

# ------------------------------------------------------------------ attacks
# keys: [time, pose, blend]; hits: windows with the part whose tip deals the hit
func _atk(name: String, total: float, keys: Array, hits: Array, extra := {}) -> Dictionary:
	var d := {"name": name, "total": total, "keys": keys, "hits": hits, "lunge": [], "sfx": [], "charge_at": -1.0}
	d.merge(extra, true)
	return d

func attack_for(kind: String) -> Dictionary:
	var air := not on_ground
	var up: bool = inp.get("my", 0.0) < -0.5
	var down: bool = inp.get("my", 0.0) > 0.5
	if weapon == "axe":
		return _axe_attack(kind, air, up, down)
	if kind == "light":
		if air:
			if up: return A_AIR_UP()
			if down: return A_STOMP()
			return A_AIR_KICK()
		if up: return A_UPPERCUT()
		if down: return A_SWEEP()
		return A_JAB()
	if air and down: return A_POUND()
	if up: return A_LAUNCHER()
	if down and not air: return A_SLAM()
	return A_SIGNATURE()

func A_JAB() -> Dictionary:
	return _atk("Jab", 0.36, [
		[0.0, {"arm_f_up": -15, "arm_f_lo": 115, "arm_b_up": 40, "arm_b_lo": 90, "body": 6, "leg_f_up": 6, "leg_b_up": -6}, 30.0],
		[0.08, {"arm_f_up": 94, "arm_f_lo": -4, "arm_b_up": 10, "arm_b_lo": 100, "body": -16, "leg_f_up": 28, "leg_f_lo": -10, "leg_b_up": -24, "leg_b_lo": 8}, 55.0],
		[0.22, P_IDLE, 14.0]],
		[{"t0": 0.09, "t1": 0.17, "parts": ["arm_f_lo"], "r": 26.0, "dmg": 6.0, "base": 240.0, "growth": 3.0, "angle": 28.0}],
		{"lunge": [[0.08, Vector2(260, 0)]], "sfx": [[0.07, "whoosh"]]})

func A_UPPERCUT() -> Dictionary:
	return _atk("Uppercut", 0.46, [
		[0.0, {"arm_f_up": 5, "arm_f_lo": 125, "body": 6, "y": 12, "leg_f_up": 25, "leg_f_lo": -40}, 26.0],
		[0.12, {"arm_f_up": 168, "arm_f_lo": -18, "arm_b_up": 20, "arm_b_lo": 90, "body": -10, "y": -8, "leg_f_up": 10}, 45.0],
		[0.3, P_IDLE, 12.0]],
		[{"t0": 0.13, "t1": 0.23, "parts": ["arm_f_lo"], "r": 30.0, "dmg": 8.0, "base": 300.0, "growth": 3.4, "angle": 84.0}],
		{"lunge": [[0.12, Vector2(80, -120)]], "sfx": [[0.1, "whoosh"]]})

func A_SWEEP() -> Dictionary:
	return _atk("Low Sweep", 0.44, [
		[0.0, {"leg_f_up": -25, "leg_f_lo": -20, "body": 10, "y": 10, "arm_f_up": 30, "arm_f_lo": 60}, 26.0],
		[0.11, {"leg_f_up": 82, "leg_f_lo": 0, "leg_b_up": -20, "leg_b_lo": -30, "body": 24, "y": 22, "arm_f_up": -30, "arm_f_lo": 40, "arm_b_up": 60}, 50.0],
		[0.28, P_IDLE, 12.0]],
		[{"t0": 0.12, "t1": 0.22, "parts": ["leg_f_lo"], "r": 28.0, "dmg": 7.0, "base": 260.0, "growth": 3.0, "angle": 18.0}],
		{"lunge": [[0.11, Vector2(160, 0)]], "sfx": [[0.1, "whoosh"]]})

func A_AIR_KICK() -> Dictionary:
	return _atk("Flying Kick", 0.42, [
		[0.0, {"leg_f_up": 30, "leg_f_lo": -90, "body": 8}, 30.0],
		[0.08, {"leg_f_up": 88, "leg_f_lo": -4, "leg_b_up": -30, "leg_b_lo": -70, "body": 14, "arm_f_up": -40, "arm_b_up": 60}, 50.0],
		[0.3, P_FALL, 12.0]],
		[{"t0": 0.09, "t1": 0.24, "parts": ["leg_f_lo"], "r": 30.0, "dmg": 7.0, "base": 260.0, "growth": 3.2, "angle": 36.0}],
		{"lunge": [[0.08, Vector2(140, -60)]], "sfx": [[0.07, "whoosh"]]})

func A_AIR_UP() -> Dictionary:
	return _atk("Flip Kick", 0.46, [
		[0.0, {"leg_f_up": 20, "leg_f_lo": -100, "body": 10}, 30.0],
		[0.1, {"leg_f_up": 165, "leg_f_lo": -10, "leg_b_up": 30, "leg_b_lo": -60, "body": -30, "arm_f_up": -60, "arm_b_up": -40}, 45.0],
		[0.32, P_FALL, 12.0]],
		[{"t0": 0.11, "t1": 0.24, "parts": ["leg_f_lo"], "r": 32.0, "dmg": 7.0, "base": 280.0, "growth": 3.3, "angle": 86.0}],
		{"lunge": [[0.1, Vector2(0, -200)]], "sfx": [[0.09, "whoosh"]]})

func A_STOMP() -> Dictionary:
	return _atk("Stomp", 0.44, [
		[0.0, {"leg_f_up": 70, "leg_f_lo": -110, "leg_b_up": 60, "leg_b_lo": -110, "y": -20}, 30.0],
		[0.12, {"leg_f_up": 5, "leg_f_lo": 0, "leg_b_up": -5, "leg_b_lo": 0, "arm_f_up": 150, "arm_b_up": 140, "y": 10}, 50.0],
		[0.32, P_FALL, 12.0]],
		[{"t0": 0.13, "t1": 0.26, "parts": ["leg_f_lo", "leg_b_lo"], "r": 30.0, "dmg": 8.0, "base": 240.0, "growth": 2.6, "angle": -65.0}],
		{"lunge": [[0.12, Vector2(0, 500)]], "sfx": [[0.1, "whoosh"]]})

func A_LAUNCHER() -> Dictionary:
	return _atk("Sky Launcher", 0.7, [
		[0.0, {"arm_f_up": -15, "arm_f_lo": 30, "arm_b_up": -10, "arm_b_lo": 40, "y": 20, "body": 10, "leg_f_up": 35, "leg_f_lo": -55, "leg_b_up": -30, "leg_b_lo": -30}, 20.0],
		[0.24, {"arm_f_up": 176, "arm_f_lo": -10, "arm_b_up": 168, "arm_b_lo": -12, "body": -6, "y": -14, "leg_f_up": 5, "leg_b_up": -5}, 40.0],
		[0.5, P_IDLE, 10.0]],
		[{"t0": 0.25, "t1": 0.38, "parts": ["arm_f_lo", "arm_b_lo"], "r": 36.0, "dmg": 13.0, "base": 420.0, "growth": 7.0, "angle": 86.0, "heavy": true}],
		{"lunge": [[0.24, Vector2(40, -380)]], "sfx": [[0.22, "whoosh_heavy"]], "charge_at": 0.2})

func A_SLAM() -> Dictionary:
	return _atk("Ground Slam", 0.76, [
		[0.0, {"arm_f_up": 175, "arm_f_lo": 15, "arm_b_up": 168, "arm_b_lo": 15, "body": 14, "y": -6}, 20.0],
		[0.26, {"arm_f_up": 62, "arm_f_lo": 25, "arm_b_up": 55, "arm_b_lo": 30, "body": -28, "y": 22, "leg_f_up": 30, "leg_f_lo": -40, "leg_b_up": -30, "leg_b_lo": -10}, 50.0],
		[0.56, P_IDLE, 10.0]],
		[{"t0": 0.27, "t1": 0.36, "parts": ["arm_f_lo", "arm_b_lo"], "r": 40.0, "dmg": 14.0, "base": 400.0, "growth": 6.6, "angle": 58.0, "heavy": true, "quake": true}],
		{"sfx": [[0.24, "whoosh_heavy"]], "charge_at": 0.22})

func A_POUND() -> Dictionary:
	return _atk("Meteor Pound", 0.8, [
		[0.0, {"arm_f_up": 160, "arm_b_up": 150, "leg_f_up": 60, "leg_f_lo": -110, "leg_b_up": 50, "leg_b_lo": -110, "y": -10}, 24.0],
		[0.16, {"arm_f_up": 170, "arm_f_lo": -5, "arm_b_up": 165, "arm_b_lo": -5, "leg_f_up": 0, "leg_f_lo": 0, "leg_b_up": 0, "leg_b_lo": 0, "body": 0}, 40.0]],
		[{"t0": 0.17, "t1": 0.8, "parts": ["leg_f_lo", "leg_b_lo"], "r": 34.0, "dmg": 12.0, "base": 330.0, "growth": 5.0, "angle": -70.0, "heavy": true}],
		{"lunge": [[0.16, Vector2(0, 1500)]], "sfx": [[0.14, "whoosh_heavy"]], "pound": true})

func A_SIGNATURE() -> Dictionary:
	if id == "kangaroo":
		return _atk("Tail Kick", 0.86, [
			[0.0, {"body": 26, "y": -10, "leg_f_up": 62, "leg_f_lo": -110, "leg_b_up": 55, "leg_b_lo": -110, "arm_f_up": 50, "arm_f_lo": 90, "arm_b_up": 40, "arm_b_lo": 90, "tail": -25}, 18.0],
			[0.3, {"body": 32, "y": -34, "leg_f_up": 98, "leg_f_lo": 2, "leg_b_up": 88, "leg_b_lo": 0, "arm_f_up": -30, "arm_f_lo": 60, "arm_b_up": -40, "arm_b_lo": 60, "tail": -35}, 55.0],
			[0.6, P_IDLE, 9.0]],
			[{"t0": 0.31, "t1": 0.43, "parts": ["leg_f_lo", "leg_b_lo"], "r": 40.0, "dmg": 16.0, "base": 440.0, "growth": 7.6, "angle": 36.0, "heavy": true}],
			{"lunge": [[0.3, Vector2(420, -60)]], "sfx": [[0.28, "whoosh_heavy"]], "charge_at": 0.24})
	# Hyena: Frenzy - four rapid alternating blows, the last one launches
	var f := {"arm_f_up": 96, "arm_f_lo": -4, "arm_b_up": 20, "arm_b_lo": 110, "body": -18, "leg_f_up": 30, "leg_f_lo": -12, "leg_b_up": -26}
	var b := {"arm_b_up": 98, "arm_b_lo": -4, "arm_f_up": 10, "arm_f_lo": 115, "body": -20, "leg_f_up": 26, "leg_b_up": -30}
	var wind := {"arm_f_up": -20, "arm_f_lo": 120, "arm_b_up": -10, "arm_b_lo": 120, "body": 10, "y": 6}
	return _atk("Frenzy", 0.98, [
		[0.0, wind, 22.0], [0.2, f, 60.0], [0.31, b, 60.0], [0.42, f, 60.0], [0.55, wind, 40.0],
		[0.62, {"arm_f_up": 100, "arm_f_lo": -8, "arm_b_up": 95, "arm_b_lo": -8, "body": -26, "leg_f_up": 34, "leg_b_up": -32, "y": -4}, 60.0],
		[0.8, P_IDLE, 10.0]],
		[{"t0": 0.2, "t1": 0.27, "parts": ["arm_f_lo"], "r": 28.0, "dmg": 3.0, "base": 120.0, "growth": 0.4, "angle": 20.0},
		{"t0": 0.31, "t1": 0.38, "parts": ["arm_b_lo"], "r": 28.0, "dmg": 3.0, "base": 120.0, "growth": 0.4, "angle": 20.0},
		{"t0": 0.42, "t1": 0.49, "parts": ["arm_f_lo"], "r": 28.0, "dmg": 3.0, "base": 120.0, "growth": 0.4, "angle": 20.0},
		{"t0": 0.62, "t1": 0.72, "parts": ["arm_f_lo", "arm_b_lo"], "r": 36.0, "dmg": 9.0, "base": 420.0, "growth": 7.2, "angle": 34.0, "heavy": true}],
		{"lunge": [[0.2, Vector2(160, 0)], [0.31, Vector2(160, 0)], [0.42, Vector2(160, 0)], [0.62, Vector2(360, 0)]],
		"sfx": [[0.19, "whoosh"], [0.3, "whoosh"], [0.41, "whoosh"], [0.6, "whoosh_heavy"]], "charge_at": 0.16})

func _axe_attack(kind: String, air: bool, up: bool, _down: bool) -> Dictionary:
	if kind == "light" and not up:
		return _atk("Axe Chop", 0.52, [
			[0.0, {"arm_f_up": 205, "arm_f_lo": 15, "body": 12, "arm_b_up": 40, "arm_b_lo": 80}, 24.0],
			[0.15, {"arm_f_up": 70, "arm_f_lo": 12, "body": -22, "y": 8, "leg_f_up": 30, "leg_f_lo": -20, "leg_b_up": -26}, 55.0],
			[0.36, P_IDLE, 12.0]],
			[{"t0": 0.15, "t1": 0.27, "parts": ["weapon"], "r": 38.0, "dmg": 11.0, "base": 300.0, "growth": 4.4, "angle": 38.0, "metal": true}],
			{"lunge": [[0.15, Vector2(200, 0)]], "sfx": [[0.13, "whoosh_heavy"]]})
	if up:
		return _atk("Axe Riser", 0.6, [
			[0.0, {"arm_f_up": 20, "arm_f_lo": 30, "y": 14, "body": 8}, 24.0],
			[0.16, {"arm_f_up": 192, "arm_f_lo": -10, "body": -12, "y": -10}, 45.0],
			[0.42, P_IDLE, 10.0]],
			[{"t0": 0.17, "t1": 0.3, "parts": ["weapon"], "r": 42.0, "dmg": 14.0 if kind == "heavy" else 10.0, "base": 360.0, "growth": 6.0 if kind == "heavy" else 4.0, "angle": 85.0, "heavy": kind == "heavy", "metal": true}],
			{"lunge": [[0.16, Vector2(60, -260 if air else -160)]], "sfx": [[0.14, "whoosh_heavy"]], "charge_at": 0.12 if kind == "heavy" else -1.0})
	return _atk("Axe Cleave", 0.86, [
		[0.0, {"arm_f_up": -70, "arm_f_lo": 20, "body": 18, "y": 4, "arm_b_up": 50, "arm_b_lo": 80, "leg_f_up": 20, "leg_b_up": -20}, 18.0],
		[0.3, {"arm_f_up": 118, "arm_f_lo": 6, "body": -30, "y": 10, "leg_f_up": 40, "leg_f_lo": -25, "leg_b_up": -34, "leg_b_lo": 10}, 40.0],
		[0.6, P_IDLE, 9.0]],
		[{"t0": 0.3, "t1": 0.44, "parts": ["weapon"], "r": 46.0, "dmg": 18.0, "base": 480.0, "growth": 8.2, "angle": 34.0, "heavy": true, "metal": true}],
		{"lunge": [[0.3, Vector2(300, 0)]], "sfx": [[0.27, "whoosh_heavy"]], "charge_at": 0.24})

# ------------------------------------------------------------------ weapon
func _make_weapon_node() -> void:
	weapon_node = Sprite2D.new()
	weapon_node.texture = load("res://art/pickup_axe.png")
	var arm: Node2D = rig.pivots.arm_f_lo
	var tip: Node2D = rig.tips.arm_f_lo
	var len_world := 92.0
	var sc := len_world / 155.0 / rig.k
	weapon_node.scale = Vector2(sc, sc)
	weapon_node.offset = Vector2(0, -155 * 0.32)   # grip a little below the middle of the haft
	weapon_node.position = tip.position
	weapon_node.rotation = deg_to_rad(-90)        # head points forward when the arm hangs
	weapon_node.z_index = -1
	weapon_node.visible = false
	arm.add_child(weapon_node)
	weapon_tip = Node2D.new()
	weapon_tip.position = Vector2(-10, -125)
	weapon_node.add_child(weapon_tip)

func equip(kind: String) -> void:
	weapon = kind
	weapon_node.visible = kind == "axe"

func hit_point(part: String) -> Vector2:
	if part == "weapon":
		return weapon_tip.global_position
	return rig.tip_global(part)

# ------------------------------------------------------------------ main step
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
		rig.set_process(false)
		return
	rig.set_process(true)
	inp = ctrl.read(self, delta) if game.inputs_enabled else {}
	if game.demo and slot == 0 and not inp.is_empty():
		game.touch.show_bot_input(inp)
	st_time += delta
	invuln = maxf(0.0, invuln - delta)
	dodge_cd = maxf(0.0, dodge_cd - delta)
	drop_timer = maxf(0.0, drop_timer - delta)
	var mx: float = inp.get("mx", 0.0)
	var my: float = inp.get("my", 0.0)

	match state:
		"free":
			_free(delta, mx, my)
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
			if st_time > 0.3:
				state = "free"
				vel *= 0.4
			elif not on_ground:
				vel *= pow(0.9, delta * 60.0)

	# gravity
	var g := GRAV
	if state == "dodge" and not on_ground and st_time < 0.26:
		g = 0.0
	if state == "attack" and atk.get("pound", false) and st_time > 0.16:
		g = GRAV * 1.6
	vel.y += g * delta
	var cap := FAST_FALL if (my > 0.6 and state == "free") or atk.get("pound", false) else MAX_FALL
	if state == "hitstun":
		cap = 2400.0
	if wall != 0 and state == "free" and vel.y > 0.0 and signf(mx) == wall:
		cap = 220.0
	vel.y = minf(vel.y, cap)
	_move(delta)
	if state != "hitstun":
		position.x = clampf(position.x, game.blast.position.x + 160.0, game.blast.end.x - 160.0)
	_animate(delta, mx)
	if not game.blast.has_point(position + Vector2(0, -70)):
		game.ko(self)

func _free(delta: float, mx: float, my: float) -> void:
	if absf(mx) > 0.2:
		facing = 1 if mx > 0.0 else -1
	var target := mx * run_speed()
	if on_ground:
		vel.x = move_toward(vel.x, target, 4200.0 * delta)
	else:
		vel.x = move_toward(vel.x, target * 0.92, 2200.0 * delta)
	# drop through soft platforms
	if on_ground and my > 0.7 and game.on_soft(self):
		down_hold += delta
		if down_hold > 0.12:
			drop_timer = 0.28
			on_ground = false
			vel.y = 120.0
	else:
		down_hold = 0.0
	if inp.get("jump", false):
		_jump()
	if inp.get("dodge", false) and dodge_cd <= 0.0:
		_dodge(mx, my)
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
		vel.y = -data.jump
		on_ground = false
		jumps = 2
		squash = Vector2(0.82, 1.2)
		game.fx.dust(position, 6)
		Sfx.play("jump", -4.0)
	elif wall != 0:
		vel = Vector2(-wall * 520.0, -data.jump * 0.92)
		facing = -wall
		jumps = maxi(jumps, 1)
		game.fx.dust(position + Vector2(wall * 26, -60), 5)
		Sfx.play("jump", -4.0)
	elif jumps > 0:
		jumps -= 1
		vel.y = -data.jump * 0.86
		spin = TAU * -facing
		game.fx.dust(position, 4, 0.6)
		Sfx.play("jump", -4.0, 0.12)

func _dodge(mx: float, my: float) -> void:
	if not on_ground and air_dodged:
		return
	state = "dodge"
	st_time = 0.0
	invuln = 0.3
	dodge_cd = 0.85
	if on_ground:
		vel.x = signf(mx) * 600.0 if absf(mx) > 0.3 else 0.0
	else:
		var d := Vector2(mx, my)
		vel = d.normalized() * 640.0 if d.length() > 0.3 else Vector2.ZERO
		air_dodged = true
	Sfx.play("dodge", -2.0)

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

func _attack_step(delta: float, mx: float) -> void:
	var t := st_time
	# charge: hold heavy to power up
	var ca: float = atk.get("charge_at", -1.0)
	if ca >= 0.0 and t >= ca and charge < 0.6 and inp.get("heavy_held", false) and not atk_done.has("charged"):
		if not charging:
			charging = true
			Sfx.play("charge", -8.0)
		charge += delta
		st_time = ca
		flash = 0.06
		if charge >= 0.6:
			atk_done["charged"] = true
		return
	elif charging:
		charging = false
		atk_done["charged"] = true
	var keys: Array = atk.keys
	while keys_done < keys.size() and t >= keys[keys_done][0]:
		rig.pose(keys[keys_done][1], keys[keys_done][2])
		keys_done += 1
	for l in atk.lunge:
		var key := "l%s" % str(l[0])
		if t >= l[0] and not atk_done.has(key):
			atk_done[key] = true
			var v: Vector2 = l[1]
			vel.x = v.x * facing
			if v.y != 0.0:
				vel.y = v.y
	for s in atk.sfx:
		var key2 := "s%s" % str(s[0])
		if t >= s[0] and not atk_done.has(key2):
			atk_done[key2] = true
			Sfx.play(s[1], -3.0)
	for i in atk.hits.size():
		var h: Dictionary = atk.hits[i]
		if t >= h.t0 and t <= h.t1:
			for part in h.parts:
				game.check_hit(self, i, h, hit_point(part))
	if on_ground:
		vel.x = move_toward(vel.x, 0.0, 2600.0 * delta)
	else:
		vel.x = move_toward(vel.x, mx * run_speed() * 0.6, 900.0 * delta)
	if atk.get("pound", false) and on_ground and not atk_done.has("landed"):
		atk_done["landed"] = true
		game.quake(self, position, 1.0 + charge)
		st_time = atk.total - 0.25
	if t >= atk.total:
		state = "free"
		atk = {}

func take_hit(by: Fighter, h: Dictionary, at: Vector2, power: float) -> bool:
	if invuln > 0.0 or state == "dodge" or not alive:
		return false
	var d: float = h.dmg * power
	dmg += d
	stats.dmg_taken += d
	by.stats.dmg_done += d
	last_hit_by = by
	var kb: float = (h.base + h.growth * dmg) * power / weight()
	var ang := deg_to_rad(h.angle)
	var dir := Vector2(cos(ang) * by.facing, -sin(ang))
	if h.get("radial", false):
		dir.x = absf(dir.x) * signf(position.x - by.position.x + 0.01)
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
	flash = 0.12
	jumps = maxi(jumps, 1)
	air_dodged = false
	game.on_hit(by, self, at, dir, kb, h)
	return true

# ------------------------------------------------------------------ collision with the stage
func _move(delta: float) -> void:
	var was_ground := on_ground
	on_ground = false
	wall = 0
	position.x += vel.x * delta
	var box := hurt_rect()
	for r: Rect2 in game.solids:
		if box.intersects(r):
			if position.x < r.get_center().x:
				position.x = r.position.x - W * 0.5 - 0.01
			else:
				position.x = r.end.x + W * 0.5 + 0.01
			vel.x = 0.0
			box = hurt_rect()
	var prev_feet := position.y
	position.y += vel.y * delta
	box = hurt_rect()
	for r: Rect2 in game.solids:
		if box.intersects(r):
			if vel.y >= 0.0 and prev_feet <= r.position.y + 2.0:
				position.y = r.position.y
				_land(was_ground)
			elif vel.y < 0.0:
				position.y = r.end.y + H + 0.01
				vel.y = 0.0
			box = hurt_rect()
	if vel.y >= 0.0 and drop_timer <= 0.0:
		for p: Rect2 in game.platforms:
			if prev_feet <= p.position.y + 2.0 and position.y >= p.position.y and position.x > p.position.x - 4.0 and position.x < p.end.x + 4.0:
				position.y = p.position.y
				_land(was_ground)
	# wall contact (air only)
	if not on_ground:
		box = hurt_rect()
		for r: Rect2 in game.solids:
			if box.end.y > r.position.y + 20.0 and box.position.y < r.end.y:
				if absf(box.end.x - r.position.x) < 3.0:
					wall = 1
				elif absf(box.position.x - r.end.x) < 3.0:
					wall = -1

func _land(was_ground: bool) -> void:
	on_ground = true
	if not was_ground:
		var impact := vel.y
		jumps = 2
		air_dodged = false
		spin = 0.0
		rig.rotation = 0.0
		if impact > 400.0:
			squash = Vector2(1.22, 0.8)
			game.fx.dust(position, 7 if impact > 900.0 else 4)
			Sfx.play("land", -6.0 if impact < 900.0 else 0.0)
		if state == "hitstun" and impact > 900.0:
			# tech bounce
			vel.y = -impact * 0.35
			on_ground = false
			return
	vel.y = 0.0

# ------------------------------------------------------------------ animation
func _animate(delta: float, mx: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	match state:
		"free":
			if on_ground:
				if absf(vel.x) > 60.0:
					var prev := run_phase
					run_phase += delta * absf(vel.x) / 34.0
					rig.pose(run_pose(run_phase), 26.0)
					if int(prev / PI) != int(run_phase / PI):
						game.fx.dust(position + Vector2(-facing * 20, 0), 2, 0.4)
				else:
					var p := P_IDLE.duplicate()
					p["y"] = sin(t * 3.2 + slot) * 2.5
					p["arm_f_lo"] = 72.0 + sin(t * 3.2 + slot) * 5.0
					rig.pose(p, 10.0)
			elif wall != 0 and vel.y > 0.0 and signf(mx) == wall:
				rig.pose(P_WALL, 16.0)
				facing = wall
			elif vel.y < 0.0:
				rig.pose(P_JUMP, 14.0)
			else:
				rig.pose(P_FALL, 8.0)
		"hitstun":
			rig.pose(P_HURT, 22.0)
		"dodge":
			rig.pose(P_GUARD, 30.0)
	# spin for air jumps and tumbling launches
	if tumble and state == "hitstun":
		rig.rotation += delta * 15.0 * -facing
		trail_t -= delta
		if trail_t <= 0.0 and vel.length() > 500.0:
			trail_t = 0.025
			game.fx.smoke(center())
	elif absf(spin) > 0.01:
		var s := move_toward(spin, 0.0, delta * 18.0)
		rig.rotation += s - spin
		spin = s
		if absf(spin) <= 0.01:
			rig.rotation = 0.0
	else:
		rig.rotation = lerp_angle(rig.rotation, 0.0, 1.0 - exp(-14.0 * delta))
	squash = squash.lerp(Vector2.ONE, 1.0 - exp(-12.0 * delta))
	rig.scale = Vector2(rig.k * squash.x * -facing, rig.k * squash.y)
	rig.position = Vector2(0, 0)
	if absf(rig.rotation) > 0.01:
		rig.position = Vector2(0, -H * 0.5) + Vector2(0, H * 0.5).rotated(rig.rotation)
	# visual states
	var mod := Color(1, 1, 1, 1)
	if state == "dodge":
		mod = Color(0.75, 0.9, 1.4, 0.55)
		ghost_t -= delta
		if ghost_t <= 0.0:
			ghost_t = 0.04
			game.ghost(self, Color(0.5, 0.8, 1.0, 0.5))
	elif invuln > 0.0:
		mod.a = 0.45 if int(invuln * 16.0) % 2 == 0 else 1.0
	if flash > 0.0:
		mod = Color(2.2, 2.0, 1.8, mod.a) if not charging else Color(1.6, 1.3, 2.4, 1)
	if charging:
		mod = Color(1.4 + sin(t * 40.0) * 0.4, 1.2, 1.9, 1)
	rig.modulate = mod
