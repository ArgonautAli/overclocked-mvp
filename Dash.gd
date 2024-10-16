extends Node2D

@onready var timer: Timer = $Timer
@onready var cooldown_timer: Timer = $CooldownTimer

var cooldown_duration: float = 1.0  # Set the cooldown duration here (adjust as needed)
var is_on_cooldown: bool = false

# Start dash if it's not on cooldown
func start_dash(duration: float) -> void:
	if not is_on_cooldown:  # Check if the dash is on cooldown
		timer.wait_time = duration
		timer.start()
		start_cooldown()  # Start the cooldown

# Cooldown logic
func start_cooldown() -> void:
	is_on_cooldown = true
	cooldown_timer.wait_time = cooldown_duration  # Set the cooldown time
	cooldown_timer.start()  # Start the cooldown timer

# Check if the player is dashing
func is_dashing() -> bool:
	return !timer.is_stopped()

# Reset cooldown after the cooldown timer finishes
func _on_cooldown_timer_timeout() -> void:
	is_on_cooldown = false
