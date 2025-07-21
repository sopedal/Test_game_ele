# === UIManager.gd - Complete script with mutually exclusive UI behavior ===
extends Node

# UI Panel References
@onready var inventory_ui: Control = null
@onready var hotbar_ui: Control = null
@onready var quest_ui: Control = null
@onready var level_ui: Control = null
@onready var shop_ui: Control = null
@onready var settings_ui: Control = null
@onready var pause_menu: Control = null

# UI State Management
var ui_panels: Dictionary = {}
var ui_stack: Array[String] = []
var is_any_ui_open: bool = false

# UI Categories for different behaviors
enum UICategory {
	HUD,        # Always visible (hotbar, health bar)
	OVERLAY,    # Mutually exclusive toggleable UI (inventory, quest log)
	MODAL,      # Blocks other input, might pause game (settings, shop)
	POPUP       # Temporary notifications
}

# UI Panel Configuration
var ui_config = {
	"inventory": {
		"category": UICategory.OVERLAY,
		"input_action": "toggle_inventory",
		"close_on_escape": true,
		"blocks_movement": true
	},
	"quest": {
		"category": UICategory.OVERLAY,
		"input_action": "toggle_quest",
		"close_on_escape": true,
		"blocks_movement": false
	},
	"level": {
		"category": UICategory.OVERLAY,
		"input_action": "toggle_level",
		"close_on_escape": true,
		"blocks_movement": false
	},
	"shop": {
		"category": UICategory.MODAL,
		"input_action": "",
		"close_on_escape": true,
		"blocks_movement": true
	},
	"settings": {
		"category": UICategory.MODAL,
		"input_action": "toggle_settings",
		"close_on_escape": true,
		"blocks_movement": true
	},
	"pause": {
		"category": UICategory.MODAL,
		"input_action": "toggle_pause",
		"close_on_escape": false,
		"blocks_movement": true
	},
	"hotbar": {
		"category": UICategory.HUD,
		"input_action": "",
		"close_on_escape": false,
		"blocks_movement": false
	}
}

# Signals for other systems to listen to
signal ui_opened(ui_name: String)
signal ui_closed(ui_name: String)
signal ui_state_changed(is_any_open: bool)
signal movement_blocked_changed(is_blocked: bool)

func _ready():
	# Set process mode to always so UI works even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to other managers
	_connect_to_managers()
	
	# Auto-discover UI panels
	call_deferred("_auto_discover_ui_panels")

func _connect_to_managers():
	"""Connect to your existing manager systems"""
	
	# Connect to InventoryManager instead of Global
	if InventoryManager.has_signal("inventory_updated"):
		InventoryManager.inventory_updated.connect(_on_inventory_updated)
	
	# Connect to QuestManager
	if QuestManager.has_signal("quest_updated"):
		QuestManager.quest_updated.connect(_on_quest_updated)
	
	# Connect to DialogueManager
	if DialogueManager.has_signal("dialogue_started"):
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
	if DialogueManager.has_signal("dialogue_ended"):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Connect to GameState
	if GameState.has_signal("game_paused"):
		GameState.game_paused.connect(_on_game_paused)
	if GameState.has_signal("game_resumed"):
		GameState.game_resumed.connect(_on_game_resumed)

func _auto_discover_ui_panels():
	"""Auto-discover UI panels in scene"""
	_find_ui_panels(get_tree().current_scene)
	_setup_initial_ui_state()

func _find_ui_panels(node: Node):
	"""Recursively find UI panels"""
	for child in node.get_children():
		_check_and_register_ui_panel(child)
		_find_ui_panels(child)

func _check_and_register_ui_panel(node: Node):
	"""Check and register UI panels"""
	if not node is Control:
		return
		
	var node_name = node.name.to_lower()
	
	# Check for UI panels
	if node_name.contains("inventory") and node_name.contains("ui"):
		register_ui_panel("inventory", node)
	elif node_name.contains("hotbar"):
		register_ui_panel("hotbar", node)
	elif node_name.contains("quest") and node_name.contains("ui"):
		register_ui_panel("quest", node)
	elif node_name.contains("level") and node_name.contains("ui"):
		register_ui_panel("level", node)
	elif node_name.contains("shop") and node_name.contains("ui"):
		register_ui_panel("shop", node)
	elif node_name.contains("settings") and node_name.contains("ui"):
		register_ui_panel("settings", node)
	elif node_name.contains("pause"):
		register_ui_panel("pause", node)

func register_ui_panel(ui_name: String, ui_node: Control):
	"""Register UI panel with manager"""
	if ui_node == null:
		print("Warning: Attempted to register null UI panel: ", ui_name)
		return
		
	ui_panels[ui_name] = ui_node
	
	# Set initial visibility
	if ui_name in ui_config:
		var config = ui_config[ui_name]
		if config.category == UICategory.HUD:
			ui_node.visible = true
		else:
			ui_node.visible = false
	
	print("UI Panel registered: ", ui_name)

func _setup_initial_ui_state():
	"""Setup initial UI state"""
	for ui_name in ui_panels.keys():
		var ui_node = ui_panels[ui_name]
		var config = ui_config.get(ui_name, {})
		
		if config.get("category", UICategory.OVERLAY) == UICategory.HUD:
			ui_node.visible = true
		else:
			ui_node.visible = false

func _input(event):
	"""Handle UI input"""
	if event.is_action_pressed("ui_cancel"):
		_handle_escape_key()
		return
	
	# Check for UI toggle inputs
	for ui_name in ui_config.keys():
		var config = ui_config[ui_name]
		if config.input_action != "" and event.is_action_pressed(config.input_action):
			toggle_ui(ui_name)
			break

func _handle_escape_key():
	"""Handle escape key"""
	if ui_stack.is_empty():
		return
		
	for i in range(ui_stack.size() - 1, -1, -1):
		var ui_name = ui_stack[i]
		var config = ui_config.get(ui_name, {})
		if config.get("close_on_escape", true):
			close_ui(ui_name)
			break

func open_ui(ui_name: String):
	"""Open UI panel - close other overlays if opening an overlay"""
	if not ui_name in ui_panels:
		print("Warning: UI panel not found: ", ui_name)
		return false
		
	var ui_node = ui_panels[ui_name]
	var config = ui_config.get(ui_name, {})
	
	if ui_node.visible:
		return false
	
	# Close other overlay UIs when opening an overlay (mutually exclusive)
	if config.get("category", UICategory.OVERLAY) == UICategory.OVERLAY:
		_close_other_overlays(ui_name)
	
	# Handle modal UIs - close all overlays
	if config.get("category", UICategory.OVERLAY) == UICategory.MODAL:
		_close_all_overlays()
	
	ui_node.visible = true
	
	# Add to stack
	if config.get("category", UICategory.OVERLAY) != UICategory.HUD:
		if not ui_name in ui_stack:
			ui_stack.append(ui_name)
		_update_ui_state()
	
	# Handle pause
	if config.get("category", UICategory.OVERLAY) == UICategory.MODAL:
		get_tree().paused = true
	
	ui_opened.emit(ui_name)
	print("Opened UI: ", ui_name)
	return true

func close_ui(ui_name: String):
	"""Close UI panel"""
	if not ui_name in ui_panels:
		print("Warning: UI panel not found: ", ui_name)
		return false
		
	var ui_node = ui_panels[ui_name]
	var config = ui_config.get(ui_name, {})
	
	if not ui_node.visible or config.get("category", UICategory.OVERLAY) == UICategory.HUD:
		return false
	
	ui_node.visible = false
	ui_stack.erase(ui_name)
	_update_ui_state()
	
	# Handle unpause
	if config.get("category", UICategory.OVERLAY) == UICategory.MODAL:
		if not _has_modal_ui_open():
			get_tree().paused = false
	
	ui_closed.emit(ui_name)
	print("Closed UI: ", ui_name)
	return true

func toggle_ui(ui_name: String):
	"""Toggle UI visibility - overlay UIs are mutually exclusive"""
	if not ui_name in ui_panels:
		print("Warning: UI panel not found: ", ui_name)
		return
		
	var ui_node = ui_panels[ui_name]
	if ui_node.visible:
		close_ui(ui_name)
	else:
		open_ui(ui_name)  # This will auto-close other overlays

func close_all_uis():
	"""Close all non-HUD UIs"""
	var uis_to_close = ui_stack.duplicate()
	for ui_name in uis_to_close:
		close_ui(ui_name)

func _close_other_overlays(except_ui: String):
	"""Close all overlay UIs except the specified one"""
	var uis_to_close = []
	for ui_name in ui_stack:
		if ui_name == except_ui:
			continue
		var config = ui_config.get(ui_name, {})
		if config.get("category", UICategory.OVERLAY) == UICategory.OVERLAY:
			uis_to_close.append(ui_name)
	
	for ui_name in uis_to_close:
		close_ui(ui_name)

func _close_all_overlays():
	"""Close all overlay UIs (used when opening modal UIs)"""
	var uis_to_close = []
	for ui_name in ui_stack:
		var config = ui_config.get(ui_name, {})
		if config.get("category", UICategory.OVERLAY) == UICategory.OVERLAY:
			uis_to_close.append(ui_name)
	
	for ui_name in uis_to_close:
		close_ui(ui_name)

func _has_modal_ui_open() -> bool:
	"""Check if modal UI is open"""
	for ui_name in ui_stack:
		var config = ui_config.get(ui_name, {})
		if config.get("category", UICategory.OVERLAY) == UICategory.MODAL:
			return true
	return false

func _update_ui_state():
	"""Update UI state and emit signals"""
	var was_any_open = is_any_ui_open
	is_any_ui_open = not ui_stack.is_empty()
	
	if was_any_open != is_any_ui_open:
		ui_state_changed.emit(is_any_ui_open)
	
	var should_block_movement = _should_block_movement()
	movement_blocked_changed.emit(should_block_movement)

func _should_block_movement() -> bool:
	"""Check if movement should be blocked"""
	for ui_name in ui_stack:
		var config = ui_config.get(ui_name, {})
		if config.get("blocks_movement", false):
			return true
	return false

# Manager Integration Callbacks
func _on_inventory_updated():
	"""Called when inventory is updated"""
	print("UIManager: Inventory updated")

func _on_quest_updated():
	"""Called when quest is updated"""
	print("UIManager: Quest updated")

func _on_dialogue_started():
	"""Called when dialogue starts"""
	open_ui("dialogue")

func _on_dialogue_ended():
	"""Called when dialogue ends"""
	close_ui("dialogue")

func _on_game_paused():
	"""Called when game is paused"""
	print("UIManager: Game paused")

func _on_game_resumed():
	"""Called when game is resumed"""
	print("UIManager: Game resumed")

# Utility Methods
func is_ui_open(ui_name: String) -> bool:
	"""Check if UI is open"""
	return ui_name in ui_panels and ui_panels[ui_name].visible

func get_open_uis() -> Array[String]:
	"""Get currently open UIs"""
	return ui_stack.duplicate()

func is_movement_blocked() -> bool:
	"""Check if movement is blocked"""
	return _should_block_movement()

func print_ui_state():
	"""Debug UI state"""
	print("=== UI Manager State ===")
	print("Registered UIs: ", ui_panels.keys())
	print("Open UIs: ", ui_stack)
	print("Any UI Open: ", is_any_ui_open)
	print("Movement Blocked: ", _should_block_movement())
	print("Game Paused: ", get_tree().paused)
	print("Connected Managers: InventoryManager, QuestManager, DialogueManager, GameState")
