extends CharacterBody2D

@export var move_speed: float = 200.0
@export var jump_velocity: float = -350.0
@export var gravity: float = 800.0

# 8方向の方向名
var current_direction: String = "south"
var direction_textures: Dictionary = {}

func _ready() -> void:
	# 入力アクションを登録
	_ensure_input_actions()
	
	# プレイヤーの初期位置
	position = Vector2(0, 0)
	
	# コリジョン形状（32×32px）
	var cs: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if cs:
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(32, 32)
		cs.shape = shape
	
	# 8方向のテクスチャを読み込む
	_load_direction_textures()
	
	# 初期スプライトを設定
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	if sprite:
		sprite.centered = true
		_update_sprite_direction()

func _load_direction_textures() -> void:
	var directions: Array[String] = [
		"south", "south-east", "east", "north-east",
		"north", "north-west", "west", "south-west"
	]
	
	for dir in directions:
		var texture_path: String = "res://ordinary_young_man/rotations/" + dir + ".png"
		var texture: Texture2D = load(texture_path)
		if texture:
			direction_textures[dir] = texture

func _update_sprite_direction() -> void:
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	if sprite and direction_textures.has(current_direction):
		sprite.texture = direction_textures[current_direction]

func _ensure_input_actions() -> void:
	# move_up
	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		var ev_w: InputEventKey = InputEventKey.new()
		ev_w.keycode = KEY_W
		InputMap.action_add_event("move_up", ev_w)
		var ev_up: InputEventKey = InputEventKey.new()
		ev_up.keycode = KEY_UP
		InputMap.action_add_event("move_up", ev_up)
	
	# move_down
	if not InputMap.has_action("move_down"):
		InputMap.add_action("move_down")
		var ev_s: InputEventKey = InputEventKey.new()
		ev_s.keycode = KEY_S
		InputMap.action_add_event("move_down", ev_s)
		var ev_down: InputEventKey = InputEventKey.new()
		ev_down.keycode = KEY_DOWN
		InputMap.action_add_event("move_down", ev_down)
	
	# move_left
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var ev_a: InputEventKey = InputEventKey.new()
		ev_a.keycode = KEY_A
		InputMap.action_add_event("move_left", ev_a)
		var ev_left: InputEventKey = InputEventKey.new()
		ev_left.keycode = KEY_LEFT
		InputMap.action_add_event("move_left", ev_left)
	
	# move_right
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var ev_d: InputEventKey = InputEventKey.new()
		ev_d.keycode = KEY_D
		InputMap.action_add_event("move_right", ev_d)
		var ev_right: InputEventKey = InputEventKey.new()
		ev_right.keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", ev_right)

func _physics_process(delta: float) -> void:
	# 重力（必要に応じて）
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# WASDで8方向移動
	var input_vector: Vector2 = Vector2.ZERO
	
	if InputMap.has_action("move_up") and Input.is_action_pressed("move_up"):
		input_vector.y -= 1.0
	if InputMap.has_action("move_down") and Input.is_action_pressed("move_down"):
		input_vector.y += 1.0
	if InputMap.has_action("move_left") and Input.is_action_pressed("move_left"):
		input_vector.x -= 1.0
	if InputMap.has_action("move_right") and Input.is_action_pressed("move_right"):
		input_vector.x += 1.0
	
	# 正規化して斜め移動の速度を統一
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity.x = input_vector.x * move_speed
		velocity.y = input_vector.y * move_speed
		
		# 方向を決定（8方向）
		_determine_direction(input_vector)
	else:
		velocity.x = 0.0
		velocity.y = 0.0
	
	move_and_slide()

func _determine_direction(input_vector: Vector2) -> void:
	var angle: float = input_vector.angle()
	var new_direction: String = current_direction
	
	# 角度を0-2πの範囲に正規化
	if angle < 0:
		angle += 2 * PI
	
	# 8方向に分割（各45度）
	if angle >= -PI/8 and angle < PI/8:
		new_direction = "east"
	elif angle >= PI/8 and angle < 3*PI/8:
		new_direction = "north-east"
	elif angle >= 3*PI/8 and angle < 5*PI/8:
		new_direction = "north"
	elif angle >= 5*PI/8 and angle < 7*PI/8:
		new_direction = "north-west"
	elif angle >= 7*PI/8 and angle < 9*PI/8:
		new_direction = "west"
	elif angle >= 9*PI/8 and angle < 11*PI/8:
		new_direction = "south-west"
	elif angle >= 11*PI/8 and angle < 13*PI/8:
		new_direction = "south"
	elif angle >= 13*PI/8 and angle < 15*PI/8:
		new_direction = "south-east"
	
	# 方向が変わったらスプライトを更新
	if new_direction != current_direction:
		current_direction = new_direction
		_update_sprite_direction()
