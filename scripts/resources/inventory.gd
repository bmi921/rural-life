extends Resource
class_name Inventory

@export var slots: Array[InventorySlot] = []

func _init(size: int = 10):
	# Initialize slots
	slots.resize(size)
	for i in range(size):
		slots[i] = InventorySlot.new()

func add_item(item: Item, quantity: int = 1) -> bool:
	# Try to find existing stack
	for slot in slots:
		if slot.item == item and slot.quantity < item.max_stack_size:
			var space = item.max_stack_size - slot.quantity
			var to_add = min(quantity, space)
			slot.quantity += to_add
			quantity -= to_add
			emit_changed()
			if quantity <= 0:
				return true
				
	# If still have quantity, find empty slot
	if quantity > 0:
		for slot in slots:
			if slot.item == null:
				slot.item = item
				slot.quantity = quantity
				emit_changed()
				return true
				
	return false # Could not add all items
