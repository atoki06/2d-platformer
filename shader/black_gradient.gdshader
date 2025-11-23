shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = vec2(0.5,0.5) - UV;
	float dist = pow(pow(uv.x,2.0) + pow(uv.y,2.0),0.5) * 2.0;
	dist = pow(dist,2.0);
	COLOR = vec4(vec3(0.0),1.0 - dist);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
