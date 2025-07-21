# === Simple AnimalMovementComponent.gd (if NPCMovementComponent doesn't fit) ===
extends Node

@export var speed: float = 50.0
@export var wander_enabled: bool = true
@export var wander_range: float = 100.0
@export var wander_pause_time: float = 2.0

@onready var animal: CharacterBody2D = get_owner()

var home_position: Vector2
var target_position: Vector2
var wander_timer: float = 0.0
var is_wandering: bool = false

func _ready():
	home_position = animal.global_position
	target_position = home_position
	_set_new_wander_target()

func _physics_process(delta):
	if not wander_enabled:
		animal.velocity = Vector2.ZERO
		animal.move_and_slide()
		return
	
	_handle_wandering(delta)
	animal.move_and_slide()

func _handle_wandering(delta):
	wander_timer -= delta
	
	if wander_timer <= 0:
		if is_wandering:
			animal.velocity = Vector2.ZERO
			is_wandering = false
			wander_timer = wander_pause_time
		else:
			_set_new_wander_target()
			is_wandering = true
			wander_timer = randf_range(2.0, 4.0)
	
	if is_wandering:
		var direction = (target_position - animal.global_position).normalized()
		animal.velocity = direction * speed
		
		if animal.global_position.distance_to(target_position) < 10.0:
			animal.velocity = Vector2.ZERO
			is_wandering = false
			wander_timer = wander_pause_time

func _set_new_wander_target():
	var angle = randf() * TAU
	var distance = randf() * wander_range
	target_position = home_position + Vector2(cos(angle), sin(angle)) * distance
