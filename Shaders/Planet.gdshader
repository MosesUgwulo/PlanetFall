shader_type spatial;

uniform vec4 water : source_color;
uniform vec4 shore : source_color;
uniform vec4 grass : source_color;
uniform vec4 mountain : source_color;
uniform vec4 snow : source_color;

uniform float water_level : hint_range(0.0, 1.0);
uniform float mountain_level : hint_range(0.0, 1.0);
uniform float snow_level : hint_range(0.0, 1.0);

uniform sampler2D noise;

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

	if (ratio < water_level) {
		float shore_ratio = 0.005;
		if (ratio > water_level - shore_ratio) {
			tex = shore;
		}
		else {
			// tex = texture(noise, sin(TIME * UV)) * water;
			tex = water;
		}
	}
	else if (ratio < mountain_level) {
		// tex = texture(noise, UV) * grass; 
		tex = grass;
	}
	else if (ratio < snow_level) {
		tex = mountain;
	}
	else {
		tex = snow;
	}

	ALBEDO = tex.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
