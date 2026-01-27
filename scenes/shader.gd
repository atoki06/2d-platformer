extends ColorRect

var target : float = 0.0

func _ready() -> void:
	show()
	
	Global.player_pos.connect(change_player_pos)
	Global.black_screen.connect(black_screen)
	
func _process(delta: float) -> void:
	var black_strength : StringName = "shader_parameter/scale"
	var current_black : float = material.get(black_strength)
	material.set(black_strength, current_black + (target - current_black) * delta * 10.0)

func change_player_pos(pos : Vector2) -> void:
	var relative_pos : Vector2 = (pos - get_viewport().get_camera_2d().position + get_viewport_rect().size / 2) / Vector2(DisplayServer.screen_get_size())
	material.set("shader_parameter/player_pos", relative_pos)

func black_screen(target : float) -> void:
	self.target = target
