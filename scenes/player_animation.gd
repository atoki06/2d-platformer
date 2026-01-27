extends AnimationComponent

var left : bool = false
var right : bool = false

func play_animation() -> void:
	var on_floor : bool = physics_component.get_parent().is_on_floor()
	var velo : Vector2 = physics_component.velo
	
	left = (velo.x <= -1 or left) and !velo.x > 1
	right = (velo.x >= 1 or right) and !velo.x < -1
	
	var walking_left : bool = on_floor and velo.x < 0
	var walking_right : bool = on_floor and velo.x > 0
	var not_walking : bool = abs(velo.x) < 0.1 and on_floor
	
	var up_left : bool = left and !on_floor and velo.y < 0 and !abs(velo.y) < 400
	var up_right : bool = right and !on_floor and velo.y < 0 and !abs(velo.y) < 400
	var down_left : bool = left and !on_floor and velo.y > 0 and !abs(velo.y) < 400
	var down_right : bool = right and !on_floor and velo.y > 0 and !abs(velo.y) < 400
	var air_left : bool = left and !on_floor and abs(velo.y) < 400
	var air_right : bool = right and !on_floor and abs(velo.y) < 400
	
	play(walking_left, "walking_left", 10)
	play(walking_right, "walking_right", 10)
	play(up_left, "up_left")
	play(up_right, "up_right")
	play(down_left, "down_left")
	play(down_right, "down_right")
	play(air_left, "air_left")
	play(air_right, "air_right")
	pause(not_walking)
	
