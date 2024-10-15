extends CharacterBody2D

@onready var dash: Node2D = $Dash
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const JUMP_VELOCITY = -450.0
const DASH_SPEED = 1500
const DASH_DURATION = 0.2  # Adjust duration as needed
const MOVE_SPEED = 200
const DASH_DISTANCE = 1000  # How far to dash when no direction is pressed

var is_jumped = false
var speed = MOVE_SPEED
var facing_direction = 1  # 1 for right, -1 for left

func _physics_process(delta: float) -> void:
	# Start dash
	if Input.is_action_just_pressed("dash"):
		dash.start_dash(DASH_DURATION)
		if Input.get_axis("move_left", "move_right") == 0:
			# Dash in the direction the player is facing if no input
			velocity.x = facing_direction * DASH_DISTANCE

	# Adjust speed based on dash state
	speed = DASH_SPEED if dash.is_dashing() else MOVE_SPEED

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle double jump
	if Input.is_action_just_pressed("jump") and is_jumped:
		is_jumped = false
		velocity.y = JUMP_VELOCITY

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jumped = true
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	# Handle block
	if Input.is_action_pressed("block") and is_on_floor():
		direction = 0
		animated_sprite.play("block")

	# Play animation based on direction
	if direction == 0 and not Input.is_action_pressed("block"):
		animated_sprite.play("idle")
	elif not Input.is_action_pressed("block"):
		animated_sprite.play("run")

	# Flip character based on direction
	if direction > 0:
		facing_direction = 1
		animated_sprite.flip_h = false
	elif direction < 0:
		facing_direction = -1
		animated_sprite.flip_h = true 

	if not is_on_floor(): 
		animated_sprite.play("jump")

	# Handle movement
	if direction:
		velocity.x = direction * speed
	else:
		# Gradually slow down to 0 when no input is given
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
