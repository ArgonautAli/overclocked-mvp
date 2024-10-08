extends Node2D

@onready var timer: Timer = $Timer

func start_dash(duration):
	timer.wait_time = duration
	timer.start()
	
func is_dashing():
	return !timer.is_stopped()
