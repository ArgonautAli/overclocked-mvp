extends Node2D

@onready var timer: Timer = $Timer
var dashing: bool = false

func _ready():
	# Connect the timeout signal to end the dash when the timer finishes
	timer.timeout.connect(_on_dash_end)

func start_dash(duration):
	dashing = true  # Set dashing state to true when starting dash
	timer.wait_time = duration
	timer.start()

func is_dashing():
	return dashing  # Simply return the dashing state

func _on_dash_end():
	dashing = false  # Set dashing state to false when timer finishes
