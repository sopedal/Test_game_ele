# === InventoryManager.gd (Updated for Inventory Component) ===
extends Node

# Reference to player's inventory component
var player_inventory: Inventory = null

func _ready():
	print("📦 InventoryManager initialized (component version)")
	
	# Connect to basic EventBus events
	EventBus.ui_data_needed.connect(_on_ui_data_needed)
	EventBus.item_pickup_requested.connect(_on_item_pickup_requested)
	

func register_player_inventory(inventory: Inventory):
	"""Register the player's inventory component"""
	player_inventory = inventory
	
	# Connect to inventory signals
	player_inventory.updated.connect(_on_inventory_updated)
	player_inventory.item_used.connect(_on_item_used)
	
	print("🎮 Player inventory registered!")
	print("📏 Inventory size: %d, Hotbar size: %d" % [inventory.inventory_size, inventory.hotbar_size])
	
	# Add some test items to the inventory
	_add_test_items()

func _on_inventory_updated():
	"""Handle when inventory updates"""
	print("📦 Inventory updated")
	EventBus.inventory_changed.emit()
	EventBus.hotbar_changed.emit()

func _on_item_used(item: Item, slot_index: int):
	"""Handle when item is used from inventory"""
	print("✨ Item used: %s from slot %d" % [item.item_name, slot_index])

# === BASIC EVENT HANDLERS ===

func _on_action_triggered(action_name: String):
	"""Handle input actions from InputManager"""
	print("🎮 InventoryManager received action: %s" % action_name)
	
	# Handle hotbar input
	if action_name.begins_with("hotbar_"):
		var slot_index = int(action_name.get_slice("_", 1)) - 1
		use_hotbar_slot(slot_index)
	
	# Handle inventory toggle
	elif action_name == "toggle_inventory":
		UIManager.toggle_ui("inventory")

func _on_ui_data_needed(ui_id: String):
	"""Send data to UI when requested"""
	if not player_inventory:
		print("❌ No player inventory registered yet")
		return
	
	match ui_id:
		"inventory":
			_send_inventory_data()
		"hotbar":
			_send_hotbar_data()

func _on_item_pickup_requested(item_name: String, quantity: int):
	"""Handle item pickup using your Items.gd registry"""
	print("📦 Pickup requested: %s x%d" % [item_name, quantity])
	
	if not player_inventory:
		print("❌ No player inventory to add item to")
		return
	
	# Use your Items.gd registry to find the item
	var item = Items.item_registry.get(item_name)
	if item:
		var item_stack = ItemStack.new(item, quantity)
		var remaining = player_inventory.add_item(item_stack)
		
		if remaining.is_empty():
			print("✅ Picked up %d x %s" % [quantity, item.item_name])
		else:
			print("⚠️ Picked up some %s, %d remaining" % [item.item_name, remaining.count])
	else:
		print("❌ Item not found in registry: %s" % item_name)
		print("📋 Available items: %s" % Items.item_registry.keys())

# === DATA SENDERS ===

func _send_inventory_data():
	"""Send inventory data to UI"""
	var inventory_data = []
	
	for i in range(player_inventory.items.size()):
		var item_stack = player_inventory.items[i]
		
		if not item_stack.is_empty():
			inventory_data.append({
				"item": item_stack.item,
				"slot_index": i,
				"quantity": item_stack.count
			})
		else:
			inventory_data.append(null)
	
	EventBus.inventory_data_ready.emit(inventory_data)
	print("📤 Sent inventory data: %d slots" % inventory_data.size())

func _send_hotbar_data():
	"""Send hotbar data to UI"""
	var hotbar_data = []
	
	# Hotbar is first N slots of inventory
	for i in range(player_inventory.hotbar_size):
		if i < player_inventory.items.size():
			var item_stack = player_inventory.items[i]
			
			if not item_stack.is_empty():
				hotbar_data.append({
					"item": item_stack.item,
					"slot_index": i,
					"quantity": item_stack.count
				})
			else:
				hotbar_data.append(null)
		else:
			hotbar_data.append(null)
	
	EventBus.hotbar_data_ready.emit(hotbar_data)
	print("🔥 Sent hotbar data: %d slots" % hotbar_data.size())

# === INVENTORY FUNCTIONS ===

func use_hotbar_slot(slot_index: int):
	"""Use hotbar slot through inventory component"""
	if not player_inventory:
		print("❌ No player inventory registered")
		return
	
	print("🔥 Using hotbar slot %d" % [slot_index + 1])
	player_inventory.use_hotbar_item(slot_index)

func add_item(item_name: String, quantity: int = 1) -> bool:
	"""Add item to player inventory using your Items.gd registry"""
	if not player_inventory:
		print("❌ No player inventory registered")
		return false
	
	var item = Items.item_registry.get(item_name)
	if item:
		var item_stack = ItemStack.new(item, quantity)
		var remaining = player_inventory.add_item(item_stack)
		return remaining.is_empty()
	else:
		print("❌ Item not found in registry: %s" % item_name)
		return false

func has_item(item_name: String, quantity: int = 1) -> bool:
	"""Check if player has item using your Items.gd registry"""
	if not player_inventory:
		return false
	
	var item = Items.item_registry.get(item_name)
	if item:
		return player_inventory.has_count(item, quantity)
	
	return false

func _add_test_items():
	"""Add test items using your Items.gd constants"""
	print("🧪 Adding test items from your Items.gd...")
	
	# Test the Items system first
	Items.test_items()
	
	# Add items using your constants
	var test_items = [
		{"item": Items.BANANA, "count": 3},
		{"item": Items.AXE, "count": 1}
	]
	
	for test_item in test_items:
		var item = test_item.item
		var count = test_item.count
		
		if item:
			var item_stack = ItemStack.new(item, count)
			var remaining = player_inventory.add_item(item_stack)
			
			if remaining.is_empty():
				print("✅ Added %d x %s" % [count, item.item_name])
			else:
				print("⚠️ Added some %s, %d couldn't fit" % [item.item_name, remaining.count])
		else:
			print("❌ Test item is null")
	
	print("🎒 Test items added! Registry has %d items total" % Items.item_registry.size())

# === DEBUG FUNCTIONS ===

func print_inventory():
	"""Debug: print current inventory"""
	if not player_inventory:
		print("❌ No player inventory to print")
		return
	
	print("📋 === PLAYER INVENTORY DEBUG ===")
	for i in range(min(10, player_inventory.items.size())):  # Print first 10 slots
		var item_stack = player_inventory.items[i]
		if not item_stack.is_empty():
			print("Slot %d: %s x%d" % [i, item_stack.item.item_name, item_stack.count])
		else:
			print("Slot %d: Empty" % i)
	
	print("🔥 === HOTBAR SECTION ===")
	for i in range(player_inventory.hotbar_size):
		if i < player_inventory.items.size():
			var item_stack = player_inventory.items[i]
			if not item_stack.is_empty():
				print("Hotbar %d: %s x%d" % [i + 1, item_stack.item.item_name, item_stack.count])
			else:
				print("Hotbar %d: Empty" % [i + 1])

func get_inventory_status() -> String:
	"""Get inventory status for debugging"""
	if not player_inventory:
		return "No inventory registered"
	
	var filled_slots = 0
	for item_stack in player_inventory.items:
		if not item_stack.is_empty():
			filled_slots += 1
	
	return "Inventory: %d/%d slots filled" % [filled_slots, player_inventory.inventory_size]

func print_item_database():
	"""Debug: print the Items.gd registry"""
	print("📚 === ITEMS DATABASE DEBUG ===")
	if Items:
		print("📋 Registry size: %d" % Items.item_registry.size())
		for item_name in Items.item_registry:
			var item = Items.item_registry[item_name]
			print("🎯 %s: Heal=%d, Damage=%d" % [item.item_name, item.healing_amount, item.damage])
	else:
		print("❌ Items autoload not found")
