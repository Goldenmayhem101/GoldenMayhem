## On-screen controls for phones: movement pad on the left, action buttons on the right.
class_name TouchPad
extends CanvasLayer

var ghost_mode := false   # demo videos: show the layout faintly, buttons light up when the bot uses them
var ui: Control
var stick_touch := -1
var stick_center := Vector2.ZERO
var stick_vec := Vector2.ZERO
var held := {}
var lit := {}
var font: Font
var BUTTONS := [
	{"a": "jump", "c": Color(0.35, 0.8, 0.4), "o": Vector2(-120, -110), "r": 58.0, "g": "jump"},
	{"a": "light", "c": Color(0.92, 0.32, 0.28), "o": Vector2(-250, -170), "r": 54.0, "g": "fist"},
	{"a": "heavy", "c": Color(0.62, 0.42, 0.95), "o": Vector2(-150, -265), "r": 54.0, "g": "burst"},
	{"a": "dodge", "c": Color(0.3, 0.6, 0.98), "o": Vector2(-330, -70), "r": 44.0, "g": "swirl"},
	{"a": "pickup", "c": Color(0.95, 0.75, 0.25), "o": Vector2(-385, -205), "r": 38.0, "g": "hand"},
]

func _ready() -> void:
	layer = 9
	font = load("res://fonts/LilitaOne-Regular.ttf")
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	add_child(ui)

func _btn_pos(b: Dictionary) -> Vector2:
	return ui.size + b.o

func _stick_home() -> Vector2:
	return Vector2(170, ui.size.y - 160)

func _input(e: InputEvent) -> void:
	if ghost_mode:
		return
	if e is InputEventScreenTouch:
		if e.pressed:
			if e.position.x < ui.size.x * 0.4 and e.position.y > ui.size.y * 0.3:
				stick_touch = e.index
				stick_center = e.position
				stick_vec = Vector2.ZERO
			else:
				for b in BUTTONS:
					if e.position.distance_to(_btn_pos(b)) < b.r * 1.3:
						held[e.index] = b.a
						Input.action_press(b.a)
		else:
			if e.index == stick_touch:
				stick_touch = -1
				stick_vec = Vector2.ZERO
				_apply_stick()
			if held.has(e.index):
				Input.action_release(held[e.index])
				held.erase(e.index)
	elif e is InputEventScreenDrag and e.index == stick_touch:
		stick_vec = ((e.position - stick_center) / 70.0).limit_length(1.0)
		_apply_stick()

func _apply_stick() -> void:
	for pair in [["left", -stick_vec.x], ["right", stick_vec.x], ["up", -stick_vec.y], ["down", stick_vec.y]]:
		if pair[1] > 0.2:
			Input.action_press(pair[0], pair[1])
		else:
			Input.action_release(pair[0])

func show_bot_input(inp: Dictionary) -> void:
	for b in BUTTONS:
		if inp.get(b.a, false):
			lit[b.a] = 0.2
	stick_vec = stick_vec.lerp(Vector2(inp.get("mx", 0.0), inp.get("my", 0.0)), 0.5)

func _process(delta: float) -> void:
	for k in lit.keys():
		lit[k] = maxf(0.0, lit[k] - delta)
	ui.queue_redraw()

func _draw_ui() -> void:
	var a := 0.55 if not ghost_mode else 0.28
	var home := _stick_home() if stick_touch < 0 else stick_center
	ui.draw_circle(home, 92, Color(0.1, 0.07, 0.05, a * 0.6))
	ui.draw_arc(home, 92, 0, TAU, 48, Color(0.95, 0.85, 0.65, a), 4.0)
	for i in 4:
		var d := Vector2.from_angle(i * PI * 0.5)
		ui.draw_colored_polygon(PackedVector2Array([home + d * 82, home + d * 64 + d.orthogonal() * 12, home + d * 64 - d.orthogonal() * 12]), Color(0.95, 0.85, 0.65, a))
	ui.draw_circle(home + stick_vec * 56, 38, Color(0.95, 0.85, 0.65, a + 0.15))
	ui.draw_arc(home + stick_vec * 56, 38, 0, TAU, 32, Color(0.1, 0.07, 0.05, a), 4.0)
	for b in BUTTONS:
		var p := _btn_pos(b)
		var on: bool = lit.get(b.a, 0.0) > 0.0 or held.values().has(b.a)
		var r: float = b.r * (0.9 if on else 1.0)
		var c: Color = b.c
		ui.draw_circle(p + Vector2(0, 5), r, Color(0, 0, 0, a * 0.5))
		ui.draw_circle(p, r, Color(c, a + (0.4 if on else 0.0)))
		ui.draw_arc(p, r, 0, TAU, 40, Color(0.1, 0.07, 0.05, a + 0.2), 4.0)
		_glyph(b.g, p, r * 0.5, Color(1, 0.97, 0.9, a + 0.35))

func _glyph(g: String, p: Vector2, s: float, c: Color) -> void:
	match g:
		"jump":
			ui.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s), p + Vector2(s * 0.9, 0), p + Vector2(s * 0.35, 0), p + Vector2(s * 0.35, s), p + Vector2(-s * 0.35, s), p + Vector2(-s * 0.35, 0), p + Vector2(-s * 0.9, 0)]), c)
		"fist":
			ui.draw_rect(Rect2(p + Vector2(-s * 0.7, -s * 0.5), Vector2(s * 1.4, s * 1.1)), c)
			for i in 4:
				ui.draw_circle(p + Vector2(-s * 0.52 + i * s * 0.35, -s * 0.5), s * 0.2, c)
			ui.draw_rect(Rect2(p + Vector2(-s * 0.5, s * 0.6), Vector2(s, s * 0.4)), c)
		"burst":
			var pts := PackedVector2Array()
			for i in 16:
				pts.append(p + Vector2.from_angle(i * TAU / 16.0) * (s if i % 2 == 0 else s * 0.45))
			ui.draw_colored_polygon(pts, c)
		"swirl":
			ui.draw_arc(p, s * 0.8, 0.3, 5.2, 24, c, s * 0.28)
			ui.draw_colored_polygon(PackedVector2Array([p + Vector2(s * 0.95, -s * 0.1), p + Vector2(s * 0.45, -s * 0.6), p + Vector2(s * 0.3, 0.1)]), c)
		"hand":
			ui.draw_string(font, p + Vector2(-s * 0.95, s * 0.45), "GRAB", HORIZONTAL_ALIGNMENT_LEFT, -1, int(s * 0.9), c)
