shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float scale : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float distortion : hint_range(1.0, 2.0, 0.01) = 1.0;
uniform vec2 player_pos;
uniform float black_screen_strength;
uniform float size;

varying vec2 ratio;
varying vec2 screen_uv;
varying vec2 uv;
varying float dist_to_center;
varying float dist_to_player;
varying float new_dist;

void vertex() {
	// Called for every vertex the material is visible on.
}

float black_fog(vec2 _uv) {
	vec2 new_uv = (_uv - player_pos) * vec2(1.0,9.0/16.0);
	float dist = pow(pow(new_uv.x,2.0) + pow(new_uv.y,2.0),0.6) / 0.5 - 0.3;
	return dist;
}

vec3 distort_blur(vec2 _uv, float _dist_to_center, float _dist_to_player, float _new_dist) {
	vec2 distorted_uv = (_uv - 0.5) * (1.0 / distortion / _new_dist) + 0.5;
	distorted_uv = mix(distorted_uv,_uv,pow(_dist_to_center,1.5));
	vec3 background = textureLod(SCREEN_TEXTURE, distorted_uv, _dist_to_player * 2.0 - 0.2).rgb;
	return vec3(background);
}

vec3 get_color(float _size) {
	vec2 _screen_uv = (screen_uv - vec2(0.5)) * _size + vec2(0.5);
	float _dist_to_center = distance(_screen_uv * ratio,vec2(0.5,0.5) * ratio);
	float _dist_to_player = distance(_screen_uv * ratio,player_pos * ratio);
	float _dist_to_center_x = abs((_screen_uv).x - (vec2(0.5,0.5)).x);
	float _dist_to_center_y = abs((_screen_uv).y - (vec2(0.5,0.5)).y);
	float _dist_to_center_square = max(_dist_to_center_x,_dist_to_center_y);
	float _new_dist = pow(_dist_to_center_square,scale);
	vec2 _uv = mix((_screen_uv - 0.5) * (1.0 / distortion / _new_dist) + 0.5,_screen_uv,pow(_dist_to_center_square,1.5));
	float _in_bounds_x = 1.0 - clamp(sign(abs(clamp(_uv.x,0.0,1.0) - _uv.x)),0.0,1.0);
	float _in_bounds_y = 1.0 - clamp(sign(abs(clamp(_uv.y,0.0,1.0) - _uv.y)),0.0,1.0);
	
	
	vec3 color = mix(distort_blur(_screen_uv, _dist_to_center, _dist_to_player, _new_dist),vec3(0.0), vec3(black_fog(_uv)));
	color = mix(color,vec3(0.0),max(scale,black_screen_strength)) * _in_bounds_x * _in_bounds_y;
	return color;
}

void fragment() {
	screen_uv = SCREEN_UV;
	ratio = vec2(1.0,SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y);
	COLOR = vec4(vec3(get_color(0.99).r,get_color(1.0).gb),1.0);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
