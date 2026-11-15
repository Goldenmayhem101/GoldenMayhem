## Side by side: current robot proportions vs stocky proportions, same KayKit moves.
extends Node3D
signal finished
const STOCKY := {
	"mixamorig_UpLeg": null,
	"mixamorig_LeftUpLeg": Vector3(1.25, 0.78, 1.25), "mixamorig_RightUpLeg": Vector3(1.25, 0.78, 1.25),
	"mixamorig_LeftLeg": Vector3(1.2, 0.8, 1.2), "mixamorig_RightLeg": Vector3(1.2, 0.8, 1.2),
	"mixamorig_LeftArm": Vector3(1.3, 0.82, 1.3), "mixamorig_RightArm": Vector3(1.3, 0.82, 1.3),
	"mixamorig_LeftForeArm": Vector3(1.2, 0.85, 1.2), "mixamorig_RightForeArm": Vector3(1.2, 0.85, 1.2),
	"mixamorig_LeftHand": Vector3(1.35, 1.35, 1.35), "mixamorig_RightHand": Vector3(1.35, 1.35, 1.35),
	"mixamorig_Spine1": Vector3(1.25, 1.0, 1.2), "mixamorig_Spine2": Vector3(1.2, 1.0, 1.15),
	"mixamorig_Head": Vector3(1.45, 1.45, 1.45),
}
var rows: Array = []
func setup(_d: bool) -> void:
	var env := WorldEnvironment.new(); var e := Environment.new()
	e.background_mode = Environment.BG_COLOR; e.background_color = Color(0.16, 0.17, 0.24)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color = Color(0.6, 0.62, 0.72); e.ambient_light_energy = 1.0
	e.tonemap_mode = Environment.TONE_MAPPER_ACES; e.glow_enabled = true; e.glow_intensity = 0.5; e.glow_hdr_threshold = 1.2
	e.ssao_enabled = true
	env.environment = e; add_child(env)
	var key := DirectionalLight3D.new(); key.rotation_degrees = Vector3(-45, 30, 0); key.light_energy = 2.2; key.shadow_enabled = true; add_child(key)
	for c in [[Vector3(-6, 3, 3), Color(1, 0.3, 0.6)], [Vector3(6, 3, 3), Color(0.3, 0.8, 1)]]:
		var o := OmniLight3D.new(); o.position = c[0]; o.light_color = c[1]; o.light_energy = 2.5; o.omni_range = 12; add_child(o)
	var cam := Camera3D.new(); cam.fov = 34; cam.position = Vector3(0, 1.3, 8.6); add_child(cam); cam.current = true; cam.look_at(Vector3(0, 0.9, 0))
	Kit.part(self, "box", Vector3(30, 1, 10), Kit.pbr(Color(0.3, 0.31, 0.36), 0.3, 0.35), Vector3(0, -0.5, -1))
	var moves := [["Unarmed_Melee_Attack_Punch_A", 0.32], ["1H_Melee_Attack_Slice_Diagonal", 0.4], ["Block", 0.5]]
	for side in 2:
		for k in 3:
			var a := Actor.new(); add_child(a)
			a.setup(Kit.pbr(Color(0.72, 0.07, 0.05), 0.9, 0.22), Kit.pbr(Color(0.08, 0.08, 0.1), 0.9, 0.3, Color(1, 0.4, 0.08), 0.5))
			a.position = Vector3(-3.9 + k * 3.0 + side * 1.25, 0, 0)
			a.yaw_target = 40; a.yaw = 40
			var visor := Node3D.new(); a.attach("mixamorig_Head", visor)
			Kit.part(visor, "box", Vector3(0.18, 0.045, 0.06), Kit.pbr(Color.WHITE, 0, 0.3, Color(1, 0.5, 0.15), 5.0), Vector3(0, 0.1, 0.1))
			if k == 1:
				var sword := Node3D.new(); a.attach("mixamorig_RightHand", sword)
				Kit.part(sword, "box", Vector3(0.045, 0.9, 0.012), Kit.pbr(Color(0.7, 0.95, 1), 0.5, 0.1, Color(0.3, 0.9, 1), 5.0), Vector3(0, 0.55, 0.03))
			if k == 2:
				var sh := Node3D.new(); a.attach("mixamorig_LeftForeArm", sh)
				Kit.part(sh, "cyl", Vector3(0.3, 0.3, 0.05), Kit.pbr(Color(0.1, 0.3, 0.75), 1.0, 0.2, Color(0.2, 0.6, 1), 0.6), Vector3(0, 0.18, -0.08), Vector3(90, 0, 0))
			if side == 1:
				var s2 := STOCKY.duplicate(); s2.erase("mixamorig_UpLeg")
				a.set_shape(s2)
			rows.append([a, moves[k]])
			var lab := Label3D.new(); lab.text = "NOW" if side == 0 else "STOCKY"; lab.font_size = 70; lab.outline_size = 8
			lab.modulate = Color(1, 0.85, 0.4) if side == 1 else Color(0.85, 0.9, 1); lab.position = a.position + Vector3(0, 2.1, 0); add_child(lab)
	await get_tree().process_frame
	for r in rows:
		var a: Actor = r[0]
		var rt := Retarget.new(); add_child(rt); rt.setup(a)
		rt.play(r[1][0], 1.0)
		rt.weight = 1.0; rt.fade = 1.0
		rt.step(rt.sap.get_animation(r[1][0]).length * r[1][1])
		rt.fade = 1.0; rt.step(0.0)
		a.apply_shape()
		a.ground_lock()
		a.ground_lock()
		a.set_meta("rt", rt)
	set_process(true)
	for r in rows:
		print("HEIGHT ", (r[0] as Actor).bone_pos("mixamorig_HeadTop_End").y, " shape ", (r[0] as Actor).shape.size())
func _process(_d: float) -> void:
	for r in rows:
		var a: Actor = r[0]
		a.ap.stop()
		(a.get_meta("rt") as Retarget).step(0.0)
		a.apply_shape()
		a.ground_lock()
