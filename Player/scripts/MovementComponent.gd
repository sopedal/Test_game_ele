# === MovementComponent.gd ===
extends Node

#########################################################
# Player movement controller component
# Handles input and movement logic
# Attached as child of Player node
#########################################################

@export_group("Speed Values")
@export var max_speed := 100.0
@export var acceleration_time := 0.1

@onready var player: Player = get_owner()

func _ready():
	print("🎮 MovementComponent initialized")

func _physics_process(delta):
	if not player.alive:
		return
	
	# Simple direct check - no EventBus complexity
	if player.in_dialogue:
		_handle_dialogue_movement(delta)
	else:
		_handle_normal_movement(delta)

func _handle_normal_movement(delta):
	# Get input direction
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Apply movement
	player.velocity = player.velocity.move_toward(
		input_direction * max_speed,
		(1.0 / acceleration_time) * delta * max_speed
	)
	
	# Direction change smoothing - FIXED velocity references
	if input_direction.y and sign(input_direction.y) != sign(player.velocity.y):
		player.velocity.y *= 0.75
	
	if input_direction.x and sign(input_direction.x) != sign(player.velocity.x):
		player.velocity.x *= 0.75
	
	# Apply velocity and move
	player.move_and_slide()

func _handle_dialogue_movement(delta):
	# Stop movement during dialogue
	player.velocity = player.velocity.move_toward(
		Vector2.ZERO, 
		(1.0 / acceleration_time) * delta * max_speed
	)
	player.move_and_slide()
