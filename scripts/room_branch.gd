extends Node2D

@export var first_room = "res://scenes/room_01.tscn"

func _ready() -> void:
	for i in get_children():
		if !i.is_in_group("player"):
			remove_child(i)
			i.free()
	add_child(load(first_room).instantiate())

func change_room(new_room):
	for i in get_children():
		if !i.is_in_group("player"):
			remove_child(i)
			i.free()
	add_child(load(new_room).instantiate())
