extends CharacterBody2D

#const
const line_thickness = 2

#node connections
@onready var soundtrack_player = $soundtrack_player
@onready var black_screen : Node = $camera/black_screen
@onready var camera = $camera
@onready var attack_body = $attack
@onready var attack_hitbox = $attack/hitbox
@onready var hitbox = $hitbox
@onready var detection = $detection
@onready var black_fog = $black_fog
@onready var sound_player = $soundplayer

#@exports
@export var camera_position : Vector2
@export var walking_speed = 800;
@export var jump_height = -450
@export var jump_time = 0.4
@export var jump_down_multiplier = 0.8
@export var dubble_jump_height = -350
@export var dubble_jump_time = 0.3
@export var wall_slide_speed = -700
@export var wall_jump_height = -350
@export var wall_jump_time = 0.3

#variables
var gravity = Vector2(0,12)
var dubble_jump_used = false
var environment_velocity = Vector2(0,0)
var wall_jump_timer = 0.0
var wall_jump_direction = 0.0
var move_lock = 0.0
var quick_spawn = Vector2(0,0)
var is_black_screen = false
var attack_timer = 0.2
var attack_cooldown = 0.3
var looking_direction = 0.0
var is_pogoing = false
var camera_target = Vector2(0,0)
var is_camera_limited = false
var camera_speed = 8
var camera_speed_target = 8
var new_room = false
var collision_debug = false

var room
var drawer

#input
var input = {
	"up" : KEY_W,
	"left" : KEY_A,
	"down" : KEY_S,
	"right" : KEY_D,
	"jump" : KEY_SPACE,
	"debug" : KEY_B,
	"attack" : MOUSE_BUTTON_LEFT,
	"collision_debug" : KEY_N
}
var velo = Vector2(0,0)

#debug
var debug_open = false

func _ready() -> void:
	drawer = Node2D.new()
	drawer.top_level = true
	drawer.z_index = 20
	drawer.draw.connect(draw)
	add_child(drawer)
	var sound = load("res://sounds/Shoot_combined.wav")
	sound_player.stream = sound
	soundtrack_player.playing = false
	camera.visible = !Engine.is_editor_hint()
	black_screen.visible = !Engine.is_editor_hint()
	visible = true
	for action in InputMap.get_actions():
		InputMap.erase_action(action)
		
	for action in input:
		var action_key = input[action]
		print(action)
		var event
		if action_key < 30:
			event = InputEventMouseButton.new()
			event.button_index = action_key
		else:
			event = InputEventKey.new()
			event.keycode = action_key
		InputMap.add_action(action)
		InputMap.action_add_event(action, event)
		

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("collision_debug"):
		collision_debug = !collision_debug
	drawer.queue_redraw()
	var mouse_pos
	if Input.is_action_just_pressed("debug"):
		toggle_debug_mode()
	
	const exit_size = 500.0
	var near_exit = exit_size
	for area in detection.get_overlapping_areas():
		if area.is_in_group("exit") and area.global_position.distance_to(global_position) < near_exit:
			near_exit = area.global_position.distance_to(global_position)
	var fog = black_fog.material
	#fog.set("shader_parameter/size",0.37 * clamp(near_exit / (exit_size * 4) + 0.75,0.5,1.0))

func _physics_process(delta: float) -> void:
	black_screen.color.a += (int(is_black_screen) - black_screen.color.a) * delta * 10.0
	attack_timer = max(attack_timer - delta, 0.0)
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	move_lock = max(move_lock - delta, 0.0)
	wall_jump_timer = max(wall_jump_timer - delta, 0.0)
	if !attack_timer:
		attack_body.visible = false
		attack_body.monitoring = false
		attack_hitbox.disabled = true
	
	#walking
	velo.x += ((int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))) * walking_speed - velo.x) * 0.9
	#velo.x *= walking_speed
	
	var direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	if direction:
		looking_direction = direction
	
	#define gravity
	if velo.y < 0:
		gravity = Vector2(0,-2 * jump_height / jump_time / jump_time)
		if dubble_jump_used:
			gravity = Vector2(0,-2 * dubble_jump_height / dubble_jump_time / dubble_jump_time)
	else:
		gravity = Vector2(0,-2 * jump_height / jump_time / jump_time * jump_down_multiplier)
	
	#cancel jump
	if not Input.is_action_pressed("jump") and velo.y < 0 and !is_pogoing:
		gravity = Vector2(0,-2 * jump_height / jump_time / jump_time) * 5
	if velo.y > 0:
		is_pogoing = false
	
	#jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velo.y = 2 * jump_height / jump_time + environment_velocity.y
		is_pogoing = false
	elif Input.is_action_just_pressed("jump"):
		dubble_jump()
	
	#applying gravity
	velo += gravity * delta
	if is_on_floor():
		velo.y = min(velo.y, environment_velocity.y)
		dubble_jump_used = false
		quick_spawn = Vector2(global_position.x,global_position.y)
	if is_on_ceiling():
		velo.y = max(velo.y, environment_velocity.y)
	if is_on_wall() and !is_on_floor():
		var slide_wall = false
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("slide_wall"):
				slide_wall = true
		if !slide_wall:
			stick_to_wall()
			dubble_jump_used = false
	
	if wall_jump_timer:
		velo.x = wall_jump_direction
		
	#attack
	if Input.is_action_just_pressed("attack") and !attack_cooldown:
		attack()
	
	#final
	velo.y = min(velo.y,4500)
	if move_lock:
		velo = Vector2(0,0)
	velocity = Vector2(velo.x,velo.y)
	move_and_slide()
	#global_position.z = 0
	
	#move camera
	room = get_parent().get_child(1)
	var cam_pos_x = clamp(global_position.x,room.margin_min.x * 100,room.margin_max.x * 100)
	var cam_pos_y = clamp(global_position.y,room.margin_min.y * 100,room.margin_max.y * 100)
	var camera_direction = (Vector2(cam_pos_x,cam_pos_y) + camera_position - camera.global_position)
	camera.global_position += camera_direction * delta * camera_speed
	camera.global_position = Vector2(snapped(camera.global_position.x,1),snapped(camera.global_position.y,1))
	#if new_room:
	#	new_room = false
	#	camera.global_position = Vector2(cam_pos_x,cam_pos_y) + camera_position
	
	#parallax
	for i in room.get_children():
		if i.is_in_group("parallax"):
			i.global_position = camera.global_position - camera.global_position * i.size
			i.scale = Vector2(1,1) * i.size
	
	Global.player_position = global_position
	
	
func int_key_pressed(key):
	return int(Input.is_key_label_pressed(key))
	
	
func dubble_jump():
	if !dubble_jump_used:
		velo.y = 2 * dubble_jump_height / dubble_jump_time
		dubble_jump_used = true
		is_pogoing = false
	
func stick_to_wall():
	velo.y = min(velo.y, -wall_slide_speed)
	if Input.is_action_just_pressed("jump"):
		wall_jump()
	
func wall_jump():
	var normal = get_wall_normal()
	velo.y = 2 * wall_jump_height / wall_jump_time
	wall_jump_direction = normal.x * walking_speed * 3.0
	wall_jump_timer = 0.07
	is_pogoing = false
	
func instant_respawn(falling : bool = false):
	is_black_screen = true
	if !falling:
		move_lock = 0.6
	await get_tree().create_timer(0.4).timeout
	if falling:
		move_lock = 0.2
	global_position = Vector2(quick_spawn.x,quick_spawn.y)
	camera.global_position = global_position + camera_position
	await get_tree().create_timer(0.1).timeout
	if is_camera_limited:
		camera.global_position = camera_target + camera_position
	is_black_screen = false
	
func toggle_debug_mode():
	debug_open = !debug_open
	for child in get_all_children(get_tree().get_root()):
		if child is CollisionPolygon3D or child is CollisionShape3D:
			child.debug_color.a = 0.4 * int(debug_open)
			child.debug_fill = false
			print(child.debug_color.a)
		
	
func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr
	
func attack():
	#sound_player.play(0.0)
	attack_body.rotation_degrees = 90 + 90 * looking_direction * (int(!is_on_wall()) - 0.5) * 2.0
	if Input.is_action_pressed("down") and !is_on_floor():
		attack_body.rotation_degrees = -90
	if Input.is_action_pressed("up"):
		attack_body.rotation_degrees = 90
	attack_body.visible = true
	attack_body.monitoring = true
	attack_hitbox.disabled = false
	attack_timer = 0.2
	attack_cooldown = 0.3
		


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("spikes") and Input.is_action_pressed("down") and !is_on_floor():
		velo.y = 1.5 * jump_height / jump_time + environment_velocity.y
		is_pogoing = true
		dubble_jump_used = false
		
func draw() -> void:
	if !collision_debug:
		return
	for node in room.get_children():
		if node.is_in_group("collision"):
			var color
			if node.is_in_group("slide_wall"):
				color = Color(0.21568628, 1.0, 0.0)
			elif node.is_in_group("exit"):
				color = Color(1.0, 0.6509804, 0.0)
			elif node.is_in_group("env_damage"):
				color = Color(1.0, 0.0, 0.0)
			else:
				color = Color(0.0, 0.4, 1.0)
			
			color.a = 0.7
			
			
			for collision in node.get_children():
				if collision is CollisionShape2D and collision.shape:
					var pos = collision.global_position
					var radius = collision.shape.size / 2.0
					
					drawer.draw_line(pos - radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
					drawer.draw_line(pos + radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
					drawer.draw_line(pos + radius * Vector2(-1,1), pos + radius, color, line_thickness, true)
					drawer.draw_line(pos + radius * Vector2(-1,1), pos - radius, color, line_thickness, true)
				
				if collision is CollisionPolygon2D and collision.polygon.size() > 2:
					var pos = collision.global_position
					var polygon = collision.polygon
					for point in polygon.size():
						polygon[point] += pos
					drawer.draw_polyline(polygon, color, line_thickness, true)
					drawer.draw_line(polygon[0], polygon[polygon.size() - 1], color, line_thickness, true)
