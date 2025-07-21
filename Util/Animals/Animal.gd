# === Animal.gd ===
class_name Animal
extends CharacterBody2D

signal interacted(animal: Animal)

@export var stats: AnimalStats
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var movement_component: Node = $NPCMovementComponent  # Reuse existing!
@onready var animation_component: Node = $NPCAnimationComponent  # Reuse existing!

func _ready():
	if not stats:
		push_error("Animal requires AnimalStats resource")
		return
	
	# Apply the texture from stats to the sprite
	if stats.texture:
		sprite.texture = stats.texture
	
	print("🐾 Animal initialized: ", stats.animal_name)

func interact_with_player() -> void:
	# Simple interaction without met tracking
	EventBus.animal_interacted.emit(self)
	interacted.emit(self)

func get_animal_name() -> String:
	return stats.animal_name if stats else "Unknown Animal"

# Add these properties so NPCAnimationComponent can work with animals
var in_dialogue: bool = false  # Always false for animals
var current_interactable = null  # Not used for animals
