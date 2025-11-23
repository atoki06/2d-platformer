shader_type canvas_item;

uniform float distance_ : hint_range(-1.0, 2.0, 0.02);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 pos = (UV - vec2(0.5,0.5));
	float dist = pow(pow(abs(pos.x),2.0) + pow(abs(pos.y),2.0),0.5);
	float distortion_mask = pow(abs(dist - distance_),1.5) * 1.0;
	distortion_mask = (-(distortion_mask - 1.0)) * 0.2;
	vec2 distortion = vec2(distortion_mask * pos.x,distortion_mask * pos.y);
	COLOR = vec4(vec3(UV + distortion,0.0),1.0);
	COLOR = texture(SCREEN_TEXTURE,SCREEN_UV + distortion);
	//COLOR = vec4(vec3(distortion,0.0),1.0);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
