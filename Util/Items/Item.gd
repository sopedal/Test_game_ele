class_name Item
extends Resource

@export var item_name: String = ""
@export var sprite: Texture2D = AtlasTexture.new()

# Add simple properties for testing
@export var healing_amount: int = 0
@export var damage: int = 0

func _to_string() -> String:
	return item_name
