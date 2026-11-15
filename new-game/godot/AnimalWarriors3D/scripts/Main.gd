## 3D test start-up: Goldenmayhem intro, title, choose camera, match.
## Command line (after "--"): --demo=arena | --demo=close  [--intro]
extends Node

var font: Font
var layer: CanvasLayer
var game: Game3D
var demo := ""
var with_intro := false
var you := "hyena"

func _ready() -> void:
	Controllers.setup_input_map()
	font = load("res://fonts/LilitaOne-Regular.ttf")
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--demo="):
			demo = a.split("=")[1]
		if a == "--intro":
			with_intro = true
	layer = CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	if demo != "":
		if with_intro:
			await _intro()
		_start(demo, true)
	else:
		await _intro()
		_menu()

func _lbl(text: String, size: int, col: Color, outline := true) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	if outline:
		l.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.03))
		l.add_theme_constant_override("outline_size", maxi(6, size / 8))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l

func _intro() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.035, 0.025)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(box)
	var line := ColorRect.new()
	line.color = Color(1, 0.78, 0.25, 0.6)
	line.custom_minimum_size = Vector2(0, 2)
	for n in [_lbl("A game by", 30, Color(0.85, 0.78, 0.65), false), _lbl("GOLDENMAYHEM", 96, Color(1, 0.78, 0.25)), line, _lbl("Produced by Shawn Morris", 22, Color(0.8, 0.74, 0.62), false)]:
		box.add_child(n)
	box.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(box, "modulate:a", 1.0, 0.8)
	tw.tween_interval(1.4)
	tw.tween_property(box, "modulate:a", 0.0, 0.6)
	await tw.finished
	box.queue_free()
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", -30)
	root.add_child(vb)
	for n in [_lbl("ANIMAL", 120, Color(0.98, 0.9, 0.7)), _lbl("WARRIORS", 120, Color(1, 0.62, 0.2)), _lbl("3D look test", 28, Color(0.85, 0.78, 0.65), false)]:
		vb.add_child(n)
	vb.pivot_offset = Vector2(640, 360)
	vb.scale = Vector2(1.6, 1.6)
	vb.modulate.a = 0.0
	var tw2 := create_tween()
	tw2.tween_property(vb, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw2.parallel().tween_property(vb, "modulate:a", 1.0, 0.3)
	tw2.tween_callback(func(): Sfx.play("hit_heavy"))
	tw2.tween_interval(1.2)
	tw2.tween_property(root, "modulate:a", 0.0, 0.4)
	await tw2.finished
	root.queue_free()

func _menu() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.08, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var title := _lbl("ANIMAL WARRIORS: 3D LOOK TEST", 48, Color(1, 0.75, 0.3))
	title.position = Vector2(0, 40)
	title.size = Vector2(1280, 80)
	root.add_child(title)
	var x := 200.0
	for opt in [["arena", "ARENA CAMERA", "Wide view, fighters smaller\n(like the videos)"], ["close", "CLOSE CAMERA", "Tight view, fighters big\n(Street Fighter distance)"]]:
		var btn := Button.new()
		btn.position = Vector2(x, 200)
		btn.size = Vector2(420, 240)
		btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 32)
		btn.text = opt[1] + "\n\n" + opt[2]
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.3, 0.2, 0.12)
		sb.border_color = Color(0.9, 0.65, 0.3)
		sb.set_border_width_all(5)
		sb.set_corner_radius_all(14)
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.pressed.connect(func():
			root.queue_free()
			_start(opt[0], false))
		root.add_child(btn)
		x += 460.0
	var pick := Button.new()
	pick.add_theme_font_override("font", font)
	pick.add_theme_font_size_override("font_size", 28)
	pick.text = "You play: HYENA   (tap to switch)"
	pick.position = Vector2(420, 490)
	pick.pressed.connect(func():
		you = "kangaroo" if you == "hyena" else "hyena"
		pick.text = "You play: %s   (tap to switch)" % Chars.DATA[you].name)
	root.add_child(pick)
	var help := _lbl("Keyboard: A/D move, W/S aim, SPACE jump, J light, K heavy (hold to charge), L dodge, H grab/throw axe", 18, Color(0.85, 0.78, 0.65), false)
	help.position = Vector2(0, 600)
	help.size = Vector2(1280, 60)
	root.add_child(help)

func _start(mode: String, bots_only: bool) -> void:
	game = Game3D.new()
	add_child(game)
	var other := "kangaroo" if you == "hyena" else "hyena"
	var p1 = Bot3D.new(0.9, 3) if bots_only else Controllers.Player.new()
	game.setup(mode, [{"id": you, "ctrl": p1, "team": 0}, {"id": other, "ctrl": Bot3D.new(0.85 if bots_only else 0.7, 9), "team": 1}], bots_only)
	game.finished.connect(func():
		if demo != "":
			get_tree().quit()
		else:
			game.queue_free()
			Engine.time_scale = 1.0
			_menu())
