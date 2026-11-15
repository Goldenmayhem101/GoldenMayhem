## 10-second clip: Mech Mayhem in the HQ arena. Two AI robots trade blows; crowd cheers.
extends "res://scripts/ShotRobot.gd"

var t := 0.0
var bots: Array = []
var shake := 0.0
var cam_mid := Vector3.ZERO
var hitstop := 0.0
var fx_nodes: Array = []

class B:
	var a: Actor
	var style := "fist"
	var x := 0.0
	var y := 0.0
	var vx := 0.0
	var vy := 0.0
	var facing := 1
	var state := "idle"
	var st := 0.0
	var dur := 0.0
	var m: Dictionary = {}
	var done := false
	var think := 0.0
	var spin := 0.0

const FIST := [
	{"anim": "f_jab", "speed": 1.5, "hit": 0.38, "range": 1.2, "kb": 1.5},
	{"anim": "f_elbow", "speed": 1.4, "hit": 0.42, "range": 1.1, "kb": 1.8},
	{"anim": "f_upper", "speed": 1.4, "hit": 0.5, "range": 1.15, "kb": 2.4, "launch": true},
	{"anim": "f_round", "speed": 1.3, "hit": 0.45, "range": 1.4, "kb": 3.5, "launch": true},
	{"anim": "f_knee", "speed": 1.3, "hit": 0.4, "range": 1.0, "kb": 1.8},
]
const BLADE := [
	{"anim": "s_slash", "speed": 1.5, "hit": 0.45, "range": 1.5, "kb": 2.0, "metal": true},
	{"anim": "s_slash2", "speed": 1.7, "hit": 0.42, "range": 1.5, "kb": 2.4, "metal": true},
	{"anim": "s_attack", "speed": 1.5, "hit": 0.5, "range": 1.6, "kb": 3.5, "metal": true, "launch": true},
]

func setup(_d: bool) -> void:
	arena()
	make_fighters()
	Audio.start_music("music_techno", -10)
	Audio.start_amb("crowd_loop", -12)
	for a in crowd:
		a.ap.seek(a.get_meta("seek"), true)
	var r := B.new(); r.a = red; r.style = "fist"; r.x = -1.6; r.facing = 1
	var b := B.new(); b.a = blue; b.style = "blade"; b.x = 1.6; b.facing = -1
	bots = [r, b]
	red.play("f_idle"); blue.play("s_idle")
	red.position = Vector3(r.x, 0, 0); blue.position = Vector3(b.x, 0, 0)
	cam.attributes.dof_blur_far_distance = 7.0
	Audio.play("go", -4)

func _physics_process(delta: float) -> void:
	if bots.is_empty():
		return
	t += delta
	if hitstop > 0.0:
		hitstop -= delta
		for b in bots: b.a.ap.speed_scale = 0.0
		_camera(delta)
		return
	for b in bots:
		_step(b, delta)
	var a: B = bots[0]; var c: B = bots[1]
	if a.y < 0.2 and c.y < 0.2 and absf(a.x - c.x) < 0.8:
		var push := (0.8 - absf(a.x - c.x)) * 0.5
		a.x -= push * signf(c.x - a.x + 0.001); c.x += push * signf(c.x - a.x + 0.001)
	_camera(delta)
	if t > 10.5:
		get_tree().quit()

func _other(b: B) -> B:
	return bots[1] if b == bots[0] else bots[0]

func _step(b: B, delta: float) -> void:
	b.a.ap.speed_scale = b.a.spd
	var o := _other(b)
	b.st += delta
	match b.state:
		"idle", "run":
			var dx := o.x - b.x
			b.facing = 1 if dx > 0 else -1
			b.think -= delta
			var reach := 1.15 if b.style == "fist" else 1.4
			if o.state in ["launch", "floor", "getup"] or t < 0.6:
				b.vx = move_toward(b.vx, 0, 8 * delta)
				b.a.play("f_idle" if b.style == "fist" else "s_idle", 1.0, 0.2)
			elif absf(dx) > reach:
				b.vx = move_toward(b.vx, signf(dx) * 3.0, 14 * delta)
				b.a.play("f_run" if b.style == "fist" else "s_run", 1.1, 0.15)
			else:
				b.vx = move_toward(b.vx, 0, 16 * delta)
				b.a.play("f_idle" if b.style == "fist" else "s_idle", 1.0, 0.15)
				if b.think <= 0.0:
					b.think = randf_range(0.1, 0.35)
					if o.state == "attack" and randf() < 0.35:
						b.state = "block"; b.st = 0.0; b.dur = 0.6
						b.a.play("s_block" if b.style == "blade" else "f_block", 1.4, 0.08, true)
					else:
						var moves: Array = FIST if b.style == "fist" else BLADE
						b.m = moves.pick_random()
						if t > 6.0 and randf() < 0.5:
							b.m = moves.filter(func(q): return q.get("launch", false)).pick_random()
						b.state = "attack"; b.st = 0.0; b.done = false
						b.dur = b.a.play(b.m.anim, b.m.speed, 0.08, true)
						b.vx = b.facing * 1.4
						Audio.play("whoosh", -6)
		"attack":
			if not b.done and b.st >= b.dur * b.m.hit:
				b.done = true
				if absf(o.x - b.x) <= b.m.range + 0.25 and o.y < 1.0:
					_hit(b, o)
			b.vx = move_toward(b.vx, 0, 6 * delta)
			if b.st >= b.dur: b.state = "idle"
		"block", "hit":
			b.vx = move_toward(b.vx, 0, 5 * delta)
			if b.st >= b.dur: b.state = "idle"
		"launch":
			b.vy -= 13.0 * delta
			b.y += b.vy * delta
			b.spin += delta * 8.0 * -b.facing
			if b.y <= 0.0 and b.vy < 0:
				b.y = 0; b.spin = 0
				b.state = "floor"; b.st = 0.0; b.dur = 0.7
				b.a.play("f_floor", 1.6, 0.1, true)
				Audio.play("land", 0)
				shake = maxf(shake, 0.06)
				_burst(Vector3(b.x, 0.1, 0), Color(0.6, 0.8, 1.0), 40, 3.0)
		"floor":
			b.vx = move_toward(b.vx, 0, 8 * delta)
			if b.st >= b.dur:
				b.state = "getup"; b.st = 0.0; b.dur = b.a.play("f_getup", 3.4, 0.2, true) * 0.8
		"getup":
			if b.st >= b.dur: b.state = "idle"
	b.x = clampf(b.x + b.vx * delta, -4.0, 4.0)
	b.a.position = Vector3(b.x, b.y, 0)
	b.a.rotation.z = b.spin
	b.a.yaw_target = 90.0 * b.facing

func _hit(b: B, o: B) -> void:
	var at := Vector3((b.x + o.x) * 0.5, 1.2, 0.15)
	if o.state == "block":
		_burst(at, Color(0.4, 0.9, 1.0), 60, 4.0)
		Audio.play("clang", -2)
		o.vx = b.facing * 1.6
		hitstop = 0.06
		return
	var heavy: bool = b.m.get("launch", false)
	_burst(at, Color(1, 0.75, 0.3) if not b.m.get("metal", false) else Color(0.5, 0.95, 1.0), 110 if heavy else 50, 6.0 if heavy else 4.0)
	Audio.play("hit_heavy" if heavy else "hit_light")
	if b.m.get("metal", false): Audio.play("clang", -6)
	o.a.flash = 0.08
	hitstop = 0.11 if heavy else 0.05
	shake = maxf(shake, 0.12 if heavy else 0.04)
	o.facing = -b.facing
	if heavy:
		o.state = "launch"; o.st = 0.0
		o.vx = b.facing * b.m.kb * 0.8; o.vy = 4.6; o.y = 0.05
		o.a.play("f_launch", 1.0, 0.05, true)
		Audio.play("cheer", -10)
	else:
		o.state = "hit"; o.st = 0.0; o.dur = 0.4
		o.vx = b.facing * b.m.kb
		o.a.play("s_hit" if o.style == "blade" else "f_hit", 1.6, 0.05, true)

func _burst(at: Vector3, c: Color, n: int, sp: float) -> void:
	var p := Kit.sparks(self, at, c, n, sp, 0.45, 0.0)
	p.one_shot = true; p.emitting = true
	var fl := OmniLight3D.new(); fl.position = at; fl.light_color = c; fl.light_energy = 4.0; fl.omni_range = 3.0; add_child(fl)
	var tw := create_tween(); tw.tween_property(fl, "light_energy", 0.0, 0.18); tw.tween_callback(fl.queue_free)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)

func _camera(delta: float) -> void:
	var a: B = bots[0]; var c: B = bots[1]
	var mid := Vector3((a.x + c.x) * 0.5, 1.0 + maxf(a.y, c.y) * 0.3, 0)
	cam_mid = mid if cam_mid == Vector3.ZERO else cam_mid.lerp(mid, 1.0 - exp(-4.0 * delta))
	var span := absf(a.x - c.x)
	var d := clampf(3.4 + span * 0.7, 3.8, 6.5)
	var orbit := sin(t * 0.25) * 0.5
	cam.position = cam_mid + Vector3(-0.9 + orbit, -0.25, d)
	cam.look_at(cam_mid + Vector3(0, 0.05, 0), Vector3.UP)
	shake = maxf(0.0, shake - delta * 0.6)
	cam.h_offset = randf_range(-shake, shake)
	cam.v_offset = randf_range(-shake, shake)
