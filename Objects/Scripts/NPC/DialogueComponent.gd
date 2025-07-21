# === DialogueComponent.gd ===
class_name DialogueComponent
extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start_node: String = "start"
@export var auto_start_dialogue: bool = false

@onready var npc: NPC = get_owner()

var player_in_range: bool = false
var is_in_dialogue: bool = false
var can_interact: bool = true
var player_ref: Player = null
var dialogue_balloon = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_in_range = true
		player_ref = body
		body.set_interactable(self)
		
		if auto_start_dialogue and can_interact and not is_in_dialogue:
			interact()

func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_in_range = false
		player_ref = null
		body.clear_interactable()

func interact() -> void:
	if player_in_range and can_interact and not is_in_dialogue:
		start_dialogue()

func start_dialogue() -> void:
	if not dialogue_resource or is_in_dialogue:
		return
	
	is_in_dialogue = true
	can_interact = false
	
	# Tell player directly
	if player_ref:
		player_ref.start_dialogue()
		
		# Face each other
		_face_each_other()
	
	dialogue_balloon = DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start_node)
	print("💬 Starting dialogue")

func _face_each_other():
	if not player_ref or not npc:
		return
	
	# Make NPC face player (if it has animation component)
	var npc_anim = npc.get_node_or_null("NPCAnimationComponent")
	if npc_anim and npc_anim.has_method("face_position"):
		npc_anim.face_position(player_ref.global_position)

func force_end_dialogue():
	if dialogue_balloon:
		dialogue_balloon.queue_free()
		_end_dialogue()

func _end_dialogue():
	is_in_dialogue = false
	can_interact = true
	
	if player_ref:
		player_ref.end_dialogue()
	
	dialogue_balloon = null
	print("🔚 Dialogue ended")

func _on_dialogue_started(resource: DialogueResource) -> void:
	# DialogueManager started a dialogue
	pass

func _on_dialogue_ended(resource: DialogueResource) -> void:
	if resource == dialogue_resource:
		_end_dialogue()

func can_start_dialogue() -> bool:
	return player_in_range and can_interact and not is_in_dialogue
