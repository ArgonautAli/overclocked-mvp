extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const DASH_SPEED = 2000
const DASH_DURATION = 0.2  # Dash duration in seconds
const MOVE_SPEED = 200
const GRAVITY = Vector2(0, 900)

var is_jumped = false
var facing_direction = Vector2.RIGHT # Initial facing direction is right
var dash_time_left = 0.0  # Track remaining dash time
var is_dashing = false  # Track whether currently dashing

@onready var dash: Node2D = $Dash
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Apply gravity if not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY.y * delta

	# Handle double jump
	if Input.is_action_just_pressed("jump") and is_jumped:
		is_jumped = false
		velocity.y = JUMP_VELOCITY

	# Handle normal jump when on the floor
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jumped = true
		velocity.y = JUMP_VELOCITY

	# Handle crouch animation
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		animated_sprite.play("crouch")

	# Get horizontal input (left/right movement)
	var direction := Input.get_axis("move_left", "move_right")

	# Handle facing direction when moving
	if direction != 0:
		facing_direction = Vector2(direction, 0).normalized()  # Update the facing direction when the player moves

	# Handle blocking when on the floor
	if Input.is_action_pressed("block") and is_on_floor():
		direction = 0
		animated_sprite.play("block")

	# Handle animation states
	if direction == 0 and not Input.is_action_pressed("block") and not Input.is_action_pressed("crouch") and not Input.is_action_just_pressed("dash"):
		animated_sprite.play("idle")
	elif direction != 0 and not Input.is_action_pressed("block"):
		animated_sprite.play("run")
		animated_sprite.flip_h = direction < 0  # Flip sprite based on direction
	if not is_on_floor():
		animated_sprite.play("jump")

	# Handle movement and dashing
	if is_dashing:
		# If currently dashing, set velocity based on facing direction
		print("velocity.x ",velocity.x )
		velocity.x = facing_direction.x * DASH_SPEED
		dash_time_left -= delta  # Decrease remaining dash time
		if dash_time_left <= 0:  # Check if dash duration is over
			is_dashing = false  # Reset dashing state
			velocity.x = 0  # Stop dashing speed
	else:
		# Handle normal movement
		if direction != 0:
			velocity.x = direction * MOVE_SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)

		# Handle dash input
		if Input.is_action_just_pressed("dash"):
			if not is_dashing:  # Only dash if not currently dashing
				dash_time_left = DASH_DURATION  # Reset the dash timer
				is_dashing = true  # Set dashing state to true
				dash.start_dash(DASH_DURATION)  # Start the dash animation
				animated_sprite.play("jump")  # Optionally play the jump animation

	# Move the character using move_and_slide
	move_and_slide()
