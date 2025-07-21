# === QuestUI.gd - Fixed version ===
extends Control

# Scene references - will be set up dynamically if not found
@onready var quest_list: VBoxContainer
@onready var quest_title: Label
@onready var quest_description: Label
@onready var quest_objectives: VBoxContainer
@onready var quest_rewards: VBoxContainer

# Quest data
var selected_quest: Quest = null
var quest_manager: QuestManager

func _ready():
	# Ensure proper naming for UIManager auto-discovery
	name = "Quest_UI"
	
	# Start hidden - UIManager will control visibility
	visible = false
	
	# Set up UI nodes (create them if they don't exist)
	_setup_ui_nodes()
	
	# Connect to visibility changes
	visibility_changed.connect(_on_visibility_changed)
	
	# Connect to QuestManager
	_connect_to_quest_manager()
	
	# Clear initial state
	clear_quest_details()
	
	# FOR TESTING: Create a test quest automatically
	call_deferred("_create_test_quest")

func _setup_ui_nodes():
	"""Set up UI nodes - create them if they don't exist"""
	
	# Try to find existing nodes first
	quest_list = find_child("QuestList", true, false) as VBoxContainer
	quest_title = find_child("QuestTitle", true, false) as Label
	quest_description = find_child("QuestDescription", true, false) as Label
	quest_objectives = find_child("QuestObjectives", true, false) as VBoxContainer
	quest_rewards = find_child("QuestRewards", true, false) as VBoxContainer
	
	# If nodes don't exist, create a basic UI structure
	if not quest_list or not quest_title or not quest_description or not quest_objectives or not quest_rewards:
		print("🔧 QuestUI: Creating basic UI structure...")
		_create_basic_ui()

func _create_basic_ui():
	"""Create a basic UI structure if scene doesn't have proper nodes"""
	
	# Clear existing children
	for child in get_children():
		child.queue_free()
	
	# Create main panel
	var main_panel = Panel.new()
	main_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_panel.add_theme_color_override("bg_color", Color(0, 0, 0, 0.8))
	add_child(main_panel)
	
	# Create horizontal split
	var hsplit = HSplitContainer.new()
	hsplit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hsplit.add_theme_constant_override("separation", 10)
	main_panel.add_child(hsplit)
	
	# Left side - Quest List
	var left_panel = Panel.new()
	left_panel.custom_minimum_size = Vector2(300, 0)
	left_panel.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 0.9))
	hsplit.add_child(left_panel)
	
	var left_vbox = VBoxContainer.new()
	left_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	left_vbox.add_theme_constant_override("separation", 5)
	left_panel.add_child(left_vbox)
	
	var list_title = Label.new()
	list_title.text = "Active Quests"
	list_title.add_theme_font_size_override("font_size", 20)
	list_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_vbox.add_child(list_title)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_vbox.add_child(scroll)
	
	quest_list = VBoxContainer.new()
	quest_list.name = "QuestList"
	quest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(quest_list)
	
	# Right side - Quest Details
	var right_panel = Panel.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_color_override("bg_color", Color(0.1, 0.1, 0.1, 0.9))
	hsplit.add_child(right_panel)
	
	var right_vbox = VBoxContainer.new()
	right_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	right_vbox.add_theme_constant_override("separation", 10)
	right_panel.add_child(right_vbox)
	
	quest_title = Label.new()
	quest_title.name = "QuestTitle"
	quest_title.text = "Select a Quest"
	quest_title.add_theme_font_size_override("font_size", 24)
	quest_title.add_theme_color_override("font_color", Color.YELLOW)
	right_vbox.add_child(quest_title)
	
	quest_description = Label.new()
	quest_description.name = "QuestDescription"
	quest_description.text = "Choose a quest from the list to view details."
	quest_description.add_theme_font_size_override("font_size", 16)
	quest_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_vbox.add_child(quest_description)
	
	var objectives_title = Label.new()
	objectives_title.text = "Objectives:"
	objectives_title.add_theme_font_size_override("font_size", 18)
	objectives_title.add_theme_color_override("font_color", Color.CYAN)
	right_vbox.add_child(objectives_title)
	
	quest_objectives = VBoxContainer.new()
	quest_objectives.name = "QuestObjectives"
	right_vbox.add_child(quest_objectives)
	
	quest_rewards = VBoxContainer.new()
	quest_rewards.name = "QuestRewards"
	right_vbox.add_child(quest_rewards)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close (ESC)"
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.pressed.connect(_on_close_pressed)
	right_vbox.add_child(close_button)

func _connect_to_quest_manager():
	"""Connect to QuestManager autoload"""
	
	# QuestManager is an autoload, so access it directly
	quest_manager = QuestManager
	
	if quest_manager:
		# Connect to QuestManager signals
		quest_manager.quest_updated.connect(_on_quest_updated)
		quest_manager.objective_updated.connect(_on_objectives_updated)
		quest_manager.quest_list_updated.connect(_on_quest_list_updated)
		print("✅ Quest UI: Connected to QuestManager autoload")
	else:
		print("❌ Quest UI: QuestManager autoload not found")
		print("💡 Make sure QuestManager is added as autoload in Project Settings")

func _create_test_quest():
	"""Create a test quest for testing purposes"""
	if quest_manager:
		quest_manager.start_test_quest()
		print("🧪 Test quest created!")

func _on_visibility_changed():
	"""Called when UI becomes visible - update quest list"""
	if visible:
		update_quest_list()
		# Select first quest if none selected
		if not selected_quest:
			var active_quests = quest_manager.get_active_quests()
			if not active_quests.is_empty():
				_on_quest_selected(active_quests[0])

func update_quest_list():
	"""Populate quest list with active quests"""
	
	if not quest_list:
		print("❌ QuestUI: quest_list not found!")
		return
	
	# Clear existing quest buttons
	_clear_container(quest_list)
	
	# Get active quests from QuestManager
	var active_quests = quest_manager.get_active_quests()
	
	print("📋 QuestUI: Found %d active quests" % active_quests.size())
	
	if active_quests.is_empty():
		# No active quests
		clear_quest_details()
		selected_quest = null
		_update_player_quest_tracker(null)
		
		# Show "no quests" message
		var no_quest_label = Label.new()
		no_quest_label.text = "No active quests"
		no_quest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_quest_label.add_theme_font_size_override("font_size", 18)
		no_quest_label.add_theme_color_override("font_color", Color.GRAY)
		quest_list.add_child(no_quest_label)
	else:
		# Create button for each active quest
		for quest in active_quests:
			var quest_button = Button.new()
			quest_button.text = quest.quest_name
			quest_button.add_theme_font_size_override("font_size", 16)
			quest_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			quest_button.pressed.connect(_on_quest_selected.bind(quest))
			
			# Highlight selected quest
			if selected_quest and selected_quest.quest_id == quest.quest_id:
				quest_button.add_theme_color_override("font_color", Color.YELLOW)
				quest_button.add_theme_color_override("font_pressed_color", Color.YELLOW)
			
			quest_list.add_child(quest_button)

func _on_quest_selected(quest: Quest):
	"""Handle quest selection - show quest details"""
	
	selected_quest = quest
	_update_player_quest_tracker(quest)
	
	print("📜 QuestUI: Selected quest: %s" % quest.quest_name)
	
	# Update quest details
	if quest_title:
		quest_title.text = quest.quest_name
	if quest_description:
		quest_description.text = quest.quest_description
	
	# Update objectives
	if quest_objectives:
		_clear_container(quest_objectives)
		for objective in quest.objectives:
			var objective_label = Label.new()
			objective_label.add_theme_font_size_override("font_size", 14)
			objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			
			# Format objective text based on type
			if objective.target_type == "collection":
				objective_label.text = "• " + objective.description + " (" + str(objective.collected_quantity) + "/" + str(objective.required_quantity) + ")"
			else:
				objective_label.text = "• " + objective.description
			
			# Color based on completion
			if objective.is_completed:
				objective_label.add_theme_color_override("font_color", Color.GREEN)
			else:
				objective_label.add_theme_color_override("font_color", Color.WHITE)
			
			quest_objectives.add_child(objective_label)
	
	# Update rewards
	if quest_rewards:
		_clear_container(quest_rewards)
		if not quest.rewards.is_empty():
			var rewards_title = Label.new()
			rewards_title.text = "Rewards:"
			rewards_title.add_theme_font_size_override("font_size", 16)
			rewards_title.add_theme_color_override("font_color", Color.GOLD)
			quest_rewards.add_child(rewards_title)
			
			for reward in quest.rewards:
				var reward_label = Label.new()
				reward_label.text = "• " + reward.reward_type.capitalize() + ": " + str(reward.reward_amount)
				reward_label.add_theme_font_size_override("font_size", 14)
				reward_label.add_theme_color_override("font_color", Color.LIGHT_GREEN)
				quest_rewards.add_child(reward_label)
	
	# Update quest list to show selection
	update_quest_list()

func clear_quest_details():
	"""Clear all quest detail displays"""
	
	if quest_title:
		quest_title.text = "Select a Quest"
	if quest_description:
		quest_description.text = "Choose a quest from the list to view details."
	
	if quest_objectives:
		_clear_container(quest_objectives)
	if quest_rewards:
		_clear_container(quest_rewards)

func _clear_container(container: Node):
	"""Helper to clear all children from a container"""
	
	if not container:
		return
		
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _update_player_quest_tracker(quest: Quest):
	"""Update player's quest tracker"""
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.has_method("set_selected_quest"):
			player.set_selected_quest(quest)
		elif player.has_method("update_quest_tracker"):
			player.update_quest_tracker(quest)
		else:
			print("Player doesn't have quest tracker methods")

func _on_close_pressed():
	"""Handle close button press"""
	if has_method("hide") or has_method("set_visible"):
		visible = false
	# Try to use UIManager if available
	if get_node_or_null("/root/UIManager"):
		get_node("/root/UIManager").close_ui("quest")

# === SIGNAL HANDLERS ===

func _on_quest_updated(quest_id: String):
	"""Called when a quest is updated"""
	
	print("📜 Quest UI: Quest updated - ", quest_id)
	
	# If currently selected quest was updated, refresh its details
	if selected_quest and selected_quest.quest_id == quest_id:
		var updated_quest = quest_manager.get_quest(quest_id)
		if updated_quest:
			_on_quest_selected(updated_quest)
		else:
			# Quest was removed/completed
			selected_quest = null
			clear_quest_details()
	
	# Refresh quest list
	update_quest_list()

func _on_objectives_updated(quest_id: String, objective_id: String):
	"""Called when quest objective is updated"""
	
	print("🎯 Quest UI: Objective updated - ", quest_id, "/", objective_id)
	
	# If currently selected quest had objective updated, refresh details
	if selected_quest and selected_quest.quest_id == quest_id:
		_on_quest_selected(selected_quest)

func _on_quest_list_updated():
	"""Called when quest list changes"""
	
	print("📋 Quest UI: Quest list updated")
	update_quest_list()

# === INPUT HANDLING ===

func _input(event):
	"""Handle quest UI input"""
	
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
		# Try to use UIManager if available
		if get_node_or_null("/root/UIManager"):
			get_node("/root/UIManager").close_ui("quest")

# === LEGACY SUPPORT ===

func show_hide_log():
	"""Toggle quest log visibility"""
	visible = not visible
	if visible:
		update_quest_list()
