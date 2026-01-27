extends Sprite2D
class_name AnimationComponent

@export var animation_player : AnimationPlayer
@export var physics_component : PhysicsComponent

func _process(delta: float) -> void:
	if physics_component and animation_player:
		play_animation()
	
func play_animation() -> void:
	pass

func play(condition : bool, animation : StringName, speed : float = 10.0) -> void:
	animation_player.speed_scale = speed
	if condition and animation != animation_player.current_animation:
		animation_player.play(animation, -1, 1.0)
		
func pause(condition : bool) -> void:
	if condition:
		animation_player.pause()
