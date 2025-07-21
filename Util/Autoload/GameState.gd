extends Node

# ============================================================================
# GAMESTATE - Focused Language Learning Progress Tracker
# ============================================================================
# Streamlined version focusing on essential language learning metrics
# Easy data access for user performance analysis and dashboard creation

# ============================================================================
# CORE PLAYER DATA - Essential Tracking
# ============================================================================

var player_progress: Dictionary = {
	# Identity & Basic Info
	"player_id": "",
	"name": "Student",
	"start_date": "",
	"total_play_time": 0,  # minutes
	"current_session_time": 0,
	
	# Core Language Levels (1-10 scale)
	"overall_level": 1,
	"dialogue_level": 1,
	"pronunciation_level": 1,
	"grammar_level": 1,
	"confidence_score": 50,  # 0-100 scale
	
	# Performance Metrics (0-100 scale)
	"dialogue_accuracy": 60,
	"pronunciation_accuracy": 55,
	"grammar_accuracy": 65,
	"cultural_awareness": 40
}

# ============================================================================
# DIALOGUE PERFORMANCE TRACKING
# ============================================================================

var dialogue_stats: Dictionary = {
	# Daily Performance
	"today": {
		"conversations_attempted": 0,
		"conversations_completed": 0,
		"perfect_sequences": 0,
		"average_score": 0.0,
		"time_spent": 0,  # minutes
		"contexts_practiced": []
	},
	
	# Weekly Trends
	"this_week": {
		"total_conversations": 0,
		"success_rate": 0.0,
		"improvement_trend": 0.0,  # positive = improving
		"favorite_context": "",
		"challenging_context": ""
	},
	
	# All-Time Records
	"lifetime": {
		"total_conversations": 0,
		"perfect_conversations": 0,
		"best_streak": 0,
		"current_streak": 0,
		"total_time_hours": 0.0
	},
	
	# Context-Specific Performance (key insights)
	"by_context": {
		"casual": {"attempts": 0, "successes": 0, "avg_score": 0.0},
		"formal": {"attempts": 0, "successes": 0, "avg_score": 0.0},
		"business": {"attempts": 0, "successes": 0, "avg_score": 0.0},
		"cultural": {"attempts": 0, "successes": 0, "avg_score": 0.0},
		"emotional": {"attempts": 0, "successes": 0, "avg_score": 0.0},
		"technical": {"attempts": 0, "successes": 0, "avg_score": 0.0}
	}
}

# ============================================================================
# PRONUNCIATION TRACKING - Regional Focus
# ============================================================================

var pronunciation_data: Dictionary = {
	# Core Accuracy Metrics
	"overall_accuracy": 55,  # 0-100
	"accent_rating": "beginner",  # beginner, intermediate, advanced, native-like
	
	# Regional Dialect Progress (0-100 familiarity)
	"regional_progress": {
		"neutral": 60,
		"argentina": 20,  # Focus on Argentinian pronunciation
		"spain": 15,
		"mexico": 25,
		"colombia": 10
	},
	
	# Specific Sound Mastery (key pronunciation challenges)
	"sound_mastery": {
		"ll_argentina": {"attempts": 0, "accuracy": 0, "mastered": false},  # "lluvia" → "shuvia"
		"rr_trill": {"attempts": 0, "accuracy": 0, "mastered": false},      # Rolling R
		"j_velar": {"attempts": 0, "accuracy": 0, "mastered": false},       # /x/ sound
		"vowel_precision": {"attempts": 0, "accuracy": 0, "mastered": false}
	},
	
	# Practice History
	"recent_practice": [],  # Last 10 pronunciation sessions
	"problem_sounds": [],   # Sounds that need work
	"mastered_sounds": []   # Successfully learned sounds
}

# ============================================================================
# GRAMMAR PROGRESS TRACKING
# ============================================================================

var grammar_data: Dictionary = {
	# Overall Progress
	"competence_level": 1,  # 1-10 scale
	"accuracy_score": 65,   # 0-100
	
	# Grammar Categories Progress (1-10 mastery level)
	"categories": {
		"verb_conjugation": {"level": 1, "accuracy": 50, "practice_time": 0},
		"noun_gender": {"level": 1, "accuracy": 60, "practice_time": 0},
		"pronouns": {"level": 1, "accuracy": 40, "practice_time": 0},
		"subjunctive": {"level": 0, "accuracy": 0, "practice_time": 0},
		"complex_structures": {"level": 0, "accuracy": 0, "practice_time": 0}
	},
	
	# Specific Rules Mastered
	"mastered_rules": [],
	"challenging_rules": [],
	
	# Practice Patterns
	"weekly_practice_time": 0,  # minutes
	"preferred_practice_method": ""  # "exercises", "conversation", "games"
}

# ============================================================================
# TESTING & ASSESSMENT RESULTS
# ============================================================================

var assessment_data: Dictionary = {
	# Latest Test Results
	"last_test": {
		"date": "",
		"type": "",
		"score": 0,
		"result": "",  # "failed", "passed", "excellent", "perfect"
		"time_taken": 0,
		"areas_tested": []
	},
	
	# Test History (last 10 tests)
	"test_history": [],
	
	# Performance Analytics
	"analytics": {
		"average_score": 0.0,
		"improvement_rate": 0.0,  # score improvement per week
		"strongest_area": "",
		"weakest_area": "",
		"tests_taken": 0,
		"pass_rate": 0.0
	},
	
	# Recommendations
	"next_recommended_test": "",
	"focus_areas": []  # What to study next
}

# ============================================================================
# SESSION & TIME TRACKING
# ============================================================================

var session_data: Dictionary = {
	"start_time": 0,
	"current_session_minutes": 0,
	"activity_log": [],  # What user did this session
	
	# Daily Activity Breakdown
	"today_activities": {
		"dialogue_practice": 0,  # minutes
		"pronunciation_drills": 0,
		"grammar_exercises": 0,
		"testing": 0,
		"free_conversation": 0
	},
	
	# Engagement Metrics
	"engagement": {
		"sessions_this_week": 0,
		"average_session_length": 0,
		"longest_session": 0,
		"preferred_activity": "",
		"completion_rate": 0.0  # Percentage of started activities completed
	}
}

# ============================================================================
# SIMPLE GAME SYSTEMS (Minimal)
# ============================================================================

var game_state: Dictionary = {
	"current_location": "home",
	"energy": 100,
	"confidence": 50,
	"money": 500,
	"day": 1,
	"level": 1
}

# Current active systems
var active_dialogue: Dictionary = {}
var active_test: Dictionary = {}

# ============================================================================
# CORE FUNCTIONS - Easy Data Access
# ============================================================================

func start_session():
	session_data.start_time = Time.get_ticks_msec()
	session_data.current_session_minutes = 0
	session_data.engagement.sessions_this_week += 1
	print("Session started for player: %s" % player_progress.name)

func end_session():
	var session_length = (Time.get_ticks_msec() - session_data.start_time) / 60000  # Convert to minutes
	session_data.current_session_minutes = session_length
	player_progress.total_play_time += session_length
	
	# Update engagement metrics
	session_data.engagement.average_session_length = player_progress.total_play_time / session_data.engagement.sessions_this_week
	if session_length > session_data.engagement.longest_session:
		session_data.engagement.longest_session = session_length
	
	_update_daily_summary()
	save_progress()

# ============================================================================
# DIALOGUE TRACKING FUNCTIONS
# ============================================================================

func start_dialogue_conversation(context: String, npc_name: String = ""):
	active_dialogue = {
		"context": context,
		"npc": npc_name,
		"start_time": Time.get_ticks_msec(),
		"choices_made": 0,
		"perfect_choices": 0,
		"completed": false
	}
	
	dialogue_stats.today.conversations_attempted += 1
	dialogue_stats.by_context[context].attempts += 1
	
	print("Started %s conversation with %s" % [context, npc_name])

func make_dialogue_choice(quality: int, context_appropriate: bool) -> Dictionary:
	if active_dialogue.is_empty():
		return {"error": "No active dialogue"}
	
	active_dialogue.choices_made += 1
	
	# Score the choice (1-5 quality scale)
	var choice_score = quality
	if not context_appropriate:
		choice_score = max(1, choice_score - 2)
	
	if choice_score >= 4:  # Good or better
		active_dialogue.perfect_choices += 1
		dialogue_stats.lifetime.current_streak += 1
	else:
		dialogue_stats.lifetime.current_streak = 0
	
	return {"score": choice_score, "streak": dialogue_stats.lifetime.current_streak}

func complete_dialogue_conversation() -> Dictionary:
	if active_dialogue.is_empty():
		return {"error": "No active dialogue"}
	
	var duration = (Time.get_ticks_msec() - active_dialogue.start_time) / 60000
	var success_rate = float(active_dialogue.perfect_choices) / float(active_dialogue.choices_made)
	var overall_score = success_rate * 100
	
	# Update statistics
	dialogue_stats.today.conversations_completed += 1
	dialogue_stats.today.time_spent += duration
	dialogue_stats.today.contexts_practiced.append(active_dialogue.context)
	dialogue_stats.lifetime.total_conversations += 1
	
	var context = active_dialogue.context
	dialogue_stats.by_context[context].successes += 1
	dialogue_stats.by_context[context].avg_score = (dialogue_stats.by_context[context].avg_score + overall_score) / 2.0
	
	# Check for perfect conversation
	if success_rate >= 1.0:
		dialogue_stats.today.perfect_sequences += 1
		dialogue_stats.lifetime.perfect_conversations += 1
	
	# Update streak tracking
	dialogue_stats.lifetime.best_streak = max(dialogue_stats.lifetime.best_streak, dialogue_stats.lifetime.current_streak)
	
	# Update overall performance
	player_progress.dialogue_accuracy = (player_progress.dialogue_accuracy + overall_score) / 2.0
	
	var result = {
		"score": overall_score,
		"perfect": success_rate >= 1.0,
		"duration": duration,
		"context": context
	}
	
	active_dialogue = {}  # Clear active dialogue
	_update_confidence()
	
	print("Dialogue completed: %.1f%% score in %s context" % [overall_score, context])
	return result

# ============================================================================
# PRONUNCIATION TRACKING FUNCTIONS
# ============================================================================

func practice_pronunciation(sound_id: String, region: String = "neutral") -> Dictionary:
	if not sound_id in pronunciation_data.sound_mastery:
		return {"error": "Unknown sound"}
	
	# Simulate pronunciation accuracy (would connect to speech recognition)
	var accuracy = randi_range(40, 95)
	
	# Update sound-specific data
	var sound_data = pronunciation_data.sound_mastery[sound_id]
	sound_data.attempts += 1
	sound_data.accuracy = (sound_data.accuracy + accuracy) / 2.0
	
	# Check for mastery (85%+ accuracy)
	if sound_data.accuracy >= 85 and not sound_data.mastered:
		sound_data.mastered = true
		pronunciation_data.mastered_sounds.append(sound_id)
		print("Sound mastered: %s!" % sound_id)
	
	# Update regional progress
	if region in pronunciation_data.regional_progress:
		pronunciation_data.regional_progress[region] = min(100, pronunciation_data.regional_progress[region] + 2)
	
	# Update overall accuracy
	var total_accuracy = 0
	var mastered_count = 0
	for sound in pronunciation_data.sound_mastery.values():
		total_accuracy += sound.accuracy
		if sound.mastered:
			mastered_count += 1
	
	pronunciation_data.overall_accuracy = total_accuracy / pronunciation_data.sound_mastery.size()
	
	# Update accent rating
	if mastered_count >= 3:
		pronunciation_data.accent_rating = "advanced"
	elif mastered_count >= 2:
		pronunciation_data.accent_rating = "intermediate"
	
	# Track session time
	session_data.today_activities.pronunciation_drills += 10  # Assume 10 min practice
	
	return {
		"accuracy": accuracy,
		"sound": sound_id,
		"region": region,
		"overall_accuracy": pronunciation_data.overall_accuracy,
		"mastered": sound_data.mastered
	}

# ============================================================================
# GRAMMAR TRACKING FUNCTIONS
# ============================================================================

func practice_grammar(category: String) -> Dictionary:
	if not category in grammar_data.categories:
		return {"error": "Unknown grammar category"}
	
	# Simulate grammar exercise
	var accuracy = randi_range(50, 90)
	var time_spent = randi_range(5, 15)  # minutes
	
	var cat_data = grammar_data.categories[category]
	cat_data.accuracy = (cat_data.accuracy + accuracy) / 2.0
	cat_data.practice_time += time_spent
	
	# Level progression
	if cat_data.accuracy >= 75 and cat_data.level < 5:
		cat_data.level += 1
		print("Grammar level up: %s is now level %d" % [category, cat_data.level])
	
	# Update overall grammar competence
	var total_level = 0
	for cat in grammar_data.categories.values():
		total_level += cat.level
	grammar_data.competence_level = total_level / grammar_data.categories.size()
	
	# Track session time
	session_data.today_activities.grammar_exercises += time_spent
	grammar_data.weekly_practice_time += time_spent
	
	return {
		"accuracy": accuracy,
		"category": category,
		"level": cat_data.level,
		"time_spent": time_spent
	}

# ============================================================================
# TESTING FUNCTIONS
# ============================================================================

func start_test(test_type: String) -> Dictionary:
	active_test = {
		"type": test_type,
		"start_time": Time.get_ticks_msec(),
		"scores": [],
		"completed": false
	}
	
	print("Started %s test" % test_type)
	return {"test_id": test_type, "status": "started"}

func complete_test_question(score: float):
	if active_test.is_empty():
		return
	
	active_test.scores.append(score)

func finish_test() -> Dictionary:
	if active_test.is_empty() or active_test.scores.is_empty():
		return {"error": "No active test or no scores"}
	
	var duration = (Time.get_ticks_msec() - active_test.start_time) / 60000
	var average_score = 0.0
	for score in active_test.scores:
		average_score += score
	average_score /= active_test.scores.size()
	
	var result = "failed"
	if average_score >= 90:
		result = "perfect"
	elif average_score >= 75:
		result = "excellent"
	elif average_score >= 60:
		result = "passed"
	
	# Update assessment data
	assessment_data.last_test = {
		"date": Time.get_date_string_from_system(),
		"type": active_test.type,
		"score": average_score,
		"result": result,
		"time_taken": duration,
		"areas_tested": [active_test.type]
	}
	
	assessment_data.test_history.append(assessment_data.last_test.duplicate())
	if assessment_data.test_history.size() > 10:
		assessment_data.test_history.pop_front()
	
	# Update analytics
	assessment_data.analytics.tests_taken += 1
	assessment_data.analytics.average_score = (assessment_data.analytics.average_score + average_score) / 2.0
	
	active_test = {}
	session_data.today_activities.testing += duration
	
	print("Test completed: %.1f%% (%s)" % [average_score, result])
	return assessment_data.last_test

# ============================================================================
# ANALYTICS & REPORTING FUNCTIONS - Easy Data Access
# ============================================================================

func get_student_dashboard_data() -> Dictionary:
	"""Main function for getting user performance overview"""
	return {
		"student_info": {
			"name": player_progress.name,
			"level": player_progress.overall_level,
			"total_time_hours": player_progress.total_play_time / 60.0,
			"confidence": player_progress.confidence_score
		},
		"current_performance": {
			"dialogue_accuracy": player_progress.dialogue_accuracy,
			"pronunciation_accuracy": pronunciation_data.overall_accuracy,
			"grammar_competence": grammar_data.competence_level,
			"accent_rating": pronunciation_data.accent_rating
		},
		"today_activity": dialogue_stats.today,
		"recent_test": assessment_data.last_test,
		"strengths": _identify_strengths(),
		"needs_improvement": _identify_weak_areas()
	}

func get_pronunciation_report() -> Dictionary:
	"""Detailed pronunciation analysis"""
	return {
		"overall_accuracy": pronunciation_data.overall_accuracy,
		"accent_rating": pronunciation_data.accent_rating,
		"regional_progress": pronunciation_data.regional_progress,
		"mastered_sounds": pronunciation_data.mastered_sounds,
		"problem_sounds": pronunciation_data.problem_sounds,
		"argentina_progress": pronunciation_data.regional_progress.argentina,
		"ll_pronunciation": pronunciation_data.sound_mastery.ll_argentina
	}

func get_dialogue_analytics() -> Dictionary:
	"""Conversation performance breakdown"""
	return {
		"overall_stats": {
			"total_conversations": dialogue_stats.lifetime.total_conversations,
			"success_rate": _calculate_overall_success_rate(),
			"current_streak": dialogue_stats.lifetime.current_streak,
			"best_streak": dialogue_stats.lifetime.best_streak
		},
		"context_performance": dialogue_stats.by_context,
		"weekly_trend": dialogue_stats.this_week,
		"today_summary": dialogue_stats.today
	}

func get_learning_recommendations() -> Array:
	"""AI-ready recommendations for next study focus"""
	var recommendations = []
	
	# Pronunciation recommendations
	if pronunciation_data.overall_accuracy < 70:
		recommendations.append({
			"type": "pronunciation",
			"priority": "high",
			"message": "Focus on pronunciation accuracy - currently %.1f%%" % pronunciation_data.overall_accuracy,
			"suggested_activity": "pronunciation_drills"
		})
	
	# Argentina-specific recommendation
	if pronunciation_data.regional_progress.argentina < 50:
		recommendations.append({
			"type": "regional_dialect",
			"priority": "medium", 
			"message": "Practice Argentinian pronunciation patterns, especially 'LL' sounds",
			"suggested_activity": "argentina_dialect_practice"
		})
	
	# Grammar recommendations
	var weak_grammar = _find_weakest_grammar_category()
	if weak_grammar.accuracy < 60:
		recommendations.append({
			"type": "grammar",
			"priority": "high",
			"message": "Improve %s grammar skills - currently %.1f%%" % [weak_grammar.name, weak_grammar.accuracy],
			"suggested_activity": "grammar_exercises"
		})
	
	# Dialogue context recommendations
	var weak_context = _find_weakest_dialogue_context()
	if weak_context.avg_score < 60:
		recommendations.append({
			"type": "dialogue",
			"priority": "medium",
			"message": "Practice %s conversations - success rate %.1f%%" % [weak_context.name, weak_context.avg_score],
			"suggested_activity": "dialogue_practice"
		})
	
	return recommendations

func get_progress_summary() -> Dictionary:
	"""Weekly/monthly progress tracking"""
	return {
		"this_week": {
			"time_spent": _calculate_weekly_time(),
			"conversations": dialogue_stats.this_week.total_conversations,
			"tests_taken": _count_tests_this_week(),
			"improvement": dialogue_stats.this_week.improvement_trend
		},
		"milestones": _check_recent_milestones(),
		"next_goals": _suggest_next_goals()
	}

# ============================================================================
# DATA PERSISTENCE - Simple Save/Load
# ============================================================================

func save_progress(file_path: String = "user://student_progress.json"):
	var save_data = {
		"player_progress": player_progress,
		"dialogue_stats": dialogue_stats,
		"pronunciation_data": pronunciation_data,
		"grammar_data": grammar_data,
		"assessment_data": assessment_data,
		"session_data": session_data,
		"save_timestamp": Time.get_date_string_from_system()
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Progress saved successfully")

func load_progress(file_path: String = "user://student_progress.json"):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			player_progress = data.get("player_progress", player_progress)
			dialogue_stats = data.get("dialogue_stats", dialogue_stats)
			pronunciation_data = data.get("pronunciation_data", pronunciation_data)
			grammar_data = data.get("grammar_data", grammar_data)
			assessment_data = data.get("assessment_data", assessment_data)
			session_data = data.get("session_data", session_data)
			print("Progress loaded successfully")

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func _calculate_overall_success_rate() -> float:
	var total_attempts = 0
	var total_successes = 0
	
	for context_data in dialogue_stats.by_context.values():
		total_attempts += context_data.attempts
		total_successes += context_data.successes
	
	if total_attempts == 0:
		return 0.0
	return float(total_successes) / float(total_attempts) * 100.0

func _identify_strengths() -> Array:
	var strengths = []
	
	if pronunciation_data.overall_accuracy >= 80:
		strengths.append("Excellent pronunciation")
	if grammar_data.competence_level >= 7:
		strengths.append("Strong grammar skills")
	if dialogue_stats.lifetime.current_streak >= 5:
		strengths.append("Consistent dialogue performance")
	
	return strengths

func _identify_weak_areas() -> Array:
	var weak_areas = []
	
	if pronunciation_data.overall_accuracy < 60:
		weak_areas.append("Pronunciation needs improvement")
	if grammar_data.competence_level < 3:
		weak_areas.append("Grammar fundamentals need work")
	if _calculate_overall_success_rate() < 50:
		weak_areas.append("Dialogue confidence needs building")
	
	return weak_areas

func _find_weakest_grammar_category() -> Dictionary:
	var weakest = {"name": "", "accuracy": 100}
	
	for category_name in grammar_data.categories.keys():
		var cat_data = grammar_data.categories[category_name]
		if cat_data.accuracy < weakest.accuracy:
			weakest.name = category_name
			weakest.accuracy = cat_data.accuracy
	
	return weakest

func _find_weakest_dialogue_context() -> Dictionary:
	var weakest = {"name": "", "avg_score": 100}
	
	for context_name in dialogue_stats.by_context.keys():
		var context_data = dialogue_stats.by_context[context_name]
		if context_data.avg_score < weakest.avg_score and context_data.attempts > 0:
			weakest.name = context_name
			weakest.avg_score = context_data.avg_score
	
	return weakest

func _update_confidence():
	# Simple confidence calculation based on recent performance
	var recent_success = _calculate_overall_success_rate()
	player_progress.confidence_score = (player_progress.confidence_score + recent_success) / 2.0

func _update_daily_summary():
	# Calculate today's average score
	if dialogue_stats.today.conversations_completed > 0:
		dialogue_stats.today.average_score = 0  # Would calculate from conversation results
	
	# Update preferred activity
	var max_time = 0
	var preferred = ""
	for activity in session_data.today_activities.keys():
		if session_data.today_activities[activity] > max_time:
			max_time = session_data.today_activities[activity]
			preferred = activity
	session_data.engagement.preferred_activity = preferred

func _calculate_weekly_time() -> float:
	# Simplified - would track actual weekly data
	return session_data.engagement.average_session_length * session_data.engagement.sessions_this_week

func _count_tests_this_week() -> int:
	# Count tests in assessment history from this week
	var count = 0
	for test in assessment_data.test_history:
		# Simple check - would use proper date comparison
		count += 1
	return min(count, 7)  # Max 7 for this week

func _check_recent_milestones() -> Array:
	var milestones = []
	
	if pronunciation_data.mastered_sounds.size() >= 2:
		milestones.append("Mastered 2+ pronunciation sounds")
	if dialogue_stats.lifetime.perfect_conversations >= 5:
		milestones.append("Achieved 5+ perfect conversations")
	
	return milestones

func _suggest_next_goals() -> Array:
	return [
		"Achieve 80% pronunciation accuracy",
		"Master Argentinian 'LL' pronunciation", 
		"Complete 10 perfect dialogue sequences",
		"Pass comprehensive grammar test"
	]
