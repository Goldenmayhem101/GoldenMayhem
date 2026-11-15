## A Mixamo X Bot that can play any animation in the shared library, with custom materials and props.
class_name Actor
extends Node3D

var model: Node3D
var sk: Skeleton3D
var ap: AnimationPlayer
var surf: MeshInstance3D
var joints: MeshInstance3D
var cur := ""
var mats: Array = []
var yaw := 90.0
var yaw_target := 90.0
var flash := 0.0
var spd := 1.0

func setup(surface_mat: Material, joint_mat: Material, size := 1.0) -> void:
	model = load("res://a/xbot.fbx").instantiate()
	add_child(model)
	model.scale = Vector3.ONE * size
	sk = model.find_children("*", "Skeleton3D", true, false)[0]
	for m in model.find_children("*", "MeshInstance3D", true, false):
		if "Joint" in m.name:
			joints = m
		else:
			surf = m
	surf.material_override = surface_mat
	joints.material_override = joint_mat
	mats = [surface_mat, joint_mat]
	ap = model.find_children("*", "AnimationPlayer", true, false)[0]
	ap.add_animation_library("m", Kit.library())
	play("f_idle")

func play(n: String, speed := 1.0, blend := 0.15, restart := false) -> float:
	var full := "m/" + n
	spd = speed
	if cur == n and not restart:
		ap.speed_scale = speed
		return Kit.lengths.get(n, 1.0)
	cur = n
	ap.play(full, blend, 1.0)
	ap.speed_scale = speed
	if restart:
		ap.seek(0.0, true)
	return Kit.lengths.get(n, 1.0) / maxf(speed, 0.01)

func attach(bone: String, node: Node3D) -> Node3D:
	var ba := BoneAttachment3D.new()
	ba.bone_name = bone
	sk.add_child(ba)
	ba.add_child(node)
	return node

func bone_pos(bone: String) -> Vector3:
	var i := sk.find_bone(bone)
	return sk.global_transform * sk.get_bone_global_pose(i).origin

func _process(delta: float) -> void:
	yaw = lerp_angle(deg_to_rad(yaw), deg_to_rad(yaw_target), 1.0 - exp(-12.0 * delta)) * 180.0 / PI
	model.rotation_degrees.y = yaw
	flash = maxf(0.0, flash - delta)
	for m in mats:
		if m is ShaderMaterial:
			m.set_shader_parameter("flash", 0.8 if flash > 0.0 else 0.0)

## ground lock: never let any part of the body go below the floor (y = 0)
const GROUND_BONES := ["mixamorig_Hips", "mixamorig_Head", "mixamorig_HeadTop_End", "mixamorig_Spine2", "mixamorig_LeftFoot", "mixamorig_RightFoot",
	"mixamorig_LeftToe_End", "mixamorig_RightToe_End", "mixamorig_LeftHand", "mixamorig_RightHand", "mixamorig_LeftForeArm", "mixamorig_RightForeArm", "mixamorig_LeftLeg", "mixamorig_RightLeg"]
var lift := 0.0
func ground_lock(floor_y := 0.0, margin := 0.07) -> void:
	sk.force_update_all_bone_transforms()
	var lo := 99.0
	for bn in GROUND_BONES:
		var i := sk.find_bone(bn)
		if i >= 0:
			lo = minf(lo, (sk.global_transform * sk.get_bone_global_pose(i).origin).y)
	lift = clampf(lift + (floor_y + margin - lo), -1.0, 1.5)
	model.position.y = lift

## body shape: scale bones along their length/width; children get the inverse so only this segment changes
var shape := {}
func set_shape(sh: Dictionary) -> void:
	shape = sh
func apply_shape() -> void:
	for bn in shape:
		var i := sk.find_bone(bn)
		if i < 0:
			continue
		var sc: Vector3 = shape[bn]
		sk.set_bone_pose_scale(i, sc)
		for c in sk.get_bone_children(i):
			if not shape.has(sk.get_bone_name(c)):
				sk.set_bone_pose_scale(c, Vector3(1.0 / sc.x, 1.0 / sc.y, 1.0 / sc.z))
