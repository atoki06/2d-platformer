extends Control
var paused : bool = false

func _ready() -> void:
	
	hide()
	#Global.pause.connect(pause.bind(true))
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		pause(!paused)
	
func pause(value : bool) -> void:
	visible = value
	paused = value
	get_tree().paused = value


func _input_resume(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		pause(false)


func _input_settings(event: InputEvent) -> void:
	pass # Replace with function body.


func _input_quit(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		get_tree().quit()
