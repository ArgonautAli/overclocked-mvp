extends CharacterBody2D
@onready var dash: Node2D = $Dash

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const JUMP_VELOCITY = -450.0
const DASH_SPEED = 2000
const DASH_DURATION = 0.002
const MOVE_SPEED = 200

var is_jumped = false
var speed = 200.0

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("dash"):
		dash.start_dash(DASH_DURATION)
		#velocity.x = 1 * DASH_SPEED
		
	speed = DASH_SPEED if dash.is_dashing() else MOVE_SPEED
		


	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#if Input.is_action_just_pressed("dash"):
		#dash.start_dash(DASH_DURATION)
		
	# Double jump 
	if Input.is_action_just_pressed("jump") and is_jumped:
		is_jumped = false
		velocity.y = JUMP_VELOCITY

	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jumped = true
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("move_left", "move_right")
	
	#handle block
		
	if Input.is_action_pressed("block") and is_on_floor():
		direction = 0
		animated_sprite.play("block")

	# Get the input direction and handle the movement/deceleration.
	
#	# play animation
	if direction == 0 and not Input.is_action_pressed("block"):
		animated_sprite.play("idle")
		
	elif not Input.is_action_pressed("block"):
		animated_sprite.play("run")
	
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true 
	if not is_on_floor(): 
		animated_sprite.play("jump")
		

	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
