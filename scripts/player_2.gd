extends CharacterBody2D

@onready var dash: Node2D = $Dash
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ghost_timer: Timer = $GhostTimer

@export var ghost_node: PackedScene
@export var GHOST_INTERVAL: float = 0.02  # Time between ghosts, adjusted for visibility

const JUMP_VELOCITY = -450.0
const DASH_SPEED = 1500
const DASH_DURATION = 0.15  # Adjusted duration for dash
const MOVE_SPEED = 200
const DASH_DISTANCE = 2 # How far to dash when no direction is pressed

var is_jumped = false
var speed = MOVE_SPEED
var facing_direction = 1  # 1 for right, -1 for left

func _physics_process(delta: float) -> void:
	# Dash input
	if Input.is_action_just_pressed("dash") and not dash.is_on_cooldown:
		# Start the dash
		dash.start_dash(DASH_DURATION)

		if Input.get_axis("move_left", "move_right") == 0:
			# Dash in the direction the player is facing if no input
			velocity.x = 1 * DASH_DISTANCE * DASH_SPEED
		else:
			# Dash in the direction of player input
			velocity.x = Input.get_axis("move_left", "move_right") * DASH_SPEED
			print("velocity.x 1 =", velocity.x)


		# Start creating ghost images during the dash
		await create_multiple_ghosts(DASH_DURATION)

	# Adjust speed based on whether the player is dashing
	speed = DASH_SPEED if dash.is_dashing() else MOVE_SPEED

	# Apply gravity if in the air
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

	# Get player movement direction
	var direction := Input.get_axis("move_left", "move_right")

	# Handle block action
	if Input.is_action_pressed("block") and is_on_floor():
		direction = 0
		animated_sprite.play("block")

	# Play animations based on state
	if direction == 0 and not Input.is_action_pressed("block") and not Input.is_action_pressed("dash"):
		animated_sprite.play("idle")
	elif not Input.is_action_pressed("block") and not Input.is_action_pressed("dash"):
		animated_sprite.play("run")

	# Flip character sprite based on movement direction
	if direction > 0:
		facing_direction = 1
		animated_sprite.flip_h = false
	elif direction < 0:
		facing_direction = -1
		animated_sprite.flip_h = true

	# Play jump animation if in the air
	if not is_on_floor(): 
		animated_sprite.play("jump")

	# Handle player movement
	if direction:
		velocity.x = direction * speed
	else:
		# Gradually slow down when no input is given
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# Add a ghost image at the player's position
func add_ghost():
	var ghost = ghost_node.instantiate()
	ghost.set_property(animated_sprite.global_position, animated_sprite.scale, animated_sprite.flip_h)
	get_tree().current_scene.add_child(ghost)

# Create multiple ghost images over the dash duration
func create_multiple_ghosts(duration: float) -> void:
	var number_of_ghosts = int(duration / GHOST_INTERVAL)
	for i in range(number_of_ghosts):
		await get_tree().create_timer(GHOST_INTERVAL).timeout  # Wait for the interval
		add_ghost()  # Add a ghost at each interval
