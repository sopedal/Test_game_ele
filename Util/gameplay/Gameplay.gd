# === MainScene.gd - Fixed for your EventBus ===
extends Node2D

# Node references
@onready var player = $Player
@onready var ui_layer = $UILayer

func _ready():
	print("=== Starting Manager Integration Test ===")
	
	# Test if all managers are available
	_test_manager_availability()
	
	# Wait for UIManager to auto-discover
	await get_tree().process_frame
	
	# Test UIManager functionality
	_test_ui_manager()
	
	# Connect to manager signals
	_connect_to_managers()

func _test_manager_availability():
	"""Test if all managers are properly loaded"""
	print("\n--- Testing Manager Availability ---")
	
	var managers = ["GameState", "EventBus", "DialogueManager", "QuestManager", "Items", "InventoryManager", "UIManager"]
	
	for manager_name in managers:
		if has_node("/root/" + manager_name):
			print("✓ ", manager_name, " loaded")
		else:
			print("✗ ", manager_name, " missing")

func _test_ui_manager():
	"""Test UIManager functionality"""
	print("\n--- Testing UIManager ---")
	
	# Print UI state
	UIManager.print_ui_state()
	
	# Test if UIs were discovered
	var expected_uis = ["inventory", "hotbar", "quest"]
	for ui_name in expected_uis:
		if UIManager.ui_panels.has(ui_name):
			print("✓ ", ui_name.capitalize(), " UI found")
		else:
			print("✗ ", ui_name.capitalize(), " UI not found - add it to scene or check naming")

func _connect_to_managers():
	"""Connect to manager signals for integration testing"""
	print("\n--- Connecting to Manager Signals ---")
	
	# UIManager signals
	UIManager.ui_opened.connect(_on_ui_opened)
	UIManager.ui_closed.connect(_on_ui_closed)
	UIManager.movement_blocked_changed.connect(_on_movement_blocked_changed)
	
	# Try connecting to other managers (if they have these signals)
	if InventoryManager.has_signal("inventory_updated"):
		InventoryManager.inventory_updated.connect(_on_inventory_updated)
		print("✓ Connected to InventoryManager.inventory_updated")
	
	if QuestManager.has_signal("quest_updated"):
		QuestManager.quest_updated.connect(_on_quest_updated)
		print("✓ Connected to QuestManager.quest_updated")

# Signal callbacks for testing - FIXED for your EventBus
func _on_ui_opened(ui_name: String):
	print("📱 UI Opened: ", ui_name)
	# Use your existing EventBus signal
	EventBus.ui_opened.emit(ui_name)

func _on_ui_closed(ui_name: String):
	print("📱 UI Closed: ", ui_name)
	# Use your existing EventBus signal
	EventBus.ui_closed.emit(ui_name)

func _on_movement_blocked_changed(is_blocked: bool):
	print("🚶 Movement blocked: ", is_blocked)
	# Tell player about movement state
	if player and player.has_method("_on_movement_blocked_changed"):
		player._on_movement_blocked_changed(is_blocked)

func _on_inventory_updated():
	print("📦 Inventory updated")
	# Use your EventBus inventory signal
	EventBus.inventory_changed.emit()

func _on_quest_updated(quest_id: String):
	print("📜 Quest updated: ", quest_id)

# Test functions you can call from Remote Inspector
func test_inventory():
	"""Test inventory system integration"""
	print("\n--- Testing Inventory Integration ---")
	UIManager.toggle_ui("inventory")

func test_quest():
	"""Test quest system integration"""
	print("\n--- Testing Quest Integration ---")
	UIManager.toggle_ui("quest")

func test_all_managers():
	"""Test integration between all managers"""
	print("\n--- Testing All Manager Integration ---")
	
	# Test inventory
	if InventoryManager.has_method("add_item"):
		print("✓ InventoryManager.add_item() available")
	
	# Test quest
	if QuestManager.has_method("start_test_quest"):
		print("✓ QuestManager.start_test_quest() available")
		QuestManager.start_test_quest()
	
	# Test game state
	if GameState.has_method("pause_game"):
		print("✓ GameState.pause_game() available")

# Remove problematic input handling
func _input(event):
	"""Test input handling - SIMPLIFIED"""
	# Only keep essential debug input
	if event.is_action_pressed("ui_accept"):  # Enter key
		print("🎮 Testing managers integration...")
		test_all_managers()
	
	# Remove the space key input that was causing conflicts
	# if event.is_action_pressed("ui_select"):  # Space key  
	#     print("🎮 Testing inventory...")
	#     test_inventory()i
