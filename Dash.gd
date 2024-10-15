extends Node2D

@onready var timer: Timer = $Timer

func start_dash(duration: float) -> void:
	timer.wait_time = duration
	timer.start()

func is_dashing() -> bool:
	return !timer.is_stopped()
