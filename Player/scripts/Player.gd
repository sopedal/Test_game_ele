# === Player.gd - Component-based with UIManager integration ===
extends CharacterBody2D
class_name Player

# Player state
var alive: bool = true
var in_dialogue: bool = false
var current_interactable = null
var movement_blocked_by_ui: bool = false

# Component references
@onready var movement_component: Node = $MovementComponent
@onready var animation_component: Node = $AnimationComponent
@onready var inventory: Inventory = $Inventory

func _ready():
	add_to_group("Player")  # Important: Capital P for UIManager
	print("🎮 Player initialized")
	
	# Connect to UIManager for movement blocking
	UIManager.movement_blocked_changed.connect(_on_movement_blocked_changed)
	
	# Connect inventory signals
	if inventory:
		inventory.updated.connect(_on_inventory_updated)
		inventory.item_used.connect(_on_item_used)
		
		# Register with InventoryManager if not auto-registered
		if not inventory.auto_register_player:
			InventoryManager.register_player_inventory(inventory)
			print("🎮 Player registered inventory with InventoryManager")
	
	# Add some test items (remove in production)
	call_deferred("_add_initial_test_items")

func _add_initial_test_items():
	"""Add initial test items (remove in production)"""
	if inventory:
		add_item_to_inventory(Items.BANANA, 3)
		add_item_to_inventory(Items.AXE, 1)
		print("🧪 Added test items to inventory")

func _input(event):
	# === DIALOGUE INPUT ===
	if event.is_action_pressed("ui_accept"):
		if current_interactable and current_interactable.can_start_dialogue():
			current_interactable.interact()
			get_viewport().set_input_as_handled()  # Prevent other scripts from processing
			return
	
	elif event.is_action_pressed("ui_cancel"):
		if in_dialogue and current_interactable:
			current_interactable.force_end_dialogue()
			get_viewport().set_input_as_handled()
			return
	
	# Don't process other input during dialogue
	if in_dialogue:
		return
	
	# === HOTBAR INPUT (1-5 keys) ===
	for i in range(5):
		var key_code = KEY_1 + i
		if event is InputEventKey and event.pressed and event.keycode == key_code:
			use_hotbar_slot(i)
			get_viewport().set_input_as_handled()
			return
	
	# === INVENTORY/QUEST INPUT ===
	if event.is_action_pressed("toggle_inventory"):
		UIManager.toggle_ui("inventory")
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("toggle_quest"):
		UIManager.toggle_ui("quest")
		get_viewport().set_input_as_handled()
		return

# === UIManager INTEGRATION ===

func _on_movement_blocked_changed(is_blocked: bool):
	"""Called by UIManager when UI blocks movement"""
	movement_blocked_by_ui = is_blocked
	print("🚶 Player movement blocked: ", is_blocked)

# === INVENTORY API FUNCTIONS ===

func add_item_to_inventory(item: Item, count: int) -> bool:
	"""Add item to player inventory"""
	if not inventory:
		print("❌ No inventory available")
		return false
	
	var item_stack = ItemStack.new(item, count)
	var remaining = inventory.add_item(item_stack)
	
	if remaining.is_empty():
		print("✅ Added %d x %s to inventory" % [count, item.item_name])
		return true
	else:
		print("⚠️ Could only partially add %s. %d items remaining" % [item.item_name, remaining.count])
		return false

func remove_item_from_inventory(item: Item, count: int):
	"""Remove item from player inventory"""
	if not inventory:
		print("❌ No inventory available")
		return
	
	if inventory.has_count(item, count):
		inventory.remove_item(item, count)
		print("🗑️ Removed %d x %s from inventory" % [count, item.item_name])
	else:
		print("❌ Not enough %s in inventory" % item.item_name)

func has_item(item: Item, count: int = 1) -> bool:
	"""Check if player has specific item and count"""
	if not inventory:
		return false
	return inventory.has_count(item, count)

func get_inventory_count(item: Item) -> int:
	"""Get total count of specific item in inventory"""
	if not inventory:
		return 0
	
	var total = 0
	for stack in inventory.items:
		if stack.item == item:
			total += stack.count
	return total

func use_hotbar_slot(slot_index: int):
	"""Use item in specific hotbar slot"""
	if inventory:
		print("🔥 Player using hotbar slot %d" % (slot_index + 1))
		inventory.use_hotbar_item(slot_index)

# === INVENTORY SIGNAL HANDLERS ===

func _on_inventory_updated():
	"""Called when inventory changes"""
	print("📦 Player: Inventory updated!")

func _on_item_used(item: Item, slot_index: int):
	"""Called when item is used from hotbar"""
	print("🔥 Used %s from hotbar slot %d" % [item.item_name, slot_index])
	
	# Handle different item types based on their properties
	if item.healing_amount > 0:
		heal_player(item.healing_amount)
		print("💊 %s consumed and healed player for %d HP" % [item.item_name, item.healing_amount])
	elif item.damage > 0:
		print("🪓 %s equipped/used! (Damage: %d)" % [item.item_name, item.damage])
	else:
		print("❓ Unknown item used: %s" % item.item_name)

# === UTILITY FUNCTIONS ===

func heal_player(amount: int):
	"""Example healing function"""
	print("💚 Player healed for %d HP" % amount)
	# Add your actual healing logic here

# === DIALOGUE FUNCTIONS ===

func set_interactable(interactable):
	current_interactable = interactable

func clear_interactable():
	current_interactable = null

func start_dialogue():
	in_dialogue = true
	print("🗣️ Player: Started dialogue, movement disabled")

func end_dialogue():
	in_dialogue = false
	print("🔚 Player: Ended dialogue, movement enabled")

# === DEBUG FUNCTIONS ===

func print_inventory():
	"""Debug function to print inventory contents"""
	if not inventory:
		print("❌ No inventory to display")
		return
	
	print("📦 === PLAYER INVENTORY ===")
	for i in range(inventory.items.size()):
		var stack = inventory.items[i]
		var slot_type = "🔥" if i < inventory.hotbar_size else "📦"
		
		if stack.is_empty():
			print("%s [%02d] Empty" % [slot_type, i])
		else:
			print("%s [%02d] %s x%d" % [slot_type, i, stack.item.item_name, stack.count])

func test_add_random_item():
	"""Test function - add random item"""
	var random_items = [Items.BANANA, Items.AXE]
	var random_item = random_items[randi() % random_items.size()]
	var random_count = randi_range(1, 3)
	
	add_item_to_inventory(random_item, random_count)
