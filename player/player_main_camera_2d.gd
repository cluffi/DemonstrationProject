extends Camera2D

@onready var player = $".."

const FOLLOW_SPEED = 8

func _physics_process(delta):
	global_position = global_position.lerp(player.global_position, delta * FOLLOW_SPEED)
