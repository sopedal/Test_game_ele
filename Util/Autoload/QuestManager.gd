# === QuestManager.gd - Autoload for Quest System ===
extends Node

# Signals (keeping your original)
signal quest_updated(quest_id: String)
signal objective_updated(quest_id: String, objective_id: String)
signal quest_list_updated()

# Quest storage (keeping your original)
var quests = {}

func _ready():
	print("🎮 QuestManager autoload initialized")

# === KEEPING YOUR ORIGINAL METHODS ===

func add_quest(quest: Quest):
	quests[quest.quest_id] = quest
	quest.state = "in_progress"  # Ensure quest is active
	quest_updated.emit(quest.quest_id)
	quest_list_updated.emit()
	print("📜 Quest added: %s" % quest.quest_name)

func _remove_quest(quest_id: String):
	var quest = get_quest(quest_id)
	if quest:
		quests.erase(quest_id)
		quest_list_updated.emit()
		print("🗑️ Quest removed: %s" % quest.quest_name)
	
func get_quest(quest_id: String) -> Quest:
	return quests.get(quest_id, null)

func update_quest(quest_id: String, state: String):
	var quest = get_quest(quest_id)
	if quest:
		quest.state = state
		quest_updated.emit(quest_id)
		if state == "completed":
			_remove_quest(quest_id)
		print("📝 Quest updated: %s -> %s" % [quest.quest_name, state])
			
func get_active_quests() -> Array:
	var active_quests = []
	for quest in quests.values():
		if quest.state == "in_progress":
			active_quests.append(quest)
	return active_quests

func complete_objective(quest_id: String, objective_id: String, quantity: int = 1):
	var quest = get_quest(quest_id)
	if quest:
		quest.complete_objective(objective_id, quantity)
		objective_updated.emit(quest_id, objective_id)
		
		# Check if quest is now complete
		if quest.is_completed():
			update_quest(quest_id, "completed")
		
		print("🎯 Objective updated: %s/%s (+%d)" % [quest_id, objective_id, quantity])
						
# === UPDATED FOR UIMANAGER ===

func show_quest_log():
	"""Use UIManager to show quest log"""
	UIManager.open_ui("quest")

func hide_quest_log():
	"""Use UIManager to hide quest log"""
	UIManager.close_ui("quest")

func toggle_quest_log():
	"""Use UIManager to toggle quest log"""
	UIManager.toggle_ui("quest")

# === HELPER METHODS ===

func progress_collection_objective(quest_id: String, target_id: String, quantity: int = 1):
	"""Helper for collection objectives"""
	var quest = get_quest(quest_id)
	if quest:
		for objective in quest.objectives:
			if objective.target_type == "collection" and objective.target_id == target_id:
				complete_objective(quest_id, objective.id, quantity)
				break

func complete_talk_objective(quest_id: String, target_id: String):
	"""Helper for talk objectives"""
	var quest = get_quest(quest_id)
	if quest:
		for objective in quest.objectives:
			if objective.target_type == "talk_to" and objective.target_id == target_id:
				complete_objective(quest_id, objective.id)
				break

# === TEST QUEST METHOD ===

func start_test_quest():
	"""Test method - create a simple quest"""
	print("🧪 Starting test quest...")
	
	# Create a simple test quest
	var test_quest = Quest.new()
	test_quest.quest_id = "test_quest_001"
	test_quest.quest_name = "Test Quest"
	test_quest.quest_description = "This is a test quest to verify the quest system works."
	test_quest.state = "in_progress"
	
	# Add test objective
	var test_objective = Objectives.new()
	test_objective.id = "collect_berries"
	test_objective.description = "Collect berries"
	test_objective.target_type = "collection"
	test_objective.target_id = "berry"
	test_objective.required_quantity = 3
	test_objective.collected_quantity = 0
	test_quest.objectives.append(test_objective)
	
	# Add test reward
	var test_reward = Rewards.new()
	test_reward.reward_type = "experience"
	test_reward.reward_amount = 100
	test_quest.rewards.append(test_reward)
	
	add_quest(test_quest)

# === DEBUG METHODS ===

func print_quest_status():
        """Debug method to print all quest info"""
        print("\n=== QUEST STATUS ===")
        print("Total quests: %d" % quests.size())
        print("Active quests: %d" % get_active_quests().size())
	
        for quest in get_active_quests():
                print("📜 %s (%s)" % [quest.quest_name, quest.state])
                for objective in quest.objectives:
                        var status = "✅" if objective.is_completed else "❌"
                        print("  %s %s" % [status, objective.description])
        print("==================\n")

# === MENTOR QUEST INTEGRATION ===

func start_mentor_quest(quest_id: String) -> bool:
        var success = GameState.start_mentor_quest(quest_id)
        if success:
                var data = GameState.mentor_quests[quest_id]
                var quest = Quest.new()
                quest.quest_id = quest_id
                quest.quest_name = data.name
                quest.quest_description = data.description
                quest.state = "in_progress"
                quests[quest_id] = quest
                quest_list_updated.emit()
        return success
