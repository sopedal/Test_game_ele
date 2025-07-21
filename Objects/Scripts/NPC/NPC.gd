# === NPC.gd ===
class_name NPC
extends CharacterBody2D

signal interacted(npc: NPC)
signal met_player(npc: NPC)

@export var stats: NPCStats

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var movement_component: Node = $NPCMovementComponent
@onready var animation_component: Node = $NPCAnimationComponent
@onready var dialogue_component: DialogueComponent = $DialogueComponent

func _ready():
	if not stats:
		push_error("NPC requires NPCStats resource")
		return
	
	# Apply the texture from stats to the sprite
	if stats.texture:
		sprite.texture = stats.texture
	
	print("🤖 NPC initialized: ", stats.npc_name)

func interact_with_player() -> void:
	if not stats.met:
		stats.met = true
		EventBus.npc_met_for_first_time.emit(self)
		print("👋 First time meeting ", stats.npc_name)
	
	EventBus.npc_interacted.emit(self)

func get_npc_name() -> String:
	return stats.npc_name if stats else "Unknown NPC"

func has_met() -> bool:
	return stats.met if stats else false
