shader_type canvas_item;

uniform sampler2D BASE_COLOR : filter_nearest;
uniform sampler2D SAMPLE_COLOR : filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 color = texture(TEXTURE,UV).rgb;
	int size = textureSize(BASE_COLOR, 0).x;
	vec3 new_color = color;
	for (int i = 0; i < size; i++) {
		float _step = 1.0 / float(size);
		float pos = (float(i) + 0.5) * _step;
		if (distance(color,texture(BASE_COLOR,vec2(pos,0.0)).rgb) < 0.05) {
			new_color = texture(SAMPLE_COLOR,vec2(pos,0.0)).rgb;
		}
	}
	COLOR = vec4(new_color,texture(TEXTURE,UV).a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
