extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player: CharacterBody2D = $"."
@onready var dash: Node2D = $Dash

const SPEED = 80.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 400
const DASH_DURATION = 0.2

var is_jumped = false


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	

		
	# Double jump 
	if Input.is_action_just_pressed("ui_accept") and is_jumped:
		#player.rotate(180)
		is_jumped = false
		velocity.y = JUMP_VELOCITY

	

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		is_jumped = true
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
