# === NPCAnimationComponent.gd ===
extends Node

@export var animation_player: AnimationPlayer
@onready var npc: NPC = get_owner()

var last_direction: String = "down"
var dialogue_face_direction: String = "down"

func _ready():
	if not animation_player:
		animation_player = npc.get_node_or_null("AnimationPlayer")

func _physics_process(delta):
	var dialogue_comp = npc.get_node_or_null("DialogueComponent")
	
	if dialogue_comp and dialogue_comp.is_in_dialogue:
		_handle_dialogue_animation()
	else:
		_handle_normal_animation()

func _handle_normal_animation():
	var velocity = npc.velocity
	var direction = _get_direction_from_velocity(velocity)
	
	var animation_name: String
	if velocity.length() > 0:
		animation_name = "walk_" + direction
		last_direction = direction
	else:
		animation_name = "idle_" + last_direction
	
	_play_animation(animation_name)

func _handle_dialogue_animation():
	var animation_name = "idle_" + dialogue_face_direction
	_play_animation(animation_name)

func face_position(target_pos: Vector2):
	var direction_to_target = (target_pos - npc.global_position).normalized()
	dialogue_face_direction = _get_direction_from_vector(direction_to_target)

func _play_animation(animation_name: String):
	if animation_player and animation_player.has_animation(animation_name):
		if animation_player.current_animation != animation_name:
			animation_player.play(animation_name)

func _get_direction_from_velocity(velocity: Vector2) -> String:
	if velocity.length() < 0.1:
		return last_direction
	return _get_direction_from_vector(velocity)

func _get_direction_from_vector(vector: Vector2) -> String:
	if abs(vector.x) > abs(vector.y):
		return "right" if vector.x > 0 else "left"
	else:
		return "down" if vector.y > 0 else "up"
