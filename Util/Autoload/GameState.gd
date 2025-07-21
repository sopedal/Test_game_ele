extends Node

# ============================================================================
# GAMESTATE - Language Learning Life Simulation Game
# ============================================================================
# Integrates with Nathan Hoad's Dialogue Manager for language learning progression
# Sims-like life simulation with jobs, hobbies, relationships, and dialogue mastery

signal time_changed(hour, minute)
signal day_changed(day, season, year)
signal season_changed(season)
signal money_changed(amount)
signal energy_changed(current, max)
signal weather_changed(weather_type)

# Time and Calendar System
var current_time: Dictionary = {
	"hour": 6,
	"minute": 0,
	"day": 1,
	"season": "spring",
	"year": 1
}

var seasons: Array = ["spring", "summer", "fall", "winter"]
var days_per_season: int = 28
var minutes_per_hour: int = 60
var hours_per_day: int = 24

# Weather System
enum WeatherType { SUNNY, RAINY, STORMY, SNOWY }
var current_weather: WeatherType = WeatherType.SUNNY
var weather_forecast: Array = []

# Player Stats - Life Simulation Focus
var player_stats: Dictionary = {
	"name": "Player",
	"money": 500,
	"energy": 270,
	"max_energy": 270,
	"health": 100,
	"max_health": 100,
	"overall_level": 1,  # Main progression level (1-20)
	
	# Life Simulation Stats
	"job_level": 1,
	"job_performance": 50,  # 0-100 scale
	"social_skills": 1,
	"creativity": 1,
	"fitness": 1,
	"intelligence": 1,
	"charisma": 1,
	
	# Language Learning Stats
	"dialogue_mastery": 1,
	"conversation_confidence": 50,  # 0-100 scale
	"cultural_understanding": 1,
	"vocabulary_size": 0,
	"perfect_sequences": 0,
	"total_sequences_attempted": 0,
	
	# Linguistic Competencies
	"phonetics": 1,               # Pronunciation mastery level
	"grammar": 1,                 # Grammar competence level
	"pronunciation_accuracy": 65, # 0-100 scale
	"grammar_accuracy": 60,       # 0-100 scale
	"accent_rating": "beginner"   # beginner, intermediate, advanced, native-like
}

# Player Experience Points
var player_exp: Dictionary = {
	"job_level": 0,
	"social_skills": 0,
	"creativity": 0,
	"fitness": 0,
	"intelligence": 0,
	"charisma": 0,
	"dialogue_mastery": 0,
	"cultural_understanding": 0,
	"phonetics": 0,
	"grammar": 0
}

# ============================================================================
# PHONETICS & PRONUNCIATION SYSTEM
# ============================================================================

enum PhoneticCategory { VOWELS, CONSONANTS, DIPHTHONGS, STRESS, INTONATION, RHYTHM }
enum DialectRegion { NEUTRAL, ARGENTINA, MEXICO, SPAIN, COLOMBIA, CHILE, PERU }

var phonetic_stats: Dictionary = {
	"pronunciation_accuracy": 65,  # 0-100 scale
	"phonetic_awareness": 1,       # Level 1-10
	"dialect_familiarity": {},     # Dict of region familiarity scores
	"mastered_phonemes": [],       # Array of phoneme IDs
	"problematic_sounds": [],      # Sounds that need work
	"accent_rating": "intermediate" # beginner, intermediate, advanced, native-like
}

# Phonetic inventory with IPA symbols and regional variations
var phonetic_inventory: Dictionary = {
	# Spanish phonemes with regional variations
	"vowels": {
		"a": {
			"ipa": "/a/",
			"description": "Open central vowel",
			"difficulty": 1,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/a/",
				DialectRegion.ARGENTINA: "/a/",
				DialectRegion.SPAIN: "/a/"
			}
		},
		"e": {
			"ipa": "/e/",
			"description": "Close-mid front vowel",
			"difficulty": 2,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/e/",
				DialectRegion.ARGENTINA: "/e/",
				DialectRegion.SPAIN: "/e/"
			}
		},
		"i": {
			"ipa": "/i/",
			"description": "Close front vowel",
			"difficulty": 1,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/i/",
				DialectRegion.ARGENTINA: "/i/",
				DialectRegion.SPAIN: "/i/"
			}
		},
		"o": {
			"ipa": "/o/",
			"description": "Close-mid back vowel",
			"difficulty": 2,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/o/",
				DialectRegion.ARGENTINA: "/o/",
				DialectRegion.SPAIN: "/o/"
			}
		},
		"u": {
			"ipa": "/u/",
			"description": "Close back vowel",
			"difficulty": 1,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/u/",
				DialectRegion.ARGENTINA: "/u/",
				DialectRegion.SPAIN: "/u/"
			}
		}
	},
	
	"consonants": {
		"ll": {
			"ipa": "/ʎ/",
			"description": "Lateral palatal consonant",
			"difficulty": 4,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/ʎ/",      # Traditional pronunciation
				DialectRegion.ARGENTINA: "/ʃ/",    # Argentinian "sh" sound
				DialectRegion.MEXICO: "/j/",       # Mexican "y" sound
				DialectRegion.SPAIN: "/ʎ/",        # Castilian lateral
				DialectRegion.COLOMBIA: "/j/",
				DialectRegion.CHILE: "/j/",
				DialectRegion.PERU: "/ʎ/"
			},
			"notes": "Famous example: Argentina pronounces 'lluvia' as 'shuvia'"
		},
		"rr": {
			"ipa": "/r/",
			"description": "Alveolar trill",
			"difficulty": 5,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/r/",
				DialectRegion.ARGENTINA: "/r/",
				DialectRegion.MEXICO: "/r/",
				DialectRegion.SPAIN: "/r/",
				DialectRegion.COLOMBIA: "/r/",
				DialectRegion.CHILE: "/r/",
				DialectRegion.PERU: "/r/"
			},
			"notes": "Most difficult sound for many learners"
		},
		"j": {
			"ipa": "/x/",
			"description": "Voiceless velar fricative",
			"difficulty": 3,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/x/",
				DialectRegion.ARGENTINA: "/x/",
				DialectRegion.MEXICO: "/x/",
				DialectRegion.SPAIN: "/x/",       # Stronger in Spain
				DialectRegion.COLOMBIA: "/h/",    # Softer in Caribbean
				DialectRegion.CHILE: "/x/",
				DialectRegion.PERU: "/x/"
			}
		},
		"s_final": {
			"ipa": "/s/",
			"description": "Final 's' pronunciation",
			"difficulty": 3,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/s/",
				DialectRegion.ARGENTINA: "/s/",
				DialectRegion.MEXICO: "/s/",
				DialectRegion.SPAIN: "/s/",
				DialectRegion.COLOMBIA: "/h/",    # Aspiration in Caribbean
				DialectRegion.CHILE: "/h/",       # Often aspirated
				DialectRegion.PERU: "/s/"
			},
			"notes": "Word-final 's' varies greatly by region"
		},
		"th": {
			"ipa": "/θ/",
			"description": "Voiceless dental fricative",
			"difficulty": 4,
			"regional_variants": {
				DialectRegion.NEUTRAL: "/s/",     # Seseo in most regions
				DialectRegion.ARGENTINA: "/s/",   # Seseo
				DialectRegion.MEXICO: "/s/",      # Seseo
				DialectRegion.SPAIN: "/θ/",       # Distinction in Spain
				DialectRegion.COLOMBIA: "/s/",    # Seseo
				DialectRegion.CHILE: "/s/",       # Seseo
				DialectRegion.PERU: "/s/"         # Seseo
			},
			"notes": "ceceo/seseo distinction: Spain vs Latin America"
		}
	},
	
	"prosody": {
		"stress_patterns": {
			"aguda": {
				"description": "Stress on final syllable",
				"examples": ["café", "mamá", "papá"],
				"difficulty": 2
			},
			"llana": {
				"description": "Stress on penultimate syllable",
				"examples": ["casa", "perro", "mesa"],
				"difficulty": 1
			},
			"esdrujula": {
				"description": "Stress on antepenultimate syllable",
				"examples": ["médico", "lógica", "típico"],
				"difficulty": 3
			}
		},
		"intonation_patterns": {
			"statement": {
				"pattern": "falling",
				"difficulty": 1
			},
			"yes_no_question": {
				"pattern": "rising",
				"difficulty": 2
			},
			"wh_question": {
				"pattern": "falling",
				"difficulty": 2
			},
			"exclamation": {
				"pattern": "emphatic_rise_fall",
				"difficulty": 3
			}
		}
	}
}

# ============================================================================
# GRAMMAR SYSTEM
# ============================================================================

var grammar_stats: Dictionary = {
	"grammar_accuracy": 60,        # 0-100 scale
	"grammar_competence": 1,       # Level 1-10
	"mastered_structures": [],     # Array of grammar rule IDs
	"challenging_areas": [],       # Grammar areas needing work
	"complexity_level": "basic"    # basic, intermediate, advanced, expert
}

# Grammar inventory organized by difficulty and type
var grammar_inventory: Dictionary = {
	"verb_conjugation": {
		"present_regular": {
			"name": "Present Tense - Regular Verbs",
			"difficulty": 1,
			"category": "verbs",
			"examples": ["hablo", "comes", "vive"],
			"rules": ["AR verbs: -o, -as, -a, -amos, -áis, -an", "ER verbs: -o, -es, -e, -emos, -éis, -en"],
			"practice_contexts": ["daily_routines", "descriptions"]
		},
		"present_irregular": {
			"name": "Present Tense - Irregular Verbs",
			"difficulty": 3,
			"category": "verbs",
			"examples": ["soy", "tengo", "voy"],
			"rules": ["Stem-changing verbs", "Irregular yo forms", "Completely irregular"],
			"practice_contexts": ["basic_conversations", "introductions"]
		},
		"preterite": {
			"name": "Preterite Tense",
			"difficulty": 4,
			"category": "verbs",
			"examples": ["hablé", "comí", "fue"],
			"rules": ["Past completed actions", "Different endings from present"],
			"practice_contexts": ["storytelling", "past_events"]
		},
		"imperfect": {
			"name": "Imperfect Tense",
			"difficulty": 4,
			"category": "verbs",
			"examples": ["hablaba", "comía", "era"],
			"rules": ["Ongoing past actions", "Descriptions in past"],
			"practice_contexts": ["childhood_memories", "descriptions"]
		},
		"subjunctive": {
			"name": "Subjunctive Mood",
			"difficulty": 8,
			"category": "verbs",
			"examples": ["hable", "coma", "sea"],
			"rules": ["Doubt, emotion, desire", "WEIRDO triggers"],
			"practice_contexts": ["opinions", "emotions", "formal_speech"]
		}
	},
	
	"noun_adjective_agreement": {
		"gender_basic": {
			"name": "Noun Gender - Basic Rules",
			"difficulty": 2,
			"category": "nouns",
			"examples": ["la mesa", "el libro"],
			"rules": ["-a usually feminine", "-o usually masculine", "Exceptions exist"],
			"practice_contexts": ["object_identification", "descriptions"]
		},
		"gender_advanced": {
			"name": "Noun Gender - Exceptions",
			"difficulty": 5,
			"category": "nouns",
			"examples": ["el problema", "la mano", "el día"],
			"rules": ["Memorization required", "Greek origins", "Common exceptions"],
			"practice_contexts": ["academic_vocabulary", "formal_writing"]
		},
		"plural_formation": {
			"name": "Plural Formation",
			"difficulty": 2,
			"category": "nouns",
			"examples": ["casas", "animales", "lápices"],
			"rules": ["Add -s or -es", "Accent changes", "Irregular plurals"],
			"practice_contexts": ["counting", "descriptions"]
		},
		"adjective_agreement": {
			"name": "Adjective Agreement",
			"difficulty": 3,
			"category": "adjectives",
			"examples": ["niño alto", "niña alta", "casas blancas"],
			"rules": ["Match gender and number", "Position matters", "Invariable adjectives"],
			"practice_contexts": ["descriptions", "comparisons"]
		}
	},
	
	"pronouns": {
		"direct_object": {
			"name": "Direct Object Pronouns",
			"difficulty": 4,
			"category": "pronouns",
			"examples": ["lo veo", "la como", "los tengo"],
			"rules": ["Placement before verb", "Attach to infinitive", "Gender agreement"],
			"practice_contexts": ["daily_activities", "preferences"]
		},
		"indirect_object": {
			"name": "Indirect Object Pronouns", 
			"difficulty": 5,
			"category": "pronouns",
			"examples": ["le doy", "me gusta", "nos dice"],
			"rules": ["Person receiving action", "Gustar construction", "Placement rules"],
			"practice_contexts": ["giving_receiving", "preferences", "communication"]
		},
		"reflexive": {
			"name": "Reflexive Pronouns",
			"difficulty": 4,
			"category": "pronouns",
			"examples": ["me lavo", "se levanta", "nos vestimos"],
			"rules": ["Action on oneself", "Reciprocal actions", "Some verbs always reflexive"],
			"practice_contexts": ["daily_routines", "personal_care"]
		}
	},
	
	"complex_structures": {
		"conditional": {
			"name": "Conditional Sentences",
			"difficulty": 7,
			"category": "complex",
			"examples": ["Si tuviera dinero, viajaría", "Si estudias, aprobarás"],
			"rules": ["Real vs hypothetical", "Tense combinations", "Si clauses"],
			"practice_contexts": ["hypotheticals", "advice", "future_plans"]
		},
		"passive_voice": {
			"name": "Passive Voice",
			"difficulty": 6,
			"category": "complex",
			"examples": ["La casa fue construida", "Se venden casas"],
			"rules": ["Ser + past participle", "Se passive", "Agent with 'por'"],
			"practice_contexts": ["formal_writing", "news", "academic"]
		},
		"relative_clauses": {
			"name": "Relative Clauses",
			"difficulty": 6,
			"category": "complex",
			"examples": ["El libro que leo", "La persona con quien hablo"],
			"rules": ["Que, quien, cual", "Preposition placement", "Subjunctive in relatives"],
			"practice_contexts": ["descriptions", "formal_speech", "writing"]
		}
	}
}

# ============================================================================
# CAREER & JOB SYSTEM
# ============================================================================

enum JobType { UNEMPLOYED, OFFICE_WORKER, TEACHER, CHEF, ARTIST, DOCTOR, ENGINEER, TRANSLATOR }
var job_type_names: Array = ["Unemployed", "Office Worker", "Teacher", "Chef", "Artist", "Doctor", "Engineer", "Translator"]

var current_job: Dictionary = {
	"type": JobType.UNEMPLOYED,
	"title": "Unemployed",
	"daily_salary": 0,
	"required_skills": {},
	"work_days": [],  # Days of week that require work
	"work_hours": {"start": 9, "end": 17},
	"performance_today": 0,
	"days_worked": 0,
	"promotion_points": 0
}

var available_jobs: Dictionary = {
	JobType.OFFICE_WORKER: {
		"title": "Office Worker",
		"daily_salary": 120,
		"required_skills": {"intelligence": 2, "social_skills": 1},
		"work_days": [1, 2, 3, 4, 5],  # Monday-Friday
		"work_hours": {"start": 9, "end": 17},
		"dialogue_contexts": ["business", "formal"]
	},
	JobType.TEACHER: {
		"title": "Language Teacher", 
		"daily_salary": 150,
		"required_skills": {"dialogue_mastery": 3, "charisma": 2, "intelligence": 3},
		"work_days": [1, 2, 3, 4, 5],
		"work_hours": {"start": 8, "end": 15},
		"dialogue_contexts": ["educational", "cultural"]
	},
	JobType.CHEF: {
		"title": "Restaurant Chef",
		"daily_salary": 100,
		"required_skills": {"creativity": 2, "fitness": 2},
		"work_days": [1, 2, 3, 4, 5, 6],
		"work_hours": {"start": 11, "end": 22},
		"dialogue_contexts": ["casual", "business"]
	},
	JobType.ARTIST: {
		"title": "Freelance Artist",
		"daily_salary": 80,
		"required_skills": {"creativity": 4, "charisma": 2},
		"work_days": [],  # Flexible schedule
		"work_hours": {"start": 10, "end": 18},
		"dialogue_contexts": ["casual", "cultural"]
	},
	JobType.DOCTOR: {
		"title": "Medical Doctor",
		"daily_salary": 300,
		"required_skills": {"intelligence": 5, "dialogue_mastery": 4, "charisma": 3},
		"work_days": [1, 2, 3, 4, 5],
		"work_hours": {"start": 7, "end": 19},
		"dialogue_contexts": ["formal", "emotional", "technical"]
	},
	JobType.TRANSLATOR: {
		"title": "Professional Translator",
		"daily_salary": 200,
		"required_skills": {"dialogue_mastery": 5, "cultural_understanding": 4, "intelligence": 3},
		"work_days": [1, 2, 3, 4, 5],
		"work_hours": {"start": 9, "end": 17},
		"dialogue_contexts": ["cultural", "technical", "formal"]
	}
}

# ============================================================================
# HOBBIES & ACTIVITIES SYSTEM
# ============================================================================

var active_hobbies: Array = []
var hobby_progress: Dictionary = {}

var available_hobbies: Dictionary = {
	"reading": {
		"name": "Reading",
		"description": "Expand vocabulary and cultural knowledge",
		"energy_cost": 10,
		"time_cost": 60,  # minutes
		"benefits": {"intelligence": 2, "cultural_understanding": 1, "vocabulary_size": 3},
		"required_items": [],
		"dialogue_bonus": {"formal": 1.2, "cultural": 1.3}
	},
	"cooking": {
		"name": "Cooking",
		"description": "Learn cultural recipes and cooking terms",
		"energy_cost": 20,
		"time_cost": 90,
		"benefits": {"creativity": 2, "cultural_understanding": 2},
		"required_items": ["ingredients"],
		"dialogue_bonus": {"casual": 1.2, "cultural": 1.1}
	},
	"exercise": {
		"name": "Exercise", 
		"description": "Stay fit and build confidence",
		"energy_cost": 30,
		"time_cost": 60,
		"benefits": {"fitness": 3, "charisma": 1, "conversation_confidence": 2},
		"required_items": [],
		"dialogue_bonus": {"casual": 1.1}
	},
	"art_creation": {
		"name": "Art Creation",
		"description": "Express creativity and learn artistic vocabulary",
		"energy_cost": 25,
		"time_cost": 120,
		"benefits": {"creativity": 3, "charisma": 1, "vocabulary_size": 2},
		"required_items": ["art_supplies"],
		"dialogue_bonus": {"cultural": 1.2, "casual": 1.1}
	},
	"music_practice": {
		"name": "Music Practice",
		"description": "Learn musical vocabulary and cultural expressions",
		"energy_cost": 20,
		"time_cost": 90,
		"benefits": {"creativity": 2, "charisma": 2, "cultural_understanding": 1},
		"required_items": ["instrument"],
		"dialogue_bonus": {"cultural": 1.3, "casual": 1.2}
	},
	"language_study": {
		"name": "Language Study",
		"description": "Focused study to improve dialogue skills",
		"energy_cost": 25,
		"time_cost": 90,
		"benefits": {"dialogue_mastery": 3, "vocabulary_size": 5, "cultural_understanding": 2},
		"required_items": ["textbooks"],
		"dialogue_bonus": {"formal": 1.3, "technical": 1.2, "cultural": 1.2}
	},
	"pronunciation_drills": {
		"name": "Pronunciation Practice",
		"description": "Practice phonetic sounds and regional accents",
		"energy_cost": 15,
		"time_cost": 45,
		"benefits": {"phonetics": 4, "conversation_confidence": 2, "pronunciation_accuracy": 3},
		"required_items": ["audio_materials"],
		"dialogue_bonus": {"formal": 1.4, "business": 1.3, "all_contexts": 1.1}
	},
	"grammar_exercises": {
		"name": "Grammar Practice",
		"description": "Study and practice grammatical structures",
		"energy_cost": 20,
		"time_cost": 60,
		"benefits": {"grammar": 4, "intelligence": 1, "grammar_accuracy": 4},
		"required_items": ["grammar_books"],
		"dialogue_bonus": {"formal": 1.4, "technical": 1.3, "business": 1.2}
	},
	"dialect_immersion": {
		"name": "Regional Dialect Study",
		"description": "Learn pronunciation patterns from different Spanish-speaking regions",
		"energy_cost": 30,
		"time_cost": 75,
		"benefits": {"phonetics": 3, "cultural_understanding": 3, "charisma": 1},
		"required_items": ["regional_media"],
		"dialogue_bonus": {"cultural": 1.5, "casual": 1.2}
	},
	"conversation_lab": {
		"name": "Conversation Laboratory",
		"description": "Practice natural conversation flow and turn-taking",
		"energy_cost": 25,
		"time_cost": 90,
		"benefits": {"dialogue_mastery": 3, "social_skills": 2, "conversation_confidence": 3},
		"required_items": ["conversation_partners"],
		"dialogue_bonus": {"casual": 1.3, "emotional": 1.2, "all_contexts": 1.1}
	}
}

# ============================================================================
# DIALOGUE SEQUENCE SYSTEM - Core Language Learning Mechanic
# ============================================================================

enum DialogueChoiceQuality { POOR, ACCEPTABLE, GOOD, EXCELLENT, PERFECT }
enum DialogueContext { CASUAL, FORMAL, BUSINESS, CULTURAL, EMOTIONAL, TECHNICAL }

# Current dialogue sequence tracking
var current_dialogue_sequence: Dictionary = {}
var dialogue_history: Array = []

# Dialogue performance metrics
var dialogue_stats: Dictionary = {
	"current_streak": 0,
	"best_streak": 0,
	"perfect_sequences_today": 0,
	"total_perfect_sequences": 0,
	"conversation_points": 0,  # Special currency for dialogue mastery
	"choices_made_today": 0,
	"excellent_choices_today": 0
}

# Dialogue sequence templates for different life contexts
var dialogue_sequence_types: Dictionary = {
	"job_interview": {
		"name": "Job Interview",
		"length": 8,
		"context": DialogueContext.FORMAL,
		"difficulty": 3,
		"description": "Navigate a professional job interview",
		"completion_reward": {"conversation_points": 40, "job_performance": 20, "exp": 30}
	},
	"workplace_meeting": {
		"name": "Workplace Meeting",
		"length": 6,
		"context": DialogueContext.BUSINESS,
		"difficulty": 4,
		"description": "Participate effectively in a work meeting",
		"completion_reward": {"conversation_points": 35, "job_performance": 15, "exp": 25}
	},
	"casual_friendship": {
		"name": "Casual Conversation",
		"length": 5,
		"context": DialogueContext.CASUAL,
		"difficulty": 1,
		"description": "Build friendships through casual talk",
		"completion_reward": {"conversation_points": 15, "relationship_bonus": 25, "exp": 15}
	},
	"cultural_event": {
		"name": "Cultural Event Discussion",
		"length": 7,
		"context": DialogueContext.CULTURAL,
		"difficulty": 3,
		"description": "Engage in cultural conversations at events",
		"completion_reward": {"conversation_points": 30, "cultural_understanding": 25, "exp": 35}
	},
	"hobby_discussion": {
		"name": "Hobby Sharing",
		"length": 6,
		"context": DialogueContext.CASUAL,
		"difficulty": 2,
		"description": "Share and discuss hobbies with others",
		"completion_reward": {"conversation_points": 20, "creativity": 10, "exp": 20}
	},
	"romantic_date": {
		"name": "Romantic Date",
		"length": 8,
		"context": DialogueContext.EMOTIONAL,
		"difficulty": 4,
		"description": "Navigate romantic conversations appropriately",
		"completion_reward": {"conversation_points": 35, "charisma": 15, "relationship_bonus": 40, "exp": 30}
	},
	"medical_appointment": {
		"name": "Medical Consultation",
		"length": 6,
		"context": DialogueContext.FORMAL,
		"difficulty": 3,
		"description": "Communicate effectively with medical professionals",
		"completion_reward": {"conversation_points": 25, "health": 10, "exp": 25}
	}
}

# Inventory System (Life Simulation Items)
var inventory: Dictionary = {}
var inventory_size: int = 36

# Life Simulation Locations
var current_location: String = "home"
var previous_location: String = ""

var locations: Dictionary = {
	"home": {
		"name": "Home",
		"available_activities": ["rest", "hobby_practice", "language_study"],
		"npc_encounters": []
	},
	"workplace": {
		"name": "Workplace", 
		"available_activities": ["work", "networking"],
		"npc_encounters": ["colleagues", "boss"]
	},
	"gym": {
		"name": "Fitness Center",
		"available_activities": ["exercise", "social_fitness"],
		"npc_encounters": ["trainer", "gym_members"]
	},
	"library": {
		"name": "Public Library",
		"available_activities": ["reading", "research", "language_study"],
		"npc_encounters": ["librarian", "students"]
	},
	"cafe": {
		"name": "Local Café",
		"available_activities": ["socializing", "cultural_events"],
		"npc_encounters": ["barista", "locals", "tourists"]
	},
	"park": {
		"name": "City Park",
		"available_activities": ["exercise", "socializing", "art_creation"],
		"npc_encounters": ["artists", "families", "joggers"]
	}
}

# NPC Relationships
var relationships: Dictionary = {}
var relationship_levels: Dictionary = {
	"stranger": 0,
	"acquaintance": 2,
	"friend": 4,
	"good_friend": 6,
	"best_friend": 8,
	"romantic_interest": 10,
	"partner": 12
}

# ============================================================================
# MENTOR QUEST SYSTEM - Adapted for Life Simulation
# ============================================================================

enum QuestGrade { EASY, NORMAL, HARD, MASTER }
var quest_grade_names: Array = ["Easy", "Normal", "Hard", "Master"]

var mentor_quests: Dictionary = {
	"career_advancement": {
		"name": "Career Growth",
		"description": "Advance your professional life through dialogue skills",
		"completed_grades": [],
		"current_grade": QuestGrade.EASY,
		"available": true,
		"timeframe_days": 7,
		"last_completed": null,
		"cooldown_days": 1
	},
	"social_integration": {
		"name": "Social Integration",
		"description": "Build meaningful relationships in your community",
		"completed_grades": [],
		"current_grade": QuestGrade.EASY,
		"available": true,
		"timeframe_days": 7,
		"last_completed": null,
		"cooldown_days": 1
	},
	"cultural_mastery": {
		"name": "Cultural Understanding",
		"description": "Gain deep appreciation for local culture and customs",
		"completed_grades": [],
		"current_grade": QuestGrade.EASY,
		"available": true,
		"timeframe_days": 7,
		"last_completed": null,
		"cooldown_days": 1
	},
	"creative_expression": {
		"name": "Creative Pursuits",
		"description": "Express yourself through creative hobbies and conversations",
		"completed_grades": [],
		"current_grade": QuestGrade.EASY,
		"available": true,
		"timeframe_days": 7,
		"last_completed": null,
		"cooldown_days": 1
	},
	"pronunciation_mastery": {
		"name": "Pronunciation Excellence",
		"description": "Master the sounds and rhythms of the language across different regions",
		"completed_grades": [],
		"current_grade": QuestGrade.EASY,
		"available": true,
		"timeframe_days": 7,
		"last_completed": null,
		"cooldown_days": 1
	},
	"grammar_proficiency": {
		"name": "Grammar Mastery",
		"description": "Achieve native-like accuracy in grammatical structures",
		"completed_grades": [],
		"current_grade": QuestGrade.EASY,
		"available": true,
		"timeframe_days": 7,
		"last_completed": null,
		"cooldown_days": 1
	},
	"dialect_explorer": {
		"name": "Regional Dialect Explorer",
		"description": "Understand and adapt to different regional speech patterns",
		"completed_grades": [],
		"current_grade": QuestGrade.EASY,
		"available": true,
		"timeframe_days": 7,
		"last_completed": null,
		"cooldown_days": 1
	}
}

# Overall Level Requirements (mentor quest completions needed)
var level_requirements: Array = [
	0,   # Level 1 (starting level)
	1,   # Level 2 - complete 1 Easy quest
	3,   # Level 3 - complete 3 Easy quests
	5,   # Level 4 - complete all Easy quests
	6,   # Level 5 - complete 1 Normal quest
	8,   # Level 6 - complete 3 Normal quests
	10,  # Level 7 - complete all Normal quests
	12,  # Level 8 - mix of Normal quests
	13,  # Level 9 - complete 1 Hard quest
	15,  # Level 10 - complete 3 Hard quests
	17,  # Level 11 - complete all Hard quests
	19,  # Level 12 - mix of Hard quests
	20,  # Level 13 - complete 1 Master quest
	22,  # Level 14 - complete 3 Master quests
	24,  # Level 15 - complete all Master quests
	26,  # Level 16 - complete more Master quests
	28,  # Level 17 - advanced Master completion
	30,  # Level 18 - near perfection
	32,  # Level 19 - mastery of all areas
	35   # Level 20 - complete life mastery
]

# Quests and Events
var active_quests: Array = []
var completed_quests: Array = []
var triggered_events: Array = []

# Game Settings
var game_settings: Dictionary = {
	"auto_save": true,
	"time_speed": 1.0,
	"pause_on_menu": true,
	"show_clock": true
}

# ============================================================================
# DIALOGUE TESTING & ASSESSMENT SYSTEM
# ============================================================================

enum TestType { QUICK_ASSESSMENT, COMPREHENSIVE_EXAM, CONTEXT_CHALLENGE, SKILL_VERIFICATION }
enum TestResult { FAILED, PASSED, EXCELLENT, PERFECT }

var test_system: Dictionary = {
	"active_test": null,
	"test_history": [],
	"next_scheduled_test": null,
	"tests_taken_today": 0,
	"max_daily_tests": 3
}

# Test scheduling - when tests become available
var test_schedule: Dictionary = {
	"level_milestones": [3, 5, 8, 10, 12, 15, 18, 20],  # Tests at these overall levels
	"weekly_assessments": true,  # Weekly comprehensive tests
	"daily_quick_tests": true,   # Daily quick skill checks
	"context_rotations": 7       # Days between context-specific tests
}

# Available test configurations
var test_configurations: Dictionary = {
	"quick_assessment": {
		"name": "Quick Skill Check",
		"description": "Brief assessment of current dialogue abilities",
		"duration_minutes": 15,
		"dialogue_count": 3,
		"contexts": "random_single",  # Pick one random context
		"passing_score": 60,
		"energy_cost": 10,
		"rewards": {"conversation_points": 25, "exp": 15}
	},
	"comprehensive_exam": {
		"name": "Comprehensive Language Exam", 
		"description": "Full assessment across all dialogue contexts",
		"duration_minutes": 45,
		"dialogue_count": 8,
		"contexts": "all_contexts",  # Test all available contexts
		"passing_score": 70,
		"energy_cost": 30,
		"rewards": {"conversation_points": 100, "exp": 75, "money": 200}
	},
	"context_challenge": {
		"name": "Context Mastery Challenge",
		"description": "Focused test on specific dialogue situations",
		"duration_minutes": 25,
		"dialogue_count": 5,
		"contexts": "theme_based",  # Focus on related contexts
		"passing_score": 75,
		"energy_cost": 20,
		"rewards": {"conversation_points": 60, "exp": 40, "skill_bonus": true}
	},
	"skill_verification": {
		"name": "Skill Level Verification",
		"description": "Verify current skill levels match claimed abilities",
		"duration_minutes": 30,
		"dialogue_count": 6,
		"contexts": "adaptive",  # Adapt to player's strong/weak areas
		"passing_score": 80,
		"energy_cost": 25,
		"rewards": {"conversation_points": 75, "exp": 50, "certification": true}
	}
}

func _ready():
	# Initialize weather forecast
	_generate_weather_forecast()
	
	# Initialize linguistics system
	_initialize_linguistics_system()
	
	# Connect to scene tree for auto-save
	if game_settings.auto_save:
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 300.0  # Auto-save every 5 minutes
		timer.timeout.connect(_auto_save)
		timer.start()

func _initialize_linguistics_system():
	# Initialize phonetic and grammar stats if not loaded
	if not phonetic_stats.has("pronunciation_accuracy"):
		phonetic_stats = {
			"pronunciation_accuracy": 65,
			"phonetic_awareness": 1,
			"dialect_familiarity": {},
			"mastered_phonemes": [],
			"problematic_sounds": [],
			"accent_rating": "beginner"
		}
	
	if not grammar_stats.has("grammar_accuracy"):
		grammar_stats = {
			"grammar_accuracy": 60,
			"grammar_competence": 1,
			"mastered_structures": [],
			"challenging_areas": [],
			"complexity_level": "basic"
		}
	
	# Add linguistics tests to test system
	add_linguistics_to_test_system()
	
	print("Linguistics system initialized")

# ============================================================================
# TIME MANAGEMENT
# ============================================================================

func advance_time(minutes: int = 10):
	current_time.minute += minutes
	
	if current_time.minute >= minutes_per_hour:
		var hours_to_add = current_time.minute / minutes_per_hour
		current_time.hour += hours_to_add
		current_time.minute = current_time.minute % minutes_per_hour
		
		if current_time.hour >= hours_per_day:
			advance_day()
			current_time.hour = current_time.hour % hours_per_day
	
	emit_signal("time_changed", current_time.hour, current_time.minute)

func advance_day():
	current_time.day += 1
	current_time.hour = 6  # Start new day at 6 AM
	current_time.minute = 0
	
	if current_time.day > days_per_season:
		advance_season()
		current_time.day = 1
	
	# Update daily systems
	_update_weather()
	_regenerate_energy()
	_reset_daily_dialogue_stats()
	_reset_daily_test_limits()
	_process_daily_job()
	_decay_unused_skills()
	_check_scheduled_tests()
	
	emit_signal("day_changed", current_time.day, current_time.season, current_time.year)

func advance_season():
	var current_season_index = seasons.find(current_time.season)
	current_season_index = (current_season_index + 1) % seasons.size()
	current_time.season = seasons[current_season_index]
	
	if current_time.season == "spring":
		current_time.year += 1
	
	_generate_weather_forecast()
	emit_signal("season_changed", current_time.season)

# ============================================================================
# CAREER & JOB FUNCTIONS
# ============================================================================

func apply_for_job(job_type: JobType) -> bool:
	if job_type == JobType.UNEMPLOYED:
		current_job = {
			"type": JobType.UNEMPLOYED,
			"title": "Unemployed",
			"daily_salary": 0,
			"required_skills": {},
			"work_days": [],
			"work_hours": {"start": 0, "end": 0},
			"performance_today": 0,
			"days_worked": 0,
			"promotion_points": 0
		}
		return true
	
	if not job_type in available_jobs:
		return false
	
	var job_data = available_jobs[job_type]
	
	# Check if player meets skill requirements
	for skill in job_data.required_skills.keys():
		var required_level = job_data.required_skills[skill]
		var player_level = player_stats.get(skill, 0)
		if player_level < required_level:
			print("Insufficient %s level. Required: %d, Current: %d" % [skill, required_level, player_level])
			return false
	
	# Apply for job (could require dialogue sequence for interview)
	current_job = job_data.duplicate()
	current_job.type = job_type
	current_job.performance_today = 0
	current_job.days_worked = 0
	current_job.promotion_points = 0
	
	print("Successfully hired as %s!" % job_data.title)
	return true

func work_today() -> Dictionary:
	if current_job.type == JobType.UNEMPLOYED:
		return {"success": false, "message": "No job to work at"}
	
	var day_of_week = _get_day_of_week()
	if not day_of_week in current_job.work_days and current_job.work_days.size() > 0:
		return {"success": false, "message": "Not a work day"}
	
	if current_time.hour < current_job.work_hours.start or current_time.hour >= current_job.work_hours.end:
		return {"success": false, "message": "Outside work hours"}
	
	# Calculate work performance based on player stats
	var performance = 50  # Base performance
	performance += player_stats.dialogue_mastery * 5
	performance += player_stats.charisma * 3
	performance += player_stats.intelligence * 2
	performance -= (100 - player_stats.conversation_confidence) * 0.2
	
	# Apply energy penalty if tired
	if player_stats.energy < 50:
		performance *= 0.7
	
	current_job.performance_today = clamp(performance, 0, 100)
	current_job.days_worked += 1
	current_job.promotion_points += performance / 10
	
	# Consume energy and time
	consume_energy(40)
	advance_time(480)  # 8 hours of work
	
	# Earn salary
	var salary = current_job.daily_salary * (performance / 100.0)
	add_money(int(salary))
	
	# Gain job experience
	add_experience("job_level", int(performance / 10))
	add_experience("social_skills", 5)
	
	return {
		"success": true,
		"performance": current_job.performance_today,
		"salary_earned": int(salary),
		"promotion_progress": current_job.promotion_points
	}

func _process_daily_job():
	# Reset daily job performance
	current_job.performance_today = 0

func _get_day_of_week() -> int:
	# Calculate day of week (1 = Monday, 7 = Sunday)
	var total_days = (current_time.year - 1) * (days_per_season * 4) + (seasons.find(current_time.season)) * days_per_season + current_time.day
	return ((total_days - 1) % 7) + 1

# ============================================================================
# HOBBIES & ACTIVITIES
# ============================================================================

func practice_hobby(hobby_id: String) -> Dictionary:
	if not hobby_id in available_hobbies:
		return {"success": false, "message": "Unknown hobby"}
	
	var hobby = available_hobbies[hobby_id]
	
	# Check energy requirement
	if player_stats.energy < hobby.energy_cost:
		return {"success": false, "message": "Not enough energy"}
	
	# Check required items
	for item in hobby.required_items:
		if get_item_count(item) == 0:
			return {"success": false, "message": "Missing required item: %s" % item}
	
	# Consume energy and time
	consume_energy(hobby.energy_cost)
	advance_time(hobby.time_cost)
	
	# Apply benefits
	var gained = {}
	for benefit in hobby.benefits.keys():
		var amount = hobby.benefits[benefit]
		if benefit in player_stats:
			player_stats[benefit] += amount
			gained[benefit] = amount
		elif benefit in player_exp:
			add_experience(benefit, amount)
			gained[benefit] = amount
	
	# Track hobby progress
	if not hobby_id in hobby_progress:
		hobby_progress[hobby_id] = 0
	hobby_progress[hobby_id] += 1
	
	# Add to active hobbies if not already there
	if not hobby_id in active_hobbies:
		active_hobbies.append(hobby_id)
	
	print("Practiced %s! Gained: %s" % [hobby.name, gained])
	return {"success": true, "benefits": gained, "progress": hobby_progress[hobby_id]}

func get_hobby_dialogue_bonus(context: String) -> float:
	var total_bonus = 1.0
	
	for hobby_id in active_hobbies:
		var hobby = available_hobbies[hobby_id]
		if context in hobby.dialogue_bonus:
			var bonus = hobby.dialogue_bonus[context]
			var progress_multiplier = min(hobby_progress.get(hobby_id, 0) * 0.1, 1.0)
			total_bonus += (bonus - 1.0) * progress_multiplier
	
	return total_bonus

# ============================================================================
# DIALOGUE SEQUENCE SYSTEM
# ============================================================================

func start_dialogue_sequence(sequence_type: String, npc_name: String = "", context_info: Dictionary = {}) -> bool:
	if not sequence_type in dialogue_sequence_types:
		print("Unknown dialogue sequence type: %s" % sequence_type)
		return false
	
	# End any existing sequence first
	if current_dialogue_sequence.has("active") and current_dialogue_sequence.active:
		end_dialogue_sequence(false, "New sequence started")
	
	var sequence_template = dialogue_sequence_types[sequence_type]
	
	current_dialogue_sequence = {
		"active": true,
		"type": sequence_type,
		"npc_name": npc_name,
		"sequence_data": sequence_template.duplicate(),
		"current_step": 0,
		"choices_made": [],
		"perfect_choices": 0,
		"good_or_better_choices": 0,
		"start_time": current_time.duplicate(),
		"context_modifiers": context_info,
		"completion_bonus_active": true
	}
	
	print("Started dialogue sequence: %s with %s" % [sequence_template.name, npc_name])
	return true

func make_dialogue_choice(choice_quality: DialogueChoiceQuality, choice_text: String = "", context_appropriate: bool = true) -> Dictionary:
	if not current_dialogue_sequence.get("active", false):
		return {"success": false, "message": "No active dialogue sequence"}
	
	var sequence = current_dialogue_sequence
	var choice_data = {
		"step": sequence.current_step,
		"quality": choice_quality,
		"text": choice_text,
		"context_appropriate": context_appropriate,
		"timestamp": current_time.duplicate()
	}
	
	# Evaluate choice and update tracking
	var evaluation = _evaluate_dialogue_choice(choice_quality, context_appropriate, sequence.sequence_data.context)
	choice_data.merge(evaluation)
	
	# Add to sequence tracking
	sequence.choices_made.append(choice_data)
	sequence.current_step += 1
	
	# Update statistics
	dialogue_stats.choices_made_today += 1
	if choice_quality >= DialogueChoiceQuality.EXCELLENT:
		dialogue_stats.excellent_choices_today += 1
	
	# Track perfect and good choices for sequence completion
	if choice_quality == DialogueChoiceQuality.PERFECT and context_appropriate:
		sequence.perfect_choices += 1
		dialogue_stats.current_streak += 1
		dialogue_stats.best_streak = max(dialogue_stats.best_streak, dialogue_stats.current_streak)
	else:
		dialogue_stats.current_streak = 0
	
	if choice_quality >= DialogueChoiceQuality.GOOD and context_appropriate:
		sequence.good_or_better_choices += 1
	
	# Give immediate rewards for choice quality
	_grant_choice_rewards(evaluation)
	
	# Check if sequence is complete
	if sequence.current_step >= sequence.sequence_data.length:
		_complete_dialogue_sequence()
	
	print("Choice made: %s (Quality: %d, Appropriate: %s)" % [choice_text, choice_quality, context_appropriate])
	return evaluation

func _evaluate_dialogue_choice(quality: DialogueChoiceQuality, context_appropriate: bool, dialogue_context: int, target_region: DialectRegion = DialectRegion.NEUTRAL) -> Dictionary:
	# Use the enhanced linguistics evaluation by default
	return _evaluate_dialogue_choice_with_linguistics(quality, context_appropriate, dialogue_context, target_region)

func _evaluate_dialogue_choice_basic(quality: DialogueChoiceQuality, context_appropriate: bool, dialogue_context: int) -> Dictionary:
	# Original evaluation without linguistics (kept for backwards compatibility)
	var base_points = 0
	var exp_gained = 0
	var confidence_change = 0
	
	# Base scoring by quality
	match quality:
		DialogueChoiceQuality.POOR:
			base_points = 1
			exp_gained = 1
			confidence_change = -2
		DialogueChoiceQuality.ACCEPTABLE:
			base_points = 3
			exp_gained = 3
			confidence_change = 0
		DialogueChoiceQuality.GOOD:
			base_points = 5
			exp_gained = 5
			confidence_change = 1
		DialogueChoiceQuality.EXCELLENT:
			base_points = 8
			exp_gained = 8
			confidence_change = 2
		DialogueChoiceQuality.PERFECT:
			base_points = 12
			exp_gained = 12
			confidence_change = 3
	
	# Context appropriateness bonus/penalty
	if context_appropriate:
		base_points = int(base_points * 1.5)
		exp_gained = int(exp_gained * 1.2)
	else:
		base_points = int(base_points * 0.5)
		confidence_change -= 3
	
	# Apply hobby bonuses
	var context_name = _get_context_name(dialogue_context)
	var hobby_bonus = get_hobby_dialogue_bonus(context_name)
	base_points = int(base_points * hobby_bonus)
	exp_gained = int(exp_gained * hobby_bonus)
	
	# Apply streak bonus
	if dialogue_stats.current_streak > 0:
		var streak_multiplier = 1.0 + (dialogue_stats.current_streak * 0.1)
		base_points = int(base_points * streak_multiplier)
		exp_gained = int(exp_gained * streak_multiplier)
	
	return {
		"conversation_points": base_points,
		"exp_gained": exp_gained,
		"confidence_change": confidence_change,
		"quality_score": quality,
		"context_appropriate": context_appropriate,
		"success": true
	}

# ============================================================================
# PHONETICS & GRAMMAR FUNCTIONS
# ============================================================================

func practice_phonetics(phoneme_id: String, region: DialectRegion = DialectRegion.NEUTRAL) -> Dictionary:
	var phoneme_data = _find_phoneme(phoneme_id)
	if phoneme_data == null:
		return {"success": false, "message": "Phoneme not found"}
	
	# Simulate pronunciation accuracy (would connect to speech recognition in real app)
	var base_accuracy = randf_range(0.6, 0.95)
	var difficulty_penalty = phoneme_data.difficulty * 0.05
	var region_bonus = _get_regional_familiarity_bonus(region)
	
	var accuracy = clamp(base_accuracy - difficulty_penalty + region_bonus, 0.0, 1.0)
	var accuracy_percent = int(accuracy * 100)
	
	# Update phonetic stats
	phonetic_stats.pronunciation_accuracy = (phonetic_stats.pronunciation_accuracy * 0.9) + (accuracy_percent * 0.1)
	
	# Track mastery
	if accuracy_percent >= 85:
		var mastery_key = "%s_%s" % [phoneme_id, DialectRegion.keys()[region]]
		if not mastery_key in phonetic_stats.mastered_phonemes:
			phonetic_stats.mastered_phonemes.append(mastery_key)
			print("Mastered phoneme: %s in %s accent!" % [phoneme_id, DialectRegion.keys()[region]])
	elif accuracy_percent < 60:
		if not phoneme_id in phonetic_stats.problematic_sounds:
			phonetic_stats.problematic_sounds.append(phoneme_id)
	
	# Gain experience
	var exp_gained = int(phoneme_data.difficulty * accuracy * 5)
	add_experience("phonetics", exp_gained)
	
	# Update regional familiarity
	if not region in phonetic_stats.dialect_familiarity:
		phonetic_stats.dialect_familiarity[region] = 0
	phonetic_stats.dialect_familiarity[region] = min(100, phonetic_stats.dialect_familiarity[region] + 2)
	
	return {
		"success": true,
		"accuracy": accuracy_percent,
		"phoneme": phoneme_data,
		"region": DialectRegion.keys()[region],
		"exp_gained": exp_gained,
		"mastered": accuracy_percent >= 85
	}

func practice_grammar(grammar_rule_id: String) -> Dictionary:
	var grammar_data = _find_grammar_rule(grammar_rule_id)
	if grammar_data == null:
		return {"success": false, "message": "Grammar rule not found"}
	
	# Simulate grammar exercise performance
	var base_accuracy = randf_range(0.5, 0.9)
	var difficulty_penalty = grammar_data.difficulty * 0.06
	var intelligence_bonus = player_stats.intelligence * 0.02
	
	var accuracy = clamp(base_accuracy - difficulty_penalty + intelligence_bonus, 0.0, 1.0)
	var accuracy_percent = int(accuracy * 100)
	
	# Update grammar stats
	grammar_stats.grammar_accuracy = (grammar_stats.grammar_accuracy * 0.9) + (accuracy_percent * 0.1)
	
	# Track mastery
	if accuracy_percent >= 80:
		if not grammar_rule_id in grammar_stats.mastered_structures:
			grammar_stats.mastered_structures.append(grammar_rule_id)
			print("Mastered grammar rule: %s!" % grammar_data.name)
	elif accuracy_percent < 50:
		if not grammar_rule_id in grammar_stats.challenging_areas:
			grammar_stats.challenging_areas.append(grammar_rule_id)
	
	# Gain experience  
	var exp_gained = int(grammar_data.difficulty * accuracy * 4)
	add_experience("grammar", exp_gained)
	
	return {
		"success": true,
		"accuracy": accuracy_percent,
		"grammar_rule": grammar_data,
		"exp_gained": exp_gained,
		"mastered": accuracy_percent >= 80
	}

func assess_pronunciation(text: String, target_region: DialectRegion = DialectRegion.NEUTRAL) -> Dictionary:
	# Analyze text for phonetic challenges (would use speech recognition in real app)
	var phonemes_in_text = _extract_phonemes_from_text(text)
	var pronunciation_score = 0.0
	var detailed_feedback = []
	
	for phoneme_data in phonemes_in_text:
		var phoneme_id = phoneme_data.id
		var expected_sound = phoneme_data.regional_variant
		
		# Check if player has mastered this phoneme in this region
		var mastery_key = "%s_%s" % [phoneme_id, DialectRegion.keys()[target_region]]
		var is_mastered = mastery_key in phonetic_stats.mastered_phonemes
		
		var phoneme_score = 0.7  # Base score
		if is_mastered:
			phoneme_score = 0.95
		elif phoneme_id in phonetic_stats.problematic_sounds:
			phoneme_score = 0.4
		
		pronunciation_score += phoneme_score
		detailed_feedback.append({
			"phoneme": phoneme_id,
			"expected": expected_sound,
			"score": phoneme_score,
			"mastered": is_mastered
		})
	
	var final_score = (pronunciation_score / phonemes_in_text.size()) * 100
	
	# Update overall pronunciation rating
	_update_pronunciation_rating(final_score)
	
	return {
		"overall_score": int(final_score),
		"regional_accuracy": _get_regional_accuracy(target_region),
		"detailed_feedback": detailed_feedback,
		"pronunciation_rating": phonetic_stats.accent_rating
	}

func get_pronunciation_challenges() -> Array:
	var challenges = []
	
	# Identify challenging phonemes based on player's native language background
	var common_challenges = {
		# For English speakers learning Spanish
		"english_speakers": ["rr", "ll", "j", "vowel_precision"],
		# Could add more language backgrounds
	}
	
	# Add regionally specific challenges
	for region in [DialectRegion.ARGENTINA, DialectRegion.SPAIN, DialectRegion.MEXICO]:
		var familiarity = phonetic_stats.dialect_familiarity.get(region, 0)
		if familiarity < 30:
			challenges.append({
				"type": "regional_accent",
				"region": DialectRegion.keys()[region],
				"description": "Practice %s pronunciation patterns" % DialectRegion.keys()[region],
				"priority": "medium"
			})
	
	# Add phonemes from problematic sounds
	for phoneme_id in phonetic_stats.problematic_sounds:
		var phoneme_data = _find_phoneme(phoneme_id)
		if phoneme_data != null:
			challenges.append({
				"type": "phoneme_practice",
				"phoneme": phoneme_id,
				"description": "Practice %s sound: %s" % [phoneme_data.ipa, phoneme_data.description],
				"priority": "high"
			})
	
	return challenges

func get_grammar_recommendations() -> Array:
	var recommendations = []
	
	# Analyze current level and suggest next grammar topics
	var current_level = grammar_stats.grammar_competence
	var available_rules = []
	
	# Get grammar rules appropriate for current level
	for category in grammar_inventory.keys():
		for rule_id in grammar_inventory[category].keys():
			var rule_data = grammar_inventory[category][rule_id]
			if rule_data.difficulty <= current_level + 2:  # Allow slight challenge
				if not rule_id in grammar_stats.mastered_structures:
					available_rules.append({
						"id": rule_id,
						"data": rule_data,
						"category": category
					})
	
	# Sort by difficulty and recommend top 3
	available_rules.sort_custom(func(a, b): return a.data.difficulty < b.data.difficulty)
	
	for i in range(min(3, available_rules.size())):
		var rule = available_rules[i]
		recommendations.append({
			"grammar_rule": rule.id,
			"name": rule.data.name,
			"difficulty": rule.data.difficulty,
			"category": rule.category,
			"practice_contexts": rule.data.practice_contexts
		})
	
	return recommendations

# ============================================================================
# INTEGRATION WITH DIALOGUE SYSTEM
# ============================================================================

func get_pronunciation_dialogue_modifier(context: int, target_region: DialectRegion = DialectRegion.NEUTRAL) -> float:
	# Pronunciation affects dialogue quality
	var base_modifier = phonetic_stats.pronunciation_accuracy / 100.0
	
	# Regional familiarity bonus
	var regional_familiarity = phonetic_stats.dialect_familiarity.get(target_region, 50) / 100.0
	
	# Context-specific modifiers
	var context_modifier = 1.0
	match context:
		DialogueContext.FORMAL:
			context_modifier = 1.2  # Pronunciation more important in formal contexts
		DialogueContext.BUSINESS:
			context_modifier = 1.15
		DialogueContext.TECHNICAL:
			context_modifier = 1.1
		DialogueContext.CASUAL:
			context_modifier = 0.9  # Less critical in casual conversation
	
	return base_modifier * regional_familiarity * context_modifier

func get_grammar_dialogue_modifier(context: int) -> float:
	# Grammar affects dialogue quality
	var base_modifier = grammar_stats.grammar_accuracy / 100.0
	
	# Context-specific modifiers
	var context_modifier = 1.0
	match context:
		DialogueContext.FORMAL:
			context_modifier = 1.3  # Grammar very important in formal contexts
		DialogueContext.BUSINESS:
			context_modifier = 1.2
		DialogueContext.TECHNICAL:
			context_modifier = 1.25
		DialogueContext.CULTURAL:
			context_modifier = 1.1
		DialogueContext.CASUAL:
			context_modifier = 0.8  # More forgiving in casual conversation
	
	return base_modifier * context_modifier

# Update the dialogue choice evaluation to include pronunciation and grammar
func _evaluate_dialogue_choice_with_linguistics(quality: DialogueChoiceQuality, context_appropriate: bool, dialogue_context: int, target_region: DialectRegion = DialectRegion.NEUTRAL) -> Dictionary:
	# Get base evaluation
	var evaluation = _evaluate_dialogue_choice(quality, context_appropriate, dialogue_context)
	
	# Apply pronunciation modifier
	var pronunciation_modifier = get_pronunciation_dialogue_modifier(dialogue_context, target_region)
	evaluation.conversation_points = int(evaluation.conversation_points * pronunciation_modifier)
	evaluation.exp_gained = int(evaluation.exp_gained * pronunciation_modifier)
	
	# Apply grammar modifier
	var grammar_modifier = get_grammar_dialogue_modifier(dialogue_context)
	evaluation.conversation_points = int(evaluation.conversation_points * grammar_modifier)
	evaluation.exp_gained = int(evaluation.exp_gained * grammar_modifier)
	
	# Add linguistic feedback
	evaluation.pronunciation_feedback = _get_pronunciation_feedback(pronunciation_modifier)
	evaluation.grammar_feedback = _get_grammar_feedback(grammar_modifier)
	
	return evaluation

# ============================================================================
# PHONETICS & GRAMMAR TESTING INTEGRATION
# ============================================================================

func add_linguistics_to_test_system():
	# Add pronunciation and grammar focused tests
	test_configurations["pronunciation_assessment"] = {
		"name": "Pronunciation Assessment",
		"description": "Comprehensive evaluation of pronunciation accuracy across dialects",
		"duration_minutes": 20,
		"dialogue_count": 4,
		"contexts": "pronunciation_focused",
		"passing_score": 65,
		"energy_cost": 15,
		"rewards": {"conversation_points": 40, "exp": 30, "phonetics": 25}
	}
	
	test_configurations["grammar_proficiency"] = {
		"name": "Grammar Proficiency Test",
		"description": "Assessment of grammatical accuracy in various contexts",
		"duration_minutes": 25,
		"dialogue_count": 5,
		"contexts": "grammar_focused", 
		"passing_score": 70,
		"energy_cost": 20,
		"rewards": {"conversation_points": 50, "exp": 35, "grammar": 30}
	}
	
	test_configurations["dialect_challenge"] = {
		"name": "Regional Dialect Challenge",
		"description": "Test comprehension and production of regional speech patterns",
		"duration_minutes": 30,
		"dialogue_count": 6,
		"contexts": "regional_specific",
		"passing_score": 60,
		"energy_cost": 25,
		"rewards": {"conversation_points": 60, "exp": 40, "regional_bonus": true}
	}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func _find_phoneme(phoneme_id: String) -> Dictionary:
	for category in phonetic_inventory.keys():
		if phonetic_inventory[category].has(phoneme_id):
			return phonetic_inventory[category][phoneme_id]
	return {}

func _find_grammar_rule(rule_id: String) -> Dictionary:
	for category in grammar_inventory.keys():
		if grammar_inventory[category].has(rule_id):
			return grammar_inventory[category][rule_id]
	return {}

func _get_regional_familiarity_bonus(region: DialectRegion) -> float:
	var familiarity = phonetic_stats.dialect_familiarity.get(region, 50)
	return (familiarity - 50) / 500.0  # Convert to small bonus/penalty

func _extract_phonemes_from_text(text: String) -> Array:
	# Simplified phoneme extraction (would use linguistic analysis in real app)
	var phonemes = []
	
	if "ll" in text.to_lower():
		phonemes.append({
			"id": "ll",
			"regional_variant": phonetic_inventory.consonants.ll.regional_variants.get(DialectRegion.NEUTRAL, "/ʎ/")
		})
	
	if "rr" in text.to_lower():
		phonemes.append({
			"id": "rr", 
			"regional_variant": phonetic_inventory.consonants.rr.regional_variants.get(DialectRegion.NEUTRAL, "/r/")
		})
	
	# Add more phoneme detection logic here
	
	return phonemes

func _update_pronunciation_rating(score: float):
	if score >= 90:
		phonetic_stats.accent_rating = "native-like"
	elif score >= 75:
		phonetic_stats.accent_rating = "advanced"
	elif score >= 60:
		phonetic_stats.accent_rating = "intermediate"
	else:
		phonetic_stats.accent_rating = "beginner"

func _get_regional_accuracy(region: DialectRegion) -> int:
	return phonetic_stats.dialect_familiarity.get(region, 50)

func _get_pronunciation_feedback(modifier: float) -> String:
	if modifier >= 0.9:
		return "Excellent pronunciation! Very clear and natural."
	elif modifier >= 0.7:
		return "Good pronunciation with minor accent features."
	elif modifier >= 0.5:
		return "Understandable but noticeable pronunciation issues."
	else:
		return "Pronunciation needs significant improvement for clarity."

func _get_grammar_feedback(modifier: float) -> String:
	if modifier >= 0.9:
		return "Perfect grammar usage for this context."
	elif modifier >= 0.7:
		return "Good grammar with minor errors."
	elif modifier >= 0.5:
		return "Generally correct but some grammar mistakes affect clarity."
	else:
		return "Significant grammar errors that interfere with communication."

func start_dialogue_test(test_type: String) -> Dictionary:
	if test_system.active_test != null:
		return {"success": false, "message": "Test already in progress"}
	
	if test_system.tests_taken_today >= test_system.max_daily_tests:
		return {"success": false, "message": "Daily test limit reached"}
	
	if not test_type in test_configurations:
		return {"success": false, "message": "Unknown test type"}
	
	var config = test_configurations[test_type]
	
	# Check energy requirement
	if player_stats.energy < config.energy_cost:
		return {"success": false, "message": "Not enough energy"}
	
	# Generate test dialogues
	var test_dialogues = _generate_test_dialogues(config)
	
	# Initialize test session
	test_system.active_test = {
		"type": test_type,
		"config": config,
		"dialogues": test_dialogues,
		"current_dialogue_index": 0,
		"start_time": current_time.duplicate(),
		"scores": [],
		"total_score": 0,
		"context_performance": {},
		"completed": false
	}
	
	# Consume energy
	consume_energy(config.energy_cost)
	test_system.tests_taken_today += 1
	
	# Start first dialogue
	_start_next_test_dialogue()
	
	print("Started %s with %d dialogues" % [config.name, test_dialogues.size()])
	return {"success": true, "test_id": test_type, "dialogue_count": test_dialogues.size()}

func _generate_test_dialogues(config: Dictionary) -> Array:
	var test_dialogues = []
	var dialogue_count = config.dialogue_count
	var context_strategy = config.contexts
	
	# Get available dialogue types for testing
	var available_sequences = []
	for seq_type in dialogue_sequence_types.keys():
		var seq_data = dialogue_sequence_types[seq_type]
		# Only include sequences the player can reasonably handle
		if seq_data.difficulty <= player_stats.dialogue_mastery + 1:
			available_sequences.append(seq_type)
	
	match context_strategy:
		"random_single":
			# Pick one context and test multiple scenarios within it
			var target_context = _get_random_context()
			var context_sequences = available_sequences.filter(func(seq): return dialogue_sequence_types[seq].context == target_context)
			if context_sequences.size() == 0:
				context_sequences = available_sequences  # Fallback
			
			for i in range(dialogue_count):
				var seq_type = context_sequences[randi() % context_sequences.size()]
				test_dialogues.append(_create_test_dialogue_data(seq_type, i))
		
		"all_contexts":
			# Ensure we test across all different contexts
			var contexts_used = []
			var all_contexts = [DialogueContext.CASUAL, DialogueContext.FORMAL, DialogueContext.BUSINESS, 
							   DialogueContext.CULTURAL, DialogueContext.EMOTIONAL, DialogueContext.TECHNICAL]
			
			for i in range(dialogue_count):
				var target_context
				if i < all_contexts.size():
					target_context = all_contexts[i]
				else:
					target_context = all_contexts[randi() % all_contexts.size()]
				
				var context_sequences = available_sequences.filter(func(seq): return dialogue_sequence_types[seq].context == target_context)
				if context_sequences.size() == 0:
					context_sequences = available_sequences
				
				var seq_type = context_sequences[randi() % context_sequences.size()]
				test_dialogues.append(_create_test_dialogue_data(seq_type, i))
		
		"theme_based":
			# Focus on related contexts (e.g., professional = business + formal)
			var theme = _select_test_theme()
			var theme_contexts = _get_theme_contexts(theme)
			
			for i in range(dialogue_count):
				var target_context = theme_contexts[randi() % theme_contexts.size()]
				var context_sequences = available_sequences.filter(func(seq): return dialogue_sequence_types[seq].context == target_context)
				if context_sequences.size() == 0:
					context_sequences = available_sequences
				
				var seq_type = context_sequences[randi() % context_sequences.size()]
				test_dialogues.append(_create_test_dialogue_data(seq_type, i))
		
		"adaptive":
			# Focus on areas where player needs improvement
			var weak_contexts = _identify_weak_contexts()
			var strong_contexts = _identify_strong_contexts()
			
			# 70% weak areas, 30% strong areas to maintain confidence
			for i in range(dialogue_count):
				var use_weak_context = (i % 10) < 7  # 70% of the time
				var target_contexts = weak_contexts if use_weak_context else strong_contexts
				
				if target_contexts.size() == 0:
					target_contexts = [DialogueContext.CASUAL]  # Fallback
				
				var target_context = target_contexts[randi() % target_contexts.size()]
				var context_sequences = available_sequences.filter(func(seq): return dialogue_sequence_types[seq].context == target_context)
				if context_sequences.size() == 0:
					context_sequences = available_sequences
				
				var seq_type = context_sequences[randi() % context_sequences.size()]
				test_dialogues.append(_create_test_dialogue_data(seq_type, i))
	
	return test_dialogues

func _create_test_dialogue_data(sequence_type: String, index: int) -> Dictionary:
	var base_data = dialogue_sequence_types[sequence_type].duplicate()
	return {
		"sequence_type": sequence_type,
		"index": index,
		"npc_name": _generate_test_npc_name(),
		"context": base_data.context,
		"difficulty": base_data.difficulty,
		"length": base_data.length,
		"completed": false,
		"score": 0,
		"perfect_choices": 0,
		"start_time": null
	}

func _start_next_test_dialogue():
	var test = test_system.active_test
	if test.current_dialogue_index >= test.dialogues.size():
		_complete_dialogue_test()
		return
	
	var dialogue_data = test.dialogues[test.current_dialogue_index]
	dialogue_data.start_time = current_time.duplicate()
	
	# Start the dialogue sequence (integrates with existing system)
	start_dialogue_sequence(dialogue_data.sequence_type, dialogue_data.npc_name, {"test_mode": true})
	
	print("Test Dialogue %d/%d: %s (Context: %s)" % [
		test.current_dialogue_index + 1, 
		test.dialogues.size(),
		dialogue_sequence_types[dialogue_data.sequence_type].name,
		_get_context_name(dialogue_data.context)
	])

func complete_test_dialogue(final_score: float, perfect_choices: int, total_choices: int):
	var test = test_system.active_test
	if test == null:
		return
	
	var dialogue_data = test.dialogues[test.current_dialogue_index]
	dialogue_data.completed = true
	dialogue_data.score = final_score
	dialogue_data.perfect_choices = perfect_choices
	
	# Track context performance
	var context_name = _get_context_name(dialogue_data.context)
	if not context_name in test.context_performance:
		test.context_performance[context_name] = []
	test.context_performance[context_name].append(final_score)
	
	test.scores.append(final_score)
	test.current_dialogue_index += 1
	
	print("Completed test dialogue %d with score: %.1f%%" % [test.current_dialogue_index, final_score])
	
	# Start next dialogue or complete test
	_start_next_test_dialogue()

func _complete_dialogue_test():
	var test = test_system.active_test
	if test == null:
		return
	
	# Calculate overall performance
	var total_score = 0.0
	for score in test.scores:
		total_score += score
	var average_score = total_score / test.scores.size()
	
	test.total_score = average_score
	test.completed = true
	
	# Determine test result
	var result = _determine_test_result(average_score, test.config.passing_score)
	
	# Calculate context breakdown
	var context_averages = {}
	for context in test.context_performance.keys():
		var context_scores = test.context_performance[context]
		var context_total = 0.0
		for score in context_scores:
			context_total += score
		context_averages[context] = context_total / context_scores.size()
	
	# Create final test record
	var test_record = {
		"type": test.type,
		"date": current_time.duplicate(),
		"overall_score": average_score,
		"result": result,
		"context_performance": context_averages,
		"dialogue_scores": test.scores,
		"duration_minutes": test.config.duration_minutes,
		"player_level": player_stats.overall_level,
		"dialogue_mastery": player_stats.dialogue_mastery
	}
	
	# Add to history
	test_system.test_history.append(test_record)
	
	# Grant rewards based on performance
	_grant_test_rewards(test.config, result, average_score)
	
	# Clear active test
	test_system.active_test = null
	
	print("Test completed! Overall score: %.1f%% (%s)" % [average_score, _get_result_name(result)])
	return test_record

func _determine_test_result(score: float, passing_score: float) -> TestResult:
	if score < passing_score:
		return TestResult.FAILED
	elif score < passing_score + 15:
		return TestResult.PASSED
	elif score < 90:
		return TestResult.EXCELLENT
	else:
		return TestResult.PERFECT

func _grant_test_rewards(config: Dictionary, result: TestResult, score: float):
	var base_rewards = config.rewards
	var multiplier = 1.0
	
	# Adjust rewards based on performance
	match result:
		TestResult.FAILED:
			multiplier = 0.3
		TestResult.PASSED:
			multiplier = 1.0
		TestResult.EXCELLENT:
			multiplier = 1.5
		TestResult.PERFECT:
			multiplier = 2.0
	
	# Grant rewards
	for reward_type in base_rewards.keys():
		if reward_type == "skill_bonus" and result >= TestResult.EXCELLENT:
			# Grant bonus skill points for excellent performance
			add_experience("dialogue_mastery", 20)
			add_experience("cultural_understanding", 15)
		elif reward_type == "certification" and result >= TestResult.PASSED:
			# Add certification to player record (could unlock new opportunities)
			print("Earned certification in dialogue skills!")
		else:
			var amount = int(base_rewards[reward_type] * multiplier)
			match reward_type:
				"conversation_points":
					dialogue_stats.conversation_points += amount
				"exp":
					add_experience("dialogue_mastery", amount)
				"money":
					add_money(amount)

# ============================================================================
# TEST SCHEDULING & AVAILABILITY 
# ============================================================================

func check_available_tests() -> Array:
	var available = []
	
	# Check if daily tests are available
	if test_schedule.daily_quick_tests and test_system.tests_taken_today < test_system.max_daily_tests:
		available.append("quick_assessment")
	
	# Check level milestone tests
	if player_stats.overall_level in test_schedule.level_milestones:
		available.append("comprehensive_exam")
	
	# Check for context challenge availability (every week)
	var days_since_start = _get_total_days_played()
	if days_since_start % test_schedule.context_rotations == 0:
		available.append("context_challenge")
	
	# Skill verification available at higher levels
	if player_stats.dialogue_mastery >= 3:
		available.append("skill_verification")
	
	return available

func get_test_recommendations() -> Dictionary:
	var recommendations = {
		"suggested_test": "",
		"reason": "",
		"urgency": "low"
	}
	
	# Analyze recent performance
	var recent_tests = test_system.test_history.filter(func(t): return _days_since_test(t.date) <= 7)
	
	if recent_tests.size() == 0:
		recommendations.suggested_test = "quick_assessment"
		recommendations.reason = "No recent test data - baseline assessment recommended"
		recommendations.urgency = "medium"
	elif _get_average_recent_score() < 70:
		recommendations.suggested_test = "context_challenge"
		recommendations.reason = "Recent performance below target - focused practice needed"
		recommendations.urgency = "high"
	elif player_stats.overall_level >= 5 and _days_since_comprehensive_exam() > 14:
		recommendations.suggested_test = "comprehensive_exam"
		recommendations.reason = "Comprehensive assessment due for level verification"
		recommendations.urgency = "medium"
	
	return recommendations

# ============================================================================
# TEST ANALYSIS & HELPER FUNCTIONS
# ============================================================================

func get_test_analytics() -> Dictionary:
	var analytics = {
		"tests_taken": test_system.test_history.size(),
		"average_score": 0.0,
		"strongest_context": "",
		"weakest_context": "",
		"improvement_trend": 0.0,
		"context_breakdown": {}
	}
	
	if test_system.test_history.size() == 0:
		return analytics
	
	# Calculate overall average
	var total_score = 0.0
	for test in test_system.test_history:
		total_score += test.overall_score
	analytics.average_score = total_score / test_system.test_history.size()
	
	# Analyze context performance
	var context_totals = {}
	var context_counts = {}
	
	for test in test_system.test_history:
		for context in test.context_performance.keys():
			if not context in context_totals:
				context_totals[context] = 0.0
				context_counts[context] = 0
			context_totals[context] += test.context_performance[context]
			context_counts[context] += 1
	
	var best_score = 0.0
	var worst_score = 100.0
	
	for context in context_totals.keys():
		var average = context_totals[context] / context_counts[context]
		analytics.context_breakdown[context] = average
		
		if average > best_score:
			best_score = average
			analytics.strongest_context = context
		if average < worst_score:
			worst_score = average
			analytics.weakest_context = context
	
	# Calculate improvement trend (recent vs older tests)
	if test_system.test_history.size() >= 4:
		var recent_avg = 0.0
		var older_avg = 0.0
		var split_point = test_system.test_history.size() / 2
		
		for i in range(split_point):
			older_avg += test_system.test_history[i].overall_score
		for i in range(split_point, test_system.test_history.size()):
			recent_avg += test_system.test_history[i].overall_score
		
		recent_avg /= (test_system.test_history.size() - split_point)
		older_avg /= split_point
		analytics.improvement_trend = recent_avg - older_avg
	
	return analytics

# Helper functions for test system
func _get_random_context() -> int:
	var contexts = [DialogueContext.CASUAL, DialogueContext.FORMAL, DialogueContext.BUSINESS, 
					DialogueContext.CULTURAL, DialogueContext.EMOTIONAL, DialogueContext.TECHNICAL]
	return contexts[randi() % contexts.size()]

func _select_test_theme() -> String:
	var themes = ["professional", "social", "cultural", "personal"]
	return themes[randi() % themes.size()]

func _get_theme_contexts(theme: String) -> Array:
	match theme:
		"professional":
			return [DialogueContext.BUSINESS, DialogueContext.FORMAL, DialogueContext.TECHNICAL]
		"social":
			return [DialogueContext.CASUAL, DialogueContext.EMOTIONAL]
		"cultural":
			return [DialogueContext.CULTURAL, DialogueContext.FORMAL]
		"personal":
			return [DialogueContext.CASUAL, DialogueContext.EMOTIONAL]
		_:
			return [DialogueContext.CASUAL]

func _identify_weak_contexts() -> Array:
	var analytics = get_test_analytics()
	var weak_contexts = []
	
	for context in analytics.context_breakdown.keys():
		if analytics.context_breakdown[context] < 70:
			weak_contexts.append(_get_context_enum(context))
	
	return weak_contexts

func _identify_strong_contexts() -> Array:
	var analytics = get_test_analytics()
	var strong_contexts = []
	
	for context in analytics.context_breakdown.keys():
		if analytics.context_breakdown[context] >= 80:
			strong_contexts.append(_get_context_enum(context))
	
	return strong_contexts

func _get_context_enum(context_name: String) -> int:
	match context_name:
		"casual": return DialogueContext.CASUAL
		"formal": return DialogueContext.FORMAL
		"business": return DialogueContext.BUSINESS
		"cultural": return DialogueContext.CULTURAL
		"emotional": return DialogueContext.EMOTIONAL
		"technical": return DialogueContext.TECHNICAL
		_: return DialogueContext.CASUAL

func _generate_test_npc_name() -> String:
	var names = ["Alex", "Maria", "David", "Sarah", "Chen", "Yuki", "Ahmed", "Lisa", "Roberto", "Nina"]
	return names[randi() % names.size()]

func _get_result_name(result: TestResult) -> String:
	match result:
		TestResult.FAILED: return "Failed"
		TestResult.PASSED: return "Passed"
		TestResult.EXCELLENT: return "Excellent"
		TestResult.PERFECT: return "Perfect"
		_: return "Unknown"

func _get_total_days_played() -> int:
	return (current_time.year - 1) * (days_per_season * 4) + (seasons.find(current_time.season)) * days_per_season + current_time.day

func _days_since_test(test_date: Dictionary) -> int:
	return _days_between_dates(test_date, current_time)

func _get_average_recent_score() -> float:
	var recent_tests = test_system.test_history.filter(func(t): return _days_since_test(t.date) <= 7)
	if recent_tests.size() == 0:
		return 0.0
	
	var total = 0.0
	for test in recent_tests:
		total += test.overall_score
	return total / recent_tests.size()

func _days_since_comprehensive_exam() -> int:
	var comprehensive_tests = test_system.test_history.filter(func(t): return t.type == "comprehensive_exam")
	if comprehensive_tests.size() == 0:
		return 999  # Never taken
	
	var latest_test = comprehensive_tests.back()
	return _days_since_test(latest_test.date)

# ============================================================================
# INTEGRATION WITH NATHAN HOAD'S DIALOGUE MANAGER
# ============================================================================

# These functions provide state values that can be accessed by dialogue conditions/mutations
func get_dialogue_manager_state() -> Dictionary:
	return {
		# Player stats accessible in dialogue
		"player_level": player_stats.overall_level,
		"dialogue_mastery": player_stats.dialogue_mastery,
		"confidence": player_stats.conversation_confidence,
		"charisma": player_stats.charisma,
		"intelligence": player_stats.intelligence,
		"money": player_stats.money,
		"energy": player_stats.energy,
		"job_title": current_job.title,
		"job_performance": current_job.get("performance_today", 0),
		
		# Current context
		"current_location": current_location,
		"time_hour": current_time.hour,
		"time_day": current_time.day,
		"season": current_time.season,
		"weather": current_weather,
		
		# Dialogue performance
		"current_streak": dialogue_stats.current_streak,
		"conversation_points": dialogue_stats.conversation_points,
		"perfect_sequences": player_stats.perfect_sequences,
		
		# Relationships
		"relationships": relationships
	}

# Functions that can be called from dialogue mutations
func dialogue_add_money(amount: int):
	add_money(amount)

func dialogue_add_experience(skill: String, amount: int):
	add_experience(skill, amount)

func dialogue_add_relationship(npc_name: String, points: int):
	add_friendship_points(npc_name, points)

func dialogue_consume_energy(amount: int):
	consume_energy(amount)

func dialogue_add_item(item_id: String, quantity: int = 1):
	add_item(item_id, quantity)

func dialogue_set_location(location: String):
	change_location(location)

func dialogue_start_quest(quest_id: String):
	start_mentor_quest(quest_id)

# ============================================================================
# STANDARD GAME FUNCTIONS (Money, Energy, Inventory, etc.)
# ============================================================================

func add_money(amount: int):
	player_stats.money += amount
	emit_signal("money_changed", player_stats.money)

func spend_money(amount: int) -> bool:
	if player_stats.money >= amount:
		player_stats.money -= amount
		emit_signal("money_changed", player_stats.money)
		return true
	return false

func consume_energy(amount: int):
	player_stats.energy = max(0, player_stats.energy - amount)
	emit_signal("energy_changed", player_stats.energy, player_stats.max_energy)
	
	if player_stats.energy == 0:
		_handle_exhaustion()

func restore_energy(amount: int):
	player_stats.energy = min(player_stats.max_energy, player_stats.energy + amount)
	emit_signal("energy_changed", player_stats.energy, player_stats.max_energy)

func _regenerate_energy():
	player_stats.energy = player_stats.max_energy
	emit_signal("energy_changed", player_stats.energy, player_stats.max_energy)

func _handle_exhaustion():
	print("Player collapsed from exhaustion!")
	var penalty = min(100, player_stats.money * 0.05)
	spend_money(penalty)
	advance_day()

func add_item(item_id: String, quantity: int = 1) -> bool:
	if get_inventory_space() < quantity:
		return false
	
	if item_id in inventory:
		inventory[item_id] += quantity
	else:
		inventory[item_id] = quantity
	
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if not item_id in inventory or inventory[item_id] < quantity:
		return false
	
	inventory[item_id] -= quantity
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	
	return true

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

func get_inventory_space() -> int:
	var used_space = 0
	for item_quantity in inventory.values():
		used_space += item_quantity
	return inventory_size - used_space

func add_experience(skill: String, amount: int):
	if skill in player_exp:
		player_exp[skill] += amount
		_check_level_up(skill)

func _check_level_up(skill: String):
	var current_level = player_stats[skill + "_level"] if skill + "_level" in player_stats else player_stats[skill]
	var required_exp = _get_exp_for_level(current_level + 1)
	
	if player_exp[skill] >= required_exp:
		if skill + "_level" in player_stats:
			player_stats[skill + "_level"] += 1
		else:
			player_stats[skill] += 1
		print("Level up! %s is now level %d" % [skill.replace("_", " ").capitalize(), player_stats[skill + "_level"] if skill + "_level" in player_stats else player_stats[skill]])

func _get_exp_for_level(level: int) -> int:
	return int(100 * level * (level - 1) / 2)

func add_friendship_points(npc_name: String, points: int):
	if not npc_name in relationships:
		relationships[npc_name] = 0
	
	relationships[npc_name] = min(12, relationships[npc_name] + points)

func change_location(new_location: String):
	previous_location = current_location
	current_location = new_location

func _decay_unused_skills():
	# Slowly decay skills that aren't being used
	for skill in ["social_skills", "creativity", "fitness"]:
		if player_stats[skill] > 1:
			player_stats[skill] = max(1, player_stats[skill] - 0.1)

func _reset_daily_dialogue_stats():
	dialogue_stats.perfect_sequences_today = 0
	dialogue_stats.choices_made_today = 0
	dialogue_stats.excellent_choices_today = 0
	print("Daily dialogue stats reset")

func _reset_daily_test_limits():
	test_system.tests_taken_today = 0

func _check_scheduled_tests():
	# Check if any tests should be automatically scheduled
	if player_stats.overall_level in test_schedule.level_milestones:
		if test_system.next_scheduled_test == null:
			test_system.next_scheduled_test = {
				"type": "comprehensive_exam",
				"reason": "Level milestone reached",
				"available_until": _add_days_to_date(current_time, 3)
			}
			print("Comprehensive exam available! Complete within 3 days.")

func _get_context_name(context: int) -> String:
	match context:
		DialogueContext.CASUAL: return "casual"
		DialogueContext.FORMAL: return "formal"
		DialogueContext.BUSINESS: return "business"
		DialogueContext.CULTURAL: return "cultural"
		DialogueContext.EMOTIONAL: return "emotional"
		DialogueContext.TECHNICAL: return "technical"
		_: return "casual"

# Continue with weather, save/load, and utility functions...
func _update_weather():
	if weather_forecast.size() > 0:
		current_weather = weather_forecast.pop_front()
	else:
		_generate_weather_forecast()
		current_weather = weather_forecast.pop_front()
	
	emit_signal("weather_changed", current_weather)

func _generate_weather_forecast():
	weather_forecast.clear()
	
	for i in range(7):
		var weather_chance = randf()
		var new_weather: WeatherType
		
		match current_time.season:
			"spring", "summer":
				if weather_chance < 0.7:
					new_weather = WeatherType.SUNNY
				else:
					new_weather = WeatherType.RAINY
			"fall":
				if weather_chance < 0.5:
					new_weather = WeatherType.SUNNY
				else:
					new_weather = WeatherType.RAINY
			"winter":
				if weather_chance < 0.4:
					new_weather = WeatherType.SUNNY
				else:
					new_weather = WeatherType.SNOWY
		
		weather_forecast.append(new_weather)

func save_game(file_path: String = "user://savegame.json"):
	var save_data = {
		"current_time": current_time,
		"player_stats": player_stats,
		"player_exp": player_exp,
		"inventory": inventory,
		"relationships": relationships,
		"current_location": current_location,
		"current_job": current_job,
		"active_hobbies": active_hobbies,
		"hobby_progress": hobby_progress,
		"dialogue_stats": dialogue_stats,
		"dialogue_history": dialogue_history,
		"mentor_quests": mentor_quests,
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"test_system": test_system,
		"phonetic_stats": phonetic_stats,
		"grammar_stats": grammar_stats
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved successfully!")

func _auto_save():
	if game_settings.auto_save:
		save_game("user://autosave.json")

func get_formatted_time() -> String:
	var hour_12 = current_time.hour
	var am_pm = "AM"
	
	if hour_12 == 0:
		hour_12 = 12
	elif hour_12 > 12:
		hour_12 -= 12
		am_pm = "PM"
	elif hour_12 == 12:
		am_pm = "PM"
	
	return "%02d:%02d %s" % [hour_12, current_time.minute, am_pm]

# ============================================================================
# LINGUISTICS SYSTEM EXAMPLE USAGE & PUBLIC API
# ============================================================================

# Example: Practice specific phoneme for a region
func practice_argentinian_ll() -> Dictionary:
	return practice_phonetics("ll", DialectRegion.ARGENTINA)

# Example: Practice challenging grammar topic
func practice_subjunctive() -> Dictionary:
	return practice_grammar("subjunctive")

# Example: Get personalized study recommendations
func get_personalized_study_plan() -> Dictionary:
	var plan = {
		"pronunciation_challenges": get_pronunciation_challenges(),
		"grammar_recommendations": get_grammar_recommendations(),
		"suggested_hobbies": [],
		"recommended_tests": [],
		"estimated_study_time": 0
	}
	
	# Add hobby recommendations based on weak areas
	if phonetic_stats.pronunciation_accuracy < 70:
		plan.suggested_hobbies.append("pronunciation_drills")
		plan.estimated_study_time += 45
	
	if grammar_stats.grammar_accuracy < 70:
		plan.suggested_hobbies.append("grammar_exercises")
		plan.estimated_study_time += 60
	
	# Add test recommendations
	var available_tests = check_available_tests()
	plan.recommended_tests = available_tests
	
	return plan

# Get comprehensive language proficiency report
func get_language_proficiency_report() -> Dictionary:
	var test_analytics = get_test_analytics()
	
	return {
		"overall_level": player_stats.overall_level,
		"dialogue_mastery": player_stats.dialogue_mastery,
		"pronunciation": {
			"accuracy": phonetic_stats.pronunciation_accuracy,
			"accent_rating": phonetic_stats.accent_rating,
			"mastered_phonemes": phonetic_stats.mastered_phonemes.size(),
			"problematic_sounds": phonetic_stats.problematic_sounds
		},
		"grammar": {
			"accuracy": grammar_stats.grammar_accuracy,
			"competence_level": grammar_stats.grammar_competence,
			"mastered_structures": grammar_stats.mastered_structures.size(),
			"challenging_areas": grammar_stats.challenging_areas
		},
		"regional_competence": phonetic_stats.dialect_familiarity,
		"conversation_confidence": player_stats.conversation_confidence,
		"test_performance": test_analytics,
		"strengths": _identify_language_strengths(),
		"areas_for_improvement": _identify_improvement_areas()
	}

# Nathan Hoad Dialogue Manager Integration Functions
func get_dialogue_manager_linguistics_state() -> Dictionary:
	var base_state = get_dialogue_manager_state()
	
	# Add linguistics data for dialogue conditions
	base_state.merge({
		"pronunciation_accuracy": phonetic_stats.pronunciation_accuracy,
		"grammar_accuracy": grammar_stats.grammar_accuracy,
		"accent_rating": phonetic_stats.accent_rating,
		"phonetics_level": player_stats.phonetics,
		"grammar_level": player_stats.grammar,
		"mastered_phonemes_count": phonetic_stats.mastered_phonemes.size(),
		"mastered_grammar_count": grammar_stats.mastered_structures.size(),
		"argentinian_familiarity": phonetic_stats.dialect_familiarity.get(DialectRegion.ARGENTINA, 0),
		"spanish_familiarity": phonetic_stats.dialect_familiarity.get(DialectRegion.SPAIN, 0),
		"mexican_familiarity": phonetic_stats.dialect_familiarity.get(DialectRegion.MEXICO, 0)
	})
	
	return base_state

func _identify_language_strengths() -> Array:
	var strengths = []
	
	if phonetic_stats.pronunciation_accuracy >= 80:
		strengths.append("Excellent pronunciation clarity")
	
	if grammar_stats.grammar_accuracy >= 80:
		strengths.append("Strong grammatical accuracy")
	
	if player_stats.conversation_confidence >= 80:
		strengths.append("High conversation confidence")
	
	if dialogue_stats.current_streak >= 10:
		strengths.append("Consistent dialogue performance")
	
	# Check for regional expertise
	for region in phonetic_stats.dialect_familiarity.keys():
		if phonetic_stats.dialect_familiarity[region] >= 80:
			strengths.append("Proficient in %s dialect" % DialectRegion.keys()[region])
	
	return strengths

func _identify_improvement_areas() -> Array:
	var areas = []
	
	if phonetic_stats.pronunciation_accuracy < 60:
		areas.append("Pronunciation accuracy needs significant work")
	
	if grammar_stats.grammar_accuracy < 60:
		areas.append("Grammar accuracy requires focused practice")
	
	if player_stats.conversation_confidence < 50:
		areas.append("Building conversation confidence")
	
	if phonetic_stats.problematic_sounds.size() > 3:
		areas.append("Multiple challenging sounds to master")
	
	if grammar_stats.challenging_areas.size() > 3:
		areas.append("Several grammar concepts need reinforcement")
	
	return areas

# Example dialogue manager mutations for linguistics
func dialogue_practice_pronunciation(phoneme: String, region: String = "NEUTRAL"):
	var region_enum = DialectRegion.get(region, DialectRegion.NEUTRAL)
	var result = practice_phonetics(phoneme, region_enum)
	print("Practiced %s pronunciation: %d%% accuracy" % [phoneme, result.get("accuracy", 0)])

func dialogue_study_grammar(rule: String):
	var result = practice_grammar(rule)
	print("Studied %s grammar: %d%% accuracy" % [rule, result.get("accuracy", 0)])

func dialogue_add_phonetic_experience(amount: int):
	add_experience("phonetics", amount)

func dialogue_add_grammar_experience(amount: int):
	add_experience("grammar", amount)
