shader_type canvas_item;

uniform vec2 global_position;

uniform vec2 v_local_position = vec2(0.0);

varying vec2 v_normalized_screen_position;

void vertex() {
	vec2 v_clip_position = (SCREEN_MATRIX * MODEL_MATRIX * vec4(v_local_position, 0.0, 1.0)).xy + global_position;
    v_normalized_screen_position = v_clip_position * 0.5 + vec2(0.5); // [-1.0, 1.0] -> [0.0, 1.0]
	COLOR = vec4(0.5);
	COLOR = vec4(v_normalized_screen_position,0.0,1.0);
}

void fragment() {
	COLOR = vec4(vec3(distance(v_normalized_screen_position,vec2(1.0))) * 0.1,1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
