@tool
extends Button

var margin = false

func _process(delta: float) -> void:
	modulate = Color(1.0, 1.0, 1.0)
	if margin:
		modulate = Color(0.0, 0.6, 1.0)
	

func _on_pressed() -> void:
	margin = !margin