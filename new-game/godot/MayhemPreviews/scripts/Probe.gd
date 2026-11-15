## Prints length and the moment of fastest hand/foot travel for each animation (--anims=a,b,...)
extends Node3D
signal finished
func setup(_d: bool) -> void:
	var names: PackedStringArray = []
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--anims="):
			names = a.split("=")[1].split(",")
	var act := Actor.new(); add_child(act)
	act.setup(Kit.pbr(Color.RED, 0, 0.5), Kit.pbr(Color.BLACK, 0, 0.5))
	act.ap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	await get_tree().process_frame
	for n in names:
		act.ap.play("m/" + n, 0.0); act.ap.seek(0.0, true)
		var L: float = Kit.lengths[n]
		var prev := {}
		var best := 0.0; var bt := 0.0; var bb := ""
		var t := 0.0
		while t <= L:
			act.ap.seek(t, true)
			var hp := act.bone_pos("mixamorig_Hips")
			for b in ["mixamorig_RightHand", "mixamorig_LeftHand", "mixamorig_RightFoot", "mixamorig_LeftFoot"]:
				var p := act.bone_pos(b) - hp
				if prev.has(b) and t > 0.1:
					var s: float = (p - prev[b]).length() * 30.0
					if s > best:
						best = s; bt = t; bb = b
				prev[b] = p
			t += 1.0 / 30.0
		print("PROBE %s len=%.2f peak=%.2f frac=%.2f by=%s" % [n, L, bt, bt / L, bb.trim_prefix("mixamorig_")])
	finished.emit()
