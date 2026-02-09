extends TileMap

@export var map_width: int = 100  # マップの幅（タイル数）
@export var map_height: int = 100  # マップの高さ（タイル数）
@export var tile_size: int = 32  # タイルサイズ（ピクセル）

func _ready() -> void:
	# タイルセットを作成
	_create_tileset()
	
	# ランダム地形を生成
	_generate_random_terrain()

func _create_tileset() -> void:
	# 新しいTileSetリソースを作成
	var tileset: TileSet = TileSet.new()
	
	# ソースを作成
	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	
	# 薄い緑色のタイル画像を生成
	var img: Image = Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.4, 0.8, 0.4))  # 薄い緑色
	var texture: ImageTexture = ImageTexture.new()
	texture.set_image(img)
	
	# テクスチャをソースに設定
	source.texture = texture
	source.create_tile(Vector2i(0, 0))
	
	# TileSetにソースを追加
	tileset.add_source(source, 0)
	
	# TileMapにTileSetを設定
	tile_set = tileset

func _generate_random_terrain() -> void:
	# ランダムシードを設定（毎回異なる地形を生成）
	randomize()
	
	# タイルを配置
	for x in range(-map_width / 2, map_width / 2):
		for y in range(-map_height / 2, map_height / 2):
			# ランダムに地形を生成（80%の確率でタイルを配置）
			if randf() > 0.2:
				set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
