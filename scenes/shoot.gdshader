shader_type canvas_item;

uniform float direction = 0.0;
uniform float thickness = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 color = vec3(0.0);
	float alpha = 0.0;
	color = vec3(UV,0.0);
	
	vec2 uv = UV - vec2(0.5);
	
	if (abs(uv.x * sin(direction) - uv.y * cos(direction)) < thickness && uv.x * sin(direction - PI / 2.0) - uv.y * cos(direction - PI / 2.0) < 0.0) {
		alpha = 1.0;
	}
	
	COLOR = vec4(color,alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
