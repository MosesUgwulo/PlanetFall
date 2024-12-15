shader_type spatial;

uniform float min_height;
uniform float max_height;
uniform float radius;
uniform sampler2D height_colour : repeat_disable;

varying float height_diff;

void vertex() {
	float base_radius = length(normalize(VERTEX) * radius);

	height_diff = length(VERTEX) - base_radius;
}

void fragment() {
	float t = (height_diff - min_height) / (max_height - min_height);
	
	t = clamp(t, 0.0, 1.0);

	ALBEDO = texture(height_colour, vec2(t)).rgb;
	// ALBEDO = vec3(t);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
