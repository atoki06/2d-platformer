@tool
extends Node2D
class_name parallax
@export var size : float = 1.0
@export var layer : int = 0
@export var z__index: int = 0

var sprite_instance : RID

func _ready() -> void:
	if !Engine.is_editor_hint():
		Global.camera_pos.connect(_parallax)

func _process(delta: float) -> void:
	if sprite_instance is RID:
		RenderingServer.free_rid(sprite_instance)
	var rs : Object = RenderingServer
	sprite_instance = rs.canvas_item_create()
	rs.canvas_item_set_z_index(sprite_instance, z__index)
	rs.canvas_item_set_parent(sprite_instance,get_canvas_item())
	for child : Node in get_children():
		if child is EnvironmentSprite and child.texture:
			var texture : Texture2D = child.texture
			var region : Rect2
			if child.texture is AtlasTexture:
				#print(child.texture)
				region = child.texture.region
				texture = child.texture
			var size : Vector2 = texture.get_size()
			var child_size : Vector2 = child.size
			if child.flip_x:
				child_size.x *= -1
			var rect : Rect2 = Rect2(child.position - (Vector2(abs(child_size.x), abs(child_size.y)) * size) / 2, child_size * size)
	
			rs.canvas_item_add_texture_rect_region(sprite_instance,rect, texture, region, child.color)

func _parallax(pos : Vector2) -> void:
	global_position = pos - pos * size
	scale = Vector2(1,1) * size
