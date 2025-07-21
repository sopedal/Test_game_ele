# === Inventory_Hotbar.gd - Working hotbar for component system ===
extends Control

@onready var hotbar_container = $HBoxContainer

# Inventory reference
var player_inventory: Inventory

func _ready():
	# Ensure proper naming for UIManager discovery
	name = "Inventory_Hotbar"
	
	# Always visible (HUD category)
	visible = true
	
	# Connect to player inventory component
	_connect_to_player_inventory()

func _connect_to_player_inventory():
	"""Find and connect to player's inventory component"""
	
	# Find player in scene
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("❌ Hotbar: Player not found")
		return
	
	# Get inventory component
	player_inventory = player.get_node("Inventory") as Inventory
	if not player_inventory:
		print("❌ Hotbar: Inventory component not found on player")
		return
	
	# Connect to inventory signals
	player_inventory.updated.connect(_update_hotbar_display)
	
	print("✅ Hotbar: Connected to player inventory")
	
	# Initial hotbar update
	_update_hotbar_display()

func _update_hotbar_display():
	"""Update the hotbar display"""
	
	# Clear existing slots
	_clear_hotbar()
	
	if not player_inventory:
		return
	
	# Create slots for hotbar size
	for i in range(player_inventory.hotbar_size):
		var slot = _create_hotbar_slot(i)
		hotbar_container.add_child(slot)

func _create_hotbar_slot(slot_index: int) -> Control:
	"""Create a single hotbar slot"""
	
	# Get the item stack at this index
	var item_stack: ItemStack = null
	if slot_index < player_inventory.items.size():
		item_stack = player_inventory.items[slot_index]
	
	# Main slot container
	var slot_panel = Panel.new()
	slot_panel.custom_minimum_size = Vector2(64, 64)
	slot_panel.add_theme_stylebox_override("panel", _create_slot_style())
	
	# Content container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 2)
	slot_panel.add_child(vbox)
	
	# Icon area
	var icon_area = Panel.new()
	icon_area.custom_minimum_size = Vector2(48, 48)
	icon_area.add_theme_stylebox_override("panel", _create_icon_style())
	vbox.add_child(icon_area)
	
	# Add item icon if available
	if item_stack and not item_stack.is_empty():
		_add_item_icon(icon_area, item_stack.item)
	
	# Quantity label
	var quantity_label = Label.new()
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quantity_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(quantity_label)
	
	# Set quantity text
	if item_stack and not item_stack.is_empty() and item_stack.count > 1:
		quantity_label.text = "×" + str(item_stack.count)
		quantity_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		quantity_label.text = ""
	
	# Slot number label
	var number_label = Label.new()
	number_label.text = str(slot_index + 1)
	number_label.position = Vector2(4, 4)
	number_label.add_theme_font_size_override("font_size", 14)
	number_label.add_theme_color_override("font_color", Color.YELLOW)
	number_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	number_label.add_theme_constant_override("shadow_offset_x", 1)
	number_label.add_theme_constant_override("shadow_offset_y", 1)
	slot_panel.add_child(number_label)
	
	# Click handler
	var button = Button.new()
	button.flat = true
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_slot_clicked.bind(slot_index))
	slot_panel.add_child(button)
	
	return slot_panel

func _add_item_icon(icon_area: Panel, item: Item):
	"""Add item icon to icon area"""
	
	if item.sprite != null:
		var texture_rect = TextureRect.new()
		texture_rect.texture = item.sprite
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon_area.add_child(texture_rect)
	else:
		# Fallback: colored square
		var color = _get_item_color(item)
		icon_area.add_theme_color_override("modulate", color)

func _get_item_color(item: Item) -> Color:
	"""Get color for item type"""
	if item.healing_amount > 0:
		return Color.GREEN
	elif item.damage > 0:
		return Color.RED
	else:
		return Color.BLUE

func _create_slot_style() -> StyleBoxFlat:
	"""Create style for hotbar slot"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.6, 0.6, 0.6, 1.0)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

func _create_icon_style() -> StyleBoxFlat:
	"""Create style for item icons"""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 1.0)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	return style

func _clear_hotbar():
	"""Clear all hotbar slots"""
	for child in hotbar_container.get_children():
		child.queue_free()

func _on_slot_clicked(slot_index: int):
	"""Handle slot click"""
	if player_inventory:
		print("🔥 Hotbar slot %d clicked" % (slot_index + 1))
		player_inventory.use_hotbar_item(slot_index)
