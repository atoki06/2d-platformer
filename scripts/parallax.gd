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
			var texture = child.texture
			var region
			if child.texture is AtlasTexture:
				#print(child.texture)
				region = child.texture.region
				texture = child.texture
			var size = texture.get_size()
			var child_size = child.size
			if child.flip_x:
				child_size.x *= -1
			var rect = Rect2(child.position - (Vector2(abs(child_size.x), abs(child_size.y)) * size) / 2, child_size * size)
	
			rs.canvas_item_add_texture_rect_region(sprite_instance,rect, texture, region, child.color)
