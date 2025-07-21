# === AnimationComponent.gd ===
extends Node

@export var animation_player: AnimationPlayer
@onready var player: Player = get_owner()

var last_direction: String = "down"

func _ready():
	if not animation_player:
		animation_player = player.get_node_or_null("AnimationPlayer")

func _physics_process(delta):
	if not player.alive:
		return
	
	if player.in_dialogue:
		_handle_dialogue_animation()
	else:
		_handle_normal_animation()

func _handle_normal_animation():
	var velocity = player.velocity
	var direction = _get_direction_from_velocity(velocity)
	
	var animation_name: String
	if velocity.length() > 0:
		animation_name = "walk_" + direction
		last_direction = direction
	else:
		animation_name = "idle_" + last_direction
	
	_play_animation(animation_name)

func _handle_dialogue_animation():
	# Face the NPC during dialogue
	if player.current_interactable:
		var npc = player.current_interactable.get_owner()
		if npc:
			var direction_to_npc = (npc.global_position - player.global_position).normalized()
			var face_direction = _get_direction_from_vector(direction_to_npc)
			_play_animation("idle_" + face_direction)
	else:
		_play_animation("idle_" + last_direction)

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
