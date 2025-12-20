@tool
extends Node2D
class_name parallax
@export var size = 1.0
@export var layer = 0

var sprite_instance

func _process(delta: float) -> void:
	if sprite_instance is RID:
		RenderingServer.free_rid(sprite_instance)
	var rs = RenderingServer
	sprite_instance = rs.canvas_item_create()
	rs.canvas_item_set_parent(sprite_instance,get_canvas_item())
	for child in get_children():
		if child is EnvironmentSprite and child.texture:
			var size = child.texture.get_size()
			var child_size = child.size
			if child.flip_x:
				child_size.x *= -1
			rs.canvas_item_add_texture_rect(sprite_instance,Rect2(child.position - (Vector2(abs(child_size.x),abs(child_size.y)) * size) / 2,child_size * size),child.texture, false, child.color)
