shader_type canvas_item;

uniform float size = 5.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 new_uv = (UV - vec2(0.5,0.5));
	float dist = pow(pow(new_uv.x,2.0) + pow(new_uv.y,2.0),0.3) / size - 0.5;
	COLOR.a = dist;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
