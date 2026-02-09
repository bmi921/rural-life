extends Control
class_name InventoryUI

@export var inventory: Inventory
@onready var container = $PanelContainer/HBoxContainer
const SLOT_SCENE = preload("res://ui/SlotUI.tscn")

func _ready() -> void:
	if inventory:
		if not inventory.changed.is_connected(update_ui):
			inventory.changed.connect(update_ui)
		update_ui()

func set_inventory(inv: Inventory) -> void:
	if inventory and inventory.changed.is_connected(update_ui):
		inventory.changed.disconnect(update_ui)
	
	inventory = inv
	
	if inventory:
		if not inventory.changed.is_connected(update_ui):
			inventory.changed.connect(update_ui)
		update_ui()

func update_ui() -> void:
	if not container:
		return
		
	for child in container.get_children():
		child.queue_free()
		
	if inventory:
		for i in range(inventory.slots.size()):
			var slot = inventory.slots[i]
			var slot_ui = SLOT_SCENE.instantiate()
			container.add_child(slot_ui)
			if slot_ui.has_method("set_slot"):
				slot_ui.set_slot(slot)
			
			if slot_ui.has_signal("selected"):
				slot_ui.selected.connect(_on_slot_selected.bind(i))

func _on_slot_selected(index: int) -> void:
	for i in range(container.get_child_count()):
		var slot_ui = container.get_child(i)
		if slot_ui.has_method("set_selected"):
			slot_ui.set_selected(i == index)
