extends Area3D
@export var is_fall_respawn = false

func _on_body_entered(body: Node3D) -> void:
	if body.get_groups().has("player"):
		body.instant_respawn(is_fall_respawn)
