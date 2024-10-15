extends Node2D

@onready var timer: Timer = $Timer
@onready var cooldown_timer: Timer = $CooldownTimer

var cooldown_duration: float = 0.02  # Set the cooldown duration here
var is_on_cooldown: bool = false

func start_dash(duration: float) -> void:
	if not is_on_cooldown:  # Check if the dash is on cooldown
		timer.wait_time = duration
		timer.start()
		start_cooldown()  # Start the cooldown

func start_cooldown() -> void:
	is_on_cooldown = true
	cooldown_timer.start()  # Start the cooldown timer


func is_dashing() -> bool:
	return !timer.is_stopped()


func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown = false 
