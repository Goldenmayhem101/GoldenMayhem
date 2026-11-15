## Concept still: the hooded Rogue holds a city street as skeletons pour out of the cemetery.
extends Node3D
var chars: Array = []
var police_r: OmniLight3D
var police_b: OmniLight3D
const C := 5.0   # city pieces are built small; scale them to character size

var cam: Camera3D

func setup() -> void:
	_env()
	_street()
	_cemetery()
	_actors()
	await get_tree().process_frame
	await get_tree().process_frame
	for c in chars:
		K.freeze(c)
	_shot_fx()

func _env() -> void:
	var env := WorldEnvironment.new(); var e := Environment.new()
	e.background_mode = Environment.BG_COLOR; e.background_color = Color(0.02, 0.025, 0.05)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color = Color(0.3, 0.35, 0.55); e.ambient_light_energy = 0.45
	e.tonemap_mode = Environment.TONE_MAPPER_ACES; e.tonemap_exposure = 1.15
	e.glow_enabled = true; e.glow_intensity = 0.6; e.glow_hdr_threshold = 1.0; e.glow_bloom = 0.03
	e.ssao_enabled = true; e.ssil_enabled = true; e.ssr_enabled = true
	e.volumetric_fog_enabled = true; e.volumetric_fog_density = 0.035; e.volumetric_fog_albedo = Color(0.55, 0.65, 0.85); e.volumetric_fog_emission = Color(0.02, 0.03, 0.05)
	env.environment = e; add_child(env)
	var moon := DirectionalLight3D.new(); moon.rotation_degrees = Vector3(-38, -35, 0); moon.light_color = Color(0.55, 0.65, 1.0); moon.light_energy = 0.7; moon.shadow_enabled = true; moon.directional_shadow_max_distance = 60; add_child(moon)
	cam = Camera3D.new(); cam.fov = 44; add_child(cam); cam.current = true
	cam.position = Vector3(-6.2, 2.0, 6.0)
	cam.look_at(Vector3(1.5, 1.4, -1.5), Vector3.UP)
	var ca := CameraAttributesPractical.new(); ca.dof_blur_far_enabled = true; ca.dof_blur_far_distance = 18; ca.dof_blur_far_transition = 10; ca.dof_blur_amount = 0.06; cam.attributes = ca

func _street() -> void:
	# road along X, sidewalk + buildings on the far side
	for i in range(-4, 6):
		K.place(self, "city/road_straight" if i != 1 else "city/road_straight_crossing", Vector3(i * 2 * C, 0, 0), 90, C)
		K.place(self, "city/base", Vector3(i * 2 * C, 0, -2 * C), 0, C)
		K.place(self, "city/base", Vector3(i * 2 * C, 0, 2 * C), 0, C)
	var bl := ["building_D", "building_G", "building_B", "building_F", "building_H", "building_E", "building_C", "building_A"]
	for i in range(-4, 1):
		K.place(self, "city/" + bl[(i + 8) % 8], Vector3(i * 2 * C, 0, -2 * C), 0, C)
	# street furniture
	for lx in [-12.0, 0.0, 13.0, 25.0]:
		K.place(self, "city/streetlight", Vector3(lx, 0, -5.3), 180, C)
		K.spot(self, Vector3(lx + 1.1, 4.6, -5.0), Vector3(lx + 1.6, 0, -2.5), Color(1, 0.72, 0.42), 14, 42, 9)
		var bulb := MeshInstance3D.new(); var sm := SphereMesh.new(); sm.radius = 0.12; sm.height = 0.24; bulb.mesh = sm; bulb.material_override = K.glow_mat(Color(1, 0.8, 0.5), 8); bulb.position = Vector3(lx + 1.1, 4.62, -5.15); add_child(bulb)
	var pc := K.place(self, "city/car_police", Vector3(7.5, 0, -1.2), 128, C)
	pc.rotation_degrees.z = 4
	police_r = K.omni(self, Vector3(7.3, 2.4, -1.4), Color(1, 0.1, 0.1), 6, 7)
	police_b = K.omni(self, Vector3(8.1, 2.4, -0.7), Color(0.15, 0.3, 1), 6, 7)
	K.place(self, "city/car_taxi", Vector3(-8.0, 0, -3.6), 82, C)
	K.place(self, "city/dumpster", Vector3(-3.0, 0, -5.6), 0, C)
	K.place(self, "city/trash_A", Vector3(-1.4, 0, -5.4), 20, C)
	K.place(self, "city/trash_B", Vector3(-4.6, 0, -4.4), -40, C)
	K.place(self, "city/firehydrant", Vector3(3.4, 0, -5.4), 0, C)
	K.place(self, "city/box_A", Vector3(-2.2, 0, -4.4), 30, C)

func _cemetery() -> void:
	# a fenced graveyard opens up on the far side to the right
	for i in 5:
		K.place(self, "hall/fence" if i != 2 else "hall/fence_gate", Vector3(4 + i * 4.0, 0, -6.2), 0)
		K.place(self, "hall/fence_pillar", Vector3(2 + i * 4.0, 0, -6.2), 0)
	var dirt := 0
	for gx in 4:
		for gz in 3:
			K.place(self, "hall/floor_dirt", Vector3(6 + gx * 4.0, 0.0, -9 - gz * 4.0), 0)
	var stones := ["gravestone", "grave_A", "grave_B", "gravemarker_A", "gravemarker_B", "grave_A_destroyed"]
	var r := RandomNumberGenerator.new(); r.seed = 8
	for k in 14:
		K.place(self, "hall/" + stones[k % 6], Vector3(5.5 + (k % 5) * 3.2 + r.randf_range(-0.5, 0.5), 0, -8.5 - (k / 5) * 3.0 + r.randf_range(-0.4, 0.4)), r.randf_range(-12, 12))
	K.place(self, "hall/crypt", Vector3(16, 0, -16), -10)
	K.place(self, "hall/tree_dead_large", Vector3(9, 0, -11), 30, 1.3)
	K.place(self, "hall/tree_dead_large_decorated", Vector3(21, 0, -10), -60, 1.2)
	for lp in [Vector3(4.6, 0, -6.9), Vector3(12.6, 0, -6.9), Vector3(20.6, 0, -6.9)]:
		K.place(self, "hall/lantern_standing", lp, 0)
		K.omni(self, lp + Vector3(0, 0.75, 0), Color(1, 0.55, 0.2), 3.5, 5)
	for pp in [Vector3(6.2, 0, -7.2), Vector3(13.8, 0, -7.4), Vector3(18.5, 0, -7.1)]:
		K.place(self, "hall/pumpkin_orange_jackolantern", pp, randf_range(-30, 30))
		K.omni(self, pp + Vector3(0, 0.3, 0.2), Color(1, 0.5, 0.1), 1.6, 2.5)
	K.place(self, "hall/skull_candle", Vector3(2.5, 0, -5.6), 0)
	K.place(self, "hall/ribcage", Vector3(1.0, 0, 0.8), 40)
	K.place(self, "hall/bone_A", Vector3(-1.5, 0, 1.6), 10)
	K.place(self, "hall/bone_B", Vector3(2.8, 0, 1.2), 70)
	K.omni(self, Vector3(16, 3, -13), Color(0.3, 1.0, 0.5), 5, 9)   # eerie green glow from the crypt

func _actors() -> void:
	# survivor
	var rogue := K.char(self, "Rogue_Hooded", Vector3(-4.2, 0, 1.0), 75, "2H_Ranged_Shooting", 0.35)
	for m in ["Knife_Offhand", "1H_Crossbow", "Knife", "Throwable"]:
		var mi := K.mesh(rogue, m)
		if mi: mi.visible = false
	chars.append(rogue)
	# the horde
	var who := ["Skeleton_Minion", "Skeleton_Warrior", "Skeleton_Rogue", "Skeleton_Minion", "Skeleton_Mage", "Skeleton_Warrior", "Skeleton_Minion", "Skeleton_Rogue"]
	var spots := [
		[Vector3(1.4, 0, 0.6), -100, "Running_C", 0.2], [Vector3(3.2, 0, -1.6), -95, "Walking_D_Skeletons", 0.4],
		[Vector3(4.6, 0, 1.3), -110, "Walking_D_Skeletons", 0.75], [Vector3(6.4, 0, -0.2), -90, "Running_C", 0.6],
		[Vector3(9.8, 0, 0.9), -100, "Walking_D_Skeletons", 0.1], [Vector3(11.6, 0, -2.0), -85, "Walking_D_Skeletons", 0.55],
		[Vector3(8.6, 0, -9.0), 160, "Spawn_Ground_Skeletons", 0.55], [Vector3(14.2, 0, -10.5), -150, "Skeletons_Awaken_Floor", 0.7]]
	for i in spots.size():
		var s = spots[i]
		var sk := K.char(self, who[i], s[0], s[1], s[2], s[3])
		var eyes := K.mesh(sk, who[i] + "_Eyes")
		if eyes:
			eyes.material_override = K.glow_mat(Color(0.35, 1.0, 0.6), 6)
		chars.append(sk)
	# lead skeleton is taking the hit
	var lead: Node3D = chars[1]
	lead.set_meta("anim", "Hit_A"); lead.get_meta("ap").play("Hit_A"); lead.set_meta("at", 0.25)

func _shot_fx() -> void:
	var rogue: Node3D = chars[0]
	var bow := K.mesh(rogue, "2H_Crossbow")
	var from: Vector3 = bow.global_transform * (bow.get_aabb().get_center() + Vector3(0, 0, bow.get_aabb().size.z * 0.5))
	var lead: Node3D = chars[1]
	var to := lead.global_position + Vector3(0, 1.3, 0)
	# glowing bolt in flight with a light trail
	var bolt := K.place(self, "items/arrow", from.lerp(to, 0.55), 0, 1.0)
	bolt.look_at(to, Vector3.UP)
	bolt.rotate_object_local(Vector3.RIGHT, -PI / 2)
	var trail := MeshInstance3D.new(); var bm := BoxMesh.new(); bm.size = Vector3(0.025, 0.025, from.distance_to(to) * 0.5); trail.mesh = bm
	trail.material_override = K.glow_mat(Color(1, 0.8, 0.45), 5)
	add_child(trail); trail.global_position = from.lerp(to, 0.3); trail.look_at(to, Vector3.UP)
	K.omni(self, from.lerp(to, 0.5), Color(1, 0.8, 0.45), 2, 3)
	# bone splinters where the previous bolt struck
	var p := GPUParticles3D.new(); p.amount = 50; p.lifetime = 0.5; p.preprocess = 0.08; p.explosiveness = 1.0
	var pm := ParticleProcessMaterial.new(); pm.direction = Vector3(1, 0.4, 0); pm.spread = 70; pm.initial_velocity_min = 2; pm.initial_velocity_max = 5; pm.gravity = Vector3(0, -9, 0)
	p.process_material = pm
	var cm := BoxMesh.new(); cm.size = Vector3(0.04, 0.02, 0.02); var bmat := StandardMaterial3D.new(); bmat.albedo_color = Color(0.92, 0.88, 0.78); cm.material = bmat; p.draw_pass_1 = cm
	p.position = to; add_child(p)
