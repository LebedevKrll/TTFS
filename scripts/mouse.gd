extends CharacterBody2D

@export var follow_speed: float = 30.0

func _physics_process(delta):
	global_position = global_position.lerp(get_global_mouse_position(), follow_speed * delta)
