@tool
extends Button

var player = false

func _process(delta: float) -> void:
	modulate = Color(1.0, 1.0, 1.0)
	if player:
		modulate = Color(0.0, 0.6, 1.0)
	

func _on_pressed() -> void:
	player = !player