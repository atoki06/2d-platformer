extends Area2D
class_name room_exit

@onready var player = $"../../Player"

@export_category("properties")
@export var index : int
@export_enum("left", "right", "top", "bottom") var direction : int
@export_category("target")
@export var room_path : String
@export var room_entry_index : int

var room_switch_buffer = 0.0

func countdown_buffer(delta):
	room_switch_buffer = max(room_switch_buffer - delta, 0.0)

func set_player_position():
	var distance_to_side = 0
	match direction:
		0:
			distance_to_side = 400
		1:
			distance_to_side = -400
	if SceneSwitch.entrance_index == index:
		player.position = Vector2(position.x + distance_to_side,position.y)
		player.camera.global_position = player.global_position + player.camera_position
		var room = player.get_parent().get_child(1)
		var cam_pos_x = clamp(player.global_position.x,room.margin_min.x * 100,room.margin_max.x * 100)
		var cam_pos_y = clamp(player.global_position.y,room.margin_min.y * 100,room.margin_max.y * 100)
		player.camera.global_position = Vector2(cam_pos_x,cam_pos_y) + player.camera_position
		await get_tree().create_timer(0.1).timeout
	room_switch_buffer = 0.1

func is_player_leaving():
	for body in get_overlapping_bodies():
		#return test_for_player_conditions(body)
		if body.is_in_group("player"):
			return has_right_direction(body)
	

#func test_for_player_conditions(body):
#	if body.is_in_group("player"):
#		Debug.print_to_debug(str(body))
#		return has_right_direction(body)
		
func has_right_direction(body):
	match direction:
		0:
			return body.velocity.x < 0
		1:
			return body.velocity.x > 0
		2:
			return body.velocity.y > 0
		3:
			return body.velocity.y < 0

func switch_room():
	if !room_switch_buffer:
		room_switch_buffer = 0.5
		player.is_black_screen = true
		await get_tree().create_timer(0.4).timeout
		Debug.print_to_debug("true")
		SceneSwitch.entrance_index = room_entry_index
		player.move_lock = 10.0
		$"../..".change_room(room_path)
	#get_tree().change_scene_to_file(room_path)
	#Debug.print_to_debug(str(get_tree().change_scene_to_packed(room_path)))
	
