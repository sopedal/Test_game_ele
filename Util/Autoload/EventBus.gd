# === EventBus.gd (Simple Start) ===
extends Node

# Basic UI events
signal ui_data_needed(ui_id: String)
signal ui_opened(ui_id: String)
signal ui_closed(ui_id: String)

# Basic inventory events
signal inventory_data_ready(inventory_data: Array)
signal hotbar_data_ready(hotbar_data: Array)
signal inventory_changed
signal hotbar_changed
signal item_pickup_requested(item_name: String, quantity: int)
signal item_used_from_inventory(item: Item, slot_index: int)

# Player events
signal player_healed(amount: int)
signal player_stat_changed(stat_name: String, value)

# NPC events (existing)
signal npc_interacted(npc: NPC)
signal npc_met_for_first_time(npc: NPC)
signal dialogue_started
signal dialogue_ended

func _ready():
	print("📡 EventBus initialized (simple version)")

# === HELPER FUNCTIONS ===

func request_inventory_data():
	"""Helper to request inventory data"""
	ui_data_needed.emit("inventory")

func request_hotbar_data():
	"""Helper to request hotbar data"""
	ui_data_needed.emit("hotbar")

func pickup_item(item_id: String, quantity: int = 1):
	"""Helper to pickup item"""
	item_pickup_requested.emit(item_id, quantity)

func notify_hotbar_changed():
	"""Helper to notify hotbar changed"""
	hotbar_changed.emit()
