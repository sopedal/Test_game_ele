extends Node

# ============================================================================
# EVENTBUS - Comprehensive Language Learning Life Simulation Game
# ============================================================================
# Central event management for all game systems including life simulation,
# dialogue mastery, phonetics, grammar, careers, hobbies, and testing
# Integrates with Nathan Hoad's Dialogue Manager for language learning progression

# ============================================================================
# TIME & CALENDAR EVENTS
# ============================================================================
signal time_tick(hour: int, minute: int)
signal time_advanced(minutes_passed: int)
signal hour_changed(new_hour: int)
signal day_started(day: int, season: String, year: int)
signal day_ended(day: int, season: String, year: int)
signal season_changed(new_season: String, year: int)
signal year_changed(new_year: int)
signal festival_day(festival_name: String)

# ============================================================================
# PLAYER STATUS & LIFE SIMULATION EVENTS
# ============================================================================
signal player_spawned(position: Vector2)
signal player_health_changed(current: int, max: int, difference: int)
signal player_energy_changed(current: int, max: int, difference: int)
signal player_exhausted()
signal player_fainted()
signal player_sleeping()
signal player_woke_up()
signal player_leveled_up(skill: String, new_level: int, old_level: int)
signal player_experience_gained(skill: String, amount: int, total: int)
signal player_stats_updated(stats: Dictionary)
signal overall_level_changed(new_level: int, old_level: int)

# ============================================================================
# LINGUISTICS & LANGUAGE LEARNING EVENTS
# ============================================================================

# Phonetics & Pronunciation Events
signal phoneme_practiced(phoneme_id: String, region: String, accuracy: int)
signal phoneme_mastered(phoneme_id: String, region: String)
signal pronunciation_accuracy_changed(new_accuracy: int, old_accuracy: int)
signal accent_rating_improved(new_rating: String, old_rating: String)
signal regional_familiarity_gained(region: String, familiarity_level: int)
signal problematic_sound_identified(phoneme_id: String)
signal pronunciation_challenge_completed(phoneme_id: String, success: bool)

# Grammar Learning Events
signal grammar_rule_practiced(rule_id: String, accuracy: int)
signal grammar_rule_mastered(rule_id: String, category: String)
signal grammar_accuracy_changed(new_accuracy: int, old_accuracy: int)
signal grammar_level_increased(new_level: int, old_level: int)
signal challenging_grammar_identified(rule_id: String)
signal grammar_exercise_completed(rule_id: String, success: bool)

# Vocabulary & Cultural Events
signal vocabulary_expanded(new_word: String, context: String, total_size: int)
signal cultural_knowledge_gained(topic: String, amount: int)
signal cultural_event_learned(event_name: String, region: String)

# ============================================================================
# DIALOGUE & CONVERSATION EVENTS
# ============================================================================
signal dialogue_sequence_started(sequence_type: String, npc_name: String, context: String)
signal dialogue_choice_made(quality: int, context_appropriate: bool, points_gained: int)
signal dialogue_sequence_completed(sequence_type: String, overall_score: float, quality: String)
signal dialogue_sequence_failed(sequence_type: String, reason: String)
signal conversation_streak_started(streak_count: int)
signal conversation_streak_broken(final_count: int)
signal conversation_confidence_changed(new_confidence: int, old_confidence: int)
signal perfect_dialogue_achieved(sequence_type: String, npc_name: String)
signal dialogue_mastery_improved(new_level: int, old_level: int)

# ============================================================================
# CAREER & EMPLOYMENT EVENTS
# ============================================================================
signal job_applied(job_type: String, success: bool)
signal job_started(job_title: String, salary: int)
signal job_quit(job_title: String, reason: String)
signal work_day_completed(performance: int, salary_earned: int)
signal work_performance_evaluated(score: int, feedback: String)
signal promotion_available(new_position: String, requirements: Dictionary)
signal promotion_achieved(old_position: String, new_position: String)
signal work_skills_improved(skill: String, improvement: int)
signal workplace_event(event_type: String, description: String)

# ============================================================================
# HOBBIES & PERSONAL DEVELOPMENT EVENTS
# ============================================================================
signal hobby_started(hobby_id: String, hobby_name: String)
signal hobby_practiced(hobby_id: String, progress: int, benefits: Dictionary)
signal hobby_milestone_reached(hobby_id: String, milestone: String)
signal hobby_mastery_achieved(hobby_id: String, mastery_level: int)
signal hobby_abandoned(hobby_id: String, reason: String)
signal creative_achievement(hobby_id: String, achievement: String)
signal fitness_goal_reached(activity: String, target: String)
signal skill_synergy_discovered(skill1: String, skill2: String, bonus: float)

# ============================================================================
# TESTING & ASSESSMENT EVENTS
# ============================================================================
signal test_available(test_type: String, urgency: String)
signal test_started(test_type: String, dialogue_count: int)
signal test_dialogue_completed(test_index: int, score: float, context: String)
signal test_completed(test_type: String, overall_score: float, result: String)
signal test_failed(test_type: String, score: float, areas_for_improvement: Array)
signal test_passed_with_excellence(test_type: String, score: float)
signal assessment_scheduled(test_type: String, deadline: Dictionary)
signal certification_earned(certification_type: String, level: String)
signal test_analytics_updated(performance_summary: Dictionary)

# ============================================================================
# MENTOR QUEST & PROGRESSION EVENTS
# ============================================================================
signal mentor_quest_available(quest_id: String, quest_name: String, difficulty: String)
signal mentor_quest_started(quest_id: String, quest_name: String, timeframe: int)
signal mentor_quest_progress_updated(quest_id: String, progress: Dictionary)
signal mentor_quest_completed(quest_id: String, grade: String, rewards: Dictionary)
signal mentor_quest_failed(quest_id: String, reason: String)
signal mentor_quest_abandoned(quest_id: String)
signal quest_deadline_approaching(quest_id: String, days_remaining: int)
signal achievement_unlocked(achievement_id: String, title: String, description: String)

# ============================================================================
# MONEY & ECONOMY EVENTS
# ============================================================================
signal money_changed(new_amount: int, difference: int)
signal money_gained(amount: int, source: String)
signal money_spent(amount: int, purpose: String)
signal purchase_completed(item: String, quantity: int, total_cost: int)
signal sale_completed(item: String, quantity: int, total_earned: int)
signal insufficient_funds(required: int, available: int)
signal financial_milestone_reached(milestone: String, amount: int)
signal budget_set(category: String, amount: int)
signal expense_tracked(category: String, amount: int)

# ============================================================================
# INVENTORY & ITEMS EVENTS
# ============================================================================
signal inventory_changed()
signal item_added(item_id: String, quantity: int)
signal item_removed(item_id: String, quantity: int)
signal item_used(item_id: String, quantity: int, purpose: String)
signal item_crafted(item_id: String, quantity: int, materials_used: Array)
signal item_found(item_id: String, quantity: int, location: String)
signal inventory_full()
signal special_item_acquired(item_id: String, rarity: String)
signal collection_completed(collection_name: String, items: Array)

# ============================================================================
# SOCIAL & RELATIONSHIP EVENTS
# ============================================================================
signal npc_met(npc_name: String, location: String)
signal relationship_changed(npc_name: String, new_points: int, old_points: int)
signal relationship_level_up(npc_name: String, new_level: String)
signal gift_given(npc_name: String, item: String, points_gained: int)
signal birthday_gift_given(npc_name: String, item: String, points_gained: int)
signal social_event_attended(event_name: String, participants: Array)
signal friendship_milestone(npc_name: String, milestone: String)
signal romantic_interest_developed(npc_name: String)
signal social_skill_demonstrated(skill_type: String, success: bool)
signal cultural_exchange_completed(npc_name: String, topic: String)

# ============================================================================
# LOCATION & ENVIRONMENT EVENTS
# ============================================================================
signal location_changed(new_location: String, old_location: String)
signal area_discovered(area_name: String, description: String)
signal fast_travel_unlocked(location: String)
signal location_activity_completed(location: String, activity: String)
signal environmental_change(location: String, change_type: String)
signal weather_changed(new_weather: int, old_weather: int)
signal weather_affects_activity(activity: String, weather: String, impact: String)

# ============================================================================
# LEARNING & EDUCATION EVENTS
# ============================================================================
signal lesson_started(subject: String, topic: String, difficulty: int)
signal lesson_completed(subject: String, score: int, mastery: bool)
signal study_session_started(duration_minutes: int, focus_area: String)
signal study_session_completed(effectiveness: int, areas_studied: Array)
signal learning_goal_set(goal_type: String, target: String, deadline: Dictionary)
signal learning_goal_achieved(goal_type: String, target: String)
signal study_streak_started(streak_count: int)
signal study_streak_milestone(streak_count: int)

# ============================================================================
# CULTURAL & REGIONAL EVENTS
# ============================================================================
signal cultural_activity_participated(activity: String, region: String)
signal regional_custom_learned(custom: String, region: String, importance: String)
signal festival_participated(festival: String, region: String, role: String)
signal local_tradition_discovered(tradition: String, region: String)
signal cultural_competency_demonstrated(region: String, situation: String)
signal cross_cultural_understanding_gained(topic: String, perspectives: Array)

# ============================================================================
# SAVE & GAME STATE EVENTS
# ============================================================================
signal game_saved(save_slot: int, timestamp: String)
signal game_loaded(save_slot: int, timestamp: String)
signal auto_save_triggered()
signal save_corrupted(save_slot: int)
signal new_game_started(difficulty: String, region: String)
signal game_paused()
signal game_unpaused()
signal settings_changed(setting: String, new_value)
signal backup_created(backup_name: String)

# ============================================================================
# UI & INTERFACE EVENTS
# ============================================================================
signal menu_opened(menu_type: String)
signal menu_closed(menu_type: String)
signal notification_shown(message: String, type: String, duration: float)
signal tooltip_requested(item: String, position: Vector2)
signal interface_mode_changed(new_mode: String)
signal tutorial_started(tutorial_id: String)
signal tutorial_completed(tutorial_id: String)
signal help_requested(topic: String)

# ============================================================================
# PERFORMANCE & ANALYTICS EVENTS
# ============================================================================
signal performance_milestone_reached(category: String, milestone: String, value: int)
signal weekly_summary_generated(summary: Dictionary)
signal monthly_report_available(report: Dictionary)
signal learning_analytics_updated(analytics: Dictionary)
signal improvement_suggestion(area: String, suggestion: String)
signal study_efficiency_calculated(efficiency: float, recommendations: Array)

# ============================================================================
# UTILITY FUNCTIONS FOR EVENT MANAGEMENT
# ============================================================================

# Batch emit multiple related events
func emit_skill_progression(skill_name: String, old_level: int, new_level: int, exp_gained: int):
	emit_signal("player_experience_gained", skill_name, exp_gained, 0)
	if new_level > old_level:
		emit_signal("player_leveled_up", skill_name, new_level, old_level)

# Emit comprehensive dialogue completion
func emit_dialogue_completion(sequence_type: String, npc_name: String, score: float, perfect_choices: int, total_choices: int):
	var quality = "poor"
	if score >= 90:
		quality = "perfect"
		emit_signal("perfect_dialogue_achieved", sequence_type, npc_name)
	elif score >= 75:
		quality = "excellent"
	elif score >= 60:
		quality = "good"
	
	emit_signal("dialogue_sequence_completed", sequence_type, score, quality)
	
	if perfect_choices == total_choices:
		emit_signal("conversation_streak_started", 1)

# Emit test progression events
func emit_test_progression(test_type: String, current_dialogue: int, total_dialogues: int, dialogue_score: float, context: String):
	emit_signal("test_dialogue_completed", current_dialogue, dialogue_score, context)
	
	if current_dialogue == total_dialogues:
		# Test completed - overall score would be calculated elsewhere
		pass

# Emit career advancement
func emit_career_advancement(old_job: String, new_job: String, salary_increase: int):
	if old_job != "":
		emit_signal("job_quit", old_job, "promotion")
	emit_signal("promotion_achieved", old_job, new_job)
	if salary_increase > 0:
		emit_signal("money_gained", salary_increase, "promotion_bonus")

# Emit linguistics improvement
func emit_pronunciation_improvement(phoneme_id: String, region: String, old_accuracy: int, new_accuracy: int):
	emit_signal("phoneme_practiced", phoneme_id, region, new_accuracy)
	if new_accuracy >= 85 and old_accuracy < 85:
		emit_signal("phoneme_mastered", phoneme_id, region)

func emit_grammar_improvement(rule_id: String, category: String, old_accuracy: int, new_accuracy: int):
	emit_signal("grammar_rule_practiced", rule_id, new_accuracy)
	if new_accuracy >= 80 and old_accuracy < 80:
		emit_signal("grammar_rule_mastered", rule_id, category)

# Emit location-based learning
func emit_location_learning(location: String, activity: String, skills_gained: Array):
	emit_signal("location_activity_completed", location, activity)
	for skill in skills_gained:
		emit_signal("player_experience_gained", skill.name, skill.amount, skill.total)

# Emit social interaction outcome
func emit_social_interaction(npc_name: String, interaction_type: String, success: bool, relationship_change: int):
	if relationship_change != 0:
		emit_signal("relationship_changed", npc_name, 0, relationship_change)  # Old points would come from game state
	
	if success:
		emit_signal("social_skill_demonstrated", interaction_type, true)
	
	match interaction_type:
		"cultural_exchange":
			emit_signal("cultural_exchange_completed", npc_name, "general_topics")
		"gift_giving":
			emit_signal("gift_given", npc_name, "unknown_item", relationship_change)

# Debug function to list all connected signals with their connection counts
func debug_list_connections():
	print("=== EventBus Signal Connections ===")
	var total_signals = 0
	var total_connections = 0
	
	for signal_info in get_signal_list():
		var signal_name = signal_info.name
		var connections = get_signal_connection_list(signal_name)
		total_signals += 1
		
		if connections.size() > 0:
			total_connections += connections.size()
			print("%s: %d connections" % [signal_name, connections.size()])
			for connection in connections:
				print("  -> %s.%s" % [connection.target, connection.method])
		else:
			print("%s: no connections" % signal_name)
	
	print("Total: %d signals, %d connections" % [total_signals, total_connections])

# Helper to check if a specific event has listeners
func has_listeners(signal_name: String) -> bool:
	return get_signal_connection_list(signal_name).size() > 0

# Get connection statistics for monitoring
func get_connection_stats() -> Dictionary:
	var stats = {
		"total_signals": 0,
		"connected_signals": 0,
		"total_connections": 0,
		"categories": {}
	}
	
	for signal_info in get_signal_list():
		var signal_name = signal_info.name
		var connections = get_signal_connection_list(signal_name)
		stats.total_signals += 1
		
		if connections.size() > 0:
			stats.connected_signals += 1
			stats.total_connections += connections.size()
		
		# Categorize signals
		var category = "other"
		if signal_name.begins_with("dialogue_"):
			category = "dialogue"
		elif signal_name.begins_with("phoneme_") or signal_name.begins_with("grammar_") or signal_name.begins_with("pronunciation_"):
			category = "linguistics"
		elif signal_name.begins_with("job_") or signal_name.begins_with("work_") or signal_name.begins_with("career_"):
			category = "career"
		elif signal_name.begins_with("test_") or signal_name.begins_with("assessment_"):
			category = "testing"
		elif signal_name.begins_with("hobby_") or signal_name.begins_with("creative_"):
			category = "hobbies"
		elif signal_name.begins_with("relationship_") or signal_name.begins_with("social_"):
			category = "social"
		elif signal_name.begins_with("time_") or signal_name.begins_with("day_") or signal_name.begins_with("season_"):
			category = "time"
		elif signal_name.begins_with("money_") or signal_name.begins_with("purchase_"):
			category = "economy"
		
		if not category in stats.categories:
			stats.categories[category] = {"signals": 0, "connections": 0}
		
		stats.categories[category].signals += 1
		stats.categories[category].connections += connections.size()
	
	return stats

# Performance monitoring
func log_event_performance():
	var stats = get_connection_stats()
	print("=== EventBus Performance ===")
	print("Connected signals: %d/%d (%.1f%%)" % [stats.connected_signals, stats.total_signals, float(stats.connected_signals) / stats.total_signals * 100])
	print("Average connections per signal: %.1f" % (float(stats.total_connections) / stats.total_signals))
	
	print("\nBy category:")
	for category in stats.categories.keys():
		var cat_stats = stats.categories[category]
		print("  %s: %d signals, %d connections" % [category, cat_stats.signals, cat_stats.connections])

# Helper to emit events safely with error handling
func safe_emit(signal_name: String, args: Array = []):
	if has_signal(signal_name):
		if args.size() == 0:
			emit_signal(signal_name)
		else:
			emit_signal(signal_name, args[0] if args.size() >= 1 else null, args[1] if args.size() >= 2 else null, args[2] if args.size() >= 3 else null, args[3] if args.size() >= 4 else null, args[4] if args.size() >= 5 else null)
	else:
		push_error("Attempted to emit non-existent signal: %s" % signal_name)

# Event filtering for UI systems that only want specific categories
func connect_category_events(category: String, target: Object, method: String):
	var relevant_signals = []
	
	match category:
		"dialogue":
			relevant_signals = ["dialogue_sequence_started", "dialogue_choice_made", "dialogue_sequence_completed", "perfect_dialogue_achieved"]
		"linguistics":
			relevant_signals = ["phoneme_practiced", "phoneme_mastered", "grammar_rule_practiced", "pronunciation_accuracy_changed"]
		"career":
			relevant_signals = ["job_applied", "job_started", "work_day_completed", "promotion_achieved"]
		"testing":
			relevant_signals = ["test_available", "test_started", "test_completed", "certification_earned"]
		"progress":
			relevant_signals = ["player_leveled_up", "overall_level_changed", "achievement_unlocked", "mentor_quest_completed"]
	
	for signal_name in relevant_signals:
		if has_signal(signal_name):
			connect(signal_name, Callable(target, method))

# Specialized event emitters for complex game situations
func emit_immersive_learning_session(location: String, activity: String, duration: int, linguistic_gains: Dictionary):
	emit_signal("location_activity_completed", location, activity)
	emit_signal("study_session_completed", 85, [activity])  # High effectiveness for immersive learning
	
	for skill in linguistic_gains.keys():
		emit_signal("player_experience_gained", skill, linguistic_gains[skill], 0)
	
	if linguistic_gains.has("phonetics") and linguistic_gains.phonetics > 10:
		emit_signal("pronunciation_improvement_notable", activity, linguistic_gains.phonetics)

func emit_cultural_immersion_event(region: String, activity: String, npcs_met: Array, cultural_learning: Dictionary):
	emit_signal("cultural_activity_participated", activity, region)
	
	for npc in npcs_met:
		emit_signal("npc_met", npc, region)
	
	for cultural_aspect in cultural_learning.keys():
		emit_signal("regional_custom_learned", cultural_aspect, region, "important")
	
	emit_signal("cross_cultural_understanding_gained", region, cultural_learning.keys())
