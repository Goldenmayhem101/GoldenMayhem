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
	func read(_f, _dt: float) -> Dictionary:
		return {
			"mx": Input.get_axis("left", "right"), "my": Input.get_axis("up", "down"),
			"jump": Input.is_action_just_pressed("jump"), "light": Input.is_action_just_pressed("light"),
			"heavy": Input.is_action_just_pressed("heavy"), "heavy_held": Input.is_action_pressed("heavy"),
			"dodge": Input.is_action_just_pressed("dodge"), "pickup": Input.is_action_just_pressed("pickup"),
		}


