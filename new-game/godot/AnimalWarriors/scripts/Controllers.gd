## Input sources for a fighter: the human player (keyboard, gamepad, touch) or the computer.
class_name Controllers

static func setup_input_map() -> void:
	var map := {
		"left": [KEY_A, KEY_LEFT], "right": [KEY_D, KEY_RIGHT], "up": [KEY_W, KEY_UP], "down": [KEY_S, KEY_DOWN],
		"jump": [KEY_SPACE], "light": [KEY_J], "heavy": [KEY_K], "dodge": [KEY_L, KEY_SHIFT], "pickup": [KEY_H], "pause": [KEY_ESCAPE, KEY_P],
	}
	var pad := {"jump": JOY_BUTTON_A, "light": JOY_BUTTON_X, "heavy": JOY_BUTTON_Y, "dodge": JOY_BUTTON_RIGHT_SHOULDER, "pickup": JOY_BUTTON_LEFT_SHOULDER, "pause": JOY_BUTTON_START}
	for a in map:
		if not InputMap.has_action(a):
			InputMap.add_action(a, 0.25)
		for k in map[a]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(a, e)
		if pad.has(a):
			var b := InputEventJoypadButton.new()
			b.button_index = pad[a]
			InputMap.action_add_event(a, b)
	for pair in [["left", JOY_AXIS_LEFT_X, -1.0], ["right", JOY_AXIS_LEFT_X, 1.0], ["up", JOY_AXIS_LEFT_Y, -1.0], ["down", JOY_AXIS_LEFT_Y, 1.0]]:
		var m := InputEventJoypadMotion.new()
		m.axis = pair[1]
		m.axis_value = pair[2]
		InputMap.action_add_event(pair[0], m)


class Player:
	func read(_f: Fighter, _dt: float) -> Dictionary:
		return {
			"mx": Input.get_axis("left", "right"), "my": Input.get_axis("up", "down"),
			"jump": Input.is_action_just_pressed("jump"), "light": Input.is_action_just_pressed("light"),
			"heavy": Input.is_action_just_pressed("heavy"), "heavy_held": Input.is_action_pressed("heavy"),
			"dodge": Input.is_action_just_pressed("dodge"), "pickup": Input.is_action_just_pressed("pickup"),
		}


class Bot:
	var skill := 0.8
	var think := 0.0
	var move := 0.0
	var want := ""
	var jump_cd := 0.0
	var act_cd := 0.0
	var hold := 0.0
	var rng := RandomNumberGenerator.new()

	func _init(level: float = 0.8, seed_value: int = 0) -> void:
		skill = level
		rng.seed = seed_value

	func read(f: Fighter, dt: float) -> Dictionary:
		var o := {"mx": 0.0, "my": 0.0, "jump": false, "light": false, "heavy": false, "heavy_held": false, "dodge": false, "pickup": false}
		var g: Node = f.game
		think -= dt
		jump_cd -= dt
		act_cd -= dt
		var st: Rect2 = g.main_rect
		# ---- recover to the stage
		if absf(f.position.x) > 950.0 and f.state == "free":
			o.mx = -signf(f.position.x)
			return o
		if false:
			o.mx = signf(st.get_center().x - f.position.x)
			if f.vel.y > -150.0 and jump_cd <= 0.0 and (f.jumps > 0 or f.wall != 0):
				o.jump = true
				jump_cd = 0.32
			elif f.jumps == 0 and f.vel.y > 150.0 and f.state == "free" and f.position.y > st.position.y - 40.0:
				o.heavy = true
				o.my = -1.0
			return o
		if hold > 0.0:
			hold -= dt
			o.heavy_held = true
		var tgt: Fighter = g.nearest_enemy(f)
		if tgt == null:
			return o
		var dx := tgt.position.x - f.position.x
		var dy := tgt.position.y - f.position.y
		var goal_x := tgt.position.x
		# ---- grab a weapon if one is closer than the enemy
		var pk = g.nearest_pickup(f)
		if f.weapon == "" and pk != null and pk.landed and absf(pk.pos.x - f.position.x) < absf(dx) + 120.0:
			goal_x = pk.pos.x
			if f.position.distance_to(pk.pos) < 70.0:
				o.pickup = true
		if think <= 0.0:
			think = rng.randf_range(0.06, 0.2) / skill
			move = signf(goal_x - f.position.x) if absf(goal_x - f.position.x) > 60.0 else 0.0
			if rng.randf() < 0.15:
				move = -move
			want = ""
			var close := absf(dx) < 105.0 and absf(dy) < 95.0
			if close and act_cd <= 0.0:
				var r := rng.randf()
				if tgt.state == "attack" and r < 0.28 * skill:
					want = "dodge"
				elif tgt.dmg > 85.0 and r < 0.55:
					want = "heavy"
				elif r < 0.75:
					want = "light"
				else:
					want = "heavy"
			elif dy < -110.0 and absf(dx) < 140.0:
				want = "up"
			elif f.weapon != "" and absf(dx) > 260.0 and rng.randf() < 0.05:
				want = "throw"
		o.mx = move
		# don't run off the edge after an enemy who is off stage
		if f.on_ground and ((move < 0.0 and f.position.x < st.position.x + 30.0) or (move > 0.0 and f.position.x > st.end.x - 30.0)):
			o.mx = 0.0
		match want:
			"light", "heavy":
				f.facing = 1 if dx > 0.0 else -1
				o[want] = true
				o.mx = signf(dx) * 0.4
				if absf(dy) > 50.0 and dy < 0.0:
					o.my = -1.0
				elif not f.on_ground and dy > 40.0:
					o.my = 1.0
				if want == "heavy":
					hold = rng.randf_range(0.0, 0.35)
				act_cd = rng.randf_range(0.15, 0.4) / skill
				want = ""
			"dodge":
				o.dodge = true
				o.mx = -signf(dx)
				want = ""
			"up":
				if f.on_ground and jump_cd <= 0.0:
					o.jump = true
					jump_cd = 0.4
				elif not f.on_ground and absf(dy) < 120.0:
					o.light = true
					o.my = -1.0
					want = ""
			"throw":
				f.facing = 1 if dx > 0.0 else -1
				o.pickup = true
				want = ""
		# jump onto platforms toward the goal
		if f.on_ground and dy < -120.0 and jump_cd <= 0.0 and absf(dx) < 260.0:
			o.jump = true
			jump_cd = 0.6
		if not f.on_ground and dy > 120.0 and absf(dx) < 140.0:
			o.my = 1.0
		return o
