extends Node2D
class_name PhysicsComponent

@export var can_climb : bool = false
@export var wall_slide_speed : int = -700

@export var jump_height : int = -450
@export var jump_time : float = 0.4
@export var fall_mult : float = 0.8

var velo : Vector2 = Vector2(0,0)
var gravity : Vector2 = Vector2(0,12)
var environment_velocity : Vector2 = Vector2(0,0)

var _jump_height : int = 0

var _jump_time : float = 0.0

var paused : bool = false

func _process(delta: float) -> void:
	if !paused:
		calc_gravity(delta, jump_height, jump_time, fall_mult)
		get_parent().velocity = get_velocity()
		get_parent().move_and_slide()

func calc_gravity(delta : float, jump_height : int, jump_time : float , down_mult : float = 1.0) -> void:
	_jump_height = jump_height
	_jump_time = jump_time
	if velo.y < 0:
		gravity = Vector2(0,-2 * jump_height / jump_time / jump_time)
		#if dubble_jump_used:
		#	gravity = Vector2(0,-2 * dubble_jump_height / dubble_jump_time / dubble_jump_time)
	else:
		gravity = Vector2(0,-2 * jump_height / jump_time / jump_time * down_mult)
	
	
	velo += gravity * delta
	if get_parent().is_on_floor():
		velo.y = min(velo.y, environment_velocity.y)
	if get_parent().is_on_ceiling():
		velo.y = max(velo.y, environment_velocity.y)
	if get_parent().is_on_wall() and !get_parent().is_on_floor() and can_climb:
		var slide_wall : bool = false
		for i : int in range(get_parent().get_slide_collision_count()):
			var collision : KinematicCollision2D = get_parent().get_slide_collision(i)
			if collision.get_collider() and collision.get_collider().is_in_group("slide_wall"):
				slide_wall = true
		if !slide_wall:
			velo.y = min(velo.y, -wall_slide_speed)
	velo.y = min(velo.y,4500)

func get_velocity() -> Vector2:
	return velo
