## Match HUD: fighter cards with damage %, stocks, banners, off-screen bubbles and the results podium.
class_name Hud3D
extends CanvasLayer

var game: Node
var portraits := {}
func portrait(id: String) -> Texture2D:
	if not portraits.has(id):
		portraits[id] = load("res://art/portrait_%s.png" % id)
	return portraits[id]
var font: Font
var ui: Control
var cards := {}
var banner_label: Label
var banner_sub: Label
var results: Control

func _ready() -> void:
	layer = 10
	font = load("res://fonts/LilitaOne-Regular.ttf")
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	add_child(ui)
	banner_label = _label(130, Color.WHITE)
	banner_label.set_anchors_preset(Control.PRESET_CENTER)
	add_child(banner_label)
	banner_label.visible = false

func _label(size: int, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.03))
	l.add_theme_constant_override("outline_size", maxi(8, size / 7))
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	l.add_theme_constant_override("shadow_offset_y", size / 18)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func banner(text: String, col: Color, dur: float, size_mul: float = 1.0) -> void:
	banner_label.text = text
	banner_label.add_theme_color_override("font_color", col)
	banner_label.add_theme_font_size_override("font_size", int(130 * size_mul))
	banner_label.visible = true
	banner_label.reset_size()
	var vs := ui.size
	banner_label.position = Vector2((vs.x - banner_label.size.x) * 0.5, vs.y * 0.36 - banner_label.size.y * 0.5)
	banner_label.pivot_offset = banner_label.size * 0.5
	banner_label.scale = Vector2(2.2, 2.2)
	banner_label.modulate.a = 1.0
	banner_label.rotation = deg_to_rad(-4)
	var tw := banner_label.create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(banner_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(dur * 0.6)
	tw.tween_property(banner_label, "modulate:a", 0.0, dur * 0.3)

var pops := {}
func pop(f) -> void:
	pops[f.slot] = 0.25

func _process(delta: float) -> void:
	for k in pops.keys():
		pops[k] = maxf(0.0, pops[k] - delta)
	for w in words:
		w.life -= delta
	words = words.filter(func(w): return w.life > 0.0)
	ui.queue_redraw()

func _dmg_color(d: float) -> Color:
	if d < 40.0:
		return Color(1, 1, 1).lerp(Color(1, 0.92, 0.35), d / 40.0)
	if d < 100.0:
		return Color(1, 0.92, 0.35).lerp(Color(1, 0.45, 0.15), (d - 40.0) / 60.0)
	return Color(1, 0.45, 0.15).lerp(Color(0.85, 0.08, 0.08), clampf((d - 100.0) / 80.0, 0, 1))

func _draw_ui() -> void:
	if game == null:
		return
	var vs := ui.size
	var n: int = game.fighters.size()
	var cw := 250.0
	var gap := 18.0
	var total := n * cw + (n - 1) * gap
	var x0 := (vs.x - total) * 0.5
	for i in n:
		var f = game.fighters[i]
		var r := Rect2(x0 + i * (cw + gap), 14, cw, 74)
		var team_col := Color(0.25, 0.55, 0.95) if f.team == 0 else Color(0.9, 0.3, 0.25)
		ui.draw_rect(Rect2(r.position + Vector2(4, 5), r.size), Color(0, 0, 0, 0.35))
		ui.draw_rect(r, Color(0.13, 0.09, 0.06, 0.88))
		ui.draw_rect(Rect2(r.position, Vector2(r.size.x, 6)), team_col)
		ui.draw_rect(r, Color(0.85, 0.62, 0.3), false, 3.0)
		var pc := r.position + Vector2(40, 42)
		ui.draw_circle(pc, 31, team_col)
		ui.draw_circle(pc, 27, Color(0.95, 0.88, 0.72))
		var tex: Texture2D = portrait(f.id)
		ui.draw_texture_rect(tex, Rect2(pc - Vector2(29, 29), Vector2(58, 58)), false, Color(1, 1, 1) if not f.eliminated else Color(0.3, 0.3, 0.3))
		ui.draw_string(font, r.position + Vector2(80, 30), f.data.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.98, 0.9, 0.72))
		var p: float = pops.get(f.slot, 0.0)
		var ds := 36 + int(p * 40.0)
		var txt := "%d%%" % int(f.dmg)
		var dc := _dmg_color(f.dmg)
		var dp := r.position + Vector2(80, 68 + p * 6.0)
		for o in [Vector2(-2, 0), Vector2(2, 0), Vector2(0, -2), Vector2(0, 2), Vector2(2, 3)]:
			ui.draw_string(font, dp + o, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, ds, Color(0.08, 0.05, 0.03))
		ui.draw_string(font, dp, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, ds, dc)
		for s in 3:
			var sc := r.position + Vector2(cw - 22 - s * 22, 56)
			ui.draw_circle(sc, 8, Color(0.08, 0.05, 0.03))
			ui.draw_circle(sc, 6, Color(1, 0.8, 0.3) if s < f.stocks else Color(0.35, 0.28, 0.2))
		if f.weapon != "":
			ui.draw_string(font, r.position + Vector2(cw - 70, 30), "AXE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.8, 0.9, 1))
	# off-screen bubbles
	for f in game.fighters:
		if not f.alive:
			continue
		var sp: Vector2 = game.to_screen(f.center())
		if Rect2(Vector2.ZERO, vs).grow(-10).has_point(sp):
			continue
		var c := sp.clamp(Vector2(60, 140), vs - Vector2(60, 60))
		var dir := (sp - c).normalized()
		ui.draw_circle(c, 40, Color(0.1, 0.07, 0.05))
		ui.draw_circle(c, 35, Color(0.95, 0.88, 0.72))
		var tex2: Texture2D = portrait(f.id)
		ui.draw_texture_rect(tex2, Rect2(c - Vector2(30, 30), Vector2(60, 60)), false)
		ui.draw_colored_polygon(PackedVector2Array([c + dir * 56, c + dir.orthogonal() * 16 + dir * 38, c - dir.orthogonal() * 16 + dir * 38]), Color(0.1, 0.07, 0.05))
	# comic impact words
	for w in words:
		var k: float = 1.0 - w.life / 0.7
		var sc: float = 1.0 + (1.0 - minf(k * 6.0, 1.0)) * 0.8
		var sz := int(54.0 * sc)
		ui.draw_set_transform(w.pos, w.rot, Vector2.ONE)
		var col: Color = w.color
		col.a = 1.0 - maxf(0.0, k - 0.6) * 2.5
		for o in [Vector2(-4, 0), Vector2(4, 0), Vector2(0, -4), Vector2(0, 4), Vector2(4, 6)]:
			ui.draw_string(font, o - Vector2(sz * 1.2, 0), w.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(0.1, 0.06, 0.03, col.a))
		ui.draw_string(font, -Vector2(sz * 1.2, 0), w.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, col)
		ui.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

var words: Array = []
func comic(text: String, at: Vector2, col: Color) -> void:
	words.append({"text": text, "pos": at, "color": col, "life": 0.7, "rot": randf_range(-0.25, 0.25)})

var flash_rect: ColorRect
func flash() -> void:
	if flash_rect == null:
		flash_rect = ColorRect.new()
		flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(flash_rect)
	flash_rect.color = Color(1, 0.96, 0.85, 0.75)
	var tw := flash_rect.create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(flash_rect, "color:a", 0.0, 0.35)

func show_results(winner) -> void:
	results = Control.new()
	results.set_anchors_preset(Control.PRESET_FULL_RECT)
	results.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(results)
	var dim := ColorRect.new()
	dim.color = Color(0.1, 0.06, 0.04, 0.0)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	results.add_child(dim)
	dim.create_tween().tween_property(dim, "color:a", 0.82, 0.4)
	var vs := ui.size
	var title := _label(84, Color(1, 0.82, 0.3))
	title.text = "%s WINS!" % (winner.data.name if winner else "NOBODY")
	title.size = Vector2(vs.x, 120)
	title.position = Vector2(0, 30)
	results.add_child(title)
	var order: Array = game.fighters.duplicate()
	order.sort_custom(func(a, b): return (a == winner) or (a != winner and b != winner and a.stocks > b.stocks))
	var n := order.size()
	for i in n:
		var f = order[i]
		var cx := vs.x * 0.5 + (i - (n - 1) * 0.5) * 300.0
		var ph := 150.0 - i * 30.0
		var pod := Panel.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.55, 0.42, 0.3) if i == 0 else Color(0.4, 0.3, 0.22)
		sb.border_color = Color(0.85, 0.62, 0.3)
		sb.set_border_width_all(4)
		sb.set_corner_radius_all(8)
		pod.add_theme_stylebox_override("panel", sb)
		pod.position = Vector2(cx - 110, vs.y - ph - 40)
		pod.size = Vector2(220, ph + 60)
		results.add_child(pod)
		var place := _label(40, Color(1, 0.9, 0.6))
		place.text = ["1ST", "2ND", "3RD", "4TH"][i]
		place.position = Vector2(cx - 110, vs.y - ph - 30)
		place.size = Vector2(220, 50)
		results.add_child(place)
		var st := _label(20, Color(0.95, 0.9, 0.8))
		st.text = "KOs %d   Falls %d\nDamage done %d" % [f.stats.kos, f.stats.falls, int(f.stats.dmg_done)]
		st.position = Vector2(cx - 110, vs.y - ph + 20)
		st.size = Vector2(220, 70)
		results.add_child(st)
		var art := TextureRect.new()
		art.texture = load("res://art/%s_body.png" % f.id)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var hh := 300.0 if i == 0 else 230.0
		art.size = Vector2(hh * 0.7, hh)
		art.position = Vector2(cx - hh * 0.35, vs.y - ph - 40 - hh)
		art.pivot_offset = Vector2(hh * 0.35, hh)
		art.flip_h = i % 2 == 0
		results.add_child(art)
		art.scale = Vector2(0.2, 0.2)
		art.create_tween().tween_property(art, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0.3 + i * 0.15)
