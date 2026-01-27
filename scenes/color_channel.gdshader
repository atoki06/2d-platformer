shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture; 
uniform vec2 size_red = vec2(1.0,1.0);
uniform vec2 offset_red = vec2(0.0,0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 resized_uv = ((SCREEN_UV - vec2(0.5,0.5)) * size_red) + vec2(0.5,0.5);
	float red = texture(SCREEN_TEXTURE,resized_uv + offset_red).r;
	float green = texture(SCREEN_TEXTURE,SCREEN_UV).g;
	float blue = texture(SCREEN_TEXTURE,SCREEN_UV).b;
	COLOR = vec4(red,green,blue,1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
