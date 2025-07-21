# === NPCAnimationComponent.gd ===
extends Node

@export var animation_player: AnimationPlayer
@export var animation_prefix: String = ""  # For different naming conventions like "dog_", "cat_", etc.

@onready var character: CharacterBody2D = get_owner()  # Generic - works for both NPC and Animal
var last_direction: String = "down"
var dialogue_face_direction: String = "down"

func _ready():
	if not animation_player:
		animation_player = character.get_node_or_null("AnimationPlayer")

func _physics_process(delta):
	var dialogue_comp = character.get_node_or_null("DialogueComponent")
	
	if dialogue_comp and dialogue_comp.is_in_dialogue:
		_handle_dialogue_animation()
	else:
		_handle_normal_animation()

func _handle_normal_animation():
	var velocity = character.velocity
	var direction = _get_direction_from_velocity(velocity)
	
	var animation_name: String
	if velocity.length() > 0:
		animation_name = _build_animation_name("run", direction)
		last_direction = direction
	else:
		animation_name = _build_animation_name("idle", last_direction)
	
	_play_animation(animation_name)

func _handle_dialogue_animation():
	var animation_name = _build_animation_name("idle", dialogue_face_direction)
	_play_animation(animation_name)

func face_position(target_pos: Vector2):
	var direction_to_target = (target_pos - character.global_position).normalized()
	dialogue_face_direction = _get_direction_from_vector(direction_to_target)

func _build_animation_name(action: String, direction: String) -> String:
	if animation_prefix.is_empty():
		return action + "_" + direction
	else:
		return animation_prefix + action + "_" + direction

func _play_animation(animation_name: String):
	if animation_player and animation_player.has_animation(animation_name):
		if animation_player.current_animation != animation_name:
			animation_player.play(animation_name)
	else:
		# Debug: Print if animation is missing
		print("⚠️ Missing animation: ", animation_name, " for ", character.name)

func _get_direction_from_velocity(velocity: Vector2) -> String:
	if velocity.length() < 0.1:
		return last_direction
	return _get_direction_from_vector(velocity)

func _get_direction_from_vector(vector: Vector2) -> String:
	if abs(vector.x) > abs(vector.y):
		return "right" if vector.x > 0 else "left"
	else:
		return "down" if vector.y > 0 else "up"
