extends Node3D
signal finished
var rts: Array = []
func setup(_d: bool) -> void:
	var env := WorldEnvironment.new(); var e := Environment.new(); e.background_mode = Environment.BG_COLOR; e.background_color = Color(0.85, 0.85, 0.88)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color = Color(0.6, 0.6, 0.6); env.environment = e; add_child(env)
	var l := DirectionalLight3D.new(); l.rotation_degrees = Vector3(-40, 30, 0); add_child(l)
	var cam := Camera3D.new(); cam.position = Vector3(0, 1.1, 9); cam.fov = 40; add_child(cam); cam.current = true
	var poses := [["Idle", 0.3], ["1H_Melee_Attack_Slice_Diagonal", 0.45], ["Unarmed_Melee_Attack_Punch_A", 0.5], ["Block", 0.6], ["Spellcast_Shoot", 0.5], ["Unarmed_Melee_Attack_Kick", 0.5]]
	for i in poses.size():
		var a := Actor.new(); add_child(a)
		a.setup(Kit.pbr(Color(0.8, 0.2, 0.15), 0.5, 0.4), Kit.pbr(Color(0.2, 0.2, 0.2), 0.5, 0.4))
		a.position = Vector3(-6.25 + i * 2.5, 0, 0); a.yaw_target = 30; a.yaw = 30
		var r := Retarget.new(); add_child(r)
		await get_tree().process_frame
		r.setup(a)
		r.play(poses[i][0], 1.0)
		r.set_meta("t", poses[i][1] * r.sap.get_animation(poses[i][0]).length)
		rts.append(r)
		var src := load("res://kk/Skeleton_Warrior.glb").instantiate() as Node3D
		add_child(src); src.position = a.position + Vector3(0, 0, -2.5); src.rotation_degrees.y = 30
		var ap: AnimationPlayer = src.find_children("*", "AnimationPlayer", true, false)[0]
		ap.play(poses[i][0]); ap.seek(r.get_meta("t"), true); ap.pause()
	await get_tree().process_frame
	for r in rts:
		r.weight = 1.0
		r.fade = 1.0
		r.step(r.get_meta("t"))
		r.fade = 1.0
		r.step(0.0)
