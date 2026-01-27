extends CharacterBody2D

#composition
@onready var physics_component : PhysicsComponent = $PhysicsComp
@onready var movement_component : MovementComponent = $MovementComp

#node connections
@onready var soundtrack_player : Node = $soundtrack_player
@onready var attack_hitbox : Node = $attack/hitbox
@onready var sound_player : Node = $soundplayer
@onready var detection : Node = $detection
@onready var attack_body : Node = $attack
@onready var camera : Node = $camera
@onready var hitbox : Node = $hitbox
@onready var animation : AnimationComponent = $AnimationComp

#const
const camera_position : Vector2 = Vector2(0,0)
const line_thickness : float = 2.0
const dubble_jump_time : float = 0.3
const wall_jump_time : float = 0.3
const jump_time : float = 0.4
const jump_down_multiplier : float = 1.8

const jump_height : int = -450
const dubble_jump_height : int = -350
const wall_jump_height : int = -350
const walking_speed : int = 800
const wall_slide_speed : int = -700

#variables
var is_camera_limited : bool = false
var dubble_jump_used : bool = false
var last_is_on_floor : bool = false
var is_black_screen : bool = false
var collision_debug : bool = false
var is_pogoing : bool = false
var new_room : bool = false

var wall_jump_direction : float = 0.0
var camera_speed_target : float = 8.0
var looking_direction : float = 0.0
var wall_jump_timer : float = 0.0
var attack_cooldown : float = 0.3
var attack_timer : float = 0.2
var camera_speed : float = 8.0
var move_lock : float = 0.0

var environment_velocity : Vector2 = Vector2(0,0)
var camera_target : Vector2 = Vector2(0,0)
var quick_spawn : Vector2 = Vector2(0,0)
var gravity : Vector2 = Vector2(0,12)
var velo : Vector2 = Vector2(0,0)

var drawer : Node
var room : Node

#signals
signal landing

#input
var input : Dictionary = {
	"esc" : KEY_ESCAPE,
	"up" : KEY_W,
	"left" : KEY_A,
	"down" : KEY_S,
	"right" : KEY_D,
	"jump" : KEY_SPACE,
	"debug" : KEY_B,
	"attack" : MOUSE_BUTTON_LEFT,
	"collision_debug" : KEY_N
}

#debug
var debug_open : bool = false

func _ready() -> void:
	#animation.start_animation(0,8,true)
	
	#connect signals
	landing.connect(_landing)
	
	drawer = Node2D.new()
	drawer.top_level = true
	drawer.z_index = 20
	drawer.draw.connect(draw)
	add_child(drawer)
	var sound : AudioStream = load("res://sounds/Shoot_combined.wav")
	sound_player.stream = sound
	soundtrack_player.playing = false
	camera.visible = !Engine.is_editor_hint()
	visible = true
	for action : StringName in InputMap.get_actions():
		InputMap.erase_action(action)
	
		
	for action : StringName in input:
		var action_key : int = input[action]
		var event : InputEvent
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
	if Input.is_action_just_pressed("debug"):
		toggle_debug_mode()
	
	if Input.is_action_just_pressed("esc"):
		Global.emit_signal("pause")
	
	#fog.set("shader_parameter/size",0.37 * clamp(near_exit / (exit_size * 4) + 0.75,0.5,1.0))

func _physics_process(delta: float) -> void:
	Global.emit_signal("black_screen", float(is_black_screen))
	
	attack_timer = max(attack_timer - delta, 0.0)
	attack_cooldown = max(attack_cooldown - delta, 0.0)
	move_lock = max(move_lock - delta, 0.0)
	wall_jump_timer = max(wall_jump_timer - delta, 0.0)
	
	if !attack_timer:
		attack_body.visible = false
		attack_body.monitoring = false
		attack_hitbox.disabled = true
	

	if wall_jump_timer:
		velo.x = wall_jump_direction
		
	#attack
	if Input.is_action_just_pressed("attack") and !attack_cooldown:
		attack()
	
	physics_component.paused = move_lock
	
	if Input.is_action_just_pressed("jump"):
		movement_component.set_max_air_jumps(1)
		movement_component.trigger_jump()
	
	movement_component.cancel_jump()
	var right : bool = Input.is_action_pressed("right")
	var left : bool = Input.is_action_pressed("left")
	
	var direction : float = int(right) - int(left)
	movement_component.walk(direction)
	
	if direction:
		looking_direction = direction
	
	Global.emit_signal("player_pos",global_position)
	Global.emit_signal("camera_pos",camera.global_position)
	#global_position.z = 0
	
	#move camera
	room = Global.current_scene
	var cam_pos_x : float = clamp(global_position.x,room.margin_min.x * 100,room.margin_max.x * 100)
	var cam_pos_y : float = clamp(global_position.y,room.margin_min.y * 100,room.margin_max.y * 100)
	var camera_direction : Vector2 = (Vector2(cam_pos_x,cam_pos_y) + camera_position - camera.global_position)
	camera.global_position += camera_direction * delta * camera_speed
	camera.global_position = Vector2(snapped(camera.global_position.x,1),snapped(camera.global_position.y,1))

	if is_on_floor() and !last_is_on_floor:
		emit_signal("landing")
	
	#saving for next frame:
	last_is_on_floor = is_on_floor()

#func int_key_pressed(key):
#	return int(Input.is_key_label_pressed(key))

	
func instant_respawn(falling : bool = false) -> void:
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
	
func toggle_debug_mode() -> void:
	debug_open = !debug_open
	for child : Node in get_all_children(get_tree().get_root()):
		if child is CollisionPolygon3D or child is CollisionShape3D:
			child.debug_color.a = 0.4 * int(debug_open)
			child.debug_fill = false
		
	
func get_all_children(in_node : Node ,arr : Array = []) -> Array:
	arr.push_back(in_node)
	for child : Node in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr
	

func attack() -> void:
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
	for node : Node in room.get_children():
		if node.is_in_group("collision"):
			var color : Color
			if node.is_in_group("slide_wall"):
				color = Color(0.21568628, 1.0, 0.0)
			elif node.is_in_group("exit"):
				color = Color(1.0, 0.6509804, 0.0)
			elif node.is_in_group("env_damage"):
				color = Color(1.0, 0.0, 0.0)
			else:
				color = Color(0.0, 0.4, 1.0)
			color.a = 0.7
			
			for collision : Node in node.get_children():
				if collision is CollisionShape2D and collision.shape:
					var pos : Vector2 = collision.global_position
					var radius : Vector2 = collision.shape.size / 2.0
					
					drawer.draw_line(pos - radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
					drawer.draw_line(pos + radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
					drawer.draw_line(pos + radius * Vector2(-1,1), pos + radius, color, line_thickness, true)
					drawer.draw_line(pos + radius * Vector2(-1,1), pos - radius, color, line_thickness, true)
				
				if collision is CollisionPolygon2D and collision.polygon.size() > 2:
					var pos : Vector2 = collision.global_position
					var polygon : PackedVector2Array = collision.polygon
					for point : int in polygon.size():
						polygon[point] += pos
					drawer.draw_polyline(polygon, color, line_thickness, true)
					drawer.draw_line(polygon[0], polygon[polygon.size() - 1], color, line_thickness, true)

func _landing() -> void:
	var fps : int = 10
	var time : float = 0.2
	var strength : float = 0.0
	var timer : SceneTreeTimer = get_tree().create_timer(time)
	for i : int in range(fps):
		if timer.time_left:
			await get_tree().create_timer(time/fps).timeout
			_camera_shake(strength * (timer.time_left / time))
	_camera_shake(0)
	
func _camera_shake(_range : float) -> void:
	camera.offset = Vector2(randf_range(-_range,_range),randf_range(-_range,_range))
