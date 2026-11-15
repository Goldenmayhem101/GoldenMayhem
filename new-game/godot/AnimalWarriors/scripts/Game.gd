## A match: stage, fighters, camera, rules, knock-outs, weapon drops and the HUD.
class_name Game
extends Node2D

signal finished

var mode := "arena"            # "arena" (small fighters) or "close" (big fighters)
var demo := false
var fighters: Array[Fighter] = []
var solids: Array[Rect2] = []
var platforms: Array[Rect2] = []
var main_rect := Rect2()
var blast := Rect2()
var stage: Stage
var cam: Camera2D
var fx: Fx
var hud: Hud
var touch: TouchPad
var world: Node2D
var inputs_enabled := false
var pickups: Array = []
var projectiles: Array = []
var drop_timer := 5.0
var potion_timer := 16.0
var shake := 0.0
var first_strike := false
var over := false
var cam_zoom_min := 0.55
var cam_zoom_max := 1.25
var slowmo := 0.0

func setup(m: String, roster: Array, is_demo: bool) -> void:
	mode = m
	demo = is_demo
	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()
	var sky := CanvasLayer.new()
	sky.layer = -20
	add_child(sky)
	var bg := TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(0.55, 0.72, 0.86))
	grad.set_color(1, Color(1.0, 0.86, 0.6))
	grad.add_point(0.45, Color(0.93, 0.86, 0.74))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	bg.texture = gt
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	sky.add_child(bg)
	world = Node2D.new()
	add_child(world)
	stage = Stage.new()
	world.add_child(stage)
	stage.build(mode, cam)
	solids = stage.solids
	platforms = stage.platforms
	main_rect = Rect2(-1100, 0, 2200, 300)
	if mode == "arena":
		blast = Rect2(-1250, -1050, 2500, 1700)
		cam_zoom_min = 0.5
		cam_zoom_max = 0.82
	else:
		blast = Rect2(-1400, -1150, 2800, 1800)
		cam_zoom_min = 1.15
		cam_zoom_max = 2.35
	fx = Fx.new()
	fx.z_index = 50
	world.add_child(fx)
	var spawns := [Vector2(-260, -10), Vector2(260, -10), Vector2(-90, -10), Vector2(90, -10)]
	for i in roster.size():
		var r: Dictionary = roster[i]
		var f := Fighter.new()
		f.setup(r.id, self, r.ctrl, r.team, i)
		f.position = spawns[i]
		f.facing = 1 if spawns[i].x < 0 else -1
		f.z_index = 10 + i * 4
		world.add_child(f)
		fighters.append(f)
	hud = Hud.new()
	hud.game = self
	add_child(hud)
	touch = TouchPad.new()
	touch.ghost_mode = demo
	add_child(touch)
	cam.position = Vector2(0, -150)
	cam.zoom = Vector2.ONE * (0.9 if mode == "arena" else 1.6)
	_countdown()

func _countdown() -> void:
	Sfx.start_music()
	for n in ["3", "2", "1"]:
		hud.banner(n, Color(1, 0.84, 0.25), 0.8)
		Sfx.play("beep")
		await get_tree().create_timer(0.75).timeout
	hud.banner("FIGHT!", Color(1, 0.55, 0.2), 1.0)
	Sfx.play("go")
	inputs_enabled = true

func _physics_process(delta: float) -> void:
	if slowmo > 0.0:
		slowmo -= delta / Engine.time_scale
		if slowmo <= 0.0:
			Engine.time_scale = 1.0
	for f in fighters:
		f.step(delta)
	_separate()
	_pickups_step(delta)
	_projectiles_step(delta)
	_camera(delta)

func _separate() -> void:
	# fighters push each other apart a little so they don't stand inside one another
	for i in fighters.size():
		for j in range(i + 1, fighters.size()):
			var a := fighters[i]
			var b := fighters[j]
			if not a.alive or not b.alive or a.state == "hitstun" or b.state == "hitstun":
				continue
			var dx := b.position.x - a.position.x
			if absf(dx) < 46.0 and absf(b.position.y - a.position.y) < 100.0:
				var push := (46.0 - absf(dx)) * 0.25 * (1.0 if dx >= 0.0 else -1.0)
				a.position.x -= push
				b.position.x += push

# ------------------------------------------------------------------ queries used by fighters and bots
func nearest_enemy(f: Fighter) -> Fighter:
	var best: Fighter = null
	var bd := INF
	for o in fighters:
		if o == f or o.team == f.team or not o.alive or o.eliminated:
			continue
		var d := f.position.distance_squared_to(o.position)
		if d < bd:
			bd = d
			best = o
	return best

func nearest_pickup(f: Fighter):
	var best = null
	var bd := INF
	for p in pickups:
		if p.kind != "axe":
			continue
		var d: float = f.position.distance_squared_to(p.pos)
		if d < bd:
			bd = d
			best = p
	return best

func on_soft(f: Fighter) -> bool:
	for p in platforms:
		if absf(f.position.y - p.position.y) < 2.0 and f.position.x > p.position.x - 4.0 and f.position.x < p.end.x + 4.0:
			return true
	return false

# ------------------------------------------------------------------ combat
func check_hit(by: Fighter, idx: int, h: Dictionary, at: Vector2) -> void:
	var power := 1.0 + by.charge * 0.7
	for o in fighters:
		if o == by or o.team == by.team or not o.alive:
			continue
		var key := "h%d_%d" % [idx, o.slot]
		if by.atk_done.has(key):
			continue
		var r := o.hurt_rect().grow(h.r)
		if r.has_point(at):
			by.atk_done[key] = true
			o.take_hit(by, h, at, power)

func on_hit(by: Fighter, victim: Fighter, at: Vector2, dir: Vector2, kb: float, h: Dictionary) -> void:
	var heavy: bool = h.get("heavy", false) or kb > 700.0
	var tint := Color(1, 0.85, 0.4)
	if h.get("metal", false):
		tint = Color(0.85, 0.95, 1.0)
	fx.hit(at, dir, heavy, tint)
	Sfx.play("hit_heavy" if heavy else "hit_light", 0.0 if heavy else -3.0)
	if h.get("metal", false):
		Sfx.play("clang", -6.0)
	shake = maxf(shake, 4.0 + kb * 0.012)
	if not first_strike:
		first_strike = true
		hud.banner("FIRST STRIKE!", Color(0.5, 0.85, 1.0), 1.1, 0.55)
	hud.pop(victim)

func quake(by: Fighter, at: Vector2, power: float) -> void:
	fx.dust(at, 14, 2.4)
	fx.hit(at + Vector2(0, -8), Vector2.UP, true, Color(0.95, 0.8, 0.55))
	Sfx.play("hit_heavy", -2.0)
	shake = maxf(shake, 12.0)
	var h := {"dmg": 8.0, "base": 340.0, "growth": 5.0, "angle": 62.0, "heavy": true, "radial": true, "r": 0.0}
	for o in fighters:
		if o != by and o.team != by.team and o.alive and o.on_ground and absf(o.position.x - at.x) < 150.0 * power and absf(o.position.y - at.y) < 30.0:
			o.take_hit(by, h, o.center(), power)

func ghost(f: Fighter, tint: Color) -> void:
	var g: Node2D = f.rig.duplicate(0)
	g.set_script(null)
	g.global_transform = f.rig.global_transform
	g.modulate = tint
	g.z_index = f.z_index - 1
	world.add_child(g)
	var tw := g.create_tween()
	tw.tween_property(g, "modulate:a", 0.0, 0.25)
	tw.tween_callback(g.queue_free)

func ko(f: Fighter) -> void:
	if not f.alive:
		return
	f.alive = false
	f.visible = false
	f.stocks -= 1
	f.stats.falls += 1
	if f.last_hit_by and f.last_hit_by != f:
		f.last_hit_by.stats.kos += 1
	var edge := f.position.clamp(blast.position + Vector2(30, 30), blast.end - Vector2(30, 30))
	var view := _view_rect()
	edge = edge.clamp(view.position + Vector2(40, 40), view.end - Vector2(40, 40))
	var dir := (f.position - main_rect.get_center()).normalized()
	fx.ko(edge, dir, f.data.color)
	Sfx.play("ko", 2.0)
	shake = 26.0
	f.respawn_t = 1.8
	var alive_teams := {}
	for o in fighters:
		if o.stocks > 0 or o.alive:
			alive_teams[o.team] = true
	if f.stocks <= 0:
		f.eliminated = true
	if alive_teams.size() <= 1 and not over:
		over = true
		Engine.time_scale = 0.35
		slowmo = 0.9
		hud.banner("K.O.!", Color(1, 0.35, 0.25), 1.4, 1.0)
		await get_tree().create_timer(2.0, true, false, true).timeout
		Engine.time_scale = 1.0
		_results()
	else:
		hud.banner("K.O.!", Color(1, 0.4, 0.3), 0.9, 0.8)

func respawn(f: Fighter) -> void:
	if f.eliminated:
		return
	f.alive = true
	f.visible = true
	f.dmg = 0.0
	f.vel = Vector2.ZERO
	f.state = "free"
	f.atk = {}
	f.invuln = 2.0
	f.tumble = false
	f.weapon = ""
	f.equip("")
	f.position = Vector2(cam.position.x * 0.5, -600)
	f.rig.rotation = 0.0
	fx.sparkle(f.center(), Color(1, 0.95, 0.6))

func _results() -> void:
	inputs_enabled = false
	var winner: Fighter = null
	for f in fighters:
		if not f.eliminated:
			winner = f
	hud.show_results(winner)
	await get_tree().create_timer(4.5).timeout
	finished.emit()

# ------------------------------------------------------------------ weapon drops
func _pickups_step(delta: float) -> void:
	if not inputs_enabled:
		return
	drop_timer -= delta
	potion_timer -= delta
	var held := false
	for f in fighters:
		if f.weapon != "":
			held = true
	var on_field := 0
	for p in pickups:
		if p.kind == "axe":
			on_field += 1
	for p in projectiles:
		on_field += 1
	if drop_timer <= 0.0:
		drop_timer = 9.0
		if on_field + (1 if held else 0) < 2:
			_spawn_pickup("axe")
	if potion_timer <= 0.0:
		potion_timer = 20.0
		_spawn_pickup("potion")
	var keep: Array = []
	for p in pickups:
		p.life -= delta
		if p.life <= 0.0:
			p.node.queue_free()
			continue
		if not p.landed:
			p.vel.y = minf(p.vel.y + 1400.0 * delta, 700.0)
			var prev: float = p.pos.y
			p.pos += p.vel * delta
			for r in solids + platforms:
				if prev <= r.position.y and p.pos.y >= r.position.y and p.pos.x > r.position.x and p.pos.x < r.end.x:
					p.pos.y = r.position.y
					p.landed = true
					fx.dust(p.pos, 5)
					Sfx.play("land", -8.0)
			if p.pos.y > blast.end.y:
				p.node.queue_free()
				continue
		p.node.position = p.pos
		p.node.rotation = 0.0 if p.landed else sin(p.life * 9.0) * 0.2
		p.node.queue_redraw()
		if p.kind == "potion":
			var took := false
			for f in fighters:
				if f.alive and f.hurt_rect().grow(16).has_point(p.pos + Vector2(0, -20)):
					f.dmg = maxf(0.0, f.dmg - 25.0)
					fx.sparkle(f.center(), Color(1, 0.4, 0.4))
					Sfx.play("heal", -2.0)
					hud.pop(f)
					took = true
					break
			if took:
				p.node.queue_free()
				continue
		keep.append(p)
	pickups = keep

func _spawn_pickup(kind: String, at := Vector2.INF, landed := false) -> void:
	var spots: Array = [Vector2(clampf(cam.position.x + randf_range(-500, 500), -900, 900), 0.0)]
	var target: Vector2 = spots.pick_random() if at == Vector2.INF else at
	var node := PickupNode.new()
	node.kind = kind
	node.tex = load("res://art/pickup_%s.png" % kind)
	node.z_index = 30
	world.add_child(node)
	var p := {"kind": kind, "node": node, "pos": Vector2(target.x, -900.0) if at == Vector2.INF else at, "vel": Vector2.ZERO, "landed": landed, "life": 16.0}
	pickups.append(p)

func try_pickup(f: Fighter) -> void:
	for p in pickups:
		if p.kind == "axe" and p.landed and f.position.distance_to(p.pos) < 80.0:
			f.equip("axe")
			p.node.queue_free()
			pickups.erase(p)
			Sfx.play("pickup", -2.0)
			fx.sparkle(f.center(), Color(1, 0.9, 0.5))
			return

func throw_weapon(f: Fighter) -> void:
	var node := PickupNode.new()
	node.kind = "axe"
	node.tex = load("res://art/pickup_axe.png")
	node.spinning = true
	node.z_index = 30
	world.add_child(node)
	var pos := f.center() + Vector2(f.facing * 40, -10)
	var v := Vector2(f.facing * 1150.0, -260.0)
	projectiles.append({"node": node, "pos": pos, "vel": v, "owner": f, "life": 1.4})
	f.equip("")
	Sfx.play("whoosh_heavy")

func _projectiles_step(delta: float) -> void:
	var keep: Array = []
	for pr in projectiles:
		pr.life -= delta
		pr.vel.y += 900.0 * delta
		pr.pos += pr.vel * delta
		pr.node.position = pr.pos
		pr.node.rotation += delta * 22.0 * signf(pr.vel.x)
		var done: bool = pr.life <= 0.0
		for o in fighters:
			if o != pr.owner and o.team != pr.owner.team and o.alive and o.hurt_rect().grow(22).has_point(pr.pos):
				var h := {"dmg": 9.0, "base": 320.0, "growth": 4.0, "angle": 30.0, "metal": true}
				var tmp_face: int = pr.owner.facing
				pr.owner.facing = 1 if pr.vel.x > 0.0 else -1
				o.take_hit(pr.owner, h, pr.pos, 1.0)
				pr.owner.facing = tmp_face
				done = true
		for r in solids:
			if r.has_point(pr.pos):
				done = true
		if done:
			pr.node.queue_free()
			if pr.pos.y < blast.end.y - 200.0:
				_spawn_pickup("axe", pr.pos + Vector2(0, -40))
		else:
			keep.append(pr)
	projectiles = keep

# ------------------------------------------------------------------ camera
func _view_rect() -> Rect2:
	var vs := get_viewport_rect().size / cam.zoom
	return Rect2(cam.get_screen_center_position() - vs * 0.5, vs)

func _camera(delta: float) -> void:
	var box := Rect2()
	var first := true
	for f in fighters:
		if not f.alive:
			continue
		var p := f.center().clamp(blast.position + Vector2(250, 250), Vector2(blast.end.x - 250, 0))
		if first:
			box = Rect2(p, Vector2.ZERO)
			first = false
		else:
			box = box.expand(p)
	if first:
		box = Rect2(main_rect.get_center(), Vector2.ZERO)
	var vs := get_viewport_rect().size
	var margin := Vector2(900, 620) if mode == "arena" else Vector2(380, 300)
	var need := box.size + margin
	var z := clampf(minf(vs.x / need.x, vs.y / need.y), cam_zoom_min, cam_zoom_max)
	var target := box.get_center() + Vector2(0, -40 if mode == "arena" else -10)
	target.y = minf(target.y, -get_viewport_rect().size.y / cam.zoom.y * 0.28)
	if mode == "close":
		target.y = minf(target.y, -110.0)
	var a := 1.0 - exp(-4.0 * delta)
	cam.zoom = cam.zoom.lerp(Vector2(z, z), a)
	cam.position = cam.position.lerp(target, a)
	shake = maxf(0.0, shake - delta * 60.0)
	cam.offset = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))


## A dropped item: glowing axe or health potion.
class PickupNode extends Node2D:
	var kind := "axe"
	var tex: Texture2D
	var spinning := false
	var t := 0.0
	func _process(d: float) -> void:
		t += d
		queue_redraw()
	func _draw() -> void:
		var h := 92.0 if kind == "axe" else 46.0
		var s := h / tex.get_height()
		if not spinning:
			var glow := Color(1, 0.85, 0.4, 0.25 + 0.15 * sin(t * 6.0)) if kind == "axe" else Color(1, 0.4, 0.4, 0.3)
			draw_circle(Vector2(0, -h * 0.5), h * 0.62, glow)
			draw_line(Vector2(0, -h * 0.5), Vector2(0, -900), Color(1, 0.92, 0.6, 0.12), 26.0)
		var sz := tex.get_size() * s
		var bob := 0.0 if spinning else sin(t * 3.0) * 4.0
		draw_texture_rect(tex, Rect2(Vector2(-sz.x * 0.5, -sz.y + bob - (0.0 if spinning else 6.0)) + (Vector2(0, sz.y * 0.5) if spinning else Vector2.ZERO), sz), false)
