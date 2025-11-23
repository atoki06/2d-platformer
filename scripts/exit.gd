extends room_exit
@export var disabled = false

func _ready() -> void:
	set_player_position()
	await get_tree().create_timer(0.4).timeout
	player.is_black_screen = false
	player.move_lock = 0.0

func _process(delta: float) -> void:
	countdown_buffer(delta)

	if is_player_leaving() and !disabled:
		switch_room()
