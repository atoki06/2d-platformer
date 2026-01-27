extends GPUParticles2D

func _process(delta: float) -> void:
	material.set("shader_parameter/global_position",global_position / -1000)
