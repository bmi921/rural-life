extends StaticBody2D

func _ready() -> void:
	# 地面の位置
	position = Vector2(0, 100)
	
	# コリジョン形状
	var cs: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if cs:
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(800, 40)
		cs.shape = shape
	
	# スプライトに簡易ドット絵（緑の長方形）
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	if sprite:
		var img: Image = Image.create(64, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.2, 0.8, 0.3))
		var tex: ImageTexture = ImageTexture.new()
		tex.set_image(img)
		sprite.texture = tex
		# 幅800×高さ40に伸ばす
		sprite.scale = Vector2(800.0 / 64.0, 40.0 / 16.0)
