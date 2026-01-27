extends Node
class_name global

signal player_pos
signal camera_pos
signal pause
signal changescene
signal black_screen

var current_scene : Node
var branch : Node
var player_position : Vector2

func _ready() -> void:
	player_pos.connect(update_player_position)
	
func update_player_position(pos : Vector2) -> void:
	player_position = pos
