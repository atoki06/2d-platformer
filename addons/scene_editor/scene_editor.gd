@tool
extends EditorPlugin

var toolbar
var overlay : Node2D
var viewport
var player
var locked_layers = []


func _enter_tree() -> void:
	var scene = get_tree().get_edited_scene_root()
	scene_changed.connect(new_scene)
	#for action in InputMap.get_actions():
	#	InputMap.erase_action(action)
	toolbar = preload("res://addons/scene_editor/control.tscn").instantiate()
	toolbar.name = "Scene Editor"
	add_control_to_dock(DOCK_SLOT_LEFT_BL,toolbar)
	viewport = get_editor_interface().get_editor_viewport_2d()
	overlay = Node2D.new()
	print(overlay)
	overlay.draw.connect(draw)
	overlay.z_index = 100
	viewport.add_child(overlay)
	player = preload("res://scenes/player.tscn").instantiate()
	player.name = "player_ghost"
	viewport.add_child(player)
	
	new_scene(scene)

	
func _process(delta: float) -> void:
	overlay.queue_redraw()
	var scene = get_tree().get_edited_scene_root()
	var camera = get_editor_interface().get_editor_viewport_2d().get_global_canvas_transform()
	var viewport_size = get_editor_interface().get_editor_viewport_2d().size
	
	var button = toolbar.get_child(0).get_child(1)
	var button2 = toolbar.get_child(0).get_child(3).get_child(0)
	var button5 = toolbar.get_child(0).get_child(3).get_child(1)
	var button4 = toolbar.get_child(0).get_child(7)
	
	
	if player and scene:
		player.global_position = -camera[2] / Vector2(camera[0].x,camera[1].y) + Vector2(viewport_size) / 2 / camera[1].y
		player.visible = button4.player and scene.is_in_group("room")
	
	
	#print(camera)
	if button.parallax:
		for i in scene.get_children():
			if i.is_in_group("parallax"):
				var pos = -camera[2] / Vector2(camera[0].x,camera[1].y) + viewport_size / 2 / camera[1].y

				i.global_position = pos - pos * i.size
				i.scale = Vector2(1,1) * i.size
				var x = 1.0 / max(i.layer * -1 + 1, 1)
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

	
	
func _exit_tree() -> void:
	var scene = get_tree().get_edited_scene_root()
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
	var scene = get_tree().get_edited_scene_root()
	var camera = get_editor_interface().get_editor_viewport_2d().get_global_canvas_transform()
	var viewport_size = get_editor_interface().get_editor_viewport_2d().size
	var line_thickness = 1.0 / ((camera[0].x + camera[0].y))
		
	var button2 = toolbar.get_child(0).get_child(3).get_child(0)
	var button3 = toolbar.get_child(0).get_child(5)
	var button4 = toolbar.get_child(0).get_child(7)
	#print(-camera[2] * Vector2(camera[1].y,camera[1].y))
	#overlay.draw_line(-camera[2] / Vector2(camera[0].x,camera[1].y) + viewport_size / 2 / camera[1].y, viewport.size, Color.RED, 10, true)
	
	#var tree = Tree.new()
	#var tree_item = tree.create_item()
	if player and scene and scene.is_in_group("room"):
		if button4.player:
			var pos = player.global_position + Vector2(0.0,1.0)
			var size = Vector2(DisplayServer.screen_get_size() / 2.0  / 0.6)
			
			overlay.draw_line(pos - size, pos + size * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
			overlay.draw_line(pos + size, pos - size * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
			overlay.draw_line(pos - size, pos + size * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)
			overlay.draw_line(pos + size, pos - size * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)	

	if scene and scene.is_in_group("room") and button3.margin:
		var margin_min = scene.margin_min * 100
		var margin_max = scene.margin_max * 100
		var cam_radius = Vector2(DisplayServer.screen_get_size() / 2  / 0.6)
		overlay.draw_line(margin_min - cam_radius, Vector2(margin_max.x,margin_min.y) + cam_radius * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
		overlay.draw_line(margin_max + cam_radius, Vector2(margin_min.x,margin_max.y) - cam_radius * Vector2(1,-1), Color(1.0, 0.0, 0.0), line_thickness, true)
		overlay.draw_line(margin_min - cam_radius, Vector2(margin_min.x,margin_max.y) + cam_radius * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)
		overlay.draw_line(margin_max + cam_radius, Vector2(margin_max.x,margin_min.y) - cam_radius * Vector2(-1,1), Color(1.0, 0.0, 0.0), line_thickness, true)
	
	if button2.collision and scene.is_in_group("room"):
		for i in scene.get_children():
			if i.is_in_group("collision"):
				

				var color = i.modulate
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
						var pos = collision.global_position
						var radius = collision.shape.size / 2.0
						
						overlay.draw_line(pos - radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
						overlay.draw_line(pos + radius, pos + radius * Vector2(1,-1), color, line_thickness, true)
						overlay.draw_line(pos + radius * Vector2(-1,1), pos + radius, color, line_thickness, true)
						overlay.draw_line(pos + radius * Vector2(-1,1), pos - radius, color, line_thickness, true)
						
					if collision is CollisionPolygon2D and collision.polygon.size() > 2:
						var pos = collision.global_position
						var polygon = collision.polygon
						for point in polygon.size():
							polygon[point] += pos
						overlay.draw_polyline(polygon, color, line_thickness, true)
						overlay.draw_line(polygon[0], polygon[polygon.size() - 1], color, line_thickness, true)
						
					
func new_scene(scene):
	var layermenu = toolbar.get_child(0).get_child(9).get_child(0)
	for child in layermenu.get_children():
		child.queue_free()
		
	for layer in scene.get_children():
		if layer.is_in_group("sprite_layer"):
			var button = Button.new()
			button.text = layer.name
			var style = load("res://addons/scene_editor/control.tres")
			button.set("theme_override_styles/focus",StyleBoxEmpty.new())
			button.set("theme_override_styles/hover",style)
			button.set("theme_override_styles/pressed",style)
			button.set("theme_override_styles/normal",style)
			layermenu.add_child(button)
			button.pressed.connect(set_layer.bind(button,layer,scene))
		
func set_layer(button,layer,scene):
	var selected = true
	var layermenu = toolbar.get_child(0).get_child(9).get_child(0)
	for child in layermenu.get_children():
		if child == button and child.modulate == Color(1.0, 1.0, 1.0):
			child.modulate = Color(0.0, 0.6, 1.0)
		else:
			child.modulate = Color(1.0, 1.0, 1.0)
		if child == button and child.modulate == Color(1.0, 1.0, 1.0):
			selected = false
	
	var behind = true
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