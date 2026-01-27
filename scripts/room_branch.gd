extends Node2D

@export var first_room : String = "res://scenes/room_01.tscn"
@onready var scene : Node = $scene

func _ready() -> void:
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	Global.branch = self
	Global.changescene.connect(change_room)
	change_room(first_room)
	
func change_room(new_room : String) -> void:
	for i : Node in scene.get_children():
		if !i.is_in_group("player"):
			scene.remove_child(i)
			i.free()
	var room : Node = load(new_room).instantiate()
	Global.current_scene = room
	scene.add_child(room)
