## PREVIEW 2 - DEAD ZONE: side-view zombie survival shooter. A soldier holds a ruined street against waves.
extends Node3D

signal finished

var cam: Camera3D
var fx: Fx
var ui: Control
var font: Font
var t := 0.0
var shake := 0.0
var player: Actor
var rifle: Node3D
var muzzle: Node3D
var flash_node: MeshInstance3D
var px := -3.0
var hp := 100.0
var ammo := 30
var reload_t := 0.0
var fire_cd := 0.0
var burst := 0
var kills := 0
var wave := 0
var zombies: Array = []
var tracers: Array = []
var banner_text := ""
var banner_t := 0.0
var banner_col := Color.WHITE
var spawn_queue: Array = []
var spawn_t := 0.0
var ended := false
var hurt_flash := 0.0

class Z:
	var a: Actor
	var x := 0.0
	var kind := "walk"
	var hp := 4
	var state := "walk"
	var st := 0.0
	var dur := 0.0
	var speed := 0.9
	var sink := 0.0
	var atk_cd := 0.0

func setup(_demo: bool) -> void:
	font = load("res://fonts/LilitaOne-Regular.ttf")
	_world()
	player = Actor.new()
	add_child(player)
	player.setup(Kit.toon(Color(0.48, 0.5, 0.32), Color(0.25, 0.27, 0.16), 0.012), Kit.toon(Color(0.2, 0.18, 0.15), Color(0.1, 0.09, 0.08), 0.008))
	var helmet := Node3D.new()
	player.attach("mixamorig_Head", helmet)
	var hm := Kit.toon(Color(0.38, 0.4, 0.24), Color(0.2, 0.21, 0.12), 0.008)
	Kit.part(helmet, "sphere", Vector3(0.14, 0, 0), hm, Vector3(0, 0.13, 0.0))
	Kit.part(helmet, "box", Vector3(0.12, 0.03, 0.04), Kit.glow(Color(0.3, 1.0, 0.4)), Vector3(0, 0.17, 0.11))
	var pack := Node3D.new()
	player.attach("mixamorig_Spine2", pack)
	Kit.part(pack, "box", Vector3(0.3, 0.35, 0.16), Kit.toon(Color(0.35, 0.3, 0.2), Color(0.18, 0.15, 0.1), 0.008), Vector3(0, 0.0, -0.16))
	player.play("r_aim")
	player.yaw_target = 90
	player.yaw = 90
	# rifle: placed each frame between the two hands so it always sits in the grip
	rifle = Node3D.new()
	add_child(rifle)
	var gun := Kit.toon(Color(0.18, 0.19, 0.2), Color(0.08, 0.08, 0.09), 0.006)
	Kit.part(rifle, "box", Vector3(0.06, 0.09, 0.62), gun, Vector3(0, 0, 0.18))
	Kit.part(rifle, "box", Vector3(0.05, 0.05, 0.3), gun, Vector3(0, 0.01, 0.6))
	Kit.part(rifle, "box", Vector3(0.05, 0.16, 0.06), gun, Vector3(0, -0.11, 0.05))
	Kit.part(rifle, "box", Vector3(0.06, 0.08, 0.2), gun, Vector3(0, -0.02, -0.18))
	Kit.part(rifle, "box", Vector3(0.03, 0.03, 0.04), Kit.glow(Color(1, 0.3, 0.2)), Vector3(0, 0.07, 0.25))
	muzzle = Node3D.new()
	muzzle.position = Vector3(0, 0.01, 0.78)
	rifle.add_child(muzzle)
	flash_node = MeshInstance3D.new()
	flash_node.mesh = Kit.mesh("sphere", 0.13)
	flash_node.material_override = Kit.glow(Color(1, 0.85, 0.4))
	flash_node.scale = Vector3(1, 1, 2.2)
	muzzle.add_child(flash_node)
	flash_node.visible = false
	var layer := CanvasLayer.new()
	add_child(layer)
	fx = Fx.new()
	layer.add_child(fx)
	ui = Control.new()
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.draw.connect(_draw_ui)
	layer.add_child(ui)
	Audio.start_music("music_dark", -6.0)
	_waves()

func _world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.07, 0.08, 0.14)
	e.glow_enabled = true
	e.glow_intensity = 0.8
	env.environment = e
	add_child(env)
	cam = Camera3D.new()
	cam.fov = 40
	cam.position = Vector3(1.3, 2.4, 10.8)
	cam.rotation_degrees.x = -7
	add_child(cam)
	cam.current = true
	var moon := Kit.part(self, "sphere", Vector3(2.2, 0, 0), Kit.glow(Color(0.95, 0.95, 0.85)), Vector3(9, 11, -40))
	moon.scale = Vector3.ONE
	var road := Kit.toon(Color(0.2, 0.2, 0.23), Color(0.12, 0.12, 0.14), 0.0)
	Kit.part(self, "box", Vector3(80, 1, 6), road, Vector3(0, -0.5, -0.5))
	for i in range(-12, 13):
		Kit.part(self, "box", Vector3(1.4, 0.01, 0.12), Kit.toon(Color(0.85, 0.75, 0.3), Color(0.6, 0.5, 0.2), 0.0), Vector3(i * 3.2, 0.005, -1.4))
	var walk := Kit.toon(Color(0.36, 0.35, 0.38), Color(0.22, 0.21, 0.24), 0.0)
	Kit.part(self, "box", Vector3(80, 0.2, 3), walk, Vector3(0, 0.1, -4.8))
	Kit.part(self, "box", Vector3(80, 0.2, 1.6), walk, Vector3(0, -0.1, 3.0))
	# ruined buildings
	var r := RandomNumberGenerator.new()
	r.seed = 21
	var x := -24.0
	while x < 26.0:
		var w := r.randf_range(3.5, 6.5)
		var h := r.randf_range(5.0, 11.0)
		var shade := r.randf_range(0.0, 0.05)
		var bm := Kit.toon(Color(0.2 + shade, 0.19 + shade, 0.25 + shade), Color(0.11, 0.1, 0.14), 0.03)
		var b := Kit.part(self, "box", Vector3(w, h, 3), bm, Vector3(x + w * 0.5, h * 0.5, -8))
		for wy in range(int(h / 1.4) - 1):
			for wx in range(int(w / 1.2)):
				var lit := r.randf() < 0.18
				var wm: Material = Kit.glow(Color(1, 0.8, 0.4)) if lit else Kit.toon(Color(0.08, 0.08, 0.12), Color(0.05, 0.05, 0.08), 0.0)
				Kit.part(b, "box", Vector3(0.5, 0.7, 0.05), wm, Vector3(-w * 0.5 + 0.7 + wx * 1.2, -h * 0.5 + 1.4 + wy * 1.4, 1.52))
		if r.randf() < 0.4:   # broken top
			Kit.part(b, "prism", Vector3(w * 0.6, 1.2, 3), bm, Vector3(r.randf_range(-1, 1), h * 0.5 + 0.6, 0), Vector3(0, 0, r.randf_range(-20, 20)))
		x += w + r.randf_range(0.2, 1.5)
	# street lamps, wrecked car with fire, barricade
	var pole := Kit.toon(Color(0.25, 0.26, 0.3), Color(0.12, 0.12, 0.15), 0.01)
	for lx in [-8.0, 4.0, 16.0]:
		Kit.part(self, "cyl", Vector3(0.07, 0.09, 5.0), pole, Vector3(lx, 2.5, -3.6))
		Kit.part(self, "box", Vector3(1.0, 0.1, 0.25), pole, Vector3(lx + 0.4, 5.0, -3.6))
		Kit.part(self, "box", Vector3(0.5, 0.06, 0.2), Kit.glow(Color(1, 0.9, 0.6)), Vector3(lx + 0.6, 4.94, -3.6))
		var cone: MeshInstance3D = Kit.part(self, "cyl", Vector3(0.25, 1.6, 4.9), Kit.glow(Color(1, 0.9, 0.6, 1)), Vector3(lx + 0.6, 2.5, -3.6))
		var cm := StandardMaterial3D.new()
		cm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cm.albedo_color = Color(1, 0.9, 0.6, 0.07)
		cone.material_override = cm
	var car := Kit.toon(Color(0.42, 0.18, 0.15), Color(0.22, 0.08, 0.07), 0.02)
	var c := Kit.part(self, "box", Vector3(3.6, 0.9, 1.7), car, Vector3(9.5, 0.65, -3.0), Vector3(0, 8, 6))
	Kit.part(c, "box", Vector3(2.0, 0.7, 1.6), car, Vector3(-0.2, 0.75, 0))
	for wx in [-1.2, 1.2]:
		Kit.part(c, "cyl", Vector3(0.35, 0.35, 1.8), Kit.toon(Color(0.08, 0.08, 0.08), Color(0.04, 0.04, 0.04), 0.0), Vector3(wx, -0.45, 0), Vector3(90, 0, 0))
	var bar := Kit.toon(Color(0.5, 0.38, 0.22), Color(0.28, 0.2, 0.1), 0.02)
	for i in 3:
		Kit.part(self, "box", Vector3(0.25, 0.9 + i * 0.1, 1.6), bar, Vector3(-5.5 + i * 0.12, 0.45, -2.6 + i * 0.3), Vector3(0, 0, -12 + i * 10))
	Kit.part(self, "box", Vector3(1.2, 0.5, 2.2), Kit.toon(Color(0.4, 0.38, 0.32), Color(0.22, 0.2, 0.16), 0.02), Vector3(-5.2, 0.25, -2.4))

func _waves() -> void:
	await get_tree().create_timer(0.8).timeout
	_banner("WAVE 1", Color(0.5, 1, 0.5), 1.6)
	Audio.play("growl", -2)
	wave = 1
	for i in 5:
		spawn_queue.append({"kind": "walk", "delay": 0.9 + i * 1.1})
	await get_tree().create_timer(16.0).timeout
	_banner("WAVE 2", Color(1, 0.4, 0.3), 1.6)
	Audio.play("scream", 0)
	wave = 2
	for i in 9:
		spawn_queue.append({"kind": ["walk", "run", "walk", "crawl", "run"][i % 5], "delay": 0.6 + i * 0.85})
	await get_tree().create_timer(19.0).timeout
	_banner("WAVE 3", Color(1, 0.2, 0.2), 1.6)
	Audio.play("scream", 0)
	wave = 3
	for i in 8:
		spawn_queue.append({"kind": ["run", "run", "walk", "crawl"][i % 4], "delay": 0.4 + i * 0.6})

func _banner(s: String, c: Color, d: float) -> void:
	banner_text = s
	banner_col = c
	banner_t = d

func _spawn(kind: String) -> void:
	var z := Z.new()
	z.kind = kind
	z.a = Actor.new()
	add_child(z.a)
	var skin := Color(0.45, 0.55, 0.38).lerp(Color(0.55, 0.5, 0.45), randf())
	z.a.setup(Kit.toon(skin, skin.darkened(0.55), 0.012), Kit.toon(Color(0.35, 0.12, 0.1), Color(0.18, 0.05, 0.04), 0.008), randf_range(0.95, 1.06))
	var eyes := Node3D.new()
	z.a.attach("mixamorig_Head", eyes)
	for sx in [-0.04, 0.04]:
		Kit.part(eyes, "sphere", Vector3(0.022, 0, 0), Kit.glow(Color(1, 0.9, 0.3)), Vector3(sx, 0.1, 0.1))
	z.x = px + 10.5 + randf_range(0, 1.5)
	z.a.yaw_target = -90
	z.a.yaw = -90
	match kind:
		"walk":
			z.hp = 7; z.speed = 0.95; z.a.play("z_walk", randf_range(0.9, 1.1), 0.0)
		"run":
			z.hp = 5; z.speed = 2.6; z.a.play("z_run", 1.0, 0.0)
		"crawl":
			z.hp = 5; z.speed = 1.3; z.a.play("z_crawl", 1.0, 0.0)
	z.state = kind
	z.a.position = Vector3(z.x, 0, randf_range(-0.6, 0.3))
	zombies.append(z)
	if randf() < 0.5:
		Audio.play("growl", -8)

func _physics_process(delta: float) -> void:
	t += delta
	banner_t -= delta
	hurt_flash = maxf(0.0, hurt_flash - delta)
	# spawning
	for s in spawn_queue:
		s.delay -= delta
	for s in spawn_queue.filter(func(q): return q.delay <= 0.0):
		_spawn(s.kind)
	spawn_queue = spawn_queue.filter(func(q): return q.delay > 0.0)
	_player(delta)
	_zombies(delta)
	_tracers(delta)
	# camera follows the soldier, looking ahead toward the threat
	var target := Vector3(px + 4.3, 2.4, 10.8)
	cam.position = cam.position.lerp(target, 1.0 - exp(-3.0 * delta))
	shake = maxf(0.0, shake - delta * 0.6)
	cam.h_offset = randf_range(-shake, shake)
	cam.v_offset = randf_range(-shake, shake)
	ui.queue_redraw()
	if not ended and wave == 3 and spawn_queue.is_empty() and zombies.filter(func(z): return z.state != "dead").is_empty():
		ended = true
		_banner("STREET CLEARED!", Color(0.5, 1, 0.5), 3.0)
		Audio.play("go")
		await get_tree().create_timer(3.5).timeout
		finished.emit()

func _player(delta: float) -> void:
	var near: Z = null
	for z in zombies:
		if z.state != "dead" and z.x > px and (near == null or z.x < near.x):
			near = z
	# retreat when something gets close, otherwise hold the line
	var retreat := near != null and near.x - px < 2.2 and px > -9.0
	if retreat:
		px -= 2.2 * delta
		player.play("r_back", 1.1, 0.15)
	else:
		player.play("r_aim", 1.0, 0.2)
	player.position = Vector3(px, 0, 0)
	# place the rifle in the hands, pointing from the right hand through the left
	var rh := player.bone_pos("mixamorig_RightHand")
	var lh := player.bone_pos("mixamorig_LeftHand")
	var dir := Vector3(1, 0, 0)
	var aim := (lh - rh)
	if aim.length() > 0.05:
		dir = aim.normalized().lerp(Vector3(1, 0, 0), 0.5).normalized()
	rifle.global_transform = Transform3D(Basis.looking_at(-dir, Vector3.UP), rh)
	flash_node.visible = false
	fire_cd -= delta
	if reload_t > 0.0:
		reload_t -= delta
		rifle.rotation_degrees.x += 25.0 * sin(reload_t * PI / 1.6)
		if reload_t <= 0.0:
			ammo = 30
		return
	if near != null and near.x - px < 8.3 and fire_cd <= 0.0:
		if ammo <= 0:
			reload_t = 1.6
			Audio.play("reload")
			return
		ammo -= 1
		fire_cd = 0.11 if burst < 5 else 0.45
		burst = 0 if burst >= 5 else burst + 1
		flash_node.visible = true
		flash_node.rotation.z = randf() * TAU
		Audio.play("gun", -4, 0.12)
		shake = maxf(shake, 0.035)
		var from := muzzle.global_position
		var hit_y := 0.35 if near.kind == "crawl" else randf_range(1.0, 1.55)
		var to := Vector3(near.x, hit_y, near.a.position.z)
		var hit := randf() < 0.85
		if not hit:
			to = Vector3(near.x + 6, hit_y + randf_range(-0.6, 0.6), 0)
		tracers.append({"from": from, "to": to, "life": 0.06})
		fx._add({"pos": _scr(from), "vel": Vector2(randf_range(-80, -20), randf_range(-260, -160)), "life": 0.5, "kind": "dot", "size": 3.0, "color": Color(1, 0.8, 0.3), "grav": 900.0, "drag": 0.98})
		if hit:
			_shoot(near, to)

func _shoot(z: Z, at: Vector3) -> void:
	z.hp -= 1
	z.a.flash = 0.06
	var s := _scr(at)
	for i in 6:
		fx._add({"pos": s, "vel": Vector2(randf_range(80, 420), randf_range(-260, 80)), "life": randf_range(0.3, 0.6), "kind": "dot", "size": randf_range(3, 6), "color": Color(0.35, 0.55, 0.12), "grav": 900.0, "drag": 0.96})
	if z.hp <= 0:
		z.state = "dead"
		z.st = 0.0
		z.dur = z.a.play("z_death" if z.kind != "crawl" else "z_dying", 1.3, 0.08, true)
		kills += 1
		Audio.play("splat", -2)
		fx.hit(s, Vector2(1, -0.2), true, Color(0.5, 0.75, 0.2))
	elif z.kind != "crawl" and randf() < 0.35 and z.state != "hit":
		z.state = "hit"
		z.st = 0.0
		z.dur = 0.5
		z.a.play("z_hit", 1.6, 0.06, true)
		z.x += 0.12

func _zombies(delta: float) -> void:
	for z in zombies:
		z.st += delta
		z.atk_cd -= delta
		match z.state:
			"walk", "run", "crawl":
				if z.x - px > 0.95:
					z.x -= z.speed * delta
				else:
					z.state = "attack"
					z.st = 0.0
					z.dur = z.a.play("z_attack", 1.4, 0.1, true)
			"hit":
				if z.st >= z.dur:
					z.state = z.kind
					z.a.play({"walk": "z_walk", "run": "z_run", "crawl": "z_crawl"}[z.kind], 1.0, 0.15)
			"attack":
				if z.st > z.dur * 0.5 and z.atk_cd <= 0.0 and absf(z.x - px) < 1.3:
					z.atk_cd = z.dur
					hp = maxf(5.0, hp - 8.0)
					hurt_flash = 0.3
					shake = 0.12
					Audio.play("hit_heavy", -4)
				if z.st >= z.dur:
					z.state = z.kind
					z.a.play({"walk": "z_walk", "run": "z_run", "crawl": "z_crawl"}[z.kind], 1.0, 0.15)
			"dead":
				if z.st > z.dur + 0.6:
					z.sink += delta * 0.5
					z.a.position.y = -z.sink
		if z.state != "dead" or z.sink == 0.0:
			z.a.position.x = z.x
	for z in zombies.filter(func(q): return q.sink > 1.0):
		z.a.queue_free()
	zombies = zombies.filter(func(q): return q.sink <= 1.0)

func _tracers(delta: float) -> void:
	for tr in tracers:
		tr.life -= delta
	tracers = tracers.filter(func(q): return q.life > 0.0)

func _scr(p: Vector3) -> Vector2:
	return cam.unproject_position(p)

func _draw_ui() -> void:
	var vs := ui.size
	for tr in tracers:
		ui.draw_line(_scr(tr.from), _scr(tr.to), Color(1, 0.9, 0.5, 0.9), 3.0)
	if hurt_flash > 0.0:
		ui.draw_rect(Rect2(Vector2.ZERO, vs), Color(0.8, 0, 0, hurt_flash * 0.6))
	# HUD
	var p := Vector2(28, 24)
	ui.draw_rect(Rect2(p, Vector2(330, 92)), Color(0.02, 0.03, 0.02, 0.75))
	ui.draw_rect(Rect2(p, Vector2(330, 92)), Color(0.4, 0.9, 0.4, 0.8), false, 2.0)
	ui.draw_string(font, p + Vector2(16, 32), "SGT. RAMIREZ", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.75, 1, 0.75))
	ui.draw_rect(Rect2(p + Vector2(16, 46), Vector2(298, 16)), Color(0.15, 0.05, 0.05))
	ui.draw_rect(Rect2(p + Vector2(16, 46), Vector2(298 * hp / 100.0, 16)), Color(0.85, 0.2, 0.15).lerp(Color(0.3, 0.9, 0.3), hp / 100.0))
	ui.draw_string(font, p + Vector2(16, 84), "AMMO  %02d / 30" % ammo if reload_t <= 0.0 else "RELOADING...", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1, 0.85, 0.4))
	var q := Vector2(vs.x - 250, 24)
	ui.draw_rect(Rect2(q, Vector2(222, 92)), Color(0.02, 0.03, 0.02, 0.75))
	ui.draw_rect(Rect2(q, Vector2(222, 92)), Color(0.9, 0.3, 0.3, 0.8), false, 2.0)
	ui.draw_string(font, q + Vector2(16, 38), "WAVE %d" % maxi(wave, 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1, 0.5, 0.4))
	ui.draw_string(font, q + Vector2(16, 76), "KILLS %d" % kills, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.85, 0.85, 0.8))
	ui.draw_string(font, Vector2(0, vs.y - 24), "DEAD ZONE  -  preview", HORIZONTAL_ALIGNMENT_CENTER, vs.x, 22, Color(0.6, 1, 0.6, 0.7))
	if banner_t > 0.0:
		for o in [Vector2(-6, 0), Vector2(6, 0), Vector2(0, -6), Vector2(0, 6)]:
			ui.draw_string(font, Vector2(0, vs.y * 0.42) + o, banner_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 120, Color(0.02, 0.02, 0.02))
		ui.draw_string(font, Vector2(0, vs.y * 0.42), banner_text, HORIZONTAL_ALIGNMENT_CENTER, vs.x, 120, banner_col)
