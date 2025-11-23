extends ColorRect
var time = 0.0
var shader = preload("res://scenes/distortion.gdshader")

func _process(delta: float) -> void:
	time += delta
	time = wrapf(time,-1.0,2.0)
	material.set("shader_parameter/distance_",time)
