## Offline baker: retargets animations from any humanoid GLB (CMU mocap, KinemIQ/Quaternius) onto the
## Mixamo X Bot skeleton and saves them as plain Animation resources in res://anim/.
## Run:  godot --headless -- --demo=bake --manifest=/abs/path/manifest.json
## Manifest: [{"glb": "/abs/x.glb", "map": "cmu"|"kq", "ref": "tpose"|"", "out": "key", "t0": 0, "t1": 99, "auto": "", "loop": false}]
## "auto": "hands" / "feet" / "all" cuts the clip into single strikes around each speed peak (out_1, out_2, ...).
extends Node3D
signal finished

const MAPS := {
	"cmu": {"Hips": "Hips", "LowerBack": "Spine", "Spine": "Spine1", "Spine1": "Spine2", "Neck": "Neck", "Head": "Head",
		"LeftShoulder": "LeftShoulder", "LeftArm": "LeftArm", "LeftForeArm": "LeftForeArm", "LeftHand": "LeftHand",
		"RightShoulder": "RightShoulder", "RightArm": "RightArm", "RightForeArm": "RightForeArm", "RightHand": "RightHand",
		"LeftUpLeg": "LeftUpLeg", "LeftLeg": "LeftLeg", "LeftFoot": "LeftFoot", "LeftToeBase": "LeftToeBase",
		"RightUpLeg": "RightUpLeg", "RightLeg": "RightLeg", "RightFoot": "RightFoot", "RightToeBase": "RightToeBase"},
	"kq": {"pelvis": "Hips", "spine_01": "Spine", "spine_02": "Spine1", "spine_03": "Spine2", "neck_01": "Neck", "Head": "Head",
		"clavicle_l": "LeftShoulder", "upperarm_l": "LeftArm", "lowerarm_l": "LeftForeArm", "hand_l": "LeftHand",
		"clavicle_r": "RightShoulder", "upperarm_r": "RightArm", "lowerarm_r": "RightForeArm", "hand_r": "RightHand",
		"thigh_l": "LeftUpLeg", "calf_l": "LeftLeg", "foot_l": "LeftFoot", "ball_l": "LeftToeBase",
		"thigh_r": "RightUpLeg", "calf_r": "RightLeg", "foot_r": "RightFoot", "ball_r": "RightToeBase"},
}
# limb chains used to line up rest directions (A-pose vs T-pose etc.)
const CHAIN := {"LeftArm": "LeftForeArm", "LeftForeArm": "LeftHand", "RightArm": "RightForeArm", "RightForeArm": "RightHand",
	"LeftUpLeg": "LeftLeg", "LeftLeg": "LeftFoot", "RightUpLeg": "RightLeg", "RightLeg": "RightFoot",
	"LeftFoot": "LeftToeBase", "RightFoot": "RightToeBase", "LeftShoulder": "LeftArm", "RightShoulder": "RightArm",
	"Spine": "Spine1", "Spine1": "Spine2", "Spine2": "Neck", "Neck": "Head"}
const FPS := 30.0

var xb: Node3D
var dsk: Skeleton3D
var prefix := ""

func setup(_d: bool) -> void:
	var mpath := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--manifest="):
			mpath = a.split("=")[1]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://anim"))
	xb = load("res://a/xbot.fbx").instantiate(); add_child(xb)
	dsk = xb.find_children("*", "Skeleton3D", true, false)[0]
	var ref_anim: Animation = Kit.lib.get_animation("f_idle")
	for i in ref_anim.get_track_count():
		var p := str(ref_anim.track_get_path(i))
		if p.ends_with("mixamorig_Hips"):
			prefix = p.substr(0, p.length() - "mixamorig_Hips".length())
			break
	var jobs = JSON.parse_string(FileAccess.get_file_as_string(mpath))
	var n := 0
	for j in jobs:
		n += _job(j)
	print("BAKED ", n, " animations")
	await get_tree().process_frame
	finished.emit()

func _job(j: Dictionary) -> int:
	var doc := GLTFDocument.new(); var st := GLTFState.new()
	if doc.append_from_file(j["glb"], st) != OK:
		push_error("cannot read " + j["glb"]); return 0
	var src: Node3D = doc.generate_scene(st); add_child(src)
	var ssk: Skeleton3D = src.find_children("*", "Skeleton3D", true, false)[0]
	var aps := src.find_children("*", "AnimationPlayer", true, false)
	print("  anims in file: ", st.get_animations().size(), " players: ", aps.size(), " nodes: ", src.get_child_count())
	if aps.is_empty():
		src.queue_free(); return 0
	var sap: AnimationPlayer = aps[0]
	sap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	var clip: String = j.get("anim", "")
	if clip == "":
		for a in sap.get_animation_list():
			if a != "tpose" and a != "RESET":
				clip = a
	var map: Dictionary = MAPS[j["map"]]
	# --- reference pose of the source
	if j.get("ref", "") != "":
		sap.play(j["ref"]); sap.seek(0.0, true)
	else:
		ssk.reset_bone_poses()
	var g := _globals(ssk)
	var sref := {}; var spos := {}
	var dst_of := {}
	for k in map:
		var si := ssk.find_bone(k); var di := dsk.find_bone("mixamorig_" + map[k])
		if si < 0 or di < 0:
			continue
		dst_of[di] = si
		sref[si] = (ssk.global_basis * (g[si] as Transform3D).basis).orthonormalized()
		spos[map[k]] = ssk.global_transform * (g[si] as Transform3D).origin
	# facing alignment: map source left->right hip axis onto the target's
	var dpos := {}
	for i in dsk.get_bone_count():
		dpos[dsk.get_bone_name(i).trim_prefix("mixamorig_")] = dsk.global_transform * dsk.get_bone_global_rest(i).origin
	var s_lr: Vector3 = (spos["RightUpLeg"] - spos["LeftUpLeg"]); s_lr.y = 0
	var d_lr: Vector3 = (dpos["RightUpLeg"] - dpos["LeftUpLeg"]); d_lr.y = 0
	var face := Basis(Quaternion(s_lr.normalized(), d_lr.normalized()))
	var drest := {}
	for i in dsk.get_bone_count():
		drest[i] = (dsk.global_basis * dsk.get_bone_global_rest(i).basis).orthonormalized()
	for k in CHAIN:
		if not spos.has(k) or not spos.has(CHAIN[k]):
			continue
		var sd: Vector3 = face * (spos[CHAIN[k]] - spos[k]).normalized()
		var di := dsk.find_bone("mixamorig_" + k)
		var dd: Vector3 = (dpos[CHAIN[k]] - dpos[k]).normalized()
		if sd.length() < 0.5 or dd.length() < 0.5:
			continue
		drest[di] = (Basis(Quaternion(dd, sd)) * (drest[di] as Basis)).orthonormalized()
	var hs := ssk.find_bone([map.keys()[0]][0])
	var hd := dsk.find_bone("mixamorig_Hips")
	var s_h0: Vector3 = spos["Hips"]
	var ratio: float = (dpos["Hips"].y - dsk.global_position.y) / maxf(s_h0.y - ssk.global_position.y, 0.01)
	# --- sample the clip
	sap.play(clip); sap.seek(0.0, true)
	var length := sap.get_animation(clip).length
	var t0: float = j.get("t0", 0.0); var t1: float = minf(j.get("t1", 1e9), length)
	var sk_inv := dsk.global_basis.orthonormalized().inverse()
	var frames: Array = []   # each: {rots: {di: Quaternion}, hip: Vector3, fx: {name: Vector3}}
	var t := t0
	while t <= t1 + 0.0001:
		sap.seek(t, true)
		g = _globals(ssk)
		var out := {}; var rots := {}
		for i in dsk.get_bone_count():
			var parent := dsk.get_bone_parent(i)
			var pb: Basis = out[parent] if parent >= 0 else Basis.IDENTITY
			var want: Basis
			if dst_of.has(i):
				var si: int = dst_of[i]
				var sw: Basis = (ssk.global_basis * (g[si] as Transform3D).basis).orthonormalized()
				var dw: Basis = face * (sw * (sref[si] as Basis).inverse()) * face.inverse()
				want = sk_inv * (dw * drest[i])
			else:
				want = pb * dsk.get_bone_rest(i).basis.orthonormalized()
			out[i] = want
			if dst_of.has(i):
				rots[i] = (pb.inverse() * want).orthonormalized().get_rotation_quaternion()
		var hw: Vector3 = ssk.global_transform * (g[hs] as Transform3D).origin
		var off: Vector3 = face * (hw - s_h0) * ratio
		var fx := {}
		for nm in ["LeftHand", "RightHand", "LeftFoot", "RightFoot"]:
			var b := ssk.find_bone(_src_name(map, nm))
			fx[nm] = ssk.global_transform * (g[b] as Transform3D).origin - hw
		frames.append({"rots": rots, "hip": off, "fx": fx})
		t += 1.0 / FPS
	src.queue_free()
	# --- write one or many animations
	var segs: Array = []
	var mode: String = j.get("auto", "")
	if mode == "":
		segs.append([0, frames.size() - 1, j["out"]])
	else:
		segs = _segments(frames, mode, j["out"], j.get("max", 12))
	for s in segs:
		var a := _anim(frames, s[0], s[1], hd, j.get("loop", false), j.get("keep_travel", false))
		ResourceSaver.save(a, "res://anim/" + s[2] + ".res")
		print("  ", s[2], "  ", snappedf(a.length, 0.01), "s")
	return segs.size()

func _src_name(map: Dictionary, dst: String) -> String:
	for k in map:
		if map[k] == dst:
			return k
	return ""

func _globals(sk: Skeleton3D) -> Dictionary:
	var g := {}
	for i in sk.get_bone_count():
		var p := sk.get_bone_parent(i)
		var l := sk.get_bone_pose(i)
		g[i] = (g[p] as Transform3D) * l if p >= 0 else l
	return g

## find strike peaks (end-effector speed relative to hips) and cut a window around each
func _segments(frames: Array, mode: String, base: String, maxn: int) -> Array:
	var names: Array = {"hands": ["LeftHand", "RightHand"], "feet": ["LeftFoot", "RightFoot"]}.get(mode, ["LeftHand", "RightHand", "LeftFoot", "RightFoot"])
	var spd: Array = [0.0]
	for f in range(1, frames.size()):
		var best := 0.0
		for nm in names:
			best = maxf(best, (frames[f]["fx"][nm] - frames[f - 1]["fx"][nm]).length() * FPS)
		spd.append(best)
	var peaks: Array = []
	var f := 6
	while f < frames.size() - 6:
		var is_peak: bool = spd[f] > 3.2
		for d in range(-6, 7):
			if spd[f + d] > spd[f]:
				is_peak = false
		if is_peak:
			peaks.append(f); f += 12
		else:
			f += 1
	var segs: Array = []
	var k := 1
	for p in peaks:
		var a: int = maxi(0, p - 14); var b: int = mini(frames.size() - 1, p + 16)
		segs.append([a, b, "%s_%d" % [base, k]]); k += 1
		if k > maxn:
			break
	return segs

func _anim(frames: Array, a: int, b: int, hd: int, loop: bool, keep_travel: bool) -> Animation:
	var an := Animation.new()
	an.length = (b - a) / FPS
	an.loop_mode = Animation.LOOP_LINEAR if loop else Animation.LOOP_NONE
	var tracks := {}
	for i in frames[a]["rots"]:
		var ti := an.add_track(Animation.TYPE_ROTATION_3D)
		an.track_set_path(ti, NodePath(prefix + dsk.get_bone_name(i)))
		tracks[i] = ti
	var pt := an.add_track(Animation.TYPE_POSITION_3D)
	an.track_set_path(pt, NodePath(prefix + "mixamorig_Hips"))
	var rest := dsk.get_bone_rest(hd).origin
	var inv := dsk.global_transform.affine_inverse().basis
	var h0: Vector3 = frames[a]["hip"]
	# face forward: cancel the hips' heading at the first frame
	var rq := dsk.get_bone_rest(hd).basis.get_rotation_quaternion()
	var fb := Basis(frames[a]["rots"][hd] * rq.inverse())
	var fz := fb.z; fz.y = 0.0
	var fix := Quaternion(Vector3.UP, -atan2(fz.x, fz.z)) if fz.length() > 0.1 else Quaternion.IDENTITY
	for f in range(a, b + 1):
		var tt := (f - a) / FPS
		for i in tracks:
			var q: Quaternion = frames[f]["rots"][i]
			if i == hd:
				q = fix * q
			an.rotation_track_insert_key(tracks[i], tt, q)
		var off: Vector3 = frames[f]["hip"]
		if not keep_travel:
			off = Vector3(h0.x, off.y, h0.z)   # in-place, like the Mixamo set
		an.position_track_insert_key(pt, tt, rest + inv * (Basis(fix) * off))
	return an
