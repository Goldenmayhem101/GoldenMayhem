## Cut-out puppet: builds a fighter from the separately cut body parts and blends between poses.
class_name Rig
extends Node2D

var pivots := {}        # part name -> pivot Node2D
var tips := {}          # part name -> Node2D marker at the fist / foot
var target := {}        # part name -> target rotation (radians)
var body_off := Vector2.ZERO
var body_off_target := Vector2.ZERO
var blend_speed := 18.0
var height_world := 150.0
var k := 1.0            # texture px -> world units

const ORDER := ["body", "arm_b_up", "arm_f_up", "leg_b_up", "leg_f_up", "tail", "arm_b_lo", "arm_f_lo", "leg_b_lo", "leg_f_lo"]

func build(id: String) -> void:
	var data: Dictionary = Chars.rig()[id]
	var extra: Dictionary = Chars.DATA[id]
	var s: float = data.scale
	var P: Dictionary = data.parts
	var ground: float = data.ground_y
	var foot_a: Array = extra.tips.leg_f_lo
	var foot_b: Array = extra.tips.leg_b_lo
	var origin := Vector2((foot_a[0] + foot_b[0]) * 0.5, ground)
	var hip := Vector2(extra.hip[0], extra.hip[1])
	var top: float = P.body.origin[1]
	k = height_world / ((ground - top) * s)
	scale = Vector2(k, k)
	var piv_src := {}
	for name in ORDER:
		if not P.has(name):
			continue
		var p: Dictionary = P[name]
		var pv := hip if name == "body" else Vector2(p.pivot[0], p.pivot[1])
		piv_src[name] = pv
		var node := Node2D.new()
		node.name = name
		var parent_node: Node2D = self
		var parent_pv := origin
		if p.parent != null:
			parent_node = pivots[p.parent]
			parent_pv = piv_src[p.parent]
		node.position = (pv - parent_pv) * s
		parent_node.add_child(node)
		var z: int = int(p.z)
		if name.ends_with("_lo"):
			node.z_index = 1 if name.begins_with("arm_f") else 0
		else:
			node.z_index = z
		var spr := Sprite2D.new()
		spr.texture = load("res://art/" + p.file)
		spr.centered = false
		spr.position = (Vector2(p.origin[0], p.origin[1]) - pv) * s
		node.add_child(spr)
		pivots[name] = node
		target[name] = 0.0
		if extra.tips.has(name):
			var t := Node2D.new()
			var tp: Array = extra.tips[name]
			t.position = (Vector2(tp[0], tp[1]) - pv) * s
			node.add_child(t)
			tips[name] = t

## pose: dictionary of part -> degrees, plus "body" (lean) and "y" (body bob in world units)
func pose(p: Dictionary, speed: float = 18.0) -> void:
	blend_speed = speed
	for n in target.keys():
		target[n] = deg_to_rad(p.get(n, 0.0))
	body_off_target = Vector2(p.get("x", 0.0), p.get("y", 0.0)) / k

func snap() -> void:
	for n in target.keys():
		pivots[n].rotation = target[n]
	body_off = body_off_target

func _process(delta: float) -> void:
	var a := 1.0 - exp(-blend_speed * delta)
	for n in target.keys():
		var nd: Node2D = pivots[n]
		nd.rotation = lerp_angle(nd.rotation, target[n], a)
	body_off = body_off.lerp(body_off_target, a)
	if pivots.has("body"):
		pivots.body.position = _body_base + body_off

var _body_base := Vector2.ZERO
func _ready() -> void:
	if pivots.has("body"):
		_body_base = pivots.body.position

func tip_global(part: String) -> Vector2:
	return tips[part].global_position if tips.has(part) else global_position
