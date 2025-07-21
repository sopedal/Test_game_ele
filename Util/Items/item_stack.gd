# === ItemStack.gd ===
class_name ItemStack
extends Resource

@export var item: Item
@export var count: int = 0

# Maximum items per stack
static var max_count: int = 99

func _init(init_item: Item = null, init_count: int = 0):
	item = init_item
	count = init_count

func is_empty() -> bool:
	"""Check if stack is empty"""
	return item == null or count <= 0 or (item != null and item.item_name == "")

func is_full() -> bool:
	"""Check if stack is at max capacity"""
	return count >= max_count

func can_stack_with(other_item: Item) -> bool:
	"""Check if this stack can accept the other item"""
	if is_empty():
		return true
	return item == other_item

func add_to_stack(amount: int) -> int:
	"""Add to stack, returns overflow amount"""
	var old_count = count
	count = min(count + amount, max_count)
	return amount - (count - old_count)

func remove_from_stack(amount: int) -> int:
	"""Remove from stack, returns amount actually removed"""
	var removed = min(amount, count)
	count -= removed
	
	if count <= 0:
		item = null
		count = 0
	
	return removed

func get_display_name() -> String:
	"""Get name for display"""
	if is_empty():
		return ""
	return item.item_name

func _to_string() -> String:
	if is_empty():
		return "Empty Stack"
	return "%s x%d" % [item.item_name, count]
