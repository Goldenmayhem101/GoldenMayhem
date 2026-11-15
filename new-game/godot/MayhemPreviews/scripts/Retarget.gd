## Drives a Mixamo body with KayKit game animations (live retargeting by world-space rotation deltas).
class_name Retarget
extends Node

const MAP := {
	"hips": "mixamorig_Hips", "spine": "mixamorig_Spine", "chest": "mixamorig_Spine2", "head": "mixamorig_Head",
	"upperarm.l": "mixamorig_LeftArm", "lowerarm.l": "mixamorig_LeftForeArm", "hand.l": "mixamorig_LeftHand",
	"upperarm.r": "mixamorig_RightArm", "lowerarm.r": "mixamorig_RightForeArm", "hand.r": "mixamorig_RightHand",
	"upperleg.l": "mixamorig_LeftUpLeg", "lowerleg.l": "mixamorig_LeftLeg", "foot.l": "mixamorig_LeftFoot", "toes.l": "mixamorig_LeftToeBase",
	"upperleg.r": "mixamorig_RightUpLeg", "lowerleg.r": "mixamorig_RightLeg", "foot.r": "mixamorig_RightFoot", "toes.r": "mixamorig_RightToeBase",
}

var actor: Actor
var src: Node3D
var ssk: Skeleton3D
var sap: AnimationPlayer
var dsk: Skeleton3D
var ref := {}          # source bone idx -> world basis at T-Pose
var dst_of := {}       # target bone idx -> source bone idx
var dst_rest_w := {}   # target bone idx -> world basis at rest
var hips_s := -1
var hips_d := -1
var src_hips_ref := Vector3.ZERO
var ratio := 1.0
var adduct := 34.0
const ADDUCT_BY := {"Block": 58.0, "Block_Hit": 58.0, "Block_Attack": 48.0, "Blocking": 58.0, "Unarmed_Melee_Attack_Punch_A": 26.0, "Unarmed_Melee_Attack_Punch_B": 26.0, "Spellcast_Shoot": 22.0, "Cheer": 10.0, "Taunt": 30.0, "1H_Melee_Attack_Slice_Diagonal": 28.0, "1H_Melee_Attack_Slice_Horizontal": 26.0, "1H_Melee_Attack_Stab": 30.0, "Unarmed_Melee_Attack_Kick": 30.0, "Hit_A": 40.0, "Hit_B": 40.0, "Running_A": 44.0, "Dodge_Backward": 40.0, "Lie_StandUp": 30.0}
var la := -1
var ra := -1
var active := false
var weight := 0.0
var speed := 1.0
var cur := ""
var fade := 1.0
const FADE_T := 0.12

func setup(a: Actor) -> void:
	actor = a
	src = load("res://kk/Skeleton_Warrior.glb").instantiate()
	a.model.add_child(src)
	for m in src.find_children("*", "MeshInstance3D", true, false):
		m.visible = false
	ssk = src.find_children("*", "Skeleton3D", true, false)[0]
	sap = src.find_children("*", "AnimationPlayer", true, false)[0]
	sap.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	dsk = a.sk
	# reference T-pose of the source
	sap.play("T-Pose")
	sap.advance(0.0)
	_recalc()
	for k in MAP:
		var si := ssk.find_bone(k)
		var di := dsk.find_bone(MAP[k])
		if si < 0 or di < 0:
			continue
		dst_of[di] = si
		ref[si] = _sw(si)
	# rest pose of the target (Mixamo rest is a T-pose)
	for i in dsk.get_bone_count():
		dst_rest_w[i] = (dsk.global_basis * dsk.get_bone_global_rest(i).basis).orthonormalized()
	# align each target limb's rest direction to the source's reference direction
	var CH := {"upperarm.l": "lowerarm.l", "lowerarm.l": "hand.l", "upperarm.r": "lowerarm.r", "lowerarm.r": "hand.r",
		"upperleg.l": "lowerleg.l", "lowerleg.l": "foot.l", "upperleg.r": "lowerleg.r", "lowerleg.r": "foot.r", "foot.l": "toes.l", "foot.r": "toes.r",
		"spine": "chest", "chest": "head"}
	for k in CH:
		var si := ssk.find_bone(k); var sc := ssk.find_bone(CH[k])
		var di := dsk.find_bone(MAP[k]); var dc := dsk.find_bone(MAP[CH[k]])
		var sd := (_sp(sc) - _sp(si)).normalized()
		var dd := (dsk.global_transform * dsk.get_bone_global_rest(dc).origin - dsk.global_transform * dsk.get_bone_global_rest(di).origin).normalized()
		if sd.length() < 0.5 or dd.length() < 0.5:
			continue
		var align := Basis(Quaternion(dd, sd))
		dst_rest_w[di] = (align * (dst_rest_w[di] as Basis)).orthonormalized()
	la = dsk.find_bone("mixamorig_LeftArm")
	ra = dsk.find_bone("mixamorig_RightArm")
	hips_s = ssk.find_bone("hips")
	hips_d = dsk.find_bone("mixamorig_Hips")
	src_hips_ref = (_g[hips_s] as Transform3D).origin
	var dh := (dsk.global_transform * dsk.get_bone_global_rest(hips_d).origin).y - dsk.global_position.y
	var sh := _sp(hips_s).y - ssk.global_position.y
	ratio = dh / maxf(sh, 0.01)

var _g := {}
func _recalc() -> void:
	_g.clear()
	for i in ssk.get_bone_count():
		var p := ssk.get_bone_parent(i)
		var l := ssk.get_bone_pose(i)
		_g[i] = (_g[p] as Transform3D) * l if p >= 0 else l

func _sw(si: int) -> Basis:
	return (ssk.global_basis * (_g[si] as Transform3D).basis).orthonormalized()

func _sp(si: int) -> Vector3:
	return ssk.global_transform * (_g[si] as Transform3D).origin

func play(anim: String, spd := 1.0, restart := true) -> float:
	active = true
	speed = spd
	if cur != anim or restart:
		cur = anim
		sap.play(anim, 0.0)
		sap.seek(0.0, true)
		fade = 0.0
	actor.ap.stop()
	return sap.get_animation(anim).length / spd

func release() -> void:
	active = false

func step(delta: float) -> void:
	weight = move_toward(weight, 1.0 if active else 0.0, delta * 10.0)
	if weight <= 0.0:
		return
	sap.advance(delta * speed)
	fade = minf(1.0, fade + delta / FADE_T)
	_recalc()
	var sk_inv := dsk.global_basis.orthonormalized().inverse()
	var out := {}   # target idx -> skeleton-space basis
	for i in dsk.get_bone_count():
		var parent := dsk.get_bone_parent(i)
		var parent_b: Basis = out[parent] if parent >= 0 else Basis.IDENTITY
		var want: Basis
		if dst_of.has(i):
			var si: int = dst_of[i]
			var delta_w: Basis = _sw(si) * (ref[si] as Basis).inverse()
			if i == la or i == ra:
				var fwd := actor.model.global_basis.z.normalized()
				delta_w = Basis(fwd, deg_to_rad(ADDUCT_BY.get(cur, adduct)) * (-1.0 if i == la else 1.0)) * delta_w
			want = sk_inv * (delta_w * dst_rest_w[i])
		else:
			want = parent_b * dsk.get_bone_rest(i).basis.orthonormalized()
		out[i] = want
		var local := (parent_b.inverse() * want).orthonormalized()
		var q := local.get_rotation_quaternion()
		var w := minf(weight, fade)
		if w < 1.0:
			q = dsk.get_bone_pose_rotation(i).slerp(q, w)
		dsk.set_bone_pose_rotation(i, q)
	# hips travel (bob, lunges, crouches) scaled to the target's size
	var off := ssk.global_basis * ((_g[hips_s] as Transform3D).origin - src_hips_ref) * ratio
	var rest := dsk.get_bone_rest(hips_d).origin
	var loc := dsk.global_transform.affine_inverse().basis * off
	dsk.set_bone_pose_position(hips_d, dsk.get_bone_pose_position(hips_d).lerp(rest + loc, minf(weight, fade)))
