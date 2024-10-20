extends CharacterBody2D

@onready var dash: Node2D = $Dash
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ghost_timer: Timer = $GhostTimer
@onready var camera_2d: Camera2D = $Camera2D
@onready var dash_fx: AnimatedSprite2D = $dashFx

@export var ghost_node: PackedScene
@export var GHOST_INTERVAL: float = 0.01  # Time between ghosts, adjusted for visibility
@export var max_offset: Vector2 = Vector2(100, 75)  # Maximum shake offset for X and Y
@export var max_roll: float = 0.05  # Maximum camera roll (rotation) during shake
@export var decay_speed: float = 3.0  # Speed at which the shake decays
@export var oscillation_frequency: float = 10.0  # Speed of oscillation (elastic effect)

var trauma: float = 0.0  # Shake intensity
var shake_timer: float = 0.0  # Timer for oscillation


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
		add_trauma(0.07)  # Trigger shake with moderate intensity
		dash.start_dash(DASH_DURATION)

		if Input.get_axis("move_left", "move_right") == 0:
			# Dash in the direction the player is facing if no input
			velocity.x = facing_direction * DASH_DISTANCE * DASH_SPEED
		else:
			# Dash in the direction of player input
			velocity.x = Input.get_axis("move_left", "move_right") * DASH_SPEED
			print("velocity.x 1 =", velocity.x)
		
		# Start creating ghost images during the dash
		await create_multiple_ghosts(DASH_DURATION)
	
		dash_fx.stop()
		dash_fx.visible = false

		

	# Adjust speed based on whether the player is dashing
	speed = DASH_SPEED if dash.is_dashing() else MOVE_SPEED
	
	shake_camera(delta)


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
	dash_fx.global_position.x = global_position.x - 30 if facing_direction == 1 else global_position.x + 30
	dash_fx.visible = true
	dash_fx.play("gray_fx")
	ghost.set_property(animated_sprite.global_position, animated_sprite.scale, animated_sprite.flip_h)
	get_tree().current_scene.add_child(ghost)

# Create multiple ghost images over the dash duration
func create_multiple_ghosts(duration: float) -> void:
	var number_of_ghosts = int(duration / GHOST_INTERVAL)
	for i in range(number_of_ghosts):
		await get_tree().create_timer(GHOST_INTERVAL).timeout  # Wait for the interval
		add_ghost()  # Add a ghost at each interval
		
		
func shake_camera(delta: float) -> void:
	if trauma > 0.0:
		# Oscillate the shake using sine for X and cosine for Y
		shake_timer += delta * oscillation_frequency
		var shake_x = sin(shake_timer) * trauma * max_offset.x
		var shake_y = cos(shake_timer * 1.5) * trauma * max_offset.y  # Different frequency for Y axis
		var roll = sin(shake_timer) * trauma * max_roll

		# Apply shake to camera
		camera_2d.offset = Vector2(shake_x, shake_y)
		camera_2d.rotation = roll

		# Gradually reduce trauma (decay effect)
		trauma = max(trauma - decay_speed * delta, 0.0)
	else:
		# Reset camera position and rotation when shake is finished
		camera_2d.offset = Vector2(0, 0)
		camera_2d.rotation = 0.0

	
func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)  # Add trauma but clamp it to 1.0 max
	shake_timer = 0.0  # Reset the shake timer whenever a new dash happens
