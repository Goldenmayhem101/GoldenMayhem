class_name Crowd
extends RefCounted
## Lightweight chunky units (soldiers + zombies) that can be drawn in the hundreds.
## Everything is one mesh with vertex colours; the run cycle (leg swing + bounce) runs on the GPU,
## so a crowd costs almost nothing compared with fully skinned characters.

const SHADER_CODE := """
shader_type spatial;
uniform float run = 1.0;
uniform float speed = 10.0;
uniform float phase = 0.0;
uniform float inst_phase = 1.0;
uniform float flash = 0.0;
uniform float lean = 0.0;
void vertex() {
	float ph = phase + float(INSTANCE_ID) * 1.713 * inst_phase;
	float t = TIME * speed + ph;
	float leg = UV.x;
	if (abs(leg) > 0.5) {
		float a = sin(t) * 0.8 * leg * run;
		float y = VERTEX.y - 0.5;
		float z = VERTEX.z;
		VERTEX.y = 0.5 + y * cos(a) - z * sin(a);
		VERTEX.z = z * cos(a) + y * sin(a);
	}
	VERTEX.y += abs(sin(t)) * 0.08 * run;
	VERTEX.x += sin(t * 0.5) * 0.025 * run;
	VERTEX.z -= lean * VERTEX.y * 0.12;
}
void fragment() {
	ALBEDO = COLOR.rgb + vec3(flash);
	ROUGHNESS = 0.8;
}
"""

static var _shader: Shader

static func make_material(run := 1.0, speed := 10.0) -> ShaderMaterial:
	if _shader == null:
		_shader = Shader.new()
		_shader.code = SHADER_CODE
	var m := ShaderMaterial.new()
	m.shader = _shader
	m.set_shader_parameter("run", run)
	m.set_shader_parameter("speed", speed)
	return m

# ------------------------------------------------------------ geometry helpers
static func _lin(c: Color) -> Color:
	return c.srgb_to_linear()

static func _sph(c: Vector3, r: Vector3, u: float, v: float) -> Array:
	var d := Vector3(sin(v) * cos(u), cos(v), sin(v) * sin(u))
	return [c + d * r, (d / r).normalized()]

static func _vert(st: SurfaceTool, p: Array, col: Color, tag: float) -> void:
	st.set_color(col)
	st.set_uv(Vector2(tag, 0))
	st.set_normal(p[1])
	st.add_vertex(p[0])

static func ell(st: SurfaceTool, c: Vector3, r: Vector3, col: Color, tag := 0.0, seg := 10, rings := 6) -> void:
	col = _lin(col)
	for ri in range(rings):
		var v0 := PI * float(ri) / float(rings)
		var v1 := PI * float(ri + 1) / float(rings)
		for si in range(seg):
			var u0 := TAU * float(si) / float(seg)
			var u1 := TAU * float(si + 1) / float(seg)
			var p00 := _sph(c, r, u0, v0)
			var p10 := _sph(c, r, u1, v0)
			var p01 := _sph(c, r, u0, v1)
			var p11 := _sph(c, r, u1, v1)
			_vert(st, p10, col, tag)
			_vert(st, p00, col, tag)
			_vert(st, p01, col, tag)
			_vert(st, p10, col, tag)
			_vert(st, p01, col, tag)
			_vert(st, p11, col, tag)

static func box(st: SurfaceTool, c: Vector3, size: Vector3, col: Color, tag := 0.0) -> void:
	col = _lin(col)
	var h := size * 0.5
	var faces := [
		[Vector3(0, 0, 1), Vector3(0, 1, 0)], [Vector3(0, 0, -1), Vector3(0, 1, 0)],
		[Vector3(1, 0, 0), Vector3(0, 1, 0)], [Vector3(-1, 0, 0), Vector3(0, 1, 0)],
		[Vector3(0, 1, 0), Vector3(0, 0, -1)], [Vector3(0, -1, 0), Vector3(0, 0, 1)]]
	for f in faces:
		var n: Vector3 = f[0]
		var up: Vector3 = f[1]
		var rt := up.cross(n)
		var o := c + n * (h * n.abs()).length() * 0.0
		var cn := c + Vector3(n.x * h.x, n.y * h.y, n.z * h.z)
		var hr := Vector3(rt.abs().x * h.x, rt.abs().y * h.y, rt.abs().z * h.z).length()
		var hu := Vector3(up.abs().x * h.x, up.abs().y * h.y, up.abs().z * h.z).length()
		var tl := cn - rt * hr + up * hu
		var tr := cn + rt * hr + up * hu
		var br := cn + rt * hr - up * hu
		var bl := cn - rt * hr - up * hu
		for p in [tl, tr, br, tl, br, bl]:
			_vert(st, [p, n], col, tag)

static func _finish(st: SurfaceTool) -> ArrayMesh:
	return st.commit()

# ------------------------------------------------------------ units
## Chunky soldier, ~1.3 tall, faces -Z, gun held forward.
static func soldier_mesh(vest: Color, helmet: Color, pants := Color(0.2, 0.22, 0.3)) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var skin := Color(0.95, 0.75, 0.6)
	var dark := Color(0.14, 0.14, 0.18)
	for s in [-1.0, 1.0]:
		ell(st, Vector3(0.1 * s, 0.27, 0), Vector3(0.09, 0.27, 0.1), pants, s)
		ell(st, Vector3(0.1 * s, 0.05, -0.05), Vector3(0.1, 0.06, 0.15), dark, s)
	ell(st, Vector3(0, 0.72, 0), Vector3(0.25, 0.28, 0.18), vest)
	box(st, Vector3(0, 0.78, 0.22), Vector3(0.3, 0.36, 0.14), vest.darkened(0.35))
	ell(st, Vector3(-0.2, 0.72, -0.2), Vector3(0.07, 0.075, 0.24), vest.lightened(0.1))
	ell(st, Vector3(0.14, 0.72, -0.24), Vector3(0.07, 0.075, 0.26), vest.lightened(0.1))
	ell(st, Vector3(-0.17, 0.72, -0.44), Vector3(0.06, 0.06, 0.06), skin)
	# gun: long and obvious
	box(st, Vector3(0.05, 0.76, -0.5), Vector3(0.1, 0.14, 0.72), Color(0.32, 0.33, 0.4))
	box(st, Vector3(0.05, 0.8, -0.9), Vector3(0.06, 0.06, 0.16), Color(1.0, 0.7, 0.2))
	box(st, Vector3(0.05, 0.66, -0.4), Vector3(0.06, 0.14, 0.08), Color(0.1, 0.1, 0.12))
	ell(st, Vector3(0, 1.1, 0), Vector3(0.2, 0.21, 0.2), skin)
	ell(st, Vector3(0, 1.17, 0.01), Vector3(0.23, 0.16, 0.23), helmet)
	ell(st, Vector3(0, 1.09, -0.17), Vector3(0.15, 0.055, 0.06), Color(0.08, 0.1, 0.16))
	return _finish(st)

## Chunky zombie, ~1.3 tall, arms stretched forward (-Z).
static func zombie_mesh(skin: Color, shirt: Color, pants: Color, hair := Color(0.15, 0.12, 0.1)) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var dark := Color(0.12, 0.1, 0.1)
	for s in [-1.0, 1.0]:
		ell(st, Vector3(0.11 * s, 0.27, 0), Vector3(0.095, 0.27, 0.105), pants, s)
		ell(st, Vector3(0.11 * s, 0.05, -0.04), Vector3(0.1, 0.06, 0.14), dark, s)
		ell(st, Vector3(0.24 * s, 0.8, -0.3), Vector3(0.065, 0.065, 0.32), skin)
		ell(st, Vector3(0.24 * s, 0.8, -0.62), Vector3(0.08, 0.07, 0.08), skin.darkened(0.12))
	ell(st, Vector3(0, 0.74, 0), Vector3(0.27, 0.3, 0.19), shirt)
	ell(st, Vector3(0, 0.56, -0.02), Vector3(0.26, 0.1, 0.19), shirt.darkened(0.25))
	ell(st, Vector3(0, 1.12, -0.04), Vector3(0.22, 0.23, 0.21), skin)
	ell(st, Vector3(0, 1.26, 0.0), Vector3(0.21, 0.1, 0.2), hair)
	for s in [-1.0, 1.0]:
		ell(st, Vector3(0.085 * s, 1.15, -0.22), Vector3(0.055, 0.06, 0.04), Color(1.0, 0.88, 0.15), 0.0, 8, 5)
	ell(st, Vector3(0, 1.04, -0.23), Vector3(0.09, 0.04, 0.04), Color(0.25, 0.04, 0.06), 0.0, 8, 4)
	return _finish(st)

static func blob_shadow_material() -> StandardMaterial3D:
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0.45))
	g.set_color(1, Color(0, 0, 0, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = g
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(1.0, 0.5)
	gt.width = 64
	gt.height = 64
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_texture = gt
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.no_depth_test = false
	return m

static func blob_shadow_mesh(size: float) -> PlaneMesh:
	var p := PlaneMesh.new()
	p.size = Vector2(size, size)
	return p
