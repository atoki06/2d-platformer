@tool
extends Node2D

@export var animation_component : AnimationComponent
@export var texture : Texture2D
@export var hair : Color
@export var skin : Color
@export var tie : Color
@export var shirt : Color
@export var skirt : Color
@export var socks : Color
@export var shoes : Color

func _process(delta: float) -> void:
	var image : Image = Image.create(7,1,false,Image.FORMAT_RGBA8)
	image.set_pixel(0,0,shirt)
	image.set_pixel(1,0,shoes)
	image.set_pixel(2,0,tie)
	image.set_pixel(3,0,hair)
	image.set_pixel(4,0,skin)
	image.set_pixel(5,0,skirt)
	image.set_pixel(6,0,socks)
	var new_texture : ImageTexture = ImageTexture.create_from_image(image)
	animation_component.material.set("shader_parameter/SAMPLE_COLOR",new_texture)
