@tool
extends Button

var collision = false

func _process(delta: float) -> void:
	modulate = Color(1.0, 1.0, 1.0)
	if collision:
		modulate = Color(0.0, 0.6, 1.0)
	

func _on_pressed() -> void:
	collision = !collision