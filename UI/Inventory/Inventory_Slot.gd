# === Inventory_Slot.gd - Minimal update for component system ===
extends Control

# Scene-Tree Node references (keeping your exact structure)
@onready var icon = $InnerBorder/ItemIcon
@onready var quantity_label = $InnerBorder/ItemQuantity
@onready var details_panel = $DetailsPanel
@onready var item_name = $DetailsPanel/ItemName
@onready var item_type = $DetailsPanel/ItemType
@onready var item_effect = $DetailsPanel/ItemEffect
@onready var usage_panel = $UsagePanel
@onready var assign_button = $UsagePanel/AssignButton
@onready var outer_border = $OuterBorder

# Signals (keeping your original)
signal drag_start(slot)
signal drag_end()

# Slot data - minimal change
var item_stack: ItemStack = null  # Instead of dictionary
var slot_index = -1
var is_assigned = false

# Reference to player inventory
var player_inventory: Inventory

func _ready():
	# Find player inventory
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player_inventory = player.get_node("Inventory") as Inventory

# Set index (unchanged)
func set_slot_index(new_index):
	slot_index = new_index

# Show item details on hover enter (unchanged)
func _on_item_button_mouse_entered():
	if item_stack and not item_stack.is_empty():
		usage_panel.visible = false
		details_panel.visible = true

# Hide item details on hover exit (unchanged)
func _on_item_button_mouse_exited():
	details_panel.visible = false

# Default empty slot (minimal change)
func set_empty():
	item_stack = null
	icon.texture = null
	quantity_label.text = ""

# Set item stack (replaces set_item)
func set_item_stack(new_item_stack: ItemStack):
	item_stack = new_item_stack
	if item_stack and not item_stack.is_empty():
		var item = item_stack.item
		
		# Set display data from .tres file
		icon.texture = item.sprite  # instead of item["texture"]
		quantity_label.text = str(item_stack.count)  # instead of item["quantity"]
		item_name.text = item.item_name  # instead of item["name"]
		
		# Set type and effect based on item properties
		if item.healing_amount > 0:
			item_type.text = "Consumable"
			item_effect.text = "+ " + str(item.healing_amount) + " Health"
		elif item.damage > 0:
			item_type.text = "Tool"
			item_effect.text = "Damage: " + str(item.damage)
		else:
			item_type.text = "Item"
			item_effect.text = ""
		
		update_assignment_status()
	else:
		set_empty()

# Drop item (minimal change - replace Global calls)
func _on_drop_button_pressed():
	if item_stack and not item_stack.is_empty() and player_inventory:
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			# Remove from inventory using component
			player_inventory.remove_item(item_stack.item, 1)
		usage_panel.visible = false

# Use item (minimal change - replace Global calls)
func _on_use_button_pressed():
	usage_panel.visible = false
	if item_stack and not item_stack.is_empty():
		var player = get_tree().get_first_node_in_group("Player")
		if player and item_stack.item.healing_amount > 0:
			# Apply healing effect
			if player.has_method("heal_player"):
				player.heal_player(item_stack.item.healing_amount)
			# Remove from inventory
			player_inventory.remove_item(item_stack.item, 1)

# Assignment status (simplified)
func update_assignment_status():
	is_assigned = _is_in_hotbar()
	if is_assigned:
		assign_button.text = "Unassign"
	else:
		assign_button.text = "Assign"

func _is_in_hotbar() -> bool:
	if not item_stack or not player_inventory:
		return false
	
	for i in range(player_inventory.hotbar_size):
		if i < player_inventory.items.size():
			var hotbar_item = player_inventory.items[i]
			if hotbar_item and hotbar_item.item == item_stack.item:
				return true
	return false

# Assign/unassign (simplified)
func _on_assign_button_pressed():
	if not item_stack or not player_inventory:
		return
	
	if is_assigned:
		# Remove from hotbar
		for i in range(player_inventory.hotbar_size):
			if i < player_inventory.items.size():
				var hotbar_item = player_inventory.items[i]
				if hotbar_item and hotbar_item.item == item_stack.item:
					hotbar_item.item = Items.EMPTY
					hotbar_item.count = 0
					break
	else:
		# Add to hotbar
		for i in range(player_inventory.hotbar_size):
			if i < player_inventory.items.size():
				var hotbar_item = player_inventory.items[i]
				if hotbar_item.is_empty():
					hotbar_item.item = item_stack.item
					hotbar_item.count = 1
					break
	
	update_assignment_status()
	player_inventory.updated.emit()

# Input handling (unchanged)
func _on_item_button_gui_input(event):
	if event is InputEventMouseButton:
		# Usage panel
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			if item_stack and not item_stack.is_empty():
				usage_panel.visible = !usage_panel.visible
		# Dragging item
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				outer_border.modulate = Color(1, 1, 0)
				drag_start.emit(self)
			else:
				outer_border.modulate = Color(1, 1, 1)
				drag_end.emit()

# Legacy support - keep your old set_item working
func set_item(item_dict: Dictionary):
	# Find matching item
	for item in Items.all_items:
		if item.item_name == item_dict.get("name", ""):
			var stack = ItemStack.new(item, item_dict.get("quantity", 1))
			set_item_stack(stack)
			return
	set_empty()
