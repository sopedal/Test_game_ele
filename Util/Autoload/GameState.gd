# === GameState.gd (Simple Start) ===
extends Node

# Simple game data
var npcs_met: Dictionary = {}

func _ready():
	# Connect to EventBus
	EventBus.npc_met_for_first_time.connect(_on_npc_met_first_time)
	print("🎮 GameState initialized (simple version)")

func _on_npc_met_first_time(npc: NPC) -> void:
	"""Handle first-time NPC meeting"""
	if npc and npc.stats:
		mark_npc_as_met(npc.stats.npc_name)

func mark_npc_as_met(npc_id: String) -> void:
	"""Mark NPC as met"""
	if not npcs_met.get(npc_id, false):
		npcs_met[npc_id] = true
		print("📝 GameState: %s marked as met" % npc_id)

func has_met_npc(npc_id: String) -> bool:
	"""Check if NPC has been met"""
	return npcs_met.get(npc_id, false)
