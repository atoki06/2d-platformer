@tool
extends EditorPlugin
var input = {
	"CTRL" : KEY_CTRL,
	"D" : KEY_D
}

func _enter_tree() -> void:
	for action in input:
		var action_key = input[action]
		var event
		if action_key < 30:
			event = InputEventMouseButton.new()
			event.button_index = action_key
		else:
			event = InputEventKey.new()
			event.keycode = action_key
		if !InputMap.has_action(action):
			InputMap.add_action(action)
			InputMap.action_add_event(action, event)
	# Initialization of the plugin goes here.
	pass


func _process(delta: float) -> void:
	var scene = get_tree().get_edited_scene_root()
	var collision
	if Input.is_action_pressed("CTRL") and Input.is_action_just_pressed("D"):
		print(true)
		for i in get_editor_interface().get_selection().get_selected_nodes():
			if i is CollisionShape2D:
				i.shape = i.shape.duplicate()
	
	
func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
	
