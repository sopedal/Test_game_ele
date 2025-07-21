# === NPCMovementComponent.gd ===
extends Node

enum MovementType { IDLE, WANDER, PATROL }

@export var movement_type: MovementType = MovementType.IDLE
@export var move_speed: float = 50.0
@export var acceleration_time: float = 0.2
@export var wander_radius: float = 100.0
@export var wander_wait_time: float = 2.0
@export var patrol_points: Array[Vector2] = []
@export var patrol_wait_time: float = 1.0

@onready var npc: NPC = get_owner()

var target_position: Vector2
var current_patrol_index: int = 0
var movement_timer: float = 0.0
var is_waiting: bool = false
var home_position: Vector2

func _ready():
	if npc:
		home_position = npc.global_position
		_setup_initial_target()

func _physics_process(delta):
	if not npc:
		return
	
	# Check if NPC is in dialogue - simple direct check
	var dialogue_comp = npc.get_node_or_null("DialogueComponent")
	if dialogue_comp and dialogue_comp.is_in_dialogue:
		_handle_dialogue_movement(delta)
		return
	
	movement_timer -= delta
	
	match movement_type:
		MovementType.IDLE:
			_handle_idle_movement(delta)
		MovementType.WANDER:
			_handle_wander_movement(delta)
		MovementType.PATROL:
			_handle_patrol_movement(delta)

func _handle_dialogue_movement(delta):
	# Stop moving during dialogue
	npc.velocity = npc.velocity.move_toward(Vector2.ZERO, (1.0 / acceleration_time) * delta * move_speed)
	npc.move_and_slide()

func _handle_idle_movement(delta):
	npc.velocity = npc.velocity.move_toward(Vector2.ZERO, (1.0 / acceleration_time) * delta * move_speed)
	npc.move_and_slide()

func _handle_wander_movement(delta):
	var distance_to_target = npc.global_position.distance_to(target_position)
	
	if is_waiting:
		npc.velocity = npc.velocity.move_toward(Vector2.ZERO, (1.0 / acceleration_time) * delta * move_speed)
		if movement_timer <= 0:
			is_waiting = false
			_set_new_wander_target()
	elif distance_to_target < 10.0:
		is_waiting = true
		movement_timer = wander_wait_time
	else:
		var direction = (target_position - npc.global_position).normalized()
		npc.velocity = npc.velocity.move_toward(direction * move_speed, (1.0 / acceleration_time) * delta * move_speed)
	
	npc.move_and_slide()

func _handle_patrol_movement(delta):
	if patrol_points.is_empty():
		_handle_idle_movement(delta)
		return
	
	var current_target = patrol_points[current_patrol_index]
	var distance_to_target = npc.global_position.distance_to(current_target)
	
	if is_waiting:
		npc.velocity = npc.velocity.move_toward(Vector2.ZERO, (1.0 / acceleration_time) * delta * move_speed)
		if movement_timer <= 0:
			is_waiting = false
			_next_patrol_point()
	elif distance_to_target < 10.0:
		is_waiting = true
		movement_timer = patrol_wait_time
	else:
		var direction = (current_target - npc.global_position).normalized()
		npc.velocity = npc.velocity.move_toward(direction * move_speed, (1.0 / acceleration_time) * delta * move_speed)
	
	npc.move_and_slide()

func _setup_initial_target():
	match movement_type:
		MovementType.WANDER:
			_set_new_wander_target()
		MovementType.PATROL:
			if not patrol_points.is_empty():
				target_position = patrol_points[0]

func _set_new_wander_target():
	var angle = randf() * 2 * PI
	var distance = randf() * wander_radius
	target_position = home_position + Vector2(cos(angle), sin(angle)) * distance

func _next_patrol_point():
	if patrol_points.is_empty():
		return
	current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
	target_position = patrol_points[current_patrol_index]
