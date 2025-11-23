@tool
extends Sprite3D
class_name sprite_layer
@export var reload = false
@export var layer = 0

func _process(delta: float) -> void:
	if reload:
		for i in get_children().size():
			if get_child(i) is Sprite3D:
				get_child(i).render_priority = i + 1
				get_child(i).render_priority = layer
		
	reload = false
