## PREVIEW 1 - MECH MAYHEM: robot platform fighter. Two AI robots fight in a neon arena.
extends Node3D

signal finished

var cam: Camera3D
var fx: Fx
var ui: Control
var font: Font
var bots: Array = []
var t := 0.0
var shake := 0.0
var started := false
var over := false
var banner_text := ""
var banner_t := 0.0
var banner_col := Color.WHITE
var words: Array = []

class Bot:
	var a: Actor
	var name := ""
	var style := "fist"
	var col := Color.RED
	var x := 0.0
	var y := 0.0
	var vx := 0.0
	var vy := 0.0
	var facing := 1
	var dmg := 0.0
	var stocks := 2
	var state := "idle"
	var st := 0.0
	var dur := 0.0
	var atk: Dictionary = {}
	var hit_done := false
	var think := 0.0
	var hitstop := 0.0
	var spin := 0.0
	var alive := true
	var respawn := 0.0

const FIST_MOVES := [
	{"anim": "f_jab", "speed": 1.6, "hit": 0.35, "dmg": 5.0, "kb": 2.0, "range": 1.15},
	{"anim": "f_elbow", "speed": 1.4, "hit": 0.42, "dmg": 6.0, "kb": 2.5, "range": 1.0},
	{"anim": "f_knee", "speed": 1.3, "hit": 0.38, "dmg": 7.0, "kb": 3.0, "range": 1.0},
	{"anim": "f_upper", "speed": 1.5, "hit": 0.5, "dmg": 9.0, "kb": 4.0, "range": 1.1, "up": true},
	{"anim": "f_round", "speed": 1.4, "hit": 0.45, "dmg": 11.0, "kb": 5.0, "range": 1.35, "heavy": true},
	{"anim": "f_hurricane", "speed": 1.3, "hit": 0.5, "dmg": 13.0, "kb": 6.0, "range": 1.4, "heavy": true},
	{"anim": "f_sweep", "speed": 1.4, "hit": 0.45, "dmg": 7.0, "kb": 2.5, "range": 1.3, "low": true},
]
const BLADE_MOVES := [
	{"anim": "s_slash", "speed": 1.5, "hit": 0.45, "dmg": 8.0, "kb": 3.0, "range": 1.5, "metal": true},
	{"anim": "s_slash2", "speed": 1.8, "hit": 0.4, "dmg": 10.0, "kb": 4.0, "range": 1.5, "metal": true},
	{"anim": "s_attack", "speed": 1.6, "hit": 0.5, "dmg": 12.0, "kb": 5.5, "range": 1.55, "metal": true, "heavy": true},
	{"anim": "m_area", "speed": 1.3, "hit": 0.55, "dmg": 12.0, "kb": 6.0, "range": 2.2, "magic": true, "heavy": true},
]

func setup(_demo: bool) -> void:
	font = load("res://fonts/LilitaOne-Regular.ttf")
	_world()
	bots.append(_make_bot("BRAWLER-7", "fist", Color(0.95, 0.3, 0.2), -2.2, 1))
	bots.append(_make_bot("AEGIS-X", "blade", Color(0.25, 0.65, 1.0), 2.2, -1))
	var layer := CanvasLayer.new()
	add_child(layer)
	fx = Fx.new()
	layer.add_child(fx)
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	layer.add_child(ui)
	Audio.start_music("music_techno", -9.0)
	_intro()

func _world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.04, 0.05, 0.1)
	e.glow_enabled = true
	e.glow_intensity = 0.9
	e.glow_bloom = 0.15
	env.environment = e
	add_child(env)
	cam = Camera3D.new()
	cam.fov = 34
	cam.position = Vector3(0, 1.4, 8.5)
	add_child(cam)
	cam.current = true
	# floor: dark metal panels with neon seams
	var floor_mat := Kit.toon(Color(0.17, 0.19, 0.26), Color(0.09, 0.1, 0.15), 0.0)
	Kit.part(self, "box", Vector3(60, 1, 10), floor_mat, Vector3(0, -0.5, -2))
	var cyan := Kit.glow(Color(0.3, 0.9, 1.0))
	var magenta := Kit.glow(Color(1.0, 0.3, 0.75))
	for i in range(-15, 16):
		Kit.part(self, "box", Vector3(0.03, 0.01, 10), cyan if i % 2 == 0 else magenta, Vector3(i * 2.0, 0.005, -2))
	Kit.part(self, "box", Vector3(60, 0.02, 0.06), cyan, Vector3(0, 0.01, 1.6))
	Kit.part(self, "box", Vector3(60, 0.02, 0.06), magenta, Vector3(0, 0.01, -2.2))
	# back wall: panels, giant screens, light columns
	var wall := Kit.toon(Color(0.12, 0.13, 0.2), Color(0.07, 0.07, 0.12), 0.02)
	Kit.part(self, "box", Vector3(60, 9, 0.5), wall, Vector3(0, 4.5, -7))
	for i in range(-6, 7):
		Kit.part(self, "box", Vector3(0.35, 9, 0.6), Kit.toon(Color(0.2, 0.22, 0.32), Color(0.1, 0.1, 0.16), 0.02), Vector3(i * 4.0, 4.5, -6.6))
		Kit.part(self, "box", Vector3(0.08, 7.5, 0.1), cyan if i % 2 == 0 else magenta, Vector3(i * 4.0, 4.5, -6.25))
	for i in [-1, 1]:
		var scr := Kit.part(self, "box", Vector3(5.5, 3.0, 0.1), Kit.glow(Color(0.1, 0.2, 0.35)), Vector3(i * 6.0, 5.2, -6.3))
		Kit.part(scr, "box", Vector3(5.1, 0.12, 0.05), magenta, Vector3(0, 1.2, 0.06))
		Kit.part(scr, "box", Vector3(5.1, 0.12, 0.05), cyan, Vector3(0, -1.2, 0.06))
		Kit.part(scr, "box", Vector3(1.5, 1.5, 0.05), Kit.glow(Color(1, 0.85, 0.2)), Vector3(0, 0, 0.06), Vector3(0, 0, 45))
	# crowd silhouettes with glow sticks
	var r := RandomNumberGenerator.new()
	r.seed = 4
	var dark := Kit.toon(Color(0.05, 0.05, 0.09), Color(0.03, 0.03, 0.05), 0.0)
	for i in 70:
		var x := -20.0 + i * 0.58 + r.randf_range(-0.1, 0.1)
		var h := r.randf_range(0.9, 1.2)
		var p := Kit.part(self, "box", Vector3(0.35, h, 0.3), dark, Vector3(x, h * 0.5 + 0.2, -5.5 + r.randf_range(-0.3, 0.3)))
		Kit.part(p, "sphere", Vector3(0.16, 0, 0), dark, Vector3(0, h * 0.5 + 0.12, 0))
		if i % 3 == 0:
			Kit.part(p, "box", Vector3(0.04, 0.35, 0.04), [cyan, magenta, Kit.glow(Color(1, 0.9, 0.3))][i % 3 if i % 2 else 1], Vector3(0.12, h * 0.5 + 0.35, 0.1), Vector3(0, 0, r.randf_range(-30, 30)))
	# barrier rails at screen edge depth
	Kit.part(self, "box", Vector3(60, 0.5, 0.2), Kit.toon(Color(0.3, 0.32, 0.42), Color(0.15, 0.15, 0.22), 0.02), Vector3(0, 0.25, -4.4))
	Kit.part(self, "box", Vector3(60, 0.05, 0.22), cyan, Vector3(0, 0.52, -4.4))

func _make_bot(n: String, style: String, c: Color, x: float, facing: int) -> Bot:
	var b := Bot.new()
	b.name = n
	b.style = style
	b.col = c
	b.x = x
	b.facing = facing
	b.a = Actor.new()
	add_child(b.a)
	var shell := Kit.toon(Color(0.85, 0.87, 0.92), Color(0.42, 0.45, 0.55), 0.012)
	var trim := Kit.toon(c, c.darkened(0.5), 0.008)
	if style == "fist":
		b.a.setup(Kit.toon(c, c.darkened(0.55), 0.012), Kit.glow(Color(1, 0.75, 0.3)))
	else:
		b.a.setup(shell, Kit.glow(c.lightened(0.3)))
	# visor + shoulder plates
	var visor := Node3D.new()
	b.a.attach("mixamorig_Head", visor)
	Kit.part(visor, "box", Vector3(0.2, 0.06, 0.06), Kit.glow(c.lightened(0.4)), Vector3(0, 0.1, 0.1))
	for side in ["Left", "Right"]:
		var pad := Node3D.new()
		b.a.attach("mixamorig_" + side + "Shoulder", pad)
		Kit.part(pad, "box", Vector3(0.2, 0.08, 0.22), trim, Vector3(0, 0.08, 0))
	if style == "blade":
		var sword := Node3D.new()
		b.a.attach("mixamorig_RightHand", sword)
		Kit.part(sword, "box", Vector3(0.05, 0.95, 0.015), Kit.glow(Color(0.6, 0.95, 1.0)), Vector3(0, 0.55, 0.03))
		Kit.part(sword, "box", Vector3(0.22, 0.04, 0.05), trim, Vector3(0, 0.08, 0.03))
		var shield := Node3D.new()
		b.a.attach("mixamorig_LeftForeArm", shield)
		var sh := Kit.part(shield, "cyl", Vector3(0.3, 0.3, 0.05), trim, Vector3(0, 0.18, -0.08), Vector3(90, 0, 0))
		Kit.part(sh, "cyl", Vector3(0.12, 0.12, 0.06), Kit.glow(c.lightened(0.3)), Vector3(0, 0, 0))
		b.a.play("s_idle")
	b.a.yaw_target = 90.0 * facing
	b.a.yaw = b.a.yaw_target
	b.a.position = Vector3(x, 0, 0)
	return b

func _intro() -> void:
	await get_tree().create_timer(0.6).timeout
	for n in ["3", "2", "1"]:
		_banner(n, Color(0.4, 0.95, 1.0), 0.7)
		Audio.play("beep")
		await get_tree().create_timer(0.7).timeout
	_banner("FIGHT!", Color(1, 0.4, 0.75), 1.0)
	Audio.play("go")
	started = true

func _banner(s: String, c: Color, d: float) -> void:
	banner_text = s
	banner_col = c
	banner_t = d

func _physics_process(delta: float) -> void:
	t += delta
	banner_t -= delta
	for b in bots:
		_step(b, delta)
	var a: Bot = bots[0]
	var c: Bot = bots[1]
	if a.alive and c.alive and a.y < 0.3 and c.y < 0.3 and absf(a.x - c.x) < 0.75:
		var push := (0.75 - absf(a.x - c.x)) * 0.5 * (1.0 if c.x >= a.x else -1.0)
		a.x -= push
		c.x += push
	_camera(delta)
	for w in words:
		w.life -= delta
	words = words.filter(func(w): return w.life > 0.0)
	ui.queue_redraw()

func _other(b: Bot) -> Bot:
	return bots[1] if b == bots[0] else bots[0]

func _step(b: Bot, delta: float) -> void:
	if not b.alive:
		b.respawn -= delta
		if b.respawn <= 0.0 and b.stocks > 0:
			b.alive = true
			b.a.visible = true
			b.x = 0.0 if absf(_other(b).x) > 1.5 else -_other(b).x * 0.5
			b.y = 5.0
			b.vy = 0.0
			b.dmg = 0.0
			b.state = "air"
			fx.sparkle(_scr(Vector3(b.x, 1, 0)), b.col)
		return
	if b.hitstop > 0.0:
		b.hitstop -= delta
		b.a.ap.speed_scale = 0.0
		return
	b.a.ap.speed_scale = b.a.spd
	var o := _other(b)
	b.st += delta
	match b.state:
		"idle", "run":
			if not started or over:
				_anim_idle(b)
				if over and b.stocks > 0 and b.state != "victory":
					b.state = "victory"
					b.a.play("f_victory", 1.0, 0.2, true)
					b.a.yaw_target = 0.0
				return
			var dx := o.x - b.x
			b.facing = 1 if dx > 0 else -1
			b.think -= delta
			var reach := 1.2 if b.style == "fist" else 1.45
			if not o.alive or o.state in ["floor", "getup"]:
				b.vx = move_toward(b.vx, 0, 10 * delta)
				_anim_idle(b)
			elif absf(dx) > reach:
				b.vx = move_toward(b.vx, signf(dx) * 3.6, 18 * delta)
				b.state = "run"
				b.a.play("f_run" if b.style == "fist" else "s_run", 1.15, 0.15)
			else:
				b.vx = move_toward(b.vx, 0, 20 * delta)
				_anim_idle(b)
				if b.think <= 0.0:
					b.think = randf_range(0.15, 0.45)
					var r := randf()
					if o.state == "attack" and r < 0.25:
						_start(b, "block")
					elif o.state == "attack" and r < 0.4:
						_start(b, "dodge")
					else:
						var moves: Array = FIST_MOVES if b.style == "fist" else BLADE_MOVES
						var m: Dictionary = moves.pick_random()
						if o.dmg > 70 and randf() < 0.6:
							m = moves.filter(func(q): return q.get("heavy", false)).pick_random()
						_attack(b, m)
		"attack":
			var m := b.atk
			if not b.hit_done and b.st >= b.dur * m.hit:
				b.hit_done = true
				if m.get("magic", false):
					fx.ko(_scr(Vector3(b.x + b.facing * 0.8, 1.0, 0)), Vector2(-b.facing, 0), Color(0.5, 0.8, 1))
					Audio.play("zap")
				if o.alive and absf(o.x - b.x) <= m.range + 0.2 and signf(o.x - b.x) == b.facing and o.y < 1.2:
					_hit(b, o, m)
			b.vx = move_toward(b.vx, 0, 8 * delta)
			if b.st >= b.dur:
				b.state = "idle"
		"block", "dodge", "hit":
			b.vx = move_toward(b.vx, 0, 6 * delta)
			if b.st >= b.dur:
				b.state = "idle"
		"launch", "air":
			b.vy -= 14.0 * delta
			b.y += b.vy * delta
			if b.state == "launch":
				b.spin += delta * 9.0 * -b.facing
				fx.smoke(_scr(Vector3(b.x, b.y + 0.9, 0)))
			if absf(b.x) > 9.5 or b.y > 7.0:
				_ko(b)
				return
			if b.y <= 0.0 and b.vy < 0.0:
				b.y = 0.0
				b.spin = 0.0
				fx.dust(_scr(Vector3(b.x, 0, 0)), 10, 1.4)
				Audio.play("land")
				shake = maxf(shake, 0.08)
				if b.state == "launch":
					b.state = "floor"
					b.st = 0.0
					b.dur = 0.9
					b.a.play("f_floor", 1.6, 0.1, true)
				else:
					b.state = "idle"
		"floor":
			b.vx = move_toward(b.vx, 0, 10 * delta)
			if b.st >= b.dur:
				b.state = "getup"
				b.st = 0.0
				b.dur = b.a.play("f_getup", 3.2, 0.2, true) * 0.85
		"getup":
			if b.st >= b.dur:
				b.state = "idle"
		"victory":
			pass
	b.x += b.vx * delta
	b.x = clampf(b.x, -12, 12)
	b.a.position = Vector3(b.x, b.y, 0)
	b.a.rotation.z = b.spin
	if b.state not in ["victory"]:
		b.a.yaw_target = 90.0 * b.facing

func _anim_idle(b: Bot) -> void:
	b.state = "idle" if b.state == "run" else b.state
	b.a.play("f_idle" if b.style == "fist" else "s_idle", 1.0, 0.2)

func _attack(b: Bot, m: Dictionary) -> void:
	b.atk = m
	b.state = "attack"
	b.st = 0.0
	b.hit_done = false
	b.dur = b.a.play(m.anim, m.speed, 0.08, true)
	b.vx = b.facing * 1.6
	Audio.play("servo", -10)
	Audio.play("whoosh_heavy" if m.get("heavy", false) else "whoosh", -4)

func _start(b: Bot, what: String) -> void:
	b.state = what
	b.st = 0.0
	if what == "block":
		b.dur = 0.7
		b.a.play("s_block" if b.style == "blade" else "f_block", 1.4, 0.08, true)
	else:
		b.dur = b.a.play("f_dodge", 2.4, 0.08, true) * 0.6
		b.vx = -b.facing * 3.0

func _hit(b: Bot, o: Bot, m: Dictionary) -> void:
	var at := Vector3((b.x + o.x) * 0.5, 1.15 if not m.get("low", false) else 0.4, 0.2)
	if o.state == "block" and o.facing != b.facing:
		fx.hit(_scr(at), Vector2(b.facing, 0), false, Color(0.6, 0.9, 1))
		Audio.play("clang", -2)
		o.vx = b.facing * 2.0
		_word("BLOCK!", _scr(at) + Vector2(0, -70), Color(0.5, 0.9, 1))
		return
	if o.state == "dodge":
		return
	o.dmg += m.dmg * 1.7
	var kb: float = m.kb * (1.0 + o.dmg / 60.0)
	var heavy: bool = m.get("heavy", false) or kb > 6.5
	var tint := Color(0.7, 0.95, 1) if m.get("metal", false) else Color(1, 0.75, 0.3)
	if m.get("magic", false):
		tint = Color(0.5, 0.8, 1)
	fx.hit(_scr(at), Vector2(b.facing, -0.3), heavy, tint)
	Audio.play("hit_heavy" if heavy else "hit_light")
	if m.get("metal", false):
		Audio.play("clang", -6)
	o.a.flash = 0.1
	var stop := 0.05 + kb * 0.01
	o.hitstop = stop
	b.hitstop = stop
	shake = maxf(shake, 0.03 + kb * 0.012)
	o.facing = -b.facing
	if heavy or kb > 5.0:
		o.state = "launch"
		o.st = 0.0
		o.vx = b.facing * kb * 0.9
		o.vy = kb * (1.15 if m.get("up", false) else 0.75)
		o.y = maxf(o.y, 0.05)
		o.a.play("f_launch", 1.0, 0.05, true)
		_word(["SMASH!", "KRAK!", "BOOM!", "WHAM!"].pick_random(), _scr(at) + Vector2(0, -80), Color(1, 0.85, 0.2))
	else:
		o.state = "hit"
		o.st = 0.0
		o.dur = 0.45
		o.vx = b.facing * kb * 0.6
		o.a.play("f_hitlow" if m.get("low", false) else ("s_hit" if o.style == "blade" else "f_hit"), 1.6, 0.05, true)

func _ko(b: Bot) -> void:
	b.alive = false
	b.a.visible = false
	b.stocks -= 1
	var p := _scr(Vector3(clampf(b.x, -8, 8), clampf(b.y + 1, 0.5, 5), 0))
	var vs := get_viewport().get_visible_rect().size
	fx.ko(p.clamp(Vector2(40, 40), vs - Vector2(40, 40)), Vector2(signf(b.x), -0.3), b.col)
	Audio.play("ko", 2)
	shake = 0.4
	b.respawn = 1.6
	if b.stocks <= 0:
		over = true
		_banner("K.O.!", Color(1, 0.35, 0.5), 2.0)
		await get_tree().create_timer(4.5).timeout
		finished.emit()
	else:
		_banner("K.O.!", Color(1, 0.4, 0.6), 1.0)

func _word(s: String, at: Vector2, c: Color) -> void:
	words.append({"text": s, "pos": at, "color": c, "life": 0.7, "rot": randf_range(-0.25, 0.25)})

func _scr(p: Vector3) -> Vector2:
	return cam.unproject_position(p)

func _camera(delta: float) -> void:
	var xs: Array = []
	for b in bots:
		if b.alive:
			xs.append(b.x)
	var cx: float = 0.0 if xs.is_empty() else (xs.min() + xs.max()) * 0.5
	var span: float = 0.0 if xs.is_empty() else xs.max() - xs.min()
	var maxy := 0.0
	for b in bots:
		if b.alive:
			maxy = maxf(maxy, b.y)
	var dist := clampf(5.5 + span * 0.9 + maxy * 0.6, 6.0, 13.0)
	var target := Vector3(cx, 1.3 + maxy * 0.35, dist)
	cam.position = cam.position.lerp(target, 1.0 - exp(-3.5 * delta))
	shake = maxf(0.0, shake - delta * 0.8)
	cam.h_offset = randf_range(-shake, shake)
	cam.v_offset = randf_range(-shake, shake)

func _draw_ui() -> void:
	var vs := ui.size
	# fighter cards
	for i in bots.size():
		var b: Bot = bots[i]
		var w := 300.0
		var x := 30.0 if i == 0 else vs.x - w - 30.0
		var r := Rect2(x, 20, w, 78)
		ui.draw_rect(r, Color(0.05, 0.06, 0.12, 0.85))
		ui.draw_rect(Rect2(r.position, Vector2(w, 5)), b.col)
		ui.draw_rect(r, b.col.lightened(0.2), false, 2.0)
		ui.draw_string(font, r.position + Vector2(16, 34), b.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.9, 0.95, 1))
		ui.draw_string(font, r.position + Vector2(16, 34 + 22), "BOXER UNIT" if b.style == "fist" else "BLADE + SHIELD UNIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, b.col.lightened(0.3))
		var d := "%d%%" % int(b.dmg)
		var dc := Color(1, 1, 1).lerp(Color(1, 0.3, 0.3), clampf(b.dmg / 120.0, 0, 1))
		ui.draw_string(font, r.position + Vector2(w - 130, 60), d, HORIZONTAL_ALIGNMENT_RIGHT, 110, 44, dc)
		for s in 2:
			ui.draw_circle(r.position + Vector2(20 + s * 22, 70), 6, b.col if s < b.stocks else Color(0.2, 0.2, 0.25))
	ui.draw_string(font, Vector2(0, vs.y - 24), "MECH MAYHEM  -  preview", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 22, Color(0.5, 0.9, 1, 0.8))
	for w2 in words:
		var k: float = 1.0 - w2.life / 0.7
		var sz := int(56 * (1.0 + (1.0 - minf(k * 6.0, 1.0)) * 0.7))
		ui.draw_set_transform(w2.pos, w2.rot, Vector2.ONE)
		for o in [Vector2(-4, 0), Vector2(4, 0), Vector2(0, -4), Vector2(0, 4)]:
			ui.draw_string(font, o - Vector2(sz * 1.3, 0), w2.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(0.02, 0.02, 0.06, 1.0 - k))
		ui.draw_string(font, -Vector2(sz * 1.3, 0), w2.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(w2.color, 1.0 - maxf(0, k - 0.6) * 2.5))
		ui.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	if banner_t > 0.0:
		var sz2 := 150
		for o in [Vector2(-6, 0), Vector2(6, 0), Vector2(0, -6), Vector2(0, 6)]:
			ui.draw_string(font, Vector2(0, vs.y * 0.45) + o, banner_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, sz2, Color(0.02, 0.02, 0.06))
		ui.draw_string(font, Vector2(0, vs.y * 0.45), banner_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, sz2, banner_col)
