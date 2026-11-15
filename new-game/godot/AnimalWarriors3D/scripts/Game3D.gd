## 3D match: flat arena floor (no falling off), side-on camera, rules, effects, drops and HUD.
class_name Game3D
extends Node3D

signal finished

const U := 0.012
var mode := "arena"
var demo := false
var fighters: Array = []
var blast := Rect2(-1250, -1150, 2500, 1600)   # game units; launched past the sides or top = K.O.
var cam: Camera3D
var fx: Fx
var overlay: Node2D
var hud: Hud3D
var touch: TouchPad
var inputs_enabled := false
var shake := 0.0
var punch_zoom := 0.0
var first_strike := false
var over := false
var slowmo := 0.0
var pickups: Array = []
var projectiles: Array = []
var drop_timer := 6.0
var potion_timer := 17.0
var shadows := {}
var trails := {}
var clouds: Node3D
var t := 0.0

func setup(m: String, roster: Array, is_demo: bool) -> void:
	mode = m
	demo = is_demo
	_build_world()
	var spawns := [Vector2(-260, 0), Vector2(260, 0), Vector2(-90, 0), Vector2(90, 0)]
	for i in roster.size():
		var r: Dictionary = roster[i]
		var f := Fighter3D.new()
		f.setup(r.id, self, r.ctrl, r.team, i, Look.LOOKS[r.id])
		f.pos = spawns[i]
		f.facing = 1 if spawns[i].x < 0 else -1
		f.model_yaw = 90.0 * f.facing
		add_child(f)
		fighters.append(f)
		var sh := MeshInstance3D.new()
		var disc := CylinderMesh.new()
		disc.top_radius = 0.45
		disc.bottom_radius = 0.45
		disc.height = 0.01
		sh.mesh = disc
		var sm := StandardMaterial3D.new()
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm.albedo_color = Color(0.2, 0.1, 0.05, 0.35)
		sh.material_override = sm
		add_child(sh)
		shadows[f] = sh
	await get_tree().process_frame
	await get_tree().process_frame
	for f in fighters:
		f.dress()
	var ov := CanvasLayer.new()
	ov.layer = 5
	add_child(ov)
	overlay = Node2D.new()
	overlay.draw.connect(_draw_trails)
	ov.add_child(overlay)
	fx = Fx.new()
	ov.add_child(fx)
	hud = Hud3D.new()
	hud.game = self
	add_child(hud)
	touch = TouchPad.new()
	touch.ghost_mode = demo
	add_child(touch)
	_countdown()

# ------------------------------------------------------------------ world
func _build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(1.0, 0.86, 0.62)
	env.environment = e
	add_child(env)
	var grad := Gradient.new()
	grad.set_color(0, Color(0.5, 0.69, 0.87))
	grad.set_color(1, Color(1.0, 0.86, 0.6))
	grad.add_point(0.6, Color(0.96, 0.9, 0.78))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_to = Vector2(0, 1)
	var skym := StandardMaterial3D.new()
	skym.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	skym.albedo_texture = gt
	var skyq := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(900, 160)
	skyq.mesh = q
	skyq.material_override = skym
	skyq.position = Vector3(0, 70, -170)
	add_child(skyq)
	var sunm := StandardMaterial3D.new()
	sunm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sunm.albedo_color = Color(1, 0.97, 0.86)
	var sun := MeshInstance3D.new()
	sun.mesh = Look.mesh("sphere", 7.0)
	sun.material_override = sunm
	sun.position = Vector3(40, 46, -160)
	add_child(sun)
	var halo := MeshInstance3D.new()
	var hq := QuadMesh.new()
	hq.size = Vector2(60, 60)
	halo.mesh = hq
	var hm := StandardMaterial3D.new()
	hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var ht := GradientTexture2D.new()
	var hg := Gradient.new()
	hg.set_color(0, Color(1, 0.95, 0.8, 0.7))
	hg.set_color(1, Color(1, 0.95, 0.8, 0.0))
	ht.gradient = hg
	ht.fill = GradientTexture2D.FILL_RADIAL
	ht.fill_from = Vector2(0.5, 0.5)
	ht.fill_to = Vector2(1, 0.5)
	hm.albedo_texture = ht
	halo.material_override = hm
	halo.position = Vector3(40, 46, -161)
	add_child(halo)
	var cloud := Look.toon(Color(1, 0.98, 0.93), Color(0.85, 0.82, 0.8), 0, Color.BLACK, 1.0, 0.22)
	var rc := RandomNumberGenerator.new()
	rc.seed = 8
	clouds = Node3D.new()
	add_child(clouds)
	for i in 12:
		var cn := Node3D.new()
		cn.position = Vector3(-140 + i * 24 + rc.randf_range(-6, 6), rc.randf_range(14, 40), -90 - rc.randf_range(0, 30))
		var sc := rc.randf_range(2.0, 4.0)
		for k in 5:
			var b := MeshInstance3D.new()
			b.mesh = Look.mesh("sphere", 1.0)
			b.material_override = cloud
			var o: Vector3 = [Vector3(-1.8, 0, 0), Vector3(-0.7, 0.6, 0), Vector3(0.5, 0.8, 0), Vector3(1.6, 0.2, 0), Vector3(0, -0.2, 0.3)][k]
			b.position = o * sc
			b.scale = Vector3.ONE * sc * (1.0 + (k % 2) * 0.25)
			cn.add_child(b)
		clouds.add_child(cn)
	cam = Camera3D.new()
	cam.fov = 30.0
	cam.near = 0.3
	cam.far = 400.0
	add_child(cam)
	cam.current = true
	cam.position = Vector3(0, 2.2, 18.0 if mode == "arena" else 8.0)
	# the arena floor: one long flat stone platform that never ends on screen
	var stone := Look.toon(Color(0.88, 0.76, 0.57), Color(0.58, 0.45, 0.32), 2, Color(0.7, 0.57, 0.4), 1.0, 0.0)
	_box(Vector3(0, -0.5, -1.0), Vector3(120, 1.0, 8.0), stone)
	var trim := Look.toon(Color(0.6, 0.46, 0.32), Color(0.38, 0.27, 0.18), 0, Color.BLACK, 1.0, 0.0)
	_box(Vector3(0, -0.06, 3.02), Vector3(120, 0.12, 0.08), trim)
	var front := Look.toon(Color(0.62, 0.5, 0.38), Color(0.4, 0.3, 0.2), 2, Color(0.3, 0.2, 0.12), 1.0, 0.0)
	_box(Vector3(0, -1.6, 2.6), Vector3(120, 2.2, 1.0), front)
	# back wall of the arena with columns and banners
	var wall := Look.toon(Color(0.8, 0.66, 0.48), Color(0.52, 0.38, 0.26), 2, Color(0.62, 0.48, 0.34), 1.0, 0.02)
	_box(Vector3(0, 0.7, -5.6), Vector3(120, 1.4, 0.8), wall)
	var col := Look.toon(Color(0.9, 0.8, 0.64), Color(0.58, 0.46, 0.34), 0, Color.BLACK, 1.0, 0.03)
	var red := Look.toon(Color(0.68, 0.18, 0.13), Color(0.38, 0.08, 0.06), 0, Color.BLACK, 1.0, 0.02)
	var gold := Look.toon(Color(0.9, 0.66, 0.25), Color(0.55, 0.36, 0.12), 0, Color.BLACK, 1.0, 0.02)
	for i in range(-9, 10):
		var x := i * 6.0
		var h := 5.0 if i % 3 != 0 else 3.2
		var c := MeshInstance3D.new()
		c.mesh = Look.mesh("cyl", 0.38, 0.45, h)
		c.material_override = col
		c.position = Vector3(x, h * 0.5, -6.4)
		add_child(c)
		if h > 4.0:
			_box(Vector3(x, h + 0.15, -6.4), Vector3(1.2, 0.3, 1.2), col)
			_box(Vector3(x, h - 1.5, -5.9), Vector3(0.9, 2.0, 0.05), red if i % 2 == 0 else gold)
	# distant savannah: mesas, hills and acacia trees
	var mesa := Look.toon(Color(0.88, 0.62, 0.44), Color(0.68, 0.44, 0.32), 0, Color.BLACK, 1.0, 0.25)
	var mesa2 := Look.toon(Color(0.8, 0.7, 0.72), Color(0.66, 0.56, 0.62), 0, Color.BLACK, 1.0, 0.3)
	var r := RandomNumberGenerator.new()
	r.seed = 5
	for i in 14:
		var x := -120.0 + i * 18.0 + r.randf_range(-5, 5)
		var w := r.randf_range(8, 16)
		var hh := r.randf_range(6, 14)
		_box(Vector3(x, hh * 0.5 - 2.0, -60.0 - r.randf_range(0, 20)), Vector3(w, hh, 6), mesa if i % 2 == 0 else mesa2)
	var trunk := Look.toon(Color(0.35, 0.24, 0.15), Color(0.2, 0.13, 0.08), 0, Color.BLACK, 1.0, 0.03)
	var leaves := Look.toon(Color(0.48, 0.52, 0.28), Color(0.3, 0.34, 0.16), 0, Color.BLACK, 1.0, 0.06)
	for i in 8:
		var x := -50.0 + i * 14.0 + r.randf_range(-4, 4)
		var z := -22.0 - r.randf_range(0, 8)
		var tr := MeshInstance3D.new(); tr.mesh = Look.mesh("cyl", 0.18, 0.3, 4.0); tr.material_override = trunk; tr.position = Vector3(x, 2.0 - 1.0, z); add_child(tr)
		var cr := MeshInstance3D.new(); cr.mesh = Look.mesh("cyl", 2.6, 2.2, 0.7); cr.material_override = leaves; cr.position = Vector3(x, 3.2, z); add_child(cr)
	var ground := Look.toon(Color(0.82, 0.68, 0.42), Color(0.6, 0.48, 0.3), 0, Color.BLACK, 1.0, 0.0)
	_box(Vector3(0, -1.1, -40), Vector3(400, 0.2, 70), ground)

func _box(p: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = Look.mesh("box", size.x, size.y, size.z)
	mi.material_override = mat
	mi.position = p
	add_child(mi)
	return mi

func _countdown() -> void:
	Sfx.start_music()
	await get_tree().create_timer(0.4).timeout
	for n in ["3", "2", "1"]:
		hud.banner(n, Color(1, 0.84, 0.25), 0.8)
		Sfx.play("beep")
		await get_tree().create_timer(0.75).timeout
	hud.banner("FIGHT!", Color(1, 0.55, 0.2), 1.0)
	Sfx.play("go")
	inputs_enabled = true

# ------------------------------------------------------------------ main loop
func _physics_process(delta: float) -> void:
	if fx == null:
		return
	t += delta
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
	for f in fighters:
		var sh: MeshInstance3D = shadows[f]
		sh.visible = f.alive
		var hgt := clampf(-f.pos.y * U, 0.0, 6.0)
		sh.position = Vector3(f.pos.x * U, 0.012, 0.0)
		var k := 1.0 / (1.0 + hgt * 0.5)
		sh.scale = Vector3(k, 1, k * 0.7)
		# fist / foot motion trails while a hit is active
		if f.state == "attack" and not f.atk.is_empty():
			for h in f.atk.hits:
				if f.st_time >= h.t0 - 0.05 and f.st_time <= h.t1 + 0.04:
					for b in h.bones:
						_trail_add(str(f.slot) + b, to_screen(f.hit_point(b)), h.get("heavy", false))
	clouds.position.x = fposmod(t * 1.5, 48.0) - 24.0
	overlay.queue_redraw()

func to_screen(p: Vector2) -> Vector2:
	return cam.unproject_position(Vector3(p.x * U, -p.y * U, 0.0))

func fx_dust(p: Vector2, n: int) -> void:
	if fx:
		fx.dust(to_screen(p), n, 0.7)

func fx_smoke(p: Vector2) -> void:
	if fx:
		fx.smoke(to_screen(p))

func ghost(f) -> void:
	var s := to_screen(f.center())
	fx._add({"pos": s + Vector2(-f.facing * 30, randf_range(-40, 40)), "vel": Vector2(-f.facing * 300, 0), "life": 0.2, "kind": "spark", "len": 60.0, "color": Color(0.6, 0.85, 1.0, 0.8)})

func _trail_add(key: String, p: Vector2, heavy: bool) -> void:
	if not trails.has(key):
		trails[key] = {"pts": [], "heavy": heavy}
	trails[key].pts.append({"p": p, "t": t})
	trails[key].heavy = heavy

func _draw_trails() -> void:
	for k in trails.keys():
		var tr: Dictionary = trails[k]
		var pts: Array = tr.pts.filter(func(e): return t - e.t < 0.12)
		tr.pts = pts
		if pts.size() < 2:
			continue
		for i in range(1, pts.size()):
			var a := float(i) / pts.size()
			var w := (14.0 if tr.heavy else 9.0) * a
			overlay.draw_line(pts[i - 1].p, pts[i].p, Color(1, 0.96, 0.85, 0.75 * a), w)

func _separate() -> void:
	for i in fighters.size():
		for j in range(i + 1, fighters.size()):
			var a = fighters[i]
			var b = fighters[j]
			if not a.alive or not b.alive or a.state == "hitstun" or b.state == "hitstun":
				continue
			var dx: float = b.pos.x - a.pos.x
			if absf(dx) < 52.0 and absf(b.pos.y - a.pos.y) < 100.0:
				var push := (52.0 - absf(dx)) * 0.25 * (1.0 if dx >= 0.0 else -1.0)
				a.pos.x -= push
				b.pos.x += push

func nearest_enemy(f):
	var best = null
	var bd := INF
	for o in fighters:
		if o == f or o.team == f.team or not o.alive or o.eliminated:
			continue
		var d: float = f.pos.distance_squared_to(o.pos)
		if d < bd:
			bd = d
			best = o
	return best

func nearest_pickup(f):
	var best = null
	var bd := INF
	for p in pickups:
		if p.kind != "axe" or not p.landed:
			continue
		var d: float = f.pos.distance_squared_to(p.pos)
		if d < bd:
			bd = d
			best = p
	return best

# ------------------------------------------------------------------ combat
func check_hit(by, idx: int, h: Dictionary, at: Vector2) -> void:
	var power: float = 1.0 + by.charge * 0.7
	for o in fighters:
		if o == by or o.team == by.team or not o.alive:
			continue
		var key := "h%d_%d" % [idx, o.slot]
		if by.atk_done.has(key):
			continue
		if o.hurt_rect().grow(h.r).has_point(at):
			by.atk_done[key] = true
			o.take_hit(by, h, at, power)

const WORDS := ["POW!", "WHAM!", "CRACK!", "BAM!", "THUD!", "SMASH!"]
func on_hit(by, victim, at: Vector2, dir: Vector2, kb: float, h: Dictionary) -> void:
	var heavy: bool = h.get("heavy", false) or kb > 700.0
	var tint := Color(0.85, 0.95, 1.0) if h.get("metal", false) else Color(1, 0.85, 0.4)
	var sp := to_screen(at)
	fx.hit(sp, Vector2(dir.x, dir.y), heavy, tint)
	Sfx.play("hit_heavy" if heavy else "hit_light", 0.0 if heavy else -3.0)
	if h.get("metal", false):
		Sfx.play("clang", -6.0)
	shake = maxf(shake, 0.04 + kb * 0.00012)
	if heavy:
		punch_zoom = 0.6
		hud.comic(WORDS.pick_random(), sp + Vector2(dir.x * 40, -60), Color(1, 0.86, 0.25) if kb < 900 else Color(1, 0.4, 0.25))
	if not first_strike:
		first_strike = true
		hud.banner("FIRST STRIKE!", Color(0.5, 0.85, 1.0), 1.1, 0.55)
	hud.pop(victim)

func quake(by, at: Vector2, power: float) -> void:
	fx.dust(to_screen(at), 16, 2.4)
	fx.hit(to_screen(at + Vector2(0, -8)), Vector2.UP, true, Color(0.95, 0.8, 0.55))
	Sfx.play("hit_heavy", -2.0)
	shake = maxf(shake, 0.14)
	var h := {"dmg": 8.0, "base": 340.0, "growth": 5.0, "angle": 62.0, "heavy": true, "radial": true, "r": 0.0}
	for o in fighters:
		if o != by and o.team != by.team and o.alive and o.on_ground and absf(o.pos.x - at.x) < 170.0 * power:
			o.take_hit(by, h, o.center(), power)

func ko(f) -> void:
	if not f.alive:
		return
	f.alive = false
	f.stocks -= 1
	f.stats.falls += 1
	if f.last_hit_by and f.last_hit_by != f:
		f.last_hit_by.stats.kos += 1
	var sp := to_screen(f.center())
	var vs := get_viewport().get_visible_rect().size
	var edge := sp.clamp(Vector2(40, 40), vs - Vector2(40, 40))
	var dir: Vector2 = (f.center() - Vector2(cam.position.x / U, 0)).normalized()
	fx.ko(edge, dir, f.data.color)
	hud.flash()
	Sfx.play("ko", 2.0)
	shake = 0.35
	f.respawn_t = 1.8
	f.equip("")
	if f.stocks <= 0:
		f.eliminated = true
	var teams := {}
	for o in fighters:
		if not o.eliminated:
			teams[o.team] = true
	if teams.size() <= 1 and not over:
		over = true
		Engine.time_scale = 0.35
		slowmo = 0.9
		hud.banner("K.O.!", Color(1, 0.35, 0.25), 1.4, 1.0)
		await get_tree().create_timer(2.0, true, false, true).timeout
		Engine.time_scale = 1.0
		_results()
	else:
		hud.banner("K.O.!", Color(1, 0.4, 0.3), 0.9, 0.8)

func respawn(f) -> void:
	if f.eliminated:
		return
	f.alive = true
	f.dmg = 0.0
	f.vel = Vector2.ZERO
	f.state = "free"
	f.atk = {}
	f.tumble = false
	f.invuln = 2.0
	f.pos = Vector2(cam.position.x / U * 0.5, -700)
	f.on_ground = false
	f.pose({}, 10.0)
	fx.sparkle(to_screen(f.center()), Color(1, 0.95, 0.6))

func _results() -> void:
	inputs_enabled = false
	var winner = null
	for f in fighters:
		if not f.eliminated:
			winner = f
			f.victory = true
			f.vel = Vector2.ZERO
	await get_tree().create_timer(1.2).timeout
	hud.show_results(winner)
	await get_tree().create_timer(4.5).timeout
	finished.emit()

# ------------------------------------------------------------------ drops: axe and health potion fall from the sky
func _pickups_step(delta: float) -> void:
	if not inputs_enabled:
		return
	drop_timer -= delta
	potion_timer -= delta
	var axes := projectiles.size()
	for p in pickups:
		if p.kind == "axe":
			axes += 1
	for f in fighters:
		if f.weapon != "":
			axes += 1
	if drop_timer <= 0.0:
		drop_timer = 9.0
		if axes < 2:
			_spawn("axe", Vector2(randf_range(-500, 500) + cam.position.x / U * 0.5, -1000))
	if potion_timer <= 0.0:
		potion_timer = 20.0
		_spawn("potion", Vector2(randf_range(-500, 500) + cam.position.x / U * 0.5, -1000))
	var keep: Array = []
	for p in pickups:
		p.life -= delta
		if p.life <= 0.0:
			p.node.queue_free()
			continue
		if not p.landed:
			p.vel.y = minf(p.vel.y + 1400.0 * delta, 700.0)
			p.pos += p.vel * delta
			if p.pos.y >= 0.0:
				p.pos.y = 0.0
				p.landed = true
				fx.dust(to_screen(p.pos), 5)
				Sfx.play("land", -8.0)
		p.node.position = Vector3(p.pos.x * U, -p.pos.y * U + (0.12 + sin(t * 3.0) * 0.05 if p.landed else 0.0), 0.3)
		p.node.rotation.y += delta * 1.5
		p.glow.position = Vector3(p.pos.x * U, -p.pos.y * U + 0.35, 0.0)
		var took := false
		if p.kind == "potion":
			for f in fighters:
				if f.alive and f.hurt_rect().grow(20).has_point(p.pos + Vector2(0, -20)):
					f.dmg = maxf(0.0, f.dmg - 25.0)
					fx.sparkle(to_screen(f.center()), Color(1, 0.4, 0.4))
					Sfx.play("heal", -2.0)
					hud.pop(f)
					took = true
					break
		if took:
			p.node.queue_free()
			p.glow.queue_free()
			continue
		keep.append(p)
	pickups = keep

func _spawn(kind: String, at: Vector2, landed := false) -> void:
	var node: Node3D = Look.axe_prop() if kind == "axe" else Look.potion_prop()
	add_child(node)
	var glow := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(1.1, 1.1)
	glow.mesh = q
	var gm := StandardMaterial3D.new()
	gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.albedo_color = Color(1, 0.85, 0.35, 0.35) if kind == "axe" else Color(1, 0.35, 0.3, 0.3)
	gm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var tex := GradientTexture2D.new()
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	tex.gradient = g
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	gm.albedo_texture = tex
	glow.material_override = gm
	add_child(glow)
	pickups.append({"kind": kind, "node": node, "glow": glow, "pos": at, "vel": Vector2.ZERO, "landed": landed, "life": 16.0})

func try_pickup(f) -> void:
	for p in pickups:
		if p.kind == "axe" and p.landed and f.pos.distance_to(p.pos) < 90.0:
			f.equip("axe")
			p.node.queue_free()
			p.glow.queue_free()
			pickups.erase(p)
			Sfx.play("pickup", -2.0)
			fx.sparkle(to_screen(f.center()), Color(1, 0.9, 0.5))
			return

func throw_weapon(f) -> void:
	var node := Look.axe_prop()
	add_child(node)
	projectiles.append({"node": node, "pos": f.center() + Vector2(f.facing * 40, -10), "vel": Vector2(f.facing * 1150.0, -260.0), "owner": f, "life": 1.4})
	f.equip("")
	Sfx.play("whoosh_heavy")

func _projectiles_step(delta: float) -> void:
	var keep: Array = []
	for pr in projectiles:
		pr.life -= delta
		pr.vel.y += 900.0 * delta
		pr.pos += pr.vel * delta
		pr.node.position = Vector3(pr.pos.x * U, -pr.pos.y * U, 0.2)
		pr.node.rotation.z -= delta * 20.0 * signf(pr.vel.x)
		var done: bool = pr.life <= 0.0 or pr.pos.y >= 0.0
		for o in fighters:
			if o != pr.owner and o.team != pr.owner.team and o.alive and o.hurt_rect().grow(24).has_point(pr.pos):
				var h := {"dmg": 9.0, "base": 320.0, "growth": 4.0, "angle": 30.0, "metal": true}
				var tf: int = pr.owner.facing
				pr.owner.facing = 1 if pr.vel.x > 0.0 else -1
				o.take_hit(pr.owner, h, pr.pos, 1.0)
				pr.owner.facing = tf
				done = true
		if done:
			pr.node.queue_free()
			_spawn("axe", Vector2(pr.pos.x, minf(pr.pos.y, -40.0)))
		else:
			keep.append(pr)
	projectiles = keep

# ------------------------------------------------------------------ camera: side-on, frames the fighters
func _camera(delta: float) -> void:
	var box := Rect2()
	var first := true
	for f in fighters:
		if not f.alive:
			continue
		var p: Vector2 = f.center().clamp(blast.position + Vector2(200, 200), blast.end - Vector2(200, 0))
		var w := Vector2(p.x * U, -p.y * U)
		if first:
			box = Rect2(w, Vector2.ZERO)
			first = false
		else:
			box = box.expand(w)
	if first:
		box = Rect2(Vector2(0, 1), Vector2.ZERO)
	var vs := get_viewport().get_visible_rect().size
	var aspect := vs.x / vs.y
	var marg := Vector2(9.0, 5.0) if mode == "arena" else Vector2(3.4, 2.2)
	var need_h := maxf(box.size.y + marg.y, (box.size.x + marg.x) / aspect)
	var dist := need_h * 0.5 / tan(deg_to_rad(cam.fov * 0.5))
	dist = clampf(dist, 14.0, 26.0) if mode == "arena" else clampf(dist, 5.2, 9.0)
	dist *= 1.0 - punch_zoom * 0.06
	punch_zoom = maxf(0.0, punch_zoom - delta * 3.0)
	var c := box.get_center()
	var half_h := dist * tan(deg_to_rad(cam.fov * 0.5))
	var cy := maxf(c.y + 0.3, half_h * 0.62 - 0.2)      # keep the floor in the lower part of the screen
	var target := Vector3(c.x, cy + dist * 0.05, dist)
	var a := 1.0 - exp(-4.0 * delta)
	cam.position = cam.position.lerp(target, a)
	shake = maxf(0.0, shake - delta * 0.9)
	cam.h_offset = randf_range(-shake, shake)
	cam.v_offset = randf_range(-shake, shake)
	cam.rotation_degrees.x = -3.0
