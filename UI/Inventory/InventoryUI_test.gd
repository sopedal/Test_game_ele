# === Inventory_UI.gd - Using preloaded slot scene ===
extends Control

# Scene-Tree Node references (keeping your original)
@onready var grid_container = $GridContainer

# Preload the inventory slot scene (like your original)
@onready var inventory_slot_scene = preload("res://UI/Inventory/Inventory_Slot.tscn")

# Inventory reference
var player_inventory: Inventory

# Drag/Drop (keeping your original functionality)
var dragged_slot = null

func _ready():
	# Ensure proper naming for UIManager discovery
	name = "Inventory_UI"
	
	# Start hidden - UIManager will control visibility
	visible = false
	
	# Connect to player inventory component
	_connect_to_player_inventory()

func _connect_to_player_inventory():
	"""Find and connect to player's inventory component"""
	
	# Find player in scene
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("❌ Inventory UI: Player not found")
		return
	
	# Get inventory component
	player_inventory = player.get_node("Inventory") as Inventory
	if not player_inventory:
		print("❌ Inventory UI: Inventory component not found on player")
		return
	
	# Connect to inventory signals
	player_inventory.updated.connect(_on_inventory_updated)
	
	print("✅ Inventory UI: Connected to player inventory")
	
	# Initial inventory update
	_on_inventory_updated()

# Update inventory UI (back to your original approach!)
func _on_inventory_updated():
	# Clear existing slots
	clear_grid_container()
	
	if not player_inventory:
		return
	
	# Add slots for each inventory position
	for i in range(player_inventory.inventory_size):
		# Use your preloaded scene (much cleaner!)
		var slot = inventory_slot_scene.instantiate()
		slot.set_slot_index(i)
		
		# Connect drag/drop signals (keeping your original functionality)
		slot.drag_start.connect(_on_drag_start)
		slot.drag_end.connect(_on_drag_end)
		
		grid_container.add_child(slot)
		
		# Set item data from inventory component
		if i < player_inventory.items.size():
			var item_stack = player_inventory.items[i]
			if item_stack and not item_stack.is_empty():
				slot.set_item_stack(item_stack)
			else:
				slot.set_empty()
		else:
			slot.set_empty()

# Clear inventory UI grid (keeping your original)
func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()

# Drag/Drop functions (keeping your original functionality)
func _on_drag_start(slot_control: Control):
	dragged_slot = slot_control
	print("Drag started from slot: ", dragged_slot)

func _on_drag_end():
	var target_slot = get_slot_under_mouse()
	if target_slot and dragged_slot != target_slot:
		drop_slot(dragged_slot, target_slot)
	dragged_slot = null

func get_slot_under_mouse() -> Control:
	var mouse_position = get_global_mouse_position()
	for slot in grid_container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func get_slot_index(slot: Control) -> int:
	for i in range(grid_container.get_child_count()):
		if grid_container.get_child(i) == slot:
			return i
	return -1

func drop_slot(slot1: Control, slot2: Control):
	var slot1_index = get_slot_index(slot1)
	var slot2_index = get_slot_index(slot2)
	if slot1_index == -1 or slot2_index == -1:
		print("Invalid slots found")
		return
	else:
		if _swap_inventory_items(slot1_index, slot2_index):
			print("Swapping slot items: ", slot1_index, " <-> ", slot2_index)
			_on_inventory_updated()

func _swap_inventory_items(index1: int, index2: int) -> bool:
	"""Swap items in inventory using inventory component"""
	if not player_inventory:
		return false
	
	if index1 < 0 or index1 >= player_inventory.inventory_size or index2 < 0 or index2 >= player_inventory.inventory_size:
		return false
	
	# Swap items in the inventory component
	if index1 < player_inventory.items.size() and index2 < player_inventory.items.size():
		var temp = player_inventory.items[index1]
		player_inventory.items[index1] = player_inventory.items[index2]
		player_inventory.items[index2] = temp
		player_inventory.updated.emit()
		return true
	
	return false

# Handle input for closing (UIManager handles opening)
func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		UIManager.close_ui("inventory")
