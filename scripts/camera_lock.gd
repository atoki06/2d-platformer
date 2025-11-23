@tool
extends Area3D
class_name camera_lock

var hitbox = CollisionShape3D.new()
var position_limit = Node3D.new()

@export_enum("point","line","rectangle") var position_type : int
var position_type_change : int
@export var point_positions = []
@export var hitbox_size = Vector2(1,1)
@export var camera_position = Vector3(0,0,0)
var positions_change = []

var all_positions = [[],[],[]]


func _ready() -> void:
	if Engine.is_editor_hint():
		position_limit.position = camera_position
		for child in get_children():
			if child != hitbox or child != position_limit:
				child.free()
		if !hitbox:
			hitbox = CollisionShape3D.new()
			hitbox.name = "hitbox"
			hitbox.shape = BoxShape3D.new()
			add_child(hitbox)
			hitbox.owner = get_tree().edited_scene_root
			
		if !position_limit:
			position_limit = Node3D.new()
			position_limit.name = "position_limit"
			add_child(position_limit)
			position_limit.owner = get_tree().edited_scene_root
		
	
func _process(delta: float) -> void:
	engine_process()
	if is_player_colliding() and position_type == 0:
		get_player().camera_target = camera_position + position
		get_player().is_camera_limited = true
		get_player().camera_speed_target = 3
	
	if camera_position != position_limit.position:
		camera_position = position_limit.position

func change_position_type():
	save_point_positions()
	delete_all_points()
	create_points(pow(2,position_type))
	
func add_missing_nodes():
	if !get_children().has(hitbox) and hitbox:
		hitbox.name = "hitbox"
		hitbox.shape = BoxShape3D.new()
		add_child(hitbox)
		hitbox.owner = get_tree().edited_scene_root
	if !get_children().has(position_limit) and position_limit:
		position_limit.name = "position_limit"
		add_child(position_limit)
		position_limit.owner = get_tree().edited_scene_root

func delete_all_points():
	for point in position_limit.get_children():
		point.free()

func create_points(count):
	if position_type < all_positions.size():
		point_positions = all_positions[position_type]
	for point in range(count):
		var point_object = Marker3D.new()
		point_object.name = "point-" + str(point)
		position_limit.add_child(point_object)
		var point_pos = Vector2(0,0)
		if point < point_positions.size():
			point_pos = point_positions[point]
		point_object.position = Vector3(point_pos.x,point_pos.y,0)
		point_object.owner = get_tree().edited_scene_root

func save_point_positions():
	point_positions = []
	for point in position_limit.get_children():
		point_positions.append(Vector2(point.position.x,point.position.y))
	all_positions.resize(3)
	all_positions[position_type_change] = point_positions
	point_positions = all_positions[position_type]

func update_point_position():
	var x = 0
	for point in position_limit.get_children():
		var point_pos = Vector2(0,0)
		if x < point_positions.size():
			point_pos = point_positions[x]
		point.position = Vector3(point_pos.x,point_pos.y,0)
		x += 1


func is_player_colliding():
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			return true

func engine_process():
	if Engine.is_editor_hint():
		if position_type_change != position_type:
			change_position_type()
		add_missing_nodes()
		#if positions_change != point_positions:
			#update_point_position()
		position_type_change = position_type
		positions_change = point_positions
		
		for point in position_limit.get_children():
			point.position.z = 0
		
		hitbox.shape.set("size",Vector3(hitbox_size.x,hitbox_size.y,1))

func get_player():
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			return body
