# === InventorySlotUI.gd ===
# Works with your existing Inventory_Slot scene structure
class_name InventorySlotUI
extends Control

# Signals
signal slot_clicked(slot_index: int)
signal item_used(slot_index: int)
signal item_dropped(slot_index: int)

# Scene references (matching your existing structure)
@onready var outer_border = $OuterBorder
@onready var inner_border = $InnerBorder
@onready var item_icon = $InnerBorder/ItemIcon
@onready var item_quantity = $InnerBorder/ItemQuantity
@onready var item_button = $InnerBorder/ItemButton
@onready var details_panel = $DetailsPanel
@onready var item_name = $DetailsPanel/ItemName
@onready var item_type = $DetailsPanel/ItemType
@onready var item_effect = $DetailsPanel/ItemEffect
@onready var usage_panel = $UsagePanel
@onready var use_button = $UsagePanel/UseButton
@onready var drop_button = $UsagePanel/DropButton

# Properties
var slot_index: int = -1
var item_stack: ItemStack = null
var is_hotbar_slot: bool = false

func _ready():
	# Connect signals
	item_button.pressed.connect(_on_item_button_pressed)
	item_button.mouse_entered.connect(_on_mouse_entered)
	item_button.mouse_exited.connect(_on_mouse_exited)
	use_button.pressed.connect(_on_use_button_pressed)
	drop_button.pressed.connect(_on_drop_button_pressed)
	
	# Initialize as empty
	set_empty()

func setup_slot(index: int, hotbar: bool = false):
	"""Initialize slot with index and type"""
	slot_index = index
	is_hotbar_slot = hotbar
	
	# Visual distinction for hotbar slots
	if is_hotbar_slot:
		outer_border.modulate = Color(1.2, 1.1, 0.8)  # Golden tint
		
		# Add hotbar number
		var hotbar_number = Label.new()
		hotbar_number.text = str(index + 1)
		hotbar_number.add_theme_font_size_override("font_size", 12)
		hotbar_number.position = Vector2(4, 2)
		add_child(hotbar_number)

func set_item_stack(stack: ItemStack):
	"""Update slot with ItemStack data"""
	item_stack = stack
	
	if stack.is_empty():
		set_empty()
	else:
		# Set icon from your Item resource
		if stack.item.icon:
			item_icon.texture = stack.item.icon
			item_icon.visible = true
		
		# Set quantity
		if stack.count > 1:
			item_quantity.text = str(stack.count)
			item_quantity.visible = true
		else:
			item_quantity.visible = false
		
		# Update details panel with item info
		item_name.text = stack.item.item_name
		
		# Handle item type - check if it exists as a property
		if "item_type" in stack.item:
			item_type.text = stack.item.item_type
		else:
			item_type.text = "Item"
		
		# Handle item effect - check for healing or other effects
		var effect_text = ""
		if "healing_amount" in stack.item and stack.item.healing_amount > 0:
			effect_text = "+ %d Health" % stack.item.healing_amount
		elif "damage" in stack.item and stack.item.damage > 0:
			effect_text = "%d Damage" % stack.item.damage
		
		item_effect.text = effect_text
		
		item_button.disabled = false

func set_empty():
	"""Set slot as empty"""
	item_stack = null
	item_icon.texture = null
	item_icon.visible = false
	item_quantity.visible = false
	item_button.disabled = true
	hide_panels()

func hide_panels():
	"""Hide all popup panels"""
	details_panel.visible = false
	usage_panel.visible = false

# === SIGNAL HANDLERS ===

func _on_item_button_pressed():
	"""Handle item button click - show/hide usage panel"""
	if item_stack and not item_stack.is_empty():
		usage_panel.visible = !usage_panel.visible
		details_panel.visible = false
		slot_clicked.emit(slot_index)

func _on_mouse_entered():
	"""Show item details on hover"""
	if item_stack and not item_stack.is_empty():
		usage_panel.visible = false
		details_panel.visible = true

func _on_mouse_exited():
	"""Hide details when mouse leaves"""
	details_panel.visible = false

func _on_use_button_pressed():
	"""Use/consume item"""
	usage_panel.visible = false
	item_used.emit(slot_index)

func _on_drop_button_pressed():
	"""Drop item to world"""
	usage_panel.visible = false
	item_dropped.emit(slot_index)
