// Comic cel shading: flat colour bands, warm shadows, soft rim, optional spots/stripes.
shader_type spatial;
render_mode unshaded, cull_back;

uniform vec3 base_color : source_color = vec3(0.8, 0.6, 0.3);
uniform vec3 shade_color : source_color = vec3(0.45, 0.28, 0.18);
uniform vec3 deep_color : source_color = vec3(0.28, 0.16, 0.1);
uniform vec3 light_dir = vec3(-0.5, 0.8, 0.6);
uniform float rim = 0.25;
uniform int pattern = 0;            // 0 none, 1 spots, 2 tile grid, 3 stripes
uniform vec3 pattern_color : source_color = vec3(0.3, 0.18, 0.1);
uniform float pattern_scale = 14.0;
uniform float hatch = 0.0;
uniform float flash = 0.0;
uniform vec3 flash_color = vec3(1.0);
varying vec3 world_pos;

vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return fract(sin(p) * 43758.5453);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 col = base_color;
	if (pattern == 1) {
		vec2 g = UV * pattern_scale;
		vec2 i = floor(g);
		float d = 9.0;
		for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
			vec2 c = i + vec2(float(x), float(y));
			vec2 o = hash2(c);
			d = min(d, length(g - c - o * 0.8 - 0.1) / (0.25 + 0.2 * o.x));
		}
		col = mix(pattern_color, col, smoothstep(0.85, 1.0, d));
	} else if (pattern == 2) {
		vec2 g = world_pos.xz * vec2(0.9, 1.6) + vec2(floor(world_pos.z * 1.6) * 0.5, 0.0);
		vec2 f = abs(fract(g) - 0.5);
		float line = step(0.465, max(f.x, f.y));
		float v = hash2(floor(g)).x;
		col = mix(col * (0.9 + 0.18 * v), pattern_color, line);
	} else if (pattern == 3) {
		float s = sin(world_pos.y * pattern_scale + sin(world_pos.x * 3.0) * 1.5);
		col = mix(col, pattern_color, step(0.55, s));
	}
	vec3 n = normalize(NORMAL);
	vec3 l = normalize((VIEW_MATRIX * vec4(normalize(light_dir), 0.0)).xyz);
	float ndl = dot(n, l);
	vec3 lit = col;
	if (ndl < 0.05) lit = mix(col, shade_color * col * 1.6, 0.8);
	if (ndl < -0.45) lit = mix(col, deep_color * col * 1.9, 0.85);
	if (hatch > 0.0 && ndl < 0.05) {
		float h = step(0.6, fract((FRAGCOORD.x + FRAGCOORD.y) * 0.18));
		lit = mix(lit, lit * 0.78, h * hatch);
	}
	float r = pow(1.0 - clamp(dot(n, normalize(VIEW)), 0.0, 1.0), 3.0);
	lit += vec3(1.0, 0.92, 0.75) * step(0.55, r) * rim;
	ALBEDO = mix(lit, flash_color, flash);
}
