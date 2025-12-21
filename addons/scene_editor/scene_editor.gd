@tool
extends EditorPlugin

#undo redo
var toolbar : Node
var overlay : Node2D
var viewport : Node
var scene : Node
var player : Node
var locked_layers : Array[Node] = []
var line_thickness : float
var selected_layer : Node
var labels: Array[Node] = []
var buttons: Array[Node] = []
var button_scenes : Array = []

var dragging : bool = false
var dragging_position : Vector2
var viewport_type : String
const dragging_distance : float = 200
var last_mouse_position : Vector2
var last_selection : Array[Node]
var buttons_down : Array[int] = []
var undo_nr : int = 0
var undo_positions : Array[Vector2]

func _enter_tree() -> void:
	scene = get_tree().get_edited_scene_root()
	scene_changed.connect(new_scene)
	toolbar = preload("res://addons/scene_editor/control.tscn").instantiate()
	toolbar.name = "Scene Editor"
	add_control_to_dock(DOCK_SLOT_LEFT_BL,toolbar)
	viewport = get_editor_interface().get_editor_viewport_2d()
	overlay = Node2D.new()
	overlay.draw.connect(draw)
	overlay.z_index = 100
	viewport.add_child(overlay)
	player = preload("res://scenes/player.tscn").instantiate()
	player.name = "player_ghost"
	viewport.add_child(player)
	main_screen_changed.connect(set_viewport)
	
	new_scene(scene)


func _process(delta: float) -> void:
	overlay.queue_redraw()
	scene = get_tree().get_edited_scene_root()
	var camera : Transform2D = get_editor_interface().get_editor_viewport_2d().get_global_canvas_transform()
	var viewport_size : Vector2i = get_editor_interface().get_editor_viewport_2d().size
	
	var button : Node = toolbar.get_child(0).get_child(1)
	var button2 : Node = toolbar.get_child(0).get_child(3).get_child(0)
	var button5 : Node = toolbar.get_child(0).get_child(3).get_child(1)
	var button4 : Node = toolbar.get_child(0).get_child(7)
	
	
	if player and scene:
		player.global_position = -camera[2] / Vector2(camera[0].x,camera[1].y) + Vector2(viewport_size) / 2 / camera[1].y + Vector2(0,100)
		player.visible = button4.player and scene.is_in_group("room")
	
	if button.parallax:
		for i in scene.get_children():
			if i.is_in_group("parallax"):
				var pos : Vector2 = -camera[2] / Vector2(camera[0].x,camera[1].y) + viewport_size / 2 / camera[1].y

				i.global_position = pos - pos * i.size
				i.scale = Vector2(1,1) * i.size
				var x : float = 1.0 / max(i.layer * -1 + 1, 1)
				i.modulate = Color(x,x,x)
	else:
		if scene:
			for i in scene.get_children():
				if i.is_in_group("parallax"):
					i.global_position = Vector2(0,0)
					i.scale = Vector2(1,1)
				
	if scene:
		for i in scene.get_children():
			if i.is_in_group("collision"):
				i.visible = button2.collision
				if button5.lock:
					i.set_meta("_edit_lock_", null)
				elif !locked_layers.has(i):
					i.set_meta("_edit_lock_", true)
				for child in i.get_children():
					if button5.lock:
						child.set_meta("_edit_lock_", null)
					elif !locked_layers.has(i):
						child.set_meta("_edit_lock_", true)
		for i in scene.get_children():
			if i.is_in_group("2d_sprites"):
				if button5.lock:
					i.set_meta("_edit_lock_", true)
				elif !locked_layers.has(i):
					i.set_meta("_edit_lock_", null)
				for child in i.get_children():
					if button5.lock:
						child.set_meta("_edit_lock_", true)
					elif !locked_layers.has(i):
						child.set_meta("_edit_lock_", null)
	
	create_exit_overlay()
	
func _exit_tree() -> void:
	
	for i in range(labels.size()):
		labels.pop_at(0).queue_free()
	
	for i in range(buttons.size()):
		buttons.pop_at(0).queue_free()
		

	var scene : Node = get_tree().get_edited_scene_root()
	if scene:
		for i in scene.get_children():
			if i.is_in_group("parallax"):
				i.global_position = Vector2(0,0)
				i.scale = Vector2(1,1)
	remove_control_from_docks(toolbar)
	
	if scene:
		for i in scene.get_children():
			if i.is_in_group("collision"):
				i.visible = false
				i.set_meta("_edit_lock_", null)
				for child in i.get_children():
					child.set_meta("_edit_lock_", null)
		for i in scene.get_children():
			if i.is_in_group("2d_sprites"):
				i.visible = true
				i.set_meta("_edit_lock_", null)
				for child in i.get_children():
					child.set_meta("_edit_lock_", null)
	
	
	toolbar.free()
	overlay.free()
	if player:
		player.free()
	
func draw():
	var camera : Transform2D = get_editor_interface().get_editor_viewport_2d().get_global_canvas_transform()
	var viewport_size : Vector2i = get_editor_interface().get_editor_viewport_2d().size
	var selection : Array[Node] = get_editor_interface().get_selection().get_selected_nodes()
	line_thickness = 1.0 / ((camera[0].x + camera[0].y))
		
	var button2 : Node = toolbar.get_child(0).get_child(3).get_child(0)
	var button3 : Node = toolbar.get_child(0).get_child(5)
	var button4 : Node = toolbar.get_child(0).get_child(7)
	
	if player and scene and scene.is_in_group("room"):
		if button4.player:
			var pos : Vector2 = player.global_position - Vector2(0.0,100)
			var size : Vector2 = Vector2(DisplayServer.screen_get_size() / 2.0  / 0.6)
			
			overlay.draw_line(pos - size, pos + size * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
			overlay.draw_line(pos + size, pos - size * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
			overlay.draw_line(pos - size, pos + size * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)
			overlay.draw_line(pos + size, pos - size * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)	

	if scene and scene.is_in_group("room") and button3.margin:
		var margin_min : Vector2 = scene.margin_min * 100
		var margin_max : Vector2 = scene.margin_max * 100
		var cam_radius : Vector2 = Vector2(DisplayServer.screen_get_size() / 2  / 0.6)
		overlay.draw_line(margin_min - cam_radius, Vector2(margin_max.x,margin_min.y) + cam_radius * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
		overlay.draw_line(margin_max + cam_radius, Vector2(margin_min.x,margin_max.y) - cam_radius * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
		overlay.draw_line(margin_min - cam_radius, Vector2(margin_min.x,margin_max.y) + cam_radius * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)
		overlay.draw_line(margin_max + cam_radius, Vector2(margin_max.x,margin_min.y) - cam_radius * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)
	
	if button2.collision and scene.is_in_group("room"):
		for i in scene.get_children():
			if i.is_in_group("collision"):
				

				var color : Color = i.modulate
				if i.is_in_group("slide_wall"):
					color = Color(0.21568628, 1.0, 0.0)
				elif i.is_in_group("exit"):
					color = Color(1.0, 0.6509804, 0.0)
				elif i.is_in_group("env_damage"):
					color = Color(1.0, 0.0, 0.0)
				else:
					color = Color(0.0, 0.4, 1.0)
				
				color.a = 0.7
				
				for collision in i.get_children():
					collision.modulate.a = 0.0
					if collision is CollisionShape2D and collision.shape:
						var pos : Vector2 = collision.global_position
						var radius : Vector2 = collision.shape.size / 2.0
						
						overlay.draw_line(pos - radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
						overlay.draw_line(pos + radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
						overlay.draw_line(pos + radius * Vector2(-1,1), pos + radius, color, line_thickness, true)
						overlay.draw_line(pos + radius * Vector2(-1,1), pos - radius, color, line_thickness, true)
						
					if collision is CollisionPolygon2D and collision.polygon.size() > 2:
						var pos : Vector2 = collision.global_position
						var polygon : PackedVector2Array = collision.polygon
						for point in polygon.size():
							polygon[point] += pos
						overlay.draw_polyline(polygon, color, line_thickness, true)
						overlay.draw_line(polygon[0], polygon[polygon.size() - 1], color, line_thickness, true)
	draw_near_mouse()
	var max : Vector2
	var min : Vector2
	var sprite = false
	for i in selection:
		if i is EnvironmentSprite:
			sprite = true
			var pos = i.global_position
			if !max:
				max = pos
			if !min:
				min = pos
			max.x = max(pos.x,max.x)
			min.x = min(pos.x,min.x)
			max.y = max(pos.y,max.y)
			min.y = min(pos.y,min.y)
	if selection and sprite:
		var rect = Rect2(min - Vector2(1,1) * dragging_distance,max - min + Vector2(1,1) * dragging_distance * 2)
		overlay.draw_rect(rect, Color(1.0,1.0,1.0,0.5), false , line_thickness)
		

						
func draw_near_mouse():
	var mouse = get_editor_interface().get_editor_viewport_2d().get_mouse_position()
	const dist = 350
	if scene:
		for layer in scene.get_children():
			if layer.is_in_group("sprite_layer") and layer == selected_layer:
				for child in layer.get_children():
					var pos = child.global_position
					var distance = pos.distance_to(mouse)
					if distance < dist:
						overlay.draw_circle(child.global_position,line_thickness * 2,Color(1,1,1,1 - distance / dist))
	
					
func new_scene(scene):
	var layermenu : Node = toolbar.get_child(0).get_child(9).get_child(0)
	for child in layermenu.get_children():
		child.queue_free()
		
	for layer in scene.get_children():
		if layer.is_in_group("sprite_layer"):
			var button : Button = Button.new()
			button.text = layer.name
			var style : StyleBox = load("res://addons/scene_editor/control.tres")
			button.set("theme_override_styles/focus",StyleBoxEmpty.new())
			button.set("theme_override_styles/hover",style)
			button.set("theme_override_styles/pressed",style)
			button.set("theme_override_styles/normal",style)
			layermenu.add_child(button)
			button.pressed.connect(set_layer.bind(button,layer,scene))
		
func set_layer(button,layer,scene):
	var selected : bool = true
	var layermenu : Node = toolbar.get_child(0).get_child(9).get_child(0)
	for child in layermenu.get_children():
		if child == button and child.modulate == Color(1.0, 1.0, 1.0):
			child.modulate = Color(0.0, 0.6, 1.0)
			selected_layer = layer
		else:
			child.modulate = Color(1.0, 1.0, 1.0)
		if child == button and child.modulate == Color(1.0, 1.0, 1.0):
			selected = false
			selected_layer = null
	
	var behind : bool = true
	for child in scene.get_children():
		child.set_display_folded(true)
		if child.is_in_group("sprite_layer") and child == layer or !selected:
			child.visible = true
			behind = false
			child.set_meta("_edit_lock_", null)
			for i in child.get_children():
				i.set_meta("_edit_lock_", null)
			if locked_layers.has(child):
				locked_layers.erase(child)
		elif child.is_in_group("sprite_layer"):
			child.visible = behind
			child.set_meta("_edit_lock_", true)
			for i in child.get_children():
				i.set_meta("_edit_lock_", true)
			if !locked_layers.has(child):
				locked_layers.append(child)
				
func change_mode():
	var selection = get_editor_interface().get_selection()
	var mouse = get_editor_interface().get_editor_viewport_2d().get_mouse_position()
	var cancel_event = InputEventAction.new()
	cancel_event.action = "Alt + W"
	cancel_event.pressed = true
	Input.parse_input_event(cancel_event)
	var command = get_editor_interface()
	

func _input(event: InputEvent) -> void:
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	for i in selection:
		if !i is EnvironmentSprite:
			return
	if viewport_type != "2D":
		return
	var camera = get_editor_interface().get_editor_viewport_2d().get_global_canvas_transform()
	var viewport = get_editor_interface().get_editor_viewport_2d()
	var mouse = get_editor_interface().get_editor_viewport_2d().get_mouse_position()
	var undo = get_editor_interface().get_editor_undo_redo()
	var near = false
	const distance = 500
	var index
	
	var viewport_position = -camera[2] / Vector2(camera[0].x,camera[1].y)
	var is_mouse_in_viewport = Rect2(viewport_position, viewport.size / camera[1].y).has_point(mouse)
	
	if event is InputEventMouseButton:
		index = event.button_index
	
	var max : Vector2
	var min : Vector2
	for i in selection:
		var pos = i.global_position
		if !max:
			max = pos
		if !min:
			min = pos
		max.x = max(pos.x,max.x)
		min.x = min(pos.x,min.x)
		max.y = max(pos.y,max.y)
		min.y = min(pos.y,min.y)
	var rect = Rect2(min - Vector2(1,1) * dragging_distance,max - min + Vector2(1,1) * dragging_distance * 2)
	var rect_mouse = Rect2(mouse,Vector2(0,0))
	
	for i in selection:
		if rect.intersects(rect_mouse):
			near = true
	
	var handled = false
	if event is InputEventMouseButton:
		if event.is_pressed() and !buttons_down.has(event.button_index):
			buttons_down.append(event.button_index)
		if !event.is_pressed() and buttons_down.has(event.button_index):
			buttons_down.erase(event.button_index)
		
		
		if index == MOUSE_BUTTON_RIGHT:
				handled = true
		if selection and !near:
			handled = true
		if near:
			handled = true
		if index == MOUSE_BUTTON_LEFT and selection:
			handled = true
		if index == MOUSE_BUTTON_WHEEL_DOWN or index == MOUSE_BUTTON_WHEEL_UP or index == MOUSE_BUTTON_MIDDLE:
			handled = false
	
		if is_mouse_in_viewport:
			if index == MOUSE_BUTTON_LEFT and selection and !near:
				get_editor_interface().get_selection().clear()
			
			if index == MOUSE_BUTTON_RIGHT:
				get_editor_interface().get_selection().clear()
		
		if index == MOUSE_BUTTON_LEFT:
			if event.is_pressed() and near and selection == last_selection and selection != []:
				dragging = true
				undo_nr += 1
				undo_positions = []
				for i in selection:
					undo_positions.append(i.global_position)
			elif !event.is_pressed():
				dragging = false
				
	
	if event is InputEventMouseMotion:
		if selection and !near:
			handled = true
		if selection:
			handled = true
		if buttons_down.has(MOUSE_BUTTON_MIDDLE):
			handled = false
	
	if !is_mouse_in_viewport and event is InputEventMouseButton:
		handled = false
		
	if !is_mouse_in_viewport and event is InputEventMouseMotion and buttons_down.has(MOUSE_BUTTON_LEFT):
		handled = false
	
	if event is InputEventMouseButton and !near and buttons_down.has(MOUSE_BUTTON_LEFT):
		handled = false
		
	if handled:
		get_viewport().set_input_as_handled()
	
	var node_index = 0
	if dragging and is_mouse_in_viewport:
		for node in selection:
			var last_position = undo_positions[node_index]
			change_position("position changed" + str(undo_nr), node, "global_position", node.global_position + mouse - last_mouse_position, last_position)
			node_index += 1
			#i.global_position += mouse - last_mouse_position
	for button in buttons:
		var button_rect = Rect2(button.global_position ,button.size * button.scale)
		if button_rect.has_point(mouse) and buttons_down.has(MOUSE_BUTTON_LEFT):
			switch_scene(button_scenes[buttons.find(button)])
	
	
	last_mouse_position = mouse
	last_selection = selection
		
func set_viewport(type : String):
	viewport_type = type

func change_position(undo_name : String, node : Node, property : String, last_value, new_value):
	var undo_redo = get_editor_interface().get_editor_undo_redo()
	undo_redo.create_action(undo_name, UndoRedo.MERGE_ALL)
	undo_redo.add_do_property(node, property, last_value)
	undo_redo.add_undo_property(node, property, new_value)
	undo_redo.commit_action()
	
func create_exit_overlay():
	for i in range(labels.size()):
		labels.pop_at(0).queue_free()
	
	for i in range(buttons.size()):
		buttons.pop_at(0).queue_free()
		
	for i in range(button_scenes.size()):
		button_scenes.pop_at(0)
	
	if !scene:
		return
	for exit in scene.get_children():
		if exit.is_in_group("exit"):
			var label = Label.new()
			labels.append(label)
			label.text = str(exit.index) + " --> " + str(exit.room_entry_index)
			viewport.add_child(label)
			label.scale *= 2
			label.global_position = exit.global_position + Vector2(-label.size.x,-175)
			label.z_index = 100
			var exit_button = Button.new()
			buttons.append(exit_button)
			button_scenes.append(exit.room_path)
			exit_button.text = exit.room_path
			viewport.add_child(exit_button)
			exit_button.scale *= 2
			exit_button.size.y = 50
			exit_button.global_position = exit.global_position + Vector2(-label.size.x,-125)
			exit_button.z_index = 100
			

func switch_scene(scene):
	get_editor_interface().open_scene_from_path(scene)

		
