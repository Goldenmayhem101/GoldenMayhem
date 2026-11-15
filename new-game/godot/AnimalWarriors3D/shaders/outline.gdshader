// Inked outline: an inflated back-face shell drawn in ink colour.
shader_type spatial;
render_mode unshaded, cull_front;
uniform vec3 ink : source_color = vec3(0.12, 0.07, 0.04);
uniform float width = 0.018;
void vertex() {
	VERTEX += normalize(NORMAL) * width;
}
void fragment() {
	ALBEDO = ink;
}
