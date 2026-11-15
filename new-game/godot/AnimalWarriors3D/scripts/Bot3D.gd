## Computer opponent for the flat arena: spacing, combos, dodges, jump-ins and weapon grabs.
class_name Bot3D

var skill := 0.8
var think := 0.0
var move := 0.0
var want := ""
var jump_cd := 0.0
var act_cd := 0.0
var hold := 0.0
var combo := 0
var rng := RandomNumberGenerator.new()

func _init(level: float = 0.8, seed_value: int = 0) -> void:
	skill = level
	rng.seed = seed_value

func read(f, dt: float) -> Dictionary:
	var o := {"mx": 0.0, "my": 0.0, "jump": false, "light": false, "heavy": false, "heavy_held": false, "dodge": false, "pickup": false}
	var g = f.game
	think -= dt
	jump_cd -= dt
	act_cd -= dt
	if hold > 0.0:
		hold -= dt
		o.heavy_held = true
	var tgt = g.nearest_enemy(f)
	if tgt == null:
		return o
	var dx: float = tgt.pos.x - f.pos.x
	var dy: float = tgt.pos.y - f.pos.y
	var goal_x: float = tgt.pos.x - signf(dx) * 70.0
	var pk = g.nearest_pickup(f)
	if f.weapon == "" and pk != null and absf(pk.pos.x - f.pos.x) < absf(dx) + 200.0:
		goal_x = pk.pos.x
		if f.pos.distance_to(pk.pos) < 80.0:
			o.pickup = true
	# stay away from the blast edges
	if absf(f.pos.x) > 900.0:
		goal_x = 0.0
	if think <= 0.0:
		think = rng.randf_range(0.05, 0.16) / skill
		move = signf(goal_x - f.pos.x) if absf(goal_x - f.pos.x) > 40.0 else 0.0
		if rng.randf() < 0.1:
			move = -move
		want = ""
		var close := absf(dx) < 115.0 and absf(dy) < 100.0
		if close and act_cd <= 0.0:
			var r := rng.randf()
			if tgt.state == "attack" and r < 0.3 * skill:
				want = "dodge"
			elif tgt.dmg > 90.0 and r < 0.6:
				want = "heavy"
			elif r < 0.78:
				want = "light"
			else:
				want = "heavy"
		elif dy < -120.0 and absf(dx) < 160.0:
			want = "up"
		elif absf(dx) > 200.0 and absf(dx) < 420.0 and rng.randf() < 0.18 and f.on_ground:
			want = "jumpin"
		elif f.weapon != "" and absf(dx) > 280.0 and rng.randf() < 0.06:
			want = "throw"
	o.mx = move
	match want:
		"light", "heavy":
			f.facing = 1 if dx > 0.0 else -1
			o[want] = true
			o.mx = signf(dx) * 0.4
			if dy < -60.0:
				o.my = -1.0
			elif not f.on_ground and dy > 40.0 and want == "heavy":
				o.my = 1.0
			elif want == "light" and rng.randf() < 0.2:
				o.my = 1.0 if f.on_ground else 0.0
			if want == "heavy":
				hold = rng.randf_range(0.0, 0.4)
			combo += 1
			act_cd = (0.08 if combo % 3 != 0 else rng.randf_range(0.3, 0.6)) / skill
			want = ""
		"dodge":
			o.dodge = true
			o.mx = -signf(dx)
			want = ""
		"up":
			if f.on_ground and jump_cd <= 0.0:
				o.jump = true
				jump_cd = 0.4
			elif not f.on_ground and absf(dy) < 130.0:
				o.light = true
				o.my = -1.0
				want = ""
		"jumpin":
			if jump_cd <= 0.0:
				o.jump = true
				o.mx = signf(dx)
				jump_cd = 0.7
			want = ""
		"throw":
			f.facing = 1 if dx > 0.0 else -1
			o.pickup = true
			want = ""
	if not f.on_ground and absf(dx) < 120.0 and absf(dy) < 90.0 and act_cd <= 0.0:
		f.facing = 1 if dx > 0.0 else -1
		o.light = true
		act_cd = 0.3 / skill
	return o
