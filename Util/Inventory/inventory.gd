# === Inventory.gd (Complete Component Version) ===
class_name Inventory
extends Node

signal updated
signal item_used(item: Item, slot_index: int)

@export var inventory_size: int = 30
@export var hotbar_size: int = 5
@export var auto_register_player: bool = false

var items: Array[ItemStack] = []

func _ready():
	_initialize_slots()
	
	if auto_register_player:
		InventoryManager.register_player_inventory(self)

func _initialize_slots():
	items.clear()
	for slot in inventory_size:
		items.append(ItemStack.new(Items.EMPTY, 0))

func add_item(new_stack: ItemStack) -> ItemStack:
	for stack in items:
		if new_stack.is_empty():
			break
		
		if stack.item == new_stack.item && stack.count < ItemStack.max_count:
			stack.count += new_stack.count
			var overload = stack.count - ItemStack.max_count
			stack.count = clamp(stack.count, 0, ItemStack.max_count)
			
			if overload <= 0:
				new_stack = ItemStack.new(Items.EMPTY, 0)
			else:
				new_stack.count = overload
	
	for stack in items:
		if new_stack.is_empty():
			break
		
		if stack.is_empty():
			stack.item = new_stack.item
			stack.count = new_stack.count
			new_stack = ItemStack.new(Items.EMPTY, 0)
	
	updated.emit()
	return new_stack

func remove_item(item: Item, count: int) -> void:
	print("🗑️ remove_item called: removing %d x %s" % [count, item.item_name])
	
	for i in range(items.size()):
		var stack = items[i]
		
		if count <= 0:
			break
		
		if stack.item == item:
			print("📍 Found item at slot %d: %s x%d" % [i, stack.item.item_name, stack.count])
			
			var old_count = stack.count
			stack.count = max(stack.count - count, 0)
			var removed = old_count - stack.count
			count -= removed
			
			print("📉 Removed %d items from slot %d, %d remaining" % [removed, i, stack.count])
			
			if stack.count <= 0:
				print("🔄 Setting slot %d to empty" % i)
				stack.item = Items.EMPTY
				stack.count = 0
	
	if count > 0:
		print("⚠️ Could not remove %d items (not enough in inventory)" % count)
	
	print("📡 Emitting updated signal...")
	updated.emit()
	
	# Debug: Print current state
	print("📋 Current inventory state after removal:")
	for i in range(min(5, items.size())):  # Print first 5 slots
		var stack = items[i]
		if stack.is_empty():
			print("  [%d] Empty" % i)
		else:
			print("  [%d] %s x%d" % [i, stack.item.item_name, stack.count])

func has_count(item: Item, count: int) -> bool:
	var total := 0
	for stack in items:
		if stack.item == item:
			total += stack.count
			if total >= count:
				return true
	return false

func use_hotbar_item(slot_index: int):
	print("🔥 use_hotbar_item called with slot_index: %d" % slot_index)
	
	if slot_index < 0 or slot_index >= hotbar_size:
		print("❌ Invalid slot index: %d (hotbar size: %d)" % [slot_index, hotbar_size])
		return
	
	if slot_index >= items.size():
		print("❌ Slot index %d exceeds items array size: %d" % [slot_index, items.size()])
		return
	
	var item_stack = items[slot_index]
	print("📦 Item stack in slot %d: %s" % [slot_index, item_stack])
	
	if item_stack.is_empty():
		print("❌ Slot %d is empty" % slot_index)
		return
	
	print("🎯 Using item: %s (count: %d)" % [item_stack.item.item_name, item_stack.count])
	
	# Emit the signal BEFORE modifying the item
	item_used.emit(item_stack.item, slot_index)
	
	# Check if item is consumable - UPDATED to use your Item structure
	var is_consumable = false
	if item_stack.item.healing_amount > 0:
		is_consumable = true
		print("💊 Item is consumable (has healing_amount: %d)" % item_stack.item.healing_amount)
	elif item_stack.item.has_method("use"):
		is_consumable = true
		print("🔧 Item is consumable (has use() method)")
		item_stack.item.use()
	else:
		print("🛠️ Item is not consumable (tool/weapon with damage: %d)" % item_stack.item.damage)
	
	# Remove one if consumable
	if is_consumable:
		print("🗑️ Removing 1 %s from inventory..." % item_stack.item.item_name)
		print("📊 Before removal: %s x%d" % [item_stack.item.item_name, item_stack.count])
		
		remove_item(item_stack.item, 1)
		
		# Check the count after removal
		var updated_stack = items[slot_index]
		print("📊 After removal: slot %d contains %s x%d" % [slot_index, updated_stack.item.item_name if not updated_stack.is_empty() else "Empty", updated_stack.count])
	else:
		print("🔄 Item not consumed (not consumable)")

func _to_string() -> String:
	var s = ""
	for stack in items:
		s += str(stack) + "\n"
	return s
