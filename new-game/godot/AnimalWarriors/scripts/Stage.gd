## Draws the stage and its parallax backdrop in the ivory-comic style of the character art.
class_name Stage
extends Node2D

const INK := Color(0.16, 0.1, 0.06)
var mode := "arena"
var solids: Array[Rect2] = []
var platforms: Array[Rect2] = []
var cam: Camera2D
var layers: Array = []   # [node, factor]
var rng := RandomNumberGenerator.new()
var t := 0.0

func build(m: String, camera: Camera2D) -> void:
	mode = m
	cam = camera
	rng.seed = 11
	# one long flat floor that never ends on screen: nothing to fall off
	solids = [Rect2(-4000, 0, 8000, 300)]
	platforms = []
	z_index = -10
	_make_layer(0.05, _draw_far)
	_make_layer(0.12, _draw_clouds)
	_make_layer(0.3, _draw_mid)
	_make_layer(0.6, _draw_near)

func _make_layer(factor: float, fn: Callable) -> void:
	var n := Node2D.new()
	n.z_index = -30 + layers.size()
	n.z_as_relative = false
	n.draw.connect(fn.bind(n))
	add_child(n)
	layers.append([n, factor])

func _process(delta: float) -> void:
	t += delta
	if cam:
		for l in layers:
			var n: Node2D = l[0]
			n.position = cam.get_screen_center_position() * l[1]
			n.queue_redraw()

# --- sky is drawn by the Game's background layer; these draw the scenery bands
func _hill(n: Node2D, base_y: float, amp: float, col: Color, seed_v: int, width: float, step: float, outline: bool) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = seed_v
	var pts := PackedVector2Array()
	var x := -width
	pts.append(Vector2(-width, base_y + 2000))
	while x <= width:
		var h := base_y - amp * (0.5 + 0.5 * sin(x * 0.004 + seed_v)) - r.randf_range(0, amp * 0.35)
		pts.append(Vector2(x, h))
		x += step
	pts.append(Vector2(width, base_y + 2000))
	n.draw_colored_polygon(pts, col)
	if outline:
		var top := pts.slice(1, pts.size() - 1)
		n.draw_polyline(top, INK, 3.0)

func _draw_far(n: Node2D) -> void:
	var sun := Vector2(520, -380)
	for i in 6:
		n.draw_circle(sun, 330.0 - i * 45.0, Color(1, 0.95, 0.78, 0.05 + i * 0.03))
	n.draw_circle(sun, 84, Color(1, 0.97, 0.86))
	# distant violet ranges sit well below the stage so the arena feels high up
	_range(n, 300.0, 120.0, Color(0.74, 0.72, 0.8), 5, 0.35)
	_range(n, 360.0, 90.0, Color(0.8, 0.7, 0.68), 8, 0.45)

func _range(n: Node2D, base_y: float, amp: float, col: Color, seed_v: int, ink: float) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = seed_v
	var pts := PackedVector2Array()
	pts.append(Vector2(-3000, base_y + 3000))
	var x := -3000.0
	while x <= 3000.0:
		var peak := base_y - amp * (0.4 + 0.6 * absf(sin(x * 0.0021 + seed_v))) - r.randf_range(0, amp * 0.3)
		pts.append(Vector2(x, peak))
		x += r.randf_range(60, 140)
	pts.append(Vector2(3000, base_y + 3000))
	n.draw_colored_polygon(pts, col)
	n.draw_polyline(pts.slice(1, pts.size() - 1), Color(INK, ink), 2.5)
	# a few hatch strokes on the slopes
	for i in range(2, pts.size() - 2, 2):
		var a := pts[i]
		n.draw_line(a + Vector2(6, 14), a + Vector2(26, 48), Color(INK, ink * 0.4), 2.0)

func _draw_clouds(n: Node2D) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 31
	for i in 12:
		var x := fposmod(-2000.0 + i * 380.0 + t * (12.0 + i % 3 * 6.0), 4200.0) - 2100.0
		var y := r.randf_range(-700, 60)
		_cloud(n, Vector2(x, y), r.randf_range(0.6, 1.3))

func _cloud(n: Node2D, c: Vector2, s: float) -> void:
	var blobs := [Vector2(-70, 6), Vector2(-30, -18), Vector2(20, -26), Vector2(66, -6), Vector2(0, 8)]
	var radii := [34.0, 42.0, 48.0, 36.0, 40.0]
	for i in blobs.size():
		n.draw_circle(c + blobs[i] * s, (radii[i] + 4.0) * s, Color(INK, 0.35))
	for i in blobs.size():
		n.draw_circle(c + blobs[i] * s, radii[i] * s, Color(1, 0.98, 0.93, 0.95))
	n.draw_rect(Rect2(c + Vector2(-90, 8) * s, Vector2(180, 30) * s), Color(1, 0.98, 0.93, 0.95))

func _draw_mid(n: Node2D) -> void:
	# warm savannah mesas far below
	var r := RandomNumberGenerator.new()
	r.seed = 21
	for i in 9:
		var cx := -2200.0 + i * 560.0 + r.randf_range(-90, 90)
		var wv := r.randf_range(160, 300)
		var top := 470.0 - r.randf_range(40, 170)
		var poly := PackedVector2Array([Vector2(cx - wv, 900), Vector2(cx - wv * 0.75, top + 50), Vector2(cx - wv * 0.55, top), Vector2(cx + wv * 0.5, top), Vector2(cx + wv * 0.7, top + 60), Vector2(cx + wv, 900)])
		n.draw_colored_polygon(poly, Color(0.86, 0.62, 0.44))
		n.draw_colored_polygon(PackedVector2Array([poly[3], poly[4], poly[5], Vector2(cx + wv * 0.25, 900), Vector2(cx + wv * 0.3, top + 20)]), Color(0.72, 0.48, 0.34))
		n.draw_polyline(poly, INK, 3.0)
		for k in 5:
			var yy := top + 40.0 + k * 40.0
			n.draw_line(Vector2(cx - wv * 0.6 + k * 8, yy), Vector2(cx + wv * 0.1, yy + 5), Color(INK, 0.18), 2.0)
	_hill(n, 640, 50, Color(0.7, 0.55, 0.32), 9, 3000, 80, true)
	for i in 8:
		_acacia(n, Vector2(-1900.0 + i * 520.0 + r.randf_range(-80, 80), 600), r.randf_range(0.7, 1.0))

func _draw_near(n: Node2D) -> void:
	if mode == "close":
		# colosseum wall behind the arena floor
		var wall := Rect2(-1600, -330, 3200, 420)
		n.draw_rect(wall, Color(0.86, 0.72, 0.52))
		for row in 8:
			n.draw_line(Vector2(-1600, -320 + row * 40), Vector2(1600, -320 + row * 40), Color(INK, 0.12), 2.0)
		for i in 26:
			var x := -1560.0 + i * 124.0
			var arch := PackedVector2Array()
			for k in 13:
				var a := PI + k * PI / 12.0
				arch.append(Vector2(x + 50, -170) + Vector2(cos(a), sin(a)) * 44)
			arch.append(Vector2(x + 94, -40))
			arch.append(Vector2(x + 6, -40))
			n.draw_colored_polygon(arch, Color(0.52, 0.36, 0.24))
			n.draw_polyline(arch + PackedVector2Array([arch[0]]), INK, 3.0)
		n.draw_line(Vector2(-1600, -330), Vector2(1600, -330), INK, 5.0)
		n.draw_rect(Rect2(-1600, -30, 3200, 120), Color(0.72, 0.56, 0.38))
		n.draw_line(Vector2(-1600, -30), Vector2(1600, -30), INK, 4.0)
		for i in 6:
			var x := -1200.0 + i * 480.0
			var flag := PackedVector2Array([Vector2(x, -320), Vector2(x + 70, -320), Vector2(x + 70, -200), Vector2(x + 35, -225), Vector2(x, -200)])
			n.draw_colored_polygon(flag, Color(0.62, 0.16, 0.12) if i % 2 == 0 else Color(0.85, 0.6, 0.2))
			n.draw_polyline(flag + PackedVector2Array([flag[0]]), INK, 3.0)
	else:
		# small floating rock islands drifting around the arena
		var r := RandomNumberGenerator.new()
		r.seed = 77
		for i in 5:
			var c := Vector2(-1300.0 + i * 650.0 + r.randf_range(-100, 100), r.randf_range(80, 360) + sin(t * 0.8 + i) * 8.0)
			_island(n, c, r.randf_range(0.5, 1.0))

func _island(n: Node2D, c: Vector2, s: float) -> void:
	var top := PackedVector2Array([c + Vector2(-90, 0) * s, c + Vector2(90, 0) * s, c + Vector2(60, 50) * s, c + Vector2(20, 120) * s, c + Vector2(-10, 150) * s, c + Vector2(-40, 90) * s, c + Vector2(-75, 40) * s])
	n.draw_colored_polygon(top, Color(0.56, 0.47, 0.38))
	n.draw_polyline(top + PackedVector2Array([top[0]]), INK, 3.0)
	n.draw_rect(Rect2(c + Vector2(-90, -10) * s, Vector2(180, 12) * s), Color(0.5, 0.58, 0.28))
	n.draw_rect(Rect2(c + Vector2(-90, -10) * s, Vector2(180, 12) * s), INK, false, 2.5)

func _column(n: Node2D, base: Vector2, h: float, broken: bool) -> void:
	var w := 46.0
	var top := base.y - h
	var poly := PackedVector2Array([Vector2(base.x - w * 0.5, base.y), Vector2(base.x - w * 0.5, top + (20.0 if broken else 0.0)), Vector2(base.x - 6, top), Vector2(base.x + w * 0.5, top + (34.0 if broken else 0.0)), Vector2(base.x + w * 0.5, base.y)])
	n.draw_colored_polygon(poly, Color(0.83, 0.71, 0.55))
	for k in 4:
		n.draw_line(Vector2(base.x - w * 0.5 + 10 + k * 9, top + 30), Vector2(base.x - w * 0.5 + 10 + k * 9, base.y), Color(INK, 0.25), 2.0)
	n.draw_polyline(poly + PackedVector2Array([poly[0]]), INK, 3.0)
	if not broken:
		n.draw_rect(Rect2(base.x - w * 0.75, top - 16, w * 1.5, 18), Color(0.86, 0.75, 0.6))
		n.draw_rect(Rect2(base.x - w * 0.75, top - 16, w * 1.5, 18), INK, false, 3.0)

func _acacia(n: Node2D, base: Vector2, s: float) -> void:
	var trunk := PackedVector2Array([base + Vector2(-8, 0) * s, base + Vector2(-4, -110) * s, base + Vector2(-50, -150) * s, base + Vector2(-44, -158) * s, base + Vector2(2, -128) * s, base + Vector2(40, -170) * s, base + Vector2(48, -162) * s, base + Vector2(10, -110) * s, base + Vector2(10, 0) * s])
	n.draw_colored_polygon(trunk, Color(0.33, 0.22, 0.14))
	n.draw_polyline(trunk, INK, 2.0)
	var crown := PackedVector2Array()
	for k in 18:
		var a := PI + k * PI / 17.0
		var rr := 1.0 + (0.12 if k % 2 == 0 else 0.0)
		crown.append(base + Vector2(cos(a) * 120 * rr, -165 + sin(a) * 34 * rr) * s)
	crown.append(base + Vector2(110, -158) * s)
	crown.append(base + Vector2(-110, -158) * s)
	n.draw_colored_polygon(crown, Color(0.42, 0.45, 0.24))
	n.draw_polyline(crown + PackedVector2Array([crown[0]]), INK, 3.0)

# --- the playable stage
func _draw() -> void:
	for r in solids:
		_stone_block(r)
	for p in platforms:
		_plank(p)

func _stone_block(r: Rect2) -> void:
	var lip := 22.0
	var body := Rect2(r.position + Vector2(0, lip), Vector2(r.size.x, r.size.y - lip))
	# tapered underside
	var under := PackedVector2Array([body.position, body.position + Vector2(body.size.x, 0), body.end + Vector2(-60, 0), Vector2(body.position.x + 60, body.end.y), ])
	draw_colored_polygon(under, Color(0.48, 0.4, 0.33))
	var rows := int(body.size.y / 46.0)
	for i in rows:
		var y := body.position.y + i * 46.0
		var inset := 60.0 * float(i) / rows
		var x0 := body.position.x + inset
		var x1 := body.end.x - inset
		draw_line(Vector2(x0, y), Vector2(x1, y), Color(INK, 0.5), 2.0)
		var off := 0.0 if i % 2 == 0 else 45.0
		var x := x0 + off
		while x < x1:
			draw_line(Vector2(x, y), Vector2(x, y + 46), Color(INK, 0.45), 2.0)
			x += 90.0
	# carved emblem rings
	for k in 24:
		var c := Vector2(-2300.0 + k * 200.0, body.position.y + 90)
		draw_arc(c, 30, 0, TAU, 32, Color(INK, 0.55), 3.0)
		draw_arc(c, 18, 0, TAU, 24, Color(0.85, 0.62, 0.3, 0.8), 3.0)
	draw_polyline(under + PackedVector2Array([under[0]]), INK, 4.0)
	if false:
		var rock := PackedVector2Array([Vector2(body.position.x + 60, body.end.y), Vector2(body.end.x - 60, body.end.y), Vector2(body.end.x - 160, body.end.y + 110), Vector2(r.get_center().x + 60, body.end.y + 260), Vector2(r.get_center().x - 20, body.end.y + 340), Vector2(r.get_center().x - 120, body.end.y + 200), Vector2(body.position.x + 150, body.end.y + 120)])
		draw_colored_polygon(rock, Color(0.45, 0.37, 0.3))
		draw_polyline(rock + PackedVector2Array([rock[0]]), INK, 4.0)
		for k in 7:
			var a := rock[k]
			draw_line(a.lerp(r.get_center() + Vector2(0, 400), 0.15), a.lerp(r.get_center() + Vector2(0, 400), 0.4), Color(INK, 0.35), 2.0)
	# sandy top lip with grass tufts
	var top := Rect2(r.position, Vector2(r.size.x, lip))
	draw_rect(top, Color(0.86, 0.71, 0.47))
	draw_rect(Rect2(r.position + Vector2(0, lip - 6), Vector2(r.size.x, 6)), Color(0.66, 0.5, 0.32))
	draw_rect(top, INK, false, 4.0)
	var x2 := r.position.x + 18
	while x2 < r.end.x - 10:
		for b in 3:
			draw_line(Vector2(x2 + b * 5, r.position.y + 2), Vector2(x2 + b * 5 - 4 + b * 4, r.position.y - 10 - b * 2), Color(0.4, 0.45, 0.2), 3.0)
		x2 += 70.0 + float(int(x2) % 37)
	# hanging vines
	for k in 6:
		var vx := r.position.x + 70 + k * (r.size.x - 140) / 5.0
		var len := 60.0 + (k * 37 % 70)
		var pts := PackedVector2Array()
		for j in 8:
			pts.append(Vector2(vx + sin(j * 0.9 + k) * 6, body.position.y + j * len / 7.0))
		draw_polyline(pts, Color(0.32, 0.4, 0.18), 4.0)

func _plank(p: Rect2) -> void:
	var r := Rect2(p.position, Vector2(p.size.x, p.size.y))
	draw_rect(r, Color(0.62, 0.42, 0.24))
	var x := r.position.x + 30
	while x < r.end.x:
		draw_line(Vector2(x, r.position.y), Vector2(x, r.end.y), Color(INK, 0.6), 2.0)
		x += 42.0
	draw_rect(r, INK, false, 3.5)
	# ropes up to nowhere: hanging chains for a floating feel
	for sx in [r.position.x + 14, r.end.x - 14]:
		draw_line(Vector2(sx, r.position.y), Vector2(sx, r.position.y - 900), Color(INK, 0.55), 3.0)
