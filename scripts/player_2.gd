extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -450.0

var is_jumped = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D



func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Double jump 
	if Input.is_action_just_pressed("jump") and is_jumped:
		#player.rotate(180)
		is_jumped = false
		velocity.y = JUMP_VELOCITY

	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		is_jumped = true
		velocity.y = JUMP_VELOCITY
		
	#handle block
		
	if Input.is_action_just_pressed("block") and is_on_floor():
		animated_sprite.play("block")

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	
#	# play animation
	if direction == 0 and not Input.is_action_just_pressed("block"):
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")
	
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true 
	if not is_on_floor(): 
		animated_sprite.play("jump")
		
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
