extends Node

var EMPTY: Item = Item.new()
const BANANA: Item = preload("res://Resources/Items/Consumables/Banana.tres")
const AXE: Item = preload("res://Resources/Items/tools/Axe.tres")

var all_items = [EMPTY, BANANA, AXE]
var item_registry := {}

func _ready() -> void:
	register_items()
	Items.EMPTY.item_name = "EMPTY"
	
func test_items():
	print("🧪 Testing Items:")
	print("BANANA: %s" % BANANA.item_name)
	print("AXE: %s" % AXE.item_name)
	print("Registry size: %d" % item_registry.size())

func register_items() -> void:
	for item in all_items:
		item_registry[item.item_name] = item
