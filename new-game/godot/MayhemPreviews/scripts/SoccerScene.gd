## PREVIEW 3 - BRAWL BALL: 3-a-side cage football where tackles (and the odd punch) are allowed.
extends Node3D

signal finished

const HALF_X := 15.0
const HALF_Z := 8.0
const GOAL_W := 1.9
var cam: Camera3D
var fx: Fx
var ui: Control
var font: Font
var t := 0.0
var clock := 0.0
var players: Array = []
var ball: MeshInstance3D
var bpos := Vector3(0, 0.11, 0)
var bvel := Vector3.ZERO
var owner_p = null
var score := [0, 0]
var frozen := 1.5
var banner_text := ""
var banner_t := 0.0
var banner_col := Color.WHITE
var words: Array = []
var shake := 0.0
var last_touch = null
var ended := false
var cam_look := Vector3.ZERO

class P:
	var a: Actor
	var team := 0
	var gk := false
	var pos := Vector3.ZERO
	var vel := Vector3.ZERO
	var state := "run"
	var st := 0.0
	var dur := 0.0
	var cd := 0.0
	var home := Vector3.ZERO
	var name := ""
	var acted := false

func setup(_demo: bool) -> void:
	font = load("res://fonts/LilitaOne-Regular.ttf")
	_world()
	var red := [Color(0.9, 0.18, 0.15), Color.WHITE]
	var blue := [Color(0.15, 0.35, 0.9), Color.WHITE]
	_add_player(0, false, Vector3(-3, 0, -1.5), red, "RED 9")
	_add_player(0, false, Vector3(-5, 0, 2.5), red, "RED 7")
	_add_player(0, true, Vector3(-HALF_X + 0.6, 0, 0), [Color(1, 0.8, 0.15), Color(0.1, 0.1, 0.1)], "RED GK")
	_add_player(1, false, Vector3(3, 0, 1.5), blue, "BLUE 10")
	_add_player(1, false, Vector3(5, 0, -2.5), blue, "BLUE 4")
	_add_player(1, true, Vector3(HALF_X - 0.6, 0, 0), [Color(0.2, 0.85, 0.4), Color(0.1, 0.1, 0.1)], "BLUE GK")
	ball = MeshInstance3D.new()
	ball.mesh = Kit.mesh("sphere", 0.11)
	ball.material_override = Kit.toon(Color(0.97, 0.97, 0.95), Color(0.6, 0.6, 0.65), 0.01)
	add_child(ball)
	for i in 6:
		var patch := Kit.part(ball, "sphere", Vector3(0.035, 0, 0), Kit.toon(Color(0.1, 0.1, 0.1), Color(0.05, 0.05, 0.05), 0.0))
		patch.position = Vector3(cos(i * 1.05), sin(i * 2.1) * 0.6, sin(i * 1.05)).normalized() * 0.1
	var layer := CanvasLayer.new()
	add_child(layer)
	fx = Fx.new()
	layer.add_child(fx)
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	layer.add_child(ui)
	Audio.start_amb("crowd_loop", -6.0)
	_banner("KICK OFF!", Color(1, 0.95, 0.4), 1.4)
	Audio.play("whistle")

func _add_player(team: int, gk: bool, at: Vector3, cols: Array, n: String) -> void:
	var p := P.new()
	p.team = team
	p.gk = gk
	p.pos = at
	p.home = at
	p.name = n
	p.a = Actor.new()
	add_child(p.a)
	p.a.setup(Kit.toon(cols[0], cols[0].darkened(0.5), 0.012), Kit.toon(cols[1], cols[1].darkened(0.4), 0.008))
	p.a.play("b_gkidle" if gk else "b_idle")
	p.a.yaw_target = 90.0 if team == 0 else -90.0
	p.a.yaw = p.a.yaw_target
	p.a.position = at
	players.append(p)

func _world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.1, 0.12, 0.2)
	e.glow_enabled = true
	env.environment = e
	add_child(env)
	cam = Camera3D.new()
	cam.fov = 40
	cam.position = Vector3(0, 10, 17)
	add_child(cam)
	cam.current = true
	# pitch stripes
	var g1 := Kit.toon(Color(0.3, 0.62, 0.28), Color(0.2, 0.45, 0.18), 0.0)
	var g2 := Kit.toon(Color(0.35, 0.7, 0.32), Color(0.24, 0.5, 0.21), 0.0)
	for i in 15:
		Kit.part(self, "box", Vector3(2.0, 0.1, HALF_Z * 2 + 1), g1 if i % 2 == 0 else g2, Vector3(-HALF_X + 1 + i * 2.0, -0.05, 0))
	Kit.part(self, "box", Vector3(60, 0.1, 40), Kit.toon(Color(0.2, 0.42, 0.2), Color(0.14, 0.3, 0.14), 0.0), Vector3(0, -0.07, 0))
	var white := Kit.toon(Color(0.95, 0.95, 0.92), Color(0.8, 0.8, 0.78), 0.0)
	for z in [-HALF_Z, HALF_Z]:
		Kit.part(self, "box", Vector3(HALF_X * 2, 0.02, 0.1), white, Vector3(0, 0.01, z))
	for x in [-HALF_X, HALF_X, 0.0]:
		Kit.part(self, "box", Vector3(0.1, 0.02, HALF_Z * 2), white, Vector3(x, 0.01, 0))
	for i in 48:
		var a := i * TAU / 48.0
		Kit.part(self, "box", Vector3(0.22, 0.02, 0.1), white, Vector3(cos(a) * 2.5, 0.01, sin(a) * 2.5), Vector3(0, -a * 180 / PI + 90, 0))
	for sx in [-1.0, 1.0]:
		Kit.part(self, "box", Vector3(0.1, 0.02, 7.0), white, Vector3(sx * (HALF_X - 4.0), 0.01, 0))
		Kit.part(self, "box", Vector3(4.0, 0.02, 0.1), white, Vector3(sx * (HALF_X - 2.0), 0.01, 3.5))
		Kit.part(self, "box", Vector3(4.0, 0.02, 0.1), white, Vector3(sx * (HALF_X - 2.0), 0.01, -3.5))
		# goal frame + net
		var post := Kit.toon(Color(0.98, 0.98, 0.98), Color(0.75, 0.75, 0.78), 0.008)
		var gx = sx * (HALF_X + 0.05)
		for z in [-GOAL_W, GOAL_W]:
			Kit.part(self, "cyl", Vector3(0.07, 0.07, 2.2), post, Vector3(gx, 1.1, z))
		Kit.part(self, "cyl", Vector3(0.07, 0.07, GOAL_W * 2), post, Vector3(gx, 2.2, 0), Vector3(90, 0, 0))
		var net := StandardMaterial3D.new()
		net.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		net.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		net.albedo_color = Color(1, 1, 1, 0.22)
		net.cull_mode = BaseMaterial3D.CULL_DISABLED
		Kit.part(self, "box", Vector3(0.02, 2.2, GOAL_W * 2), net, Vector3(gx + sx * 1.2, 1.1, 0))
		for z in [-GOAL_W, GOAL_W]:
			Kit.part(self, "box", Vector3(1.2, 2.2, 0.02), net, Vector3(gx + sx * 0.6, 1.1, z))
		Kit.part(self, "box", Vector3(1.2, 0.02, GOAL_W * 2), net, Vector3(gx + sx * 0.6, 2.2, 0))
	# cage boards with sponsor colours
	var cols := [Color(0.95, 0.75, 0.15), Color(0.2, 0.25, 0.4), Color(0.9, 0.3, 0.25), Color(0.25, 0.6, 0.9)]
	for i in 16:
		Kit.part(self, "box", Vector3(2.0, 0.8, 0.15), Kit.toon(cols[i % 4], cols[i % 4].darkened(0.4), 0.01), Vector3(-HALF_X - 1 + i * 2.0 + 1, 0.4, -HALF_Z - 0.9))
	# stands + crowd
	var r := RandomNumberGenerator.new()
	r.seed = 9
	for row in 6:
		Kit.part(self, "box", Vector3(44, 0.6, 1.2), Kit.toon(Color(0.3, 0.32, 0.4), Color(0.18, 0.19, 0.25), 0.01), Vector3(0, 0.6 + row * 0.75, -HALF_Z - 2.2 - row * 1.2))
		for k in 40:
			var c := Color.from_hsv(r.randf(), 0.6, r.randf_range(0.5, 0.95))
			if k % 3 == 0:
				c = [Color(0.9, 0.2, 0.2), Color(0.2, 0.4, 0.95)][k % 2]
			var person := Kit.part(self, "box", Vector3(0.36, 0.5, 0.3), Kit.toon(c, c.darkened(0.5), 0.0), Vector3(-21 + k * 1.05 + r.randf_range(-0.15, 0.15), 1.15 + row * 0.75, -HALF_Z - 2.2 - row * 1.2))
			Kit.part(person, "sphere", Vector3(0.14, 0, 0), Kit.toon(Color(0.8, 0.62, 0.45).lerp(Color(0.35, 0.22, 0.15), r.randf()), Color(0.3, 0.2, 0.15), 0.0), Vector3(0, 0.38, 0))
			person.set_meta("bob", r.randf() * TAU)
			crowd.append(person)
	# floodlights
	for x in [-18.0, 18.0]:
		Kit.part(self, "cyl", Vector3(0.2, 0.3, 14), Kit.toon(Color(0.4, 0.42, 0.48), Color(0.2, 0.2, 0.25), 0.01), Vector3(x, 7, -15))
		Kit.part(self, "box", Vector3(3, 1.6, 0.3), Kit.glow(Color(1, 1, 0.9)), Vector3(x, 14, -14.8))

var crowd: Array = []

func _banner(s: String, c: Color, d: float) -> void:
	banner_text = s
	banner_col = c
	banner_t = d

func _word(s: String, at: Vector3, c: Color) -> void:
	words.append({"text": s, "pos": at, "color": c, "life": 0.9, "rot": randf_range(-0.2, 0.2)})

func _goal_x(team: int) -> float:
	return HALF_X if team == 0 else -HALF_X

func _physics_process(delta: float) -> void:
	t += delta
	banner_t -= delta
	for w in words:
		w.life -= delta
	words = words.filter(func(w): return w.life > 0.0)
	for c in crowd:
		c.position.y += sin(t * 9.0 + c.get_meta("bob")) * 0.004 * (3.0 if banner_text == "GOAL!" and banner_t > 0 else 1.0)
	if frozen > 0.0:
		frozen -= delta
		for p in players:
			_face_move(p, delta, Vector3.ZERO)
		_camera(delta)
		ui.queue_redraw()
		return
	clock += delta
	for p in players:
		_think(p, delta)
	_ball(delta)
	_camera(delta)
	ui.queue_redraw()
	if not ended and (clock > 44.0 or score[0] + score[1] >= 3):
		ended = true
		frozen = 99.0
		Audio.play("whistle")
		_banner("FULL TIME", Color(1, 0.95, 0.5), 4.0)
		var win := 0 if score[0] > score[1] else 1
		for p in players:
			p.a.play("b_celebrate" if p.team == win else "b_fallen", 1.0, 0.3, true)
		await get_tree().create_timer(4.2).timeout
		finished.emit()

func _nearest(team: int, to: Vector3, outfield := true):
	var best = null
	var bd := INF
	for p in players:
		if p.team != team or (outfield and p.gk) or p.state in ["tripped", "fallen", "getup", "hurt"]:
			continue
		var d: float = p.pos.distance_to(to)
		if d < bd:
			bd = d
			best = p
	return best

func _think(p: P, delta: float) -> void:
	p.st += delta
	p.cd -= delta
	var want := Vector3.ZERO
	match p.state:
		"tackle":
			if not p.acted and p.st > p.dur * 0.25:
				p.acted = true
				var victim = owner_p
				if victim != null and victim.team != p.team and victim.pos.distance_to(p.pos) < 1.9:
					if randf() < 0.7:
						_knock_down(victim, "tripped")
						_word("TACKLE!", victim.pos + Vector3(0, 2.2, 0), Color(1, 0.85, 0.2))
						Audio.play("hit_heavy", -2)
						fx.dust(_scr(victim.pos), 10, 1.4)
						owner_p = null
						bvel = (Vector3(_goal_x(p.team), 0, 0) - p.pos).normalized() * 3.0 + Vector3(0, 1.5, 0)
						last_touch = p
			p.pos += p.vel * delta
			p.vel = p.vel.move_toward(Vector3.ZERO, 5.0 * delta)
			if p.st >= p.dur:
				p.state = "run"
			_place(p)
			return
		"punch":
			if not p.acted and p.st > p.dur * 0.35:
				p.acted = true
				var v = owner_p
				if v != null and v.team != p.team and v.pos.distance_to(p.pos) < 1.4:
					_knock_down(v, "hurt")
					_word("FOUL!", v.pos + Vector3(0, 2.2, 0), Color(1, 0.35, 0.3))
					Audio.play("hit_light")
					Audio.play("whistle", -6)
					fx.hit(_scr(v.pos + Vector3(0, 1.6, 0)), Vector2(1, -0.2), true)
					shake = 0.15
					owner_p = null
					bvel = Vector3(randf_range(-2, 2), 1.2, randf_range(-2, 2))
			if p.st >= p.dur:
				p.state = "run"
			_place(p)
			return
		"kick", "shoot":
			if not p.acted and p.st > p.dur * (0.42 if p.state == "shoot" else 0.35):
				p.acted = true
				_release(p, p.state == "shoot")
			if p.st >= p.dur:
				p.state = "run"
			_place(p)
			return
		"dive":
			p.pos += p.vel * delta
			p.vel = p.vel.move_toward(Vector3.ZERO, 4.0 * delta)
			if p.st >= p.dur:
				p.state = "run"
				p.pos.z = clampf(p.pos.z, -GOAL_W, GOAL_W)
			_place(p)
			return
		"tripped", "hurt":
			if p.st >= p.dur:
				p.state = "fallen"
				p.st = 0.0
				p.dur = 0.9
				p.a.play("b_fallen", 1.0, 0.2)
			_place(p)
			return
		"fallen":
			if p.st >= p.dur:
				p.state = "getup"
				p.st = 0.0
				p.dur = p.a.play("b_standup", 1.6, 0.2, true) * 0.9
			_place(p)
			return
		"getup", "celebrate":
			if p.st >= p.dur:
				p.state = "run"
			_place(p)
			return
	# ---- free movement
	if p.gk:
		var gx := -_goal_x(p.team) + (0.6 if p.team == 0 else -0.6)
		want = Vector3(gx, 0, clampf(bpos.z * 0.5, -GOAL_W + 0.3, GOAL_W - 0.3)) - p.pos
		var incoming := (bvel.x < -4.0 and p.team == 0) or (bvel.x > 4.0 and p.team == 1)
		if incoming and absf(bpos.x - gx) < 7.0 and owner_p == null and p.cd <= 0.0:
			p.cd = 2.0
			p.state = "dive"
			p.st = 0.0
			p.dur = p.a.play("b_dive", 1.5, 0.05, true) * 0.9
			var tz := clampf(bpos.z + bvel.z * absf((bpos.x - gx) / bvel.x), -GOAL_W, GOAL_W)
			p.vel = Vector3(0, 0, (tz - p.pos.z) * 2.2)
			p.a.yaw_target = 90.0 if p.team == 0 else -90.0
			if randf() < 0.45:
				p.set_meta("save", true)
			else:
				p.remove_meta("save")
			return
		_face_move(p, delta, want.limit_length(2.0))
		return
	if owner_p == p:
		var goal := Vector3(_goal_x(p.team), 0, sin(t * 0.7 + p.home.z) * 1.2)
		want = (goal - p.pos).normalized() * 3.4
		want.z += sin(t * 2.3 + p.home.x) * 1.6
		var dgoal: float = absf(_goal_x(p.team) - p.pos.x)
		var press = _nearest(1 - p.team, p.pos)
		if dgoal < 8.5 and p.cd <= 0.0:
			p.state = "shoot"
			p.st = 0.0
			p.acted = false
			p.dur = p.a.play("b_shoot", 1.5, 0.08, true)
			_face_dir(p, goal - p.pos)
			return
		if press != null and press.pos.distance_to(p.pos) < 2.2 and randf() < 0.025:
			var mate = _mate(p)
			if mate != null:
				p.state = "kick"
				p.st = 0.0
				p.acted = false
				p.set_meta("to", mate)
				p.dur = p.a.play("b_kick", 1.4, 0.08, true)
				_face_dir(p, mate.pos - p.pos)
				return
	elif owner_p == null:
		var chaser = _nearest(p.team, bpos)
		if chaser == p:
			want = (bpos - p.pos) * 3.0
			if p.pos.distance_to(Vector3(bpos.x, 0, bpos.z)) < 0.6 and bpos.y < 0.8 and p.cd <= 0.0:
				owner_p = p
				last_touch = p
				Audio.play("kickball", -8)
		else:
			want = (Vector3(bpos.x - (6.0 if p.team == 0 else -6.0) * 0.4, 0, p.home.z) - p.pos)
	elif owner_p.team == p.team:
		var ahead := Vector3(owner_p.pos.x + (4.0 if p.team == 0 else -4.0), 0, -owner_p.pos.z * 0.6 + p.home.z * 0.4)
		ahead.x = clampf(ahead.x, -HALF_X + 2, HALF_X - 2)
		want = ahead - p.pos
	else:
		var chaser2 = _nearest(p.team, owner_p.pos)
		if chaser2 == p:
			want = (owner_p.pos - p.pos) * 3.0
			var d: float = p.pos.distance_to(owner_p.pos)
			if d < 1.6 and p.cd <= 0.0:
				p.cd = 2.2
				p.st = 0.0
				p.acted = false
				_face_dir(p, owner_p.pos - p.pos)
				if randf() < 0.18:
					p.state = "punch"
					p.dur = p.a.play("f_jab", 1.4, 0.06, true)
				else:
					p.state = "tackle"
					p.dur = p.a.play("b_tackle", 1.5, 0.06, true)
					p.vel = (owner_p.pos - p.pos).normalized() * 4.2
				return
		else:
			want = (Vector3(-_goal_x(p.team) * 0.45, 0, owner_p.pos.z * 0.5) - p.pos)
	_face_move(p, delta, want.limit_length(4.0 if owner_p != p else 3.4))

func _mate(p: P):
	for q in players:
		if q != p and q.team == p.team and not q.gk and q.state == "run":
			return q
	return null

func _face_move(p: P, delta: float, want: Vector3) -> void:
	p.vel = p.vel.move_toward(want, 9.0 * delta)
	p.pos += p.vel * delta
	p.pos.x = clampf(p.pos.x, -HALF_X + 0.3, HALF_X - 0.3)
	p.pos.z = clampf(p.pos.z, -HALF_Z + 0.3, HALF_Z - 0.3)
	var sp := Vector2(p.vel.x, p.vel.z).length()
	if sp > 0.6:
		p.a.play("b_jog", clampf(sp / 3.0, 0.8, 1.5), 0.15)
		_face_dir(p, p.vel)
	else:
		p.a.play("b_gkidle" if p.gk else "b_idle", 1.0, 0.25)
		_face_dir(p, bpos - p.pos)
	_place(p)

func _face_dir(p: P, d: Vector3) -> void:
	if Vector2(d.x, d.z).length() > 0.05:
		p.a.yaw_target = rad_to_deg(atan2(d.x, d.z))

func _place(p: P) -> void:
	p.a.position = p.pos

func _knock_down(v: P, how: String) -> void:
	v.state = how
	v.st = 0.0
	v.dur = v.a.play("b_trip" if how == "tripped" else "f_hit", 1.2, 0.05, true) * 0.9
	v.vel = Vector3.ZERO

func _release(p: P, shot: bool) -> void:
	if owner_p != p:
		return
	owner_p = null
	last_touch = p
	p.cd = 0.6
	if shot:
		var tz := randf_range(-GOAL_W + 0.25, GOAL_W - 0.25)
		var target := Vector3(_goal_x(p.team) + (1.0 if p.team == 0 else -1.0), randf_range(0.4, 1.8), tz)
		var d := target - bpos
		bvel = Vector3(d.x, 0, d.z).normalized() * 17.0
		bvel.y = 3.2 + randf() * 1.5
		Audio.play("kickball", 0)
		Audio.play("whoosh", -4)
		_word(["BOOM!", "SHOT!", "BANG!"].pick_random(), bpos + Vector3(0, 1.8, 0), Color(1, 0.95, 0.4))
		shake = 0.1
	else:
		var to: P = p.get_meta("to")
		var d2 := to.pos + to.vel * 0.6 - bpos
		bvel = Vector3(d2.x, 0, d2.z).normalized() * clampf(d2.length() * 1.6, 6, 13)
		bvel.y = 1.0
		Audio.play("kickball", -4)

func _ball(delta: float) -> void:
	if owner_p != null:
		var p: P = owner_p
		var fwd := Vector3(sin(deg_to_rad(p.a.yaw)), 0, cos(deg_to_rad(p.a.yaw)))
		var target := p.pos + fwd * 0.5
		target.y = 0.11 + absf(sin(t * 9.0)) * 0.06
		bvel = (target - bpos) / maxf(delta, 0.001)
		bpos = target
	else:
		bvel.y -= 9.8 * delta
		bpos += bvel * delta
		if bpos.y < 0.11:
			bpos.y = 0.11
			if bvel.y < -1.5:
				bvel.y = -bvel.y * 0.5
				Audio.play("kickball", -14)
			else:
				bvel.y = 0.0
			bvel.x *= pow(0.4, delta)
			bvel.z *= pow(0.4, delta)
		# keeper save
		for p in players:
			if p.gk and p.state == "dive" and p.has_meta("save") and bpos.distance_to(p.pos + Vector3(0, 0.8, 0)) < 1.6:
				p.remove_meta("save")
				bvel = Vector3(-bvel.x * 0.35, 3.5, bvel.z * 0.5 + randf_range(-3, 3))
				_word("SAVE!", bpos + Vector3(0, 1.6, 0), Color(0.5, 1, 0.6))
				fx.hit(_scr(bpos), Vector2(0, -1), false, Color(1, 1, 1))
				Audio.play("cheer", -10)
		# goal?
		if absf(bpos.x) > HALF_X + 0.15 and absf(bpos.z) < GOAL_W and bpos.y < 2.2:
			_goal(0 if bpos.x > 0 else 1)
			return
		# cage walls
		if absf(bpos.x) > HALF_X:
			bpos.x = signf(bpos.x) * HALF_X
			bvel.x = -bvel.x * 0.6
			Audio.play("kickball", -10)
		if absf(bpos.z) > HALF_Z:
			bpos.z = signf(bpos.z) * HALF_Z
			bvel.z = -bvel.z * 0.6
			Audio.play("kickball", -10)
	ball.position = bpos
	ball.rotation.z -= bvel.x * delta * 4.0
	ball.rotation.x += bvel.z * delta * 4.0

func _goal(team: int) -> void:
	score[team] += 1
	frozen = 3.2
	_banner("GOAL!", Color(1, 0.85, 0.2) if team == 0 else Color(0.5, 0.75, 1), 2.8)
	Audio.play("cheer", 0)
	Audio.play("whistle", -4)
	fx.ko(_scr(bpos), Vector2(signf(bpos.x), 0), Color(1, 0.9, 0.4))
	shake = 0.3
	var scorer = last_touch if last_touch != null and last_touch.team == team else _nearest(team, bpos)
	for p in players:
		if p.team == team and not p.gk:
			p.state = "celebrate"
			p.st = 0.0
			p.dur = 3.0
			p.a.play("b_celebrate", 1.0, 0.2, true)
			p.a.yaw_target = 0.0
	await get_tree().create_timer(3.2).timeout
	# kick-off
	for p in players:
		p.pos = p.home
		p.vel = Vector3.ZERO
		p.state = "run"
		p.a.position = p.pos
	bpos = Vector3(0, 0.11, 0)
	bvel = Vector3.ZERO
	owner_p = null
	Audio.play("whistle", -4)

func _camera(delta: float) -> void:
	var look := Vector3(clampf(bpos.x * 0.9, -11, 11), 0.6, clampf(bpos.z * 0.6, -4, 4))
	cam_look = cam_look.lerp(look, 1.0 - exp(-3.0 * delta))
	cam.position = cam_look + Vector3(0, 5.6, 9.2)
	cam.look_at(cam_look, Vector3.UP)
	shake = maxf(0.0, shake - delta * 0.6)
	cam.h_offset = randf_range(-shake, shake)
	cam.v_offset = randf_range(-shake, shake)

func _scr(p: Vector3) -> Vector2:
	return cam.unproject_position(p)

func _draw_ui() -> void:
	var vs := ui.size
	var w := 380.0
	var r := Rect2((vs.x - w) * 0.5, 16, w, 64)
	ui.draw_rect(r, Color(0.05, 0.06, 0.1, 0.88))
	ui.draw_rect(Rect2(r.position, Vector2(w * 0.5, 6)), Color(0.9, 0.2, 0.15))
	ui.draw_rect(Rect2(r.position + Vector2(w * 0.5, 0), Vector2(w * 0.5, 6)), Color(0.2, 0.4, 0.95))
	ui.draw_string(font, r.position + Vector2(18, 46), "RED", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1, 0.45, 0.4))
	ui.draw_string(font, r.position + Vector2(0, 48), "%d - %d" % [score[0], score[1]], HORIZONTAL_ALIGNMENT_CENTER, w, 40, Color.WHITE)
	ui.draw_string(font, r.position + Vector2(w - 92, 46), "BLUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.5, 0.7, 1))
	var m := int(clock * 2.0)
	ui.draw_string(font, Vector2(0, 104), "%02d:%02d" % [m / 60 * 0 + m / 60, m % 60], HORIZONTAL_ALIGNMENT_CENTER, vs.x, 22, Color(1, 1, 1, 0.85))
	ui.draw_string(font, Vector2(0, vs.y - 24), "BRAWL BALL  -  preview", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 22, Color(1, 0.95, 0.5, 0.8))
	for w2 in words:
		var k: float = 1.0 - w2.life / 0.9
		var p := _scr(w2.pos) + Vector2(0, -k * 30)
		var sz := int(50 * (1.0 + (1.0 - minf(k * 6.0, 1.0)) * 0.7))
		ui.draw_set_transform(p, w2.rot, Vector2.ONE)
		for o in [Vector2(-4, 0), Vector2(4, 0), Vector2(0, -4), Vector2(0, 4)]:
			ui.draw_string(font, o - Vector2(sz * 1.3, 0), w2.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(0.05, 0.05, 0.08, 1.0 - k))
		ui.draw_string(font, -Vector2(sz * 1.3, 0), w2.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(w2.color, 1.0 - maxf(0, k - 0.6) * 2.5))
		ui.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	if banner_t > 0.0:
		for o in [Vector2(-6, 0), Vector2(6, 0), Vector2(0, -6), Vector2(0, 6)]:
			ui.draw_string(font, Vector2(0, vs.y * 0.45) + o, banner_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 140, Color(0.05, 0.05, 0.1))
		ui.draw_string(font, Vector2(0, vs.y * 0.45), banner_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 140, banner_col)
