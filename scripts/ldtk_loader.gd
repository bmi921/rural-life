class_name LDtkLoader
extends Node

static func load_map(path: String, tilemap: TileMap) -> void:
	if not FileAccess.file_exists(path):
		printerr("LDtk file not found: ", path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	
	# Check if it's likely binary/alias (starts with typical binary header or "book")
	if content.begins_with("book") or content.length() < 10:
		printerr("LDtk file appears to be invalid or a macOS Alias: ", path)
		return

	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		printerr("JSON Parse Error in LDtk file: ", json.get_error_message())
		return

	var data = json.data
	if not data is Dictionary:
		printerr("Invalid LDtk JSON format")
		return

	var levels = data.get("levels", [])
	if levels.is_empty():
		print("No levels found in LDtk file")
		return

	var level = levels[0] # Load first level
	var layers = level.get("layerInstances", [])
	
	tilemap.clear()
	
	# Iterate layers (LDtk top-down order)
	for layer in layers:
		if layer.__type == "IntGrid" or layer.__type == "AutoLayer":
			_load_int_grid(layer, tilemap)
		elif layer.__type == "Tiles":
			_load_tiles(layer, tilemap)

static func _load_int_grid(layer: Dictionary, tilemap: TileMap) -> void:
	var grid_width = int(layer.__cWid)
	var grid = layer.get("intGridCsv", [])
	
	for i in range(grid.size()):
		var value = int(grid[i])
		if value > 0:
			var x = int(i % grid_width)
			var y = int(i / grid_width)
			# Arbitrary mapping: value 1 -> (0,0), value 2 -> (1,0)
			# Assuming source ID 0
			tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(value - 1, 0))

static func _load_tiles(layer: Dictionary, tilemap: TileMap) -> void:
	var grid_tiles = layer.get("gridTiles", [])
	var grid_size = int(layer.__gridSize)
	
	for tile in grid_tiles:
		var px = tile.px
		var cx = int(px[0] / grid_size)
		var cy = int(px[1] / grid_size)
		var tile_id = int(tile.t)
		
		# Map tile_id to atlas coordinates assuming a 16-column atlas
		# This is a guess; real implementation requires reading tileset defs
		var atlas_x = tile_id % 16
		var atlas_y = int(tile_id / 16)
		
		tilemap.set_cell(0, Vector2i(cx, cy), 0, Vector2i(atlas_x, atlas_y))
