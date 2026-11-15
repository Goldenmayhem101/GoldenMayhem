## 10-second gameplay clip: skeletons rise and charge, the Rogue fires, reloads and shatters them.
extends "res://scripts/Shot.gd"

var rogue: Node3D
var rap: AnimationPlayer
var bow: MeshInstance3D
var foes: Array = []
var bolts: Array = []
var t := 0.0
var fire_cd := 1.2
var shots := 0
var reloading := 0.0
var cam_from := Vector3(-8.5, 2.8, 8.5)
var cam_to := Vector3(-6.6, 2.15, 6.4)

class Foe:
	var n: Node3D
	var ap: AnimationPlayer
	var hp := 2
	var speed := 1.2
	var state := "walk"
	var st := 0.0
	var walk_anim := "Walking_D_Skeletons"
	var delay := 0.0

func setup() -> void:
	_env()
	_street()
	_cemetery()
	Audio.loop("music_dark", -8)
	Audio.play("scream", -6)
	rogue = K.char(self, "Rogue_Hooded", Vector3(-4.2, 0, 1.0), 75, "2H_Ranged_Aiming")
	for m in ["Knife_Offhand", "1H_Crossbow", "Knife", "Throwable"]:
		var mi := K.mesh(rogue, m)
		if mi: mi.visible = false
	rap = rogue.get_meta("ap")
	bow = K.mesh(rogue, "2H_Crossbow")
	var plan := [
		["Skeleton_Minion", Vector3(5.5, 0, 0.6), "Running_C", 2.4, 0.0, 2],
		["Skeleton_Warrior", Vector3(7.5, 0, -1.4), "Walking_D_Skeletons", 1.3, 0.0, 3],
		["Skeleton_Rogue", Vector3(9.5, 0, 1.4), "Walking_D_Skeletons", 1.4, 0.4, 2],
		["Skeleton_Minion", Vector3(13.0, 0, -0.2), "Running_C", 2.6, 1.6, 2],
		["Skeleton_Mage", Vector3(14.5, 0, 0.9), "Walking_D_Skeletons", 1.2, 0.8, 2],
		["Skeleton_Warrior", Vector3(16.0, 0, -1.8), "Walking_D_Skeletons", 1.3, 2.4, 3],
		["Skeleton_Minion", Vector3(8.4, 0, -8.6), "", 0.0, 0.5, 9],
		["Skeleton_Rogue", Vector3(13.8, 0, -10.2), "", 0.0, 1.5, 9]]
	for p in plan:
		var f := Foe.new()
		f.n = K.char(self, p[0], p[1], -95 + randf_range(-8, 8), "Idle")
		f.ap = f.n.get_meta("ap")
		var eyes := K.mesh(f.n, p[0] + "_Eyes")
		if eyes: eyes.material_override = K.glow_mat(Color(0.35, 1.0, 0.6), 6)
		f.walk_anim = p[2]
		f.speed = p[3]
		f.delay = p[4]
		f.hp = p[5]
		if p[2] == "":
			f.state = "rise"
			f.n.rotation_degrees.y = 170
			f.ap.play("Skeletons_Inactive_Floor_Pose")
		else:
			f.ap.play(p[2])
			f.ap.seek(randf() * 0.8, true)
		foes.append(f)
	cam.position = cam_from

func _physics_process(delta: float) -> void:
	if rogue == null:
		return
	t += delta
	# slow dolly-in
	var k := smoothstep(0.0, 6.0, t)
	cam.position = cam_from.lerp(cam_to, k)
	cam.look_at(Vector3(1.5 + k * 0.3, 1.35, -1.5), Vector3.UP)
	# police lights alternate
	var ph := fmod(t * 3.0, 1.0) < 0.5
	police_r.light_energy = 7.0 if ph else 0.6
	police_b.light_energy = 0.6 if ph else 7.0
	# skeletons
	for f in foes:
		f.st += delta
		if f.delay > 0.0:
			f.delay -= delta
			if f.state != "rise":
				f.ap.speed_scale = 0.0 if f.delay > 0.0 else 1.0
			continue
		f.ap.speed_scale = 1.0
		match f.state:
			"rise":
				f.state = "rising"; f.st = 0.0
				f.ap.play("Spawn_Ground_Skeletons")
				Audio.play("growl", -10)
			"rising":
				if f.st > f.ap.current_animation_length:
					f.state = "taunt"; f.st = 0.0
					f.ap.play("Taunt")
			"walk":
				var dir: Vector3 = (rogue.position - f.n.position)
				dir.y = 0
				if dir.length() > 1.6:
					f.n.position += dir.normalized() * f.speed * delta
					f.n.rotation.y = atan2(dir.x, dir.z)
				else:
					f.state = "attack"; f.st = 0.0
					f.ap.play("1H_Melee_Attack_Chop")
			"hit":
				if f.st > 0.45:
					f.state = "walk"; f.ap.play(f.walk_anim)
			"attack":
				if f.st > 1.0:
					f.st = 0.0; f.ap.play("1H_Melee_Attack_Chop")
	# the Rogue: aim, shoot, reload
	var target: Foe = _target()
	if target:
		var d: Vector3 = target.n.position - rogue.position
		rogue.rotation.y = lerp_angle(rogue.rotation.y, atan2(d.x, d.z), 1.0 - exp(-8.0 * delta))
	if reloading > 0.0:
		reloading -= delta
		if reloading <= 0.0:
			rap.play("2H_Ranged_Aiming", 0.15)
	else:
		fire_cd -= delta
		if fire_cd <= 0.0 and target:
			_fire(target)
	# bolts in flight
	for b in bolts:
		b.t += delta
		var p: Vector3 = b.from.lerp(b.to, minf(b.t / b.dur, 1.0))
		b.node.global_position = p
		b.trail.global_position = b.from.lerp(p, 0.6)
		b.trail.scale.z = maxf(0.05, b.from.distance_to(p) * 0.6)
		if b.t >= b.dur:
			_impact(b.foe, b.to)
			b.node.queue_free(); b.trail.queue_free(); b.light.queue_free()
	bolts = bolts.filter(func(b): return b.t < b.dur)
	if t > 10.6:
		get_tree().quit()

func _target() -> Foe:
	var best: Foe = null
	for f in foes:
		if f.state in ["walk", "hit", "attack"] and f.delay <= 0.0 and f.hp > 0:
			if best == null or f.n.position.distance_to(rogue.position) < best.n.position.distance_to(rogue.position):
				best = f
	return best

func _fire(f: Foe) -> void:
	shots += 1
	fire_cd = 0.62
	rap.play("2H_Ranged_Shoot", 0.05)
	rap.seek(0.0, true)
	Audio.play("whoosh", -2)
	Audio.play("kickball", -6)
	var from: Vector3 = bow.global_transform * (bow.get_aabb().get_center() + Vector3(0, 0, bow.get_aabb().size.z * 0.5))
	var to: Vector3 = f.n.global_position + Vector3(0, 1.2, 0)
	var node := K.place(self, "items/arrow", from, 0, 1.0)
	node.look_at(to, Vector3.UP); node.rotate_object_local(Vector3.RIGHT, -PI / 2)
	var trail := MeshInstance3D.new(); var bm := BoxMesh.new(); bm.size = Vector3(0.025, 0.025, 1.0); trail.mesh = bm
	trail.material_override = K.glow_mat(Color(1, 0.8, 0.45), 5); add_child(trail)
	trail.global_position = from; trail.look_at(to, Vector3.UP)
	var light := K.omni(self, Vector3.ZERO, Color(1, 0.8, 0.45), 2.0, 3.0)
	node.add_child(light.duplicate()); light.queue_free()
	bolts.append({"node": node, "trail": trail, "light": node.get_child(node.get_child_count() - 1), "from": from, "to": to, "t": 0.0, "dur": from.distance_to(to) / 28.0, "foe": f})
	if shots % 5 == 0:
		reloading = 1.2
		get_tree().create_timer(0.25).timeout.connect(func():
			rap.play("2H_Ranged_Reload", 0.1)
			Audio.play("reload"))

func _impact(f: Foe, at: Vector3) -> void:
	f.hp -= 1
	_bones(at, 30 if f.hp > 0 else 70)
	Audio.play("hit_light" if f.hp > 0 else "hit_heavy", -2)
	if f.hp > 0:
		f.state = "hit"; f.st = 0.0
		f.ap.play("Hit_A"); f.ap.seek(0.0, true)
		f.n.position.x += 0.25
	else:
		f.state = "dead"; f.st = 0.0
		f.ap.play("Death_C_Skeletons")
		Audio.play("splat", -4)

func _bones(at: Vector3, n: int) -> void:
	var p := GPUParticles3D.new(); p.amount = n; p.lifetime = 0.9; p.one_shot = true; p.explosiveness = 1.0
	var pm := ParticleProcessMaterial.new(); pm.direction = Vector3(1, 0.6, 0); pm.spread = 75; pm.initial_velocity_min = 2; pm.initial_velocity_max = 5.5; pm.gravity = Vector3(0, -12, 0)
	pm.angular_velocity_min = -720; pm.angular_velocity_max = 720
	p.process_material = pm
	var cm := BoxMesh.new(); cm.size = Vector3(0.05, 0.025, 0.025); var bmat := StandardMaterial3D.new(); bmat.albedo_color = Color(0.92, 0.88, 0.78); cm.material = bmat; p.draw_pass_1 = cm
	p.position = at; add_child(p); p.emitting = true
	var fl := K.omni(self, at, Color(0.5, 1, 0.6), 3.0, 2.5)
	get_tree().create_timer(0.12).timeout.connect(fl.queue_free)
