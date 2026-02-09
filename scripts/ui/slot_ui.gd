extends PanelContainer
class_name SlotUI

signal selected

@onready var icon_rect: TextureRect = $Icon
@onready var quantity_label: Label = $Quantity
var is_selected: bool = false

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected.emit()

func set_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		modulate = Color(1.2, 1.2, 1.2) # Highlight
	else:
		modulate = Color(1, 1, 1)

func set_slot(slot: InventorySlot) -> void:
	if slot and slot.item:
		icon_rect.texture = slot.item.icon
		quantity_label.text = str(slot.quantity) if slot.quantity > 1 else ""
		icon_rect.visible = true
		quantity_label.visible = slot.quantity > 1
	else:
		icon_rect.visible = false
		quantity_label.visible = false
