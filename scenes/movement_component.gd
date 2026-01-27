extends Node2D
class_name MovementComponent

@export var physics_component : PhysicsComponent
@export var walking_speed : int = 800

var max_air_jumps : int = 0
var air_jumps : int = 0

func walk(direction : float) -> void:
	if !physics_component: return
	physics_component.velo.x += (direction * walking_speed - physics_component.velo.x) * 0.9
	
	
func set_max_air_jumps(amount : int) -> void:
	max_air_jumps = amount
	
func reset_air_jumps() -> void:
	air_jumps = max_air_jumps

func trigger_jump() -> void:
	if !physics_component: return
	if get_parent().is_on_floor():
		jump()
		reset_air_jumps()
	elif air_jumps:
		air_jumps = max(air_jumps - 1,0)
		jump()
	
func jump() -> void:
	physics_component.velo.y = 2 * physics_component._jump_height / physics_component._jump_time + physics_component.environment_velocity.y

func cancel_jump() -> void:
	if not Input.is_action_pressed("jump") and physics_component.velo.y < 0:
		physics_component.velo.y = 0
