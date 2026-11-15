## 10-second showcase: robots fighting with KayKit game animations (retargeted) mixed with Mixamo moves.
extends "res://scripts/ShotRobot.gd"

var t := 0.0
var bots: Array = []
var shake := 0.0
var hitstop := 0.0
var cam_mid := Vector3.ZERO
var events: Array = []
var orbs: Array = []
var hud: Control
var fill: OmniLight3D
var font: Font

class B:
	var a: Actor
	var r: Retarget
	var idle := "f_idle"
	var x := 0.0
	var y := 0.0
	var vx := 0.0
	var vy := 0.0
	var facing := 1
	var state := "idle"     # idle, act, launch, floor, getup
	var st := 0.0
	var dur := 0.0
	var gap := 1.2
	var pending: Dictionary = {}
	var spin := 0.0
	var lunge_at := -1.0
	var dmg := 0.0
	var pop := 0.0

func setup(_d: bool) -> void:
	seed(20261114)
	arena()
	make_fighters()
	Audio.start_music("music_techno", -11)
	Audio.start_amb("crowd_loop", -12)
	for a in crowd:
		a.ap.seek(a.get_meta("seek"), true)
	_armor(red, Color(0.75, 0.08, 0.05), Color(1, 0.5, 0.15))
	_armor(blue, Color(0.82, 0.85, 0.9), Color(0.3, 0.85, 1.0))
	var stocky: Dictionary = load("res://scripts/ShapeCompare.gd").STOCKY.duplicate()
	stocky.erase("mixamorig_UpLeg")
	for a in [red, blue]:
		a.set_shape(stocky)
		for ba in a.sk.get_children():
			if ba is BoneAttachment3D and ba.get_child_count() > 0:
				var sc: Vector3 = stocky.get(ba.bone_name, Vector3.ONE)
				if ba.bone_name == "mixamorig_Head":
					continue
				for ch in ba.get_children():
					ch.scale = Vector3(1.0 / sc.x, 1.0 / sc.y, 1.0 / sc.z) * (1.1 if ba.bone_name.ends_with("Hand") else 1.0)
	var r := B.new(); r.a = red; r.x = -2.2; r.facing = 1; r.idle = "f_idle"; r.gap = 1.15
	var b := B.new(); b.a = blue; b.x = 1.4; b.facing = -1; b.idle = "ss_idle"; b.gap = 1.3
	bots = [r, b]
	for q in bots:
		q.a.ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		q.a.play(q.idle)
		q.r = Retarget.new()
		add_child(q.r)
	await get_tree().process_frame
	for q in bots:
		q.r.setup(q.a)
	cam.attributes.dof_blur_far_distance = 9.0
	fill = OmniLight3D.new(); fill.light_color = Color(0.85, 0.88, 1.0); fill.light_energy = 1.6; fill.omni_range = 12; fill.light_specular = 0.6; add_child(fill)
	var layer := CanvasLayer.new(); add_child(layer)
	hud = Control.new(); hud.set_anchors_preset(Control.PRESET_FULL_RECT); hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.draw.connect(_draw_hud); layer.add_child(hud)
	font = load("res://fonts/LilitaOne-Regular.ttf")
	Audio.play("go", -4)
	# who, kind, anim, speed, hit-fraction, result on the other fighter
	events = [[0.15, 1, "kk", "Taunt", 1.4, -1.0, ""]]

func _process(delta: float) -> void:
	if bots.is_empty() or bots[0].r.src == null:
		return
	var d := delta
	if hitstop > 0.0:
		hitstop -= delta
		d = 0.0
	t += d
	while not events.is_empty() and t >= events[0][0]:
		_do(events.pop_front())
	if t > 0.9 and t < 10.6:
		for i in 2:
			_ai(i, d)
	for b in bots:
		_step(b, d)
	var p0: B = bots[0]; var p1: B = bots[1]
	var gapx := p1.x - p0.x
	if absf(gapx) < 1.0 and p0.y < 0.4 and p1.y < 0.4:
		var push := (1.0 - absf(gapx)) * 0.5 * (1.0 if gapx >= 0.0 else -1.0)
		p0.x -= push; p1.x += push
		for q in bots:
			q.a.position.x += -push if q == p0 else push
	for q in bots:
		q.a.ground_lock()
	_orbs(d)
	combo_t -= delta
	for q in bots:
		q.pop = maxf(0.0, q.pop - delta)
	hud.queue_redraw()
	_camera(delta)
	if OS.get_cmdline_user_args().has("--probe"):
		for i in bots.size():
			var b: B = bots[i]
			b.a.sk.force_update_all_bone_transforms()
			var lo := 99.0; var lob := ""
			for bn in ["mixamorig_Hips", "mixamorig_Head", "mixamorig_LeftFoot", "mixamorig_RightFoot", "mixamorig_LeftToeBase", "mixamorig_RightToeBase", "mixamorig_LeftHand", "mixamorig_RightHand", "mixamorig_Spine2"]:
				var y := b.a.bone_pos(bn).y
				if y < lo: lo = y; lob = bn
			if lo < -0.05:
				print("PROBE t=%.2f bot%d state=%s anim=%s/%s miny=%.2f (%s) y=%.2f" % [t, i, b.state, b.r.cur if b.r.active else "mx", b.a.cur, lo, lob, b.y])
	if t > 10.9 and not ended:
		ended = true
		var w := 0 if bots[0].dmg < bots[1].dmg else 1
		events.append([t + 0.1, w, "kk", "Cheer", 1.1, -1.0, ""])
		if bots[1 - w].state == "idle":
			events.append([t + 0.15, 1 - w, "kk", "Taunt", 0.8, -1.0, ""])
		win_cam = 1.0
	if t > 12.6:
		get_tree().quit()

func _other(b: B) -> B:
	return bots[1] if b == bots[0] else bots[0]

func _anim(b: B, kind: String, anim: String, spd: float) -> float:
	if kind == "kk":
		return b.r.play(anim, spd)
	b.r.release()
	return b.a.play(anim, spd, 0.14, true)

const MOVES := [
	[["mx", "c_13_17_1", 1.15, 0.47, 3.0], ["mx", "c_13_17_3", 1.15, 0.47, 3.0], ["mx", "k_punch_cross_right_2", 1.2, 0.45, 2.0], ["mx", "c_135_04_2", 1.1, 0.47, 2.0], ["mx", "c_135_11_1", 1.1, 0.47, 2.0], ["mx", "c_135_07_2", 1.05, 0.47, 2.0, "big"]],
	[["mx", "ss_slash", 1.35, 0.40, 3.0], ["mx", "ss_slash3", 1.35, 0.50, 3.0], ["mx", "ss_attack2", 1.25, 0.49, 2.0], ["mx", "ss_casting", 1.8, 0.55, 3.0, "magic"], ["mx", "ss_slash2", 2.0, 0.53, 1.0, "big"], ["mx", "ss_kick", 1.1, 0.33, 2.0]],
]
var think := [0.4, 0.7]
var magic_used := false
var ended := false
var win_cam := 0.0
var last_attacker := 1
var streak := 0
var launched := [false, false]
func _ai(i: int, d: float) -> void:
	var b: B = bots[i]
	var o := _other(b)
	think[i] -= d
	if think[i] > 0.0 or b.state != "idle" or o.state in ["launch", "getup"] or orbs.size() > 0:
		return
	if o.state == "act" and not o.pending.is_empty():
		return
	if absf(o.x - b.x) > b.gap + 0.45:
		return
	if b.dmg + 25.0 < o.dmg and i == last_attacker:
		think[i] = 0.3
		return
	if i == last_attacker and (randf() > 0.3 or streak >= 3):
		think[i] = 0.2
		return
	streak = streak + 1 if i == last_attacker else 1
	last_attacker = i
	# guaranteed spectacle: one magic blast mid-fight, one launch finisher each
	var forced: Array = []
	if i == 1 and not magic_used and t > 4.2 and t < 7.0:
		forced = MOVES[1][3]
	elif not launched[i] and o.dmg >= (18.0 if i == 1 else 8.0) and t > (8.0 if i == 1 else 5.9):
		forced = MOVES[0][5] if i == 0 else MOVES[1][4]
	if not forced.is_empty():
		if forced.size() > 5 and forced[5] == "magic":
			magic_used = true
			think[1 - i] = 1.9
			events.push_front([t, i, "kk", "Dodge_Backward", 1.0, -1.0, ""])
			events.insert(1, [t + 0.45, i, forced[0], forced[1], forced[2], forced[3], "magic"])
		else:
			launched[i] = true
			_do([t, i, forced[0], forced[1], forced[2], forced[3], "launch"])
		streak = 3
		think[i] = 0.8
		return
	var losing := b.dmg > o.dmg + 8.0
	think[i] = randf_range(0.15, 0.35) if losing else randf_range(0.35, 0.7)
	var pool: Array = []
	for m in MOVES[i]:
		if m.size() > 5 and m[5] == "big":
			continue
		if m.size() > 5 and m[5] == "magic":
			continue
		for k in int(m[4]):
			pool.append(m)
	var m: Array = pool.pick_random()
	var res := "hit" if randf() < 0.5 else "hit2"
	if m.size() > 5 and m[5] == "big":
		res = "launch"
	elif m.size() > 5 and m[5] == "magic":
		res = "magic"
		magic_used = true
		think[1 - i] = 1.9
		events.push_front([t, i, "kk", "Dodge_Backward", 1.0, -1.0, ""])
		events.insert(1, [t + 0.45, i, m[0], m[1], m[2], m[3], res])
		return
	elif o.state == "idle":
		var r := randf() * (0.45 if b.dmg + 15.0 < o.dmg else 1.0)
		res = "block" if r < 0.22 else ("dodge" if r < 0.34 else res)
	_do([t, i, m[0], m[1], m[2], m[3], res])

func _do(e: Array) -> void:
	if OS.get_cmdline_user_args().has("--trace"): print("DO t=%.2f who=%d %s res=%s states=%s/%s dmg=%d/%d" % [t, e[1], e[3], e[6], bots[0].state, bots[1].state, bots[0].dmg, bots[1].dmg])
	var b: B = bots[e[1]]
	var o := _other(b)
	if b.state in ["launch", "floor", "getup"]:
		return
	b.state = "act"; b.st = 0.0
	b.dur = _anim(b, e[2], e[3], e[4])
	b.facing = 1 if o.x > b.x else -1
	if e[5] >= 0.0:
		b.pending = {"at": b.dur * e[5], "res": e[6], "kind": e[2]}
		b.vx = 0.0
		b.lunge_at = b.dur * e[5] * 0.7
		Audio.play("whoosh", -6)
		if e[6] == "dodge":
			get_tree().create_timer(b.dur * e[5] * 0.4).timeout.connect(func():
				_react(o, "kk", "Dodge_Backward", 1.0); o.vx = -o.facing * 3.2; Audio.play("dodge", -4))
		if e[6] == "block" or e[6] == "counter":
			_react(o, "kk", "Block", 1.3)
	else:
		b.pending = {}
		if e[3] == "Taunt" or e[3] == "Cheer":
			Audio.play("cheer", -12)

const SWORD_SWAP := {"Block": ["ss_block", 1.0], "Block_Hit": ["ss_block2", 1.1], "Block_Attack": ["ss_attack4", 1.3], "k_hit_to_the_head": ["ss_impact", 1.0], "k_hit_to_the_chest": ["ss_impact3", 1.0], "Running_A": ["ss_run", 1.1]}
func _react(o: B, kind: String, anim: String, spd: float) -> void:
	if o.state in ["launch", "floor", "getup"]:
		return
	if o.idle == "ss_idle" and SWORD_SWAP.has(anim):
		kind = "mx"; spd = SWORD_SWAP[anim][1]; anim = SWORD_SWAP[anim][0]
	o.state = "act"; o.st = 0.0; o.pending = {}
	o.dur = _anim(o, kind, anim, spd)

func _step(b: B, d: float) -> void:
	var o := _other(b)
	b.st += d
	if b.r.weight < 1.0 or not b.r.active:
		b.a.ap.advance(d)
	b.r.step(d)
	match b.state:
		"idle":
			var want: float = o.x - b.facing * b.gap
			b.facing = 1 if o.x > b.x else -1
			want = o.x - b.facing * b.gap
			if absf(want - b.x) > 0.35 and o.state not in ["launch", "floor"]:
				b.vx = move_toward(b.vx, signf(want - b.x) * 2.4, 16 * d)
				if b.idle == "ss_idle":
					if b.a.cur != "ss_run": b.a.play("ss_run", 1.1, 0.18, true)
				elif b.r.cur != "Running_A" or not b.r.active:
					_anim(b, "kk", "Running_A", 1.25)
			else:
				b.vx = move_toward(b.vx, 0, 14 * d)
				if b.r.active or b.a.cur == "ss_run":
					b.r.release()
					b.a.play(b.idle, 1.0, 0.18, true)
		"act":
			if b.lunge_at >= 0.0 and b.st >= b.lunge_at:
				b.lunge_at = -1.0
				b.vx = b.facing * 2.2
			b.vx = move_toward(b.vx, 0, 9 * d)
			if not b.pending.is_empty() and b.st >= b.pending.at:
				var res: String = b.pending.res
				b.pending = {}
				_resolve(b, o, res)
			if b.st >= b.dur:
				b.state = "idle"
				if b.r.cur in ["Taunt", "Cheer"] and t > 9.9:
					b.state = "done"
		"launch":
			b.vy -= 13.0 * d
			b.y += b.vy * d
			var tilt := -b.facing * (1.25 if b.vy > 0.0 else 1.5)
			b.spin = lerpf(b.spin, tilt, 1.0 - exp(-7.0 * d))
			if b.y <= 0.0 and b.vy < 0.0 and b.vy < -4.5 and not b.has_meta("bounced"):
				b.set_meta("bounced", true)
				b.y = 0.0; b.vy = -b.vy * 0.25; b.vx *= 0.6
				Audio.play("land", -2); shake = maxf(shake, 0.1)
				_burst(Vector3(b.x, 0.1, 0), Color(0.8, 0.85, 1.0), 50, 3.0)
			elif b.y <= 0.0 and b.vy < 0.0:
				b.remove_meta("bounced")
				b.y = 0.0
				b.vx *= 0.5
				b.state = "getup"; b.st = 0.0
				b.dur = _anim(b, "mx", "k_move_get_up_from_the_ground", 1.5)
				Audio.play("land", 0); shake = maxf(shake, 0.08)
				_burst(Vector3(b.x, 0.1, 0), Color(0.6, 0.8, 1.0), 40, 3.0)
		"floor":
			b.vx = move_toward(b.vx, 0, 8 * d)
			if b.st >= b.dur:
				b.state = "getup"; b.st = 0.0
				b.dur = _anim(b, "mx", "f_getup", 6.5) * 0.8
		"getup":
			b.spin = lerpf(b.spin, 0.0, 1.0 - exp(-10.0 * d))
			if b.st >= b.dur:
				b.spin = 0.0
				b.state = "idle"
	b.x = clampf(b.x + b.vx * d, -4.0, 4.0)
	var pivot := Vector3(0, 0.95, 0)
	b.a.rotation.z = b.spin
	b.a.position = Vector3(b.x, b.y, 0) + pivot - pivot.rotated(Vector3.BACK, b.spin)
	b.a.apply_shape()
	b.a.ground_lock()
	b.a.yaw_target = 90.0 * b.facing

func _resolve(b: B, o: B, res: String) -> void:
	if OS.get_cmdline_user_args().has("--trace"): print("RES t=%.2f %s by %d" % [t, res, bots.find(b)])
	var at := Vector3((b.x + o.x) * 0.5, 1.2, 0.15)
	var blade: bool = b == bots[1]
	match res:
		"block":
			_burst(at, Color(0.4, 0.9, 1.0), 60, 4.0); Audio.play("clang", -2)
			o.vx = b.facing * 1.4; hitstop = 0.06
			_react(o, "kk", "Block_Hit", 1.4)
		"counter":
			_burst(at, Color(0.4, 0.9, 1.0), 70, 4.5); Audio.play("clang", -1)
			hitstop = 0.07
			o.state = "act"; o.st = 0.0
			o.dur = _anim(o, "mx", "ss_attack4", 1.3) if o.idle == "ss_idle" else _anim(o, "kk", "Block_Attack", 1.4)
			o.pending = {"at": o.dur * 0.45, "res": "hit2", "kind": "kk"}
			o.facing = -b.facing
		"dodge":
			Audio.play("whoosh", -8)
		"hit", "hit2":
			_damage(b, o, 10.0)
			var c := Color(0.5, 0.95, 1.0) if blade else Color(1, 0.75, 0.3)
			_burst(at, c, 60, 4.5); Audio.play("hit_light", 0)
			if blade: Audio.play("clang", -8)
			o.a.flash = 0.08; hitstop = 0.06; shake = maxf(shake, 0.05)
			o.vx = b.facing * (1.6 + o.dmg / 60.0)
			_react(o, "mx", "k_hit_to_the_head" if res == "hit" else "k_hit_to_the_chest", 1.25)
		"launch":
			_burst(at, Color(1, 0.75, 0.3), 120, 6.5); Audio.play("hit_heavy", 0); Audio.play("cheer", -8)
			o.a.flash = 0.1; hitstop = 0.12; shake = 0.14
			_damage(b, o, 14.0)
			var k := 1.0 + o.dmg / 120.0
			o.state = "launch"; o.st = 0.0; o.vx = b.facing * 2.2 * k; o.vy = 4.2 * k; o.y = 0.05
			_slowmo()
			_anim(o, "mx", "f_launch", 1.0)
		"magic":
			var hand: Vector3 = b.a.bone_pos("mixamorig_RightHand")
			var orb := Kit.part(self, "sphere", Vector3(0.14, 0, 0), Kit.pbr(Color.WHITE, 0, 0.2, Color(0.35, 0.8, 1.0), 8.0), hand)
			var core := OmniLight3D.new(); core.light_color = Color(0.35, 0.8, 1.0); core.light_energy = 4.0; core.omni_range = 3.5; orb.add_child(core)
			var trail := Kit.sparks(orb, Vector3.ZERO, Color(0.4, 0.85, 1.0), 60, 1.2, 0.35, 0.0)
			trail.local_coords = false
			orbs.append({"n": orb, "target": o, "from": b})
			Audio.play("zap", -2)

var combo := 0
var combo_by := -1
var combo_t := 0.0
func _damage(by: B, o: B, amt: float) -> void:
	o.dmg += amt
	o.pop = 0.25
	var who := bots.find(by)
	if who == combo_by and combo_t > 0.0:
		combo += 1
	else:
		combo = 1
		combo_by = who
	combo_t = 1.4

func _slowmo() -> void:
	Engine.time_scale = 0.35
	get_tree().create_timer(0.3, true, false, true).timeout.connect(func(): Engine.time_scale = 1.0)

func _orbs(d: float) -> void:
	for ob in orbs:
		var n: Node3D = ob.n
		var tgt: B = ob.target
		var aim := Vector3(tgt.x, 1.15, 0)
		n.position = n.position.move_toward(aim, 9.0 * d)
		n.rotation.y += d * 10.0
		if n.position.distance_to(aim) < 0.15:
			_burst(aim, Color(0.4, 0.85, 1.0), 160, 7.0)
			Audio.play("hit_heavy", 1); Audio.play("zap", -4); Audio.play("cheer", -8)
			hitstop = 0.12; shake = 0.16; tgt.a.flash = 0.12
			_damage(ob.from, tgt, 18.0)
			var k2 := 1.0 + tgt.dmg / 120.0
			tgt.state = "launch"; tgt.st = 0.0; tgt.vx = (ob.from as B).facing * 2.1 * k2; tgt.vy = 4.4 * k2; tgt.y = 0.05
			_slowmo()
			tgt.r.release(); tgt.a.play("f_launch", 1.0, 0.05, true)
			var caster := bots.find(ob.from)
			think[caster] = 1.0
			think[1 - caster] = 2.6
			last_attacker = 1 - caster
			n.queue_free()
			ob.done = true
	orbs = orbs.filter(func(q): return not q.get("done", false))

func _burst(at: Vector3, c: Color, n: int, sp: float) -> void:
	var p := Kit.sparks(self, at, c, n, sp, 0.45, 0.0)
	p.one_shot = true; p.emitting = true
	var fl := OmniLight3D.new(); fl.position = at; fl.light_color = c; fl.light_energy = 4.0; fl.omni_range = 3.0; add_child(fl)
	var tw := create_tween(); tw.tween_property(fl, "light_energy", 0.0, 0.18); tw.tween_callback(fl.queue_free)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _camera(delta: float) -> void:
	var a: B = bots[0]; var c: B = bots[1]
	var hy := maxf(a.y, c.y)
	var mid := Vector3((a.x + c.x) * 0.5, 0.95 + hy * 0.55, 0)
	cam_mid = mid if cam_mid == Vector3.ZERO else cam_mid.lerp(mid, 1.0 - exp(-9.0 * delta))
	var span := absf(a.x - c.x)
	var dd := clampf(4.8 + span * 1.0 + hy * 1.1, 5.4, 9.0)
	if win_cam > 0.0:
		dd *= lerpf(1.0, 0.78, clampf((t - 10.9) / 1.2, 0.0, 1.0))
	var orbit := sin(t * 0.25) * 0.5
	cam.position = cam_mid + Vector3(-0.9 + orbit, 0.15, dd)
	cam.look_at(cam_mid + Vector3(0, -0.05, 0), Vector3.UP)
	fill.global_position = cam.global_position + Vector3(0.5, 1.2, -0.5)
	shake = maxf(0.0, shake - delta * 0.6)
	cam.h_offset = randf_range(-shake, shake)
	cam.v_offset = randf_range(-shake, shake)

func _draw_hud() -> void:
	var vs := hud.size
	var names := ["BRAWLER-7", "AEGIS-X"]
	var cols := [Color(1, 0.35, 0.2), Color(0.3, 0.8, 1)]
	for i in 2:
		var b: B = bots[i]
		var w := 300.0
		var x := 40.0 if i == 0 else vs.x - w - 40.0
		var r := Rect2(x, 26, w, 84)
		hud.draw_rect(r, Color(0.03, 0.03, 0.08, 0.8))
		hud.draw_rect(Rect2(r.position, Vector2(w, 5)), cols[i])
		hud.draw_rect(r, Color(cols[i], 0.7), false, 2.0)
		hud.draw_string(font, r.position + Vector2(16, 36), names[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(0.92, 0.95, 1))
		var sz := 46 + int(b.pop * 60.0)
		var dc := Color(1, 1, 1).lerp(Color(1, 0.25, 0.2), clampf(b.dmg / 100.0, 0, 1))
		var txt := "%d%%" % int(b.dmg)
		for o in [Vector2(-3, 0), Vector2(3, 0), Vector2(0, -3), Vector2(0, 3)]:
			hud.draw_string(font, r.position + Vector2(w - 150, 72) + o, txt, HORIZONTAL_ALIGNMENT_RIGHT, 134, sz, Color(0, 0, 0))
		hud.draw_string(font, r.position + Vector2(w - 150, 72), txt, HORIZONTAL_ALIGNMENT_RIGHT, 134, sz, dc)
	if combo >= 2 and combo_t > 0.0:
		var cx := 60.0 if combo_by == 0 else vs.x - 360.0
		var a := clampf(combo_t / 0.4, 0, 1)
		var t1 := "%d HIT COMBO!" % combo
		for o in [Vector2(-4, 0), Vector2(4, 0), Vector2(0, -4), Vector2(0, 4)]:
			hud.draw_string(font, Vector2(cx, 170) + o, t1, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(0, 0, 0, a))
		hud.draw_string(font, Vector2(cx, 170), t1, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(1, 0.85, 0.25, a))

func _armor(a: Actor, col: Color, glow: Color) -> void:
	var plate := Kit.pbr(col, 0.9, 0.25)
	var dark := Kit.pbr(Color(0.07, 0.07, 0.09), 0.9, 0.35)
	var lit := Kit.pbr(Color.WHITE, 0, 0.3, glow, 3.5)
	var trim := Kit.pbr(Color.WHITE, 0, 0.3, glow, 1.6)
	# helmet: dome, wide glowing visor band, crest fin, ear discs
	var h := Node3D.new(); a.attach("mixamorig_Head", h)
	var dome := Kit.part(h, "sphere", Vector3(0.135, 0, 0), plate, Vector3(0, 0.12, -0.005)); dome.scale = Vector3(1.0, 1.02, 1.05)
	Kit.part(h, "box", Vector3(0.21, 0.055, 0.09), dark, Vector3(0, 0.115, 0.085))
	Kit.part(h, "box", Vector3(0.19, 0.03, 0.02), lit, Vector3(0, 0.115, 0.13))
	Kit.part(h, "box", Vector3(0.025, 0.07, 0.2), plate, Vector3(0, 0.255, -0.02))
	for sx in [-1.0, 1.0]:
		Kit.part(h, "cyl", Vector3(0.045, 0.045, 0.03), dark, Vector3(sx * 0.135, 0.11, 0), Vector3(0, 0, 90))
		Kit.part(h, "cyl", Vector3(0.022, 0.022, 0.035), trim, Vector3(sx * 0.138, 0.11, 0), Vector3(0, 0, 90))
	# chest plate with core, back unit
	var c := Node3D.new(); a.attach("mixamorig_Spine2", c)
	Kit.part(c, "box", Vector3(0.3, 0.2, 0.08), plate, Vector3(0, 0.03, 0.1))
	Kit.part(c, "cyl", Vector3(0.045, 0.045, 0.03), lit, Vector3(0, 0.04, 0.145), Vector3(90, 0, 0))
	Kit.part(c, "box", Vector3(0.24, 0.24, 0.12), dark, Vector3(0, 0.02, -0.13))
	for sx in [-1.0, 1.0]:
		Kit.part(c, "box", Vector3(0.03, 0.18, 0.03), trim, Vector3(sx * 0.07, 0.02, -0.19))
	# waist band
	var w := Node3D.new(); a.attach("mixamorig_Hips", w)
	Kit.part(w, "box", Vector3(0.3, 0.07, 0.22), dark, Vector3(0, 0.06, 0))
	Kit.part(w, "box", Vector3(0.12, 0.05, 0.02), trim, Vector3(0, 0.06, 0.115))
	for side in ["Left", "Right"]:
		var sh := Node3D.new(); a.attach("mixamorig_" + side + "Arm", sh)
		var pad := Kit.part(sh, "sphere", Vector3(0.085, 0, 0), plate, Vector3(0, 0.04, 0)); pad.scale = Vector3(1.15, 0.8, 1.15)
		Kit.part(sh, "box", Vector3(0.02, 0.02, 0.14), trim, Vector3(0, 0.1, 0))
		var fa := Node3D.new(); a.attach("mixamorig_" + side + "ForeArm", fa)
		Kit.part(fa, "cyl", Vector3(0.05, 0.045, 0.16), plate, Vector3(0, 0.14, 0))
		Kit.part(fa, "cyl", Vector3(0.052, 0.052, 0.015), trim, Vector3(0, 0.21, 0))
		var sn := Node3D.new(); a.attach("mixamorig_" + side + "Leg", sn)
		Kit.part(sn, "box", Vector3(0.1, 0.24, 0.07), plate, Vector3(0, 0.2, 0.04))
		Kit.part(sn, "sphere", Vector3(0.05, 0, 0), dark, Vector3(0, 0.0, 0.045))
		var th := Node3D.new(); a.attach("mixamorig_" + side + "UpLeg", th)
		Kit.part(th, "box", Vector3(0.12, 0.2, 0.1), dark, Vector3(0, 0.18, 0.02))
