## Builds the comic materials and dresses a fighter's body with its species features and warrior kit.
class_name Look

const INK := Color(0.12, 0.07, 0.04)
static var _toon: Shader
static var _outline: Shader

static func toon(base: Color, shade: Color, pattern := 0, pattern_color := Color.BLACK, pattern_scale := 14.0, outline_w := 0.012) -> ShaderMaterial:
	if _toon == null:
		_toon = load("res://shaders/toon.gdshader")
		_outline = load("res://shaders/outline.gdshader")
	var m := ShaderMaterial.new()
	m.shader = _toon
	m.set_shader_parameter("base_color", Vector3(base.r, base.g, base.b))
	m.set_shader_parameter("shade_color", Vector3(shade.r, shade.g, shade.b))
	m.set_shader_parameter("deep_color", Vector3(shade.r * 0.7, shade.g * 0.6, shade.b * 0.6))
	m.set_shader_parameter("pattern", pattern)
	m.set_shader_parameter("pattern_color", Vector3(pattern_color.r, pattern_color.g, pattern_color.b))
	m.set_shader_parameter("pattern_scale", pattern_scale)
	if outline_w > 0.0:
		var o := ShaderMaterial.new()
		o.shader = _outline
		o.set_shader_parameter("width", outline_w)
		o.set_shader_parameter("ink", Vector3(INK.r, INK.g, INK.b))
		m.next_pass = o
	return m

static func mesh(kind: String, a: float, b: float = 0.0, c: float = 0.0) -> Mesh:
	match kind:
		"sphere":
			var s := SphereMesh.new(); s.radius = a; s.height = a * 2.0 if b == 0.0 else b; s.radial_segments = 20; s.rings = 10; return s
		"capsule":
			var cp := CapsuleMesh.new(); cp.radius = a; cp.height = b; cp.radial_segments = 16; cp.rings = 6; return cp
		"cyl":
			var cy := CylinderMesh.new(); cy.top_radius = a; cy.bottom_radius = b; cy.height = c; cy.radial_segments = 20; return cy
		"box":
			var bx := BoxMesh.new(); bx.size = Vector3(a, b, c); return bx
		"prism":
			var pr := PrismMesh.new(); pr.size = Vector3(a, b, c); return pr
		"torus":
			var t := TorusMesh.new(); t.inner_radius = a; t.outer_radius = b; t.rings = 24; t.ring_segments = 8; return t
	return null

## place a mesh on a bone; offset/rotation are given in model space at the fighting stance
static func attach(f, bone: String, m: Mesh, mat: ShaderMaterial, offset: Vector3, rot := Vector3.ZERO, scl := Vector3.ONE) -> MeshInstance3D:
	var sk: Skeleton3D = f.sk
	var idx: int = f.bones[bone]
	var bg := sk.get_bone_global_pose(idx)
	var ba := BoneAttachment3D.new()
	ba.bone_name = bone
	sk.add_child(ba)
	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.material_override = mat
	var desired := Transform3D(Basis.from_euler(rot * (PI / 180.0)).scaled(scl), bg.origin + offset)
	mi.transform = bg.affine_inverse() * desired
	ba.add_child(mi)
	return mi

static func along(f, bone: String, from_b: String, to_b: String, t: float, m: Mesh, mat: ShaderMaterial) -> void:
	# a cylinder aligned along a limb segment (bracers)
	var sk: Skeleton3D = f.sk
	var a := sk.get_bone_global_pose(f.bones[from_b]).origin
	var b := sk.get_bone_global_pose(f.bones[to_b]).origin
	var dir := (b - a).normalized()
	var x := dir.cross(Vector3.FORWARD).normalized()
	if x.length() < 0.1:
		x = dir.cross(Vector3.UP).normalized()
	var basis := Basis(x, dir, x.cross(dir))
	var bg := sk.get_bone_global_pose(f.bones[bone])
	var ba := BoneAttachment3D.new()
	ba.bone_name = bone
	sk.add_child(ba)
	var mi := MeshInstance3D.new()
	mi.mesh = m
	mi.material_override = mat
	mi.transform = bg.affine_inverse() * Transform3D(basis, a.lerp(b, t))
	ba.add_child(mi)

static func dress(f) -> void:
	var L: Dictionary = f.look
	var sk: Skeleton3D = f.sk
	sk.force_update_all_bone_transforms()
	var bronze := toon(Color(0.83, 0.6, 0.3), Color(0.5, 0.3, 0.14), 0, Color.BLACK, 14.0, 0.008)
	var leather := toon(L.leather, L.leather.darkened(0.45), 3, L.leather.darkened(0.3), 60.0, 0.008)
	var dark := toon(L.leather.darkened(0.35), L.leather.darkened(0.6), 0, Color.BLACK, 14.0, 0.006)
	var fur := toon(L.skin, L.shade, 0, Color.BLACK, 14.0, 0.008)
	var muzzle := toon(L.muzzle, L.muzzle.darkened(0.5), 0, Color.BLACK, 14.0, 0.008)
	var ink := toon(Color(0.08, 0.05, 0.03), Color(0.05, 0.03, 0.02), 0, Color.BLACK, 14.0, 0.0)
	var eye := toon(Color(1.0, 0.82, 0.25), Color(0.8, 0.55, 0.1), 0, Color.BLACK, 14.0, 0.004)
	for m in [bronze, leather, dark, fur, muzzle]:
		f.mats.append(m)
	# --- warrior kit shared by every Animal Warrior (from the reference sheets)
	attach(f, "upperarm.l", mesh("sphere", 0.12, 0.17), bronze, Vector3(0.05, 0.04, 0.0), Vector3(0, 0, -25), Vector3(1.0, 1.0, 1.1))
	attach(f, "upperarm.l", mesh("sphere", 0.03), bronze, Vector3(0.1, 0.11, 0.06))
	attach(f, "spine_02", mesh("torus", 0.17, 0.205), leather, Vector3(0.0, 0.08, -0.01), Vector3(0, 0, 38), Vector3(1.0, 1.0, 0.75))
	attach(f, "spine_02", mesh("box", 0.06, 0.05, 0.03), bronze, Vector3(0.06, 0.14, 0.13), Vector3(0, 0, 38))
	attach(f, "pelvis", mesh("torus", 0.15, 0.2), leather, Vector3(0.0, 0.08, -0.02), Vector3.ZERO, Vector3(1.0, 1.4, 0.85))
	attach(f, "pelvis", mesh("cyl", 0.06, 0.06, 0.02), bronze, Vector3(0.0, 0.08, 0.15), Vector3(90, 0, 0))
	attach(f, "pelvis", mesh("cyl", 0.19, 0.26, 0.28), leather, Vector3(0.0, -0.09, -0.02), Vector3.ZERO, Vector3(1.0, 1.0, 0.8))
	attach(f, "pelvis", mesh("box", 0.11, 0.3, 0.02), dark, Vector3(0.0, -0.12, 0.17), Vector3(-6, 0, 0))
	for side in ["l", "r"]:
		along(f, "lowerarm." + side, "lowerarm." + side, "hand." + side, 0.62, mesh("cyl", 0.058, 0.05, 0.15), leather)
	# --- head: muzzle, nose, eyes, brows, ears
	attach(f, "head", mesh("capsule", L.snout_r, L.snout_len + L.snout_r * 2.0), muzzle, Vector3(0, 0.06, 0.1 + L.snout_len * 0.5), Vector3(90 - L.snout_tilt, 0, 0))
	attach(f, "head", mesh("capsule", L.snout_r * 0.8, L.snout_len * 0.8), muzzle, Vector3(0, 0.0, 0.08 + L.snout_len * 0.45), Vector3(96, 0, 0))
	attach(f, "head", mesh("sphere", 0.036), ink, Vector3(0, 0.06 + L.snout_len * 0.12, 0.12 + L.snout_len + L.snout_r * 0.6))
	for sx in [-1.0, 1.0]:
		attach(f, "head", mesh("sphere", 0.024), eye, Vector3(sx * 0.055, 0.15, 0.1))
		attach(f, "head", mesh("sphere", 0.012), ink, Vector3(sx * 0.058, 0.15, 0.121))
		attach(f, "head", mesh("box", 0.07, 0.016, 0.03), ink, Vector3(sx * 0.055, 0.178, 0.105), Vector3(0, 0, -sx * 18))
		attach(f, "head", mesh("capsule", L.ear_r, L.ear_len), fur, Vector3(sx * L.ear_x, 0.17 + L.ear_len * 0.4, -0.01), Vector3(-10, 0, -sx * L.ear_tilt))
	# --- species extras
	if L.has("mane"):
		var mane := toon(L.mane, L.mane.darkened(0.5), 0, Color.BLACK, 14.0, 0.006)
		f.mats.append(mane)
		var spots := [[Vector3(0, 0.24, -0.02), -40.0], [Vector3(0, 0.2, -0.09), -65.0], [Vector3(0, 0.12, -0.12), -80.0]]
		for s in spots:
			attach(f, "head", mesh("prism", 0.05, 0.12, 0.08), mane, s[0], Vector3(s[1], 0, 0))
		attach(f, "neck_01", mesh("prism", 0.05, 0.12, 0.08), mane, Vector3(0, 0.02, -0.1), Vector3(-90, 0, 0))
		attach(f, "spine_02", mesh("prism", 0.05, 0.1, 0.07), mane, Vector3(0, 0.12, -0.14), Vector3(-100, 0, 0))
	if L.has("tail"):
		var bga := sk.get_bone_global_pose(f.bones["pelvis"])
		var ba := BoneAttachment3D.new()
		ba.bone_name = "pelvis"
		sk.add_child(ba)
		var root := Node3D.new()
		root.transform = bga.affine_inverse() * Transform3D(Basis.IDENTITY, bga.origin + Vector3(0, -0.04, -0.12))
		ba.add_child(root)
		var parent: Node3D = root
		var radii := [0.075, 0.065, 0.05, 0.035, 0.025]
		var angles := [-38.0, -14.0, -8.0, -4.0, 6.0]
		for k in radii.size():
			var j := Node3D.new()
			j.rotation_degrees.x = angles[k]
			j.set_meta("base_x", angles[k])
			parent.add_child(j)
			var seg := MeshInstance3D.new()
			seg.mesh = mesh("capsule", radii[k], 0.26)
			seg.material_override = fur
			seg.rotation_degrees.x = 90
			seg.position = Vector3(0, 0, -0.11)
			j.add_child(seg)
			var nxt := Node3D.new()
			nxt.position = Vector3(0, 0, -0.2)
			j.add_child(nxt)
			parent = nxt
			f.tail_nodes.append(j)
	# --- the axe (hidden until picked up): haft + blade, held in the right fist
	var steel := toon(Color(0.78, 0.8, 0.82), Color(0.42, 0.44, 0.48), 0, Color.BLACK, 14.0, 0.006)
	var haft := toon(Color(0.45, 0.28, 0.15), Color(0.25, 0.14, 0.07), 3, Color(0.3, 0.18, 0.08), 90.0, 0.006)
	var hb := sk.get_bone_global_pose(f.bones["hand.r"])
	var hba := BoneAttachment3D.new()
	hba.bone_name = "hand.r"
	sk.add_child(hba)
	var axe := Node3D.new()
	axe.transform = hb.affine_inverse() * Transform3D(Basis.from_euler(Vector3(deg_to_rad(20), 0, 0)), hb.origin)
	hba.add_child(axe)
	var h := MeshInstance3D.new(); h.mesh = mesh("cyl", 0.025, 0.028, 0.85); h.material_override = haft; h.position = Vector3(0, 0.18, 0); axe.add_child(h)
	var bl := MeshInstance3D.new(); bl.mesh = mesh("prism", 0.3, 0.26, 0.035); bl.material_override = steel; bl.position = Vector3(0, 0.5, 0.13); bl.rotation_degrees = Vector3(-90, 0, 0); axe.add_child(bl)
	var cap := MeshInstance3D.new(); cap.mesh = mesh("box", 0.07, 0.12, 0.08); cap.material_override = steel; cap.position = Vector3(0, 0.55, -0.02); axe.add_child(cap)
	var tip := Node3D.new(); tip.position = Vector3(0, 0.5, 0.2); tip.name = "AxeTip"; axe.add_child(tip)
	axe.visible = false
	f.set_meta("axe", axe)
	f.set_meta("axe_tip", tip)

## a standalone axe for drops and throws
static func axe_prop() -> Node3D:
	var steel := toon(Color(0.78, 0.8, 0.82), Color(0.42, 0.44, 0.48), 0, Color.BLACK, 14.0, 0.006)
	var haft := toon(Color(0.45, 0.28, 0.15), Color(0.25, 0.14, 0.07), 3, Color(0.3, 0.18, 0.08), 90.0, 0.006)
	var axe := Node3D.new()
	var h := MeshInstance3D.new(); h.mesh = mesh("cyl", 0.025, 0.028, 0.85); h.material_override = haft; axe.add_child(h)
	var bl := MeshInstance3D.new(); bl.mesh = mesh("prism", 0.3, 0.26, 0.035); bl.material_override = steel; bl.position = Vector3(0.13, 0.32, 0); bl.rotation_degrees = Vector3(0, 0, -90); axe.add_child(bl)
	var cap := MeshInstance3D.new(); cap.mesh = mesh("box", 0.08, 0.12, 0.07); cap.material_override = steel; cap.position = Vector3(-0.02, 0.37, 0); axe.add_child(cap)
	return axe

static func potion_prop() -> Node3D:
	var glass := toon(Color(0.9, 0.2, 0.18), Color(0.5, 0.06, 0.05), 0, Color.BLACK, 14.0, 0.006)
	var cork := toon(Color(0.7, 0.5, 0.3), Color(0.4, 0.26, 0.14), 0, Color.BLACK, 14.0, 0.005)
	var p := Node3D.new()
	var b := MeshInstance3D.new(); b.mesh = mesh("sphere", 0.13); b.material_override = glass; b.position.y = 0.13; p.add_child(b)
	var n := MeshInstance3D.new(); n.mesh = mesh("cyl", 0.04, 0.05, 0.1); n.material_override = glass; n.position.y = 0.28; p.add_child(n)
	var c := MeshInstance3D.new(); c.mesh = mesh("cyl", 0.045, 0.04, 0.06); c.material_override = cork; c.position.y = 0.35; p.add_child(c)
	return p

const LOOKS := {
	"hyena": {"skin": Color(0.86, 0.62, 0.3), "shade": Color(0.55, 0.36, 0.2), "pattern": 1, "pattern_color": Color(0.33, 0.2, 0.1), "pattern_scale": 22.0,
		"muzzle": Color(0.32, 0.24, 0.17), "snout_r": 0.06, "snout_len": 0.17, "snout_tilt": 6.0, "leather": Color(0.47, 0.3, 0.17),
		"ear_r": 0.05, "ear_len": 0.12, "ear_x": 0.085, "ear_tilt": 24.0, "mane": Color(0.3, 0.18, 0.1)},
	"kangaroo": {"skin": Color(0.8, 0.42, 0.22), "shade": Color(0.5, 0.24, 0.12), "pattern": 0,
		"muzzle": Color(0.88, 0.62, 0.42), "snout_r": 0.05, "snout_len": 0.22, "snout_tilt": 10.0, "leather": Color(0.42, 0.27, 0.16),
		"ear_r": 0.035, "ear_len": 0.26, "ear_x": 0.05, "ear_tilt": 10.0, "tail": true},
}
