shader_type spatial;

uniform vec4 water : source_color;
uniform vec4 grass : source_color;
uniform vec4 hill : source_color;
uniform vec4 mountain : source_color;

uniform float water_height : hint_range(0.0, 1.0);
uniform float grass_height : hint_range(0.0, 1.0);
uniform float hill_height : hint_range(0.0, 1.0);
uniform float mountain_height : hint_range(0.0, 1.0);

uniform float min_height = 0.0;
uniform float max_height = 1.0;

varying float height;

void vertex() {
	float a = length(VERTEX);
	height = (a - min_height) / (max_height - min_height);
	UV = vec2(VERTEX.x + VERTEX.z, VERTEX.y + VERTEX.z);
}

void fragment() {
	float ratio = height;
	vec4 tex;

	if (ratio < water_height) {
		tex = water;
	} else if (ratio < grass_height) {
		tex = grass;
	} else if (ratio < hill_height) {
		tex = hill;
	} else {
		tex = mountain;
	}

	ALBEDO = tex.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
