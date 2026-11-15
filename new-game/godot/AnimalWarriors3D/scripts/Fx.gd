## Lightweight particle effects drawn in one pass: hit sparks, dust, smoke trails, KO bursts.
class_name Fx
extends Node2D

var parts: Array = []
const INK := Color(0.12, 0.07, 0.04)

func _process(delta: float) -> void:
	var keep: Array = []
	for p in parts:
		p.life -= delta
		if p.life <= 0.0:
			continue
		p.pos += p.vel * delta
		p.vel *= pow(p.drag, delta * 60.0)
		p.vel.y += p.grav * delta
		p.rot += p.spin * delta
		keep.append(p)
	parts = keep
	queue_redraw()

func _add(d: Dictionary) -> void:
	var base := {"pos": Vector2.ZERO, "vel": Vector2.ZERO, "life": 0.5, "max": 0.5, "size": 6.0, "grow": 0.0,
		"color": Color.WHITE, "kind": "dot", "drag": 0.92, "grav": 0.0, "rot": 0.0, "spin": 0.0, "len": 20.0}
	base.merge(d, true)
	base.max = base.life
	parts.append(base)

func hit(at: Vector2, dir: Vector2, heavy: bool, tint: Color = Color(1, 0.85, 0.4)) -> void:
	var n := 14 if heavy else 7
	for i in n:
		var a := dir.angle() + randf_range(-1.1, 1.1)
		var sp := randf_range(500, 1300) * (1.4 if heavy else 1.0)
		_add({"pos": at, "vel": Vector2.from_angle(a) * sp, "life": randf_range(0.12, 0.26), "kind": "spark",
			"len": randf_range(18, 42) * (1.5 if heavy else 1.0), "color": tint, "drag": 0.86})
	_add({"pos": at, "life": 0.09 if heavy else 0.06, "kind": "star", "size": 24.0 if heavy else 14.0, "grow": 90.0,
		"color": Color(1, 1, 0.92, 0.9), "rot": randf() * TAU})
	_add({"pos": at, "life": 0.18, "kind": "ring", "size": 8.0, "grow": 260.0 if heavy else 150.0, "color": tint})

func dust(at: Vector2, amount: int = 5, spread: float = 1.0) -> void:
	for i in amount:
		_add({"pos": at + Vector2(randf_range(-14, 14), -4), "vel": Vector2(randf_range(-160, 160) * spread, randf_range(-90, -20)),
			"life": randf_range(0.3, 0.55), "kind": "puff", "size": randf_range(7, 13), "grow": 30.0,
			"color": Color(0.86, 0.76, 0.6, 0.85), "drag": 0.9})

func smoke(at: Vector2) -> void:
	_add({"pos": at + Vector2(randf_range(-6, 6), randf_range(-6, 6)), "life": 0.55, "kind": "puff",
		"size": randf_range(9, 15), "grow": 40.0, "color": Color(1, 1, 1, 0.75), "drag": 0.95})

func ko(at: Vector2, dir: Vector2, tint: Color) -> void:
	for i in 34:
		var a := dir.angle() + PI + randf_range(-0.9, 0.9)
		_add({"pos": at, "vel": Vector2.from_angle(a) * randf_range(500, 1800), "life": randf_range(0.4, 0.9), "kind": "spark",
			"len": randf_range(30, 80), "color": tint.lightened(0.3), "drag": 0.9})
	for i in 3:
		_add({"pos": at, "life": 0.5 + i * 0.12, "kind": "ring", "size": 20.0, "grow": 900.0 + i * 300.0, "color": Color(1, 0.95, 0.8)})
	_add({"pos": at, "life": 0.35, "kind": "beam", "size": 140.0, "rot": dir.angle() + PI, "color": Color(1, 0.95, 0.75)})

func sparkle(at: Vector2, tint: Color) -> void:
	for i in 10:
		_add({"pos": at, "vel": Vector2.from_angle(randf() * TAU) * randf_range(80, 260), "life": randf_range(0.3, 0.6),
			"kind": "dot", "size": randf_range(3, 6), "color": tint, "drag": 0.9, "grav": -60.0})

func _draw() -> void:
	for p in parts:
		var t: float = 1.0 - p.life / p.max
		var c: Color = p.color
		var sz: float = p.size + p.grow * t
		match p.kind:
			"spark":
				var d: Vector2 = p.vel.normalized() * p.len * (1.0 - t * 0.6)
				draw_line(p.pos - d, p.pos, Color(INK, c.a * (1.0 - t)), 6.0)
				draw_line(p.pos - d, p.pos, Color(c, c.a * (1.0 - t)), 3.5)
			"star":
				var pts := PackedVector2Array()
				for i in 16:
					var r := sz if i % 2 == 0 else sz * 0.35
					pts.append(p.pos + Vector2.from_angle(p.rot + i * TAU / 16.0) * r)
				draw_colored_polygon(pts, Color(c, 1.0 - t))
			"ring":
				draw_arc(p.pos, sz, 0, TAU, 40, Color(c, (1.0 - t) * 0.7), 3.5 * (1.0 - t) + 1.0)
			"puff":
				draw_circle(p.pos, sz, Color(c, c.a * (1.0 - t)))
			"beam":
				var dir := Vector2.from_angle(p.rot)
				var w := sz * (1.0 - t)
				var nrm := dir.orthogonal() * w * 0.5
				draw_colored_polygon(PackedVector2Array([p.pos + nrm * 0.2, p.pos + dir * 1600 + nrm, p.pos + dir * 1600 - nrm, p.pos - nrm * 0.2]), Color(c, 0.8 * (1.0 - t)))
			_:
				draw_circle(p.pos, sz * (1.0 - t * 0.5), Color(c, c.a * (1.0 - t)))
