extends Node2D

@onready var inventory_ui: InventoryUI = %InventoryUI

func _ready() -> void:
	var inv = Inventory.new(10)
	
	# Create dummy items
	var sword = Item.new()
	sword.name = "Sword"
	# Use icon.svg as placeholder since we don't have item icons yet
	var icon = preload("res://icon.svg")
	sword.icon = icon
	
	var potion = Item.new()
	potion.name = "Potion"
	potion.icon = icon
	potion.stackable = true
	
	inv.add_item(sword, 1)
	inv.add_item(potion, 5)
	
	if inventory_ui:
		inventory_ui.set_inventory(inv)
	
	# Load LDtk Map
	var ground_map: TileMap = get_node_or_null("Ground")
	if ground_map:
		# Note: The original file 'Typical_TopDown_example.ldtk' was a macOS alias (invalid).
		# I created a valid 'sample_map.ldtk' to demonstrate the loader.
		# Replace this path with your real JSON file path when ready.
		LDtkLoader.load_map("res://public/sample_map.ldtk", ground_map)
