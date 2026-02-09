extends CharacterBody2D

@export var move_speed: float = 200.0

# 8方向の方向名
var current_direction: String = "south"
var is_attacking: bool = false
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Jump variables
var z_pos: float = 0.0
var z_vel: float = 0.0
const GRAVITY: float = 980.0
const JUMP_FORCE: float = 300.0

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
	
	# アニメーション設定
	_setup_animations()
	
	if anim_sprite:
		# Centered is default for AnimatedSprite2D usually, but ensure it
		anim_sprite.centered = true
		_update_animation_state()

func _setup_animations() -> void:
	if not anim_sprite:
		return
		
	var sprite_frames = SpriteFrames.new()
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	var directions = [
		"south", "south-east", "east", "north-east",
		"north", "north-west", "west", "south-west"
	]
	
	# Load walk animations
	for dir in directions:
		var anim_name = "walk_" + dir
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_loop(anim_name, true)
		sprite_frames.set_animation_speed(anim_name, 10.0)
		
		var frame_index = 0
		while true:
			var frame_str = "frame_%03d" % frame_index
			var path = "res://ordinary_young_man/animations/walk/" + dir + "/" + frame_str + ".png"
			if not FileAccess.file_exists(path):
				break
			var texture = load(path)
			if texture:
				sprite_frames.add_frame(anim_name, texture)
			frame_index += 1
			if frame_index > 20: break
			
	# Load idle (use first frame of walk)
	for dir in directions:
		var anim_name = "idle_" + dir
		sprite_frames.add_animation(anim_name)
		var path = "res://ordinary_young_man/animations/walk/" + dir + "/frame_000.png"
		if FileAccess.file_exists(path):
			var texture = load(path)
			sprite_frames.add_frame(anim_name, texture)
			
	# Load jump animations
	for dir in directions:
		var anim_name = "jump_" + dir
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_loop(anim_name, false) # Jump usually plays once
		sprite_frames.set_animation_speed(anim_name, 10.0)
		
		var frame_index = 0
		while true:
			var frame_str = "frame_%03d" % frame_index
			var path = "res://ordinary_young_man/animations/jumping-1/" + dir + "/" + frame_str + ".png"
			if not FileAccess.file_exists(path):
				break
			var texture = load(path)
			if texture:
				sprite_frames.add_frame(anim_name, texture)
			frame_index += 1
			if frame_index > 20: break
	
	anim_sprite.sprite_frames = sprite_frames

func _ensure_input_actions() -> void:
	# move_up, down, left, right (WASD + Arrows)
	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		var ev_w = InputEventKey.new()
		ev_w.keycode = KEY_W
		InputMap.action_add_event("move_up", ev_w)
		var ev_up = InputEventKey.new()
		ev_up.keycode = KEY_UP
		InputMap.action_add_event("move_up", ev_up)
	
	if not InputMap.has_action("move_down"):
		InputMap.add_action("move_down")
		var ev_s = InputEventKey.new()
		ev_s.keycode = KEY_S
		InputMap.action_add_event("move_down", ev_s)
		var ev_down = InputEventKey.new()
		ev_down.keycode = KEY_DOWN
		InputMap.action_add_event("move_down", ev_down)
	
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var ev_a = InputEventKey.new()
		ev_a.keycode = KEY_A
		InputMap.action_add_event("move_left", ev_a)
		var ev_left = InputEventKey.new()
		ev_left.keycode = KEY_LEFT
		InputMap.action_add_event("move_left", ev_left)
	
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var ev_d = InputEventKey.new()
		ev_d.keycode = KEY_D
		InputMap.action_add_event("move_right", ev_d)
		var ev_right = InputEventKey.new()
		ev_right.keycode = KEY_RIGHT
		InputMap.action_add_event("move_right", ev_right)
	
	# attack (Space)
	if not InputMap.has_action("attack"):
		InputMap.add_action("attack")
		var ev_space = InputEventKey.new()
		ev_space.keycode = KEY_SPACE
		InputMap.action_add_event("attack", ev_space)
		
	# jump (Z)
	if not InputMap.has_action("jump"):
		InputMap.add_action("jump")
		var ev_z = InputEventKey.new()
		ev_z.keycode = KEY_Z
		InputMap.action_add_event("jump", ev_z)

func _physics_process(_delta: float) -> void:
	# Jump Physics
	if z_pos < 0 or z_vel != 0:
		z_vel += GRAVITY * _delta
		z_pos += z_vel * _delta
		if z_pos > 0:
			z_pos = 0
			z_vel = 0
			
	# Jump Input
	if z_pos == 0 and InputMap.has_action("jump") and Input.is_action_just_pressed("jump"):
		z_vel = -JUMP_FORCE
	
	if is_attacking:
		_update_animation_state()
		move_and_slide()
		return

	# Attack input
	if InputMap.has_action("attack") and Input.is_action_just_pressed("attack"):
		_attack()
		return

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
		
		# 方向を決定（8方向）- 入力ベクトルから直接判定
		_determine_direction(input_vector)
	else:
		velocity.x = 0.0
		velocity.y = 0.0
	
	_update_animation_state()
	move_and_slide()

func _determine_direction(input_vector: Vector2) -> void:
	var new_direction: String = current_direction
	var x: float = input_vector.x
	var y: float = input_vector.y
	
	var threshold: float = 0.3
	
	if abs(x) > threshold and abs(y) > threshold:
		if x > 0 and y < 0:
			new_direction = "north-east"
		elif x > 0 and y > 0:
			new_direction = "south-east"
		elif x < 0 and y < 0:
			new_direction = "north-west"
		elif x < 0 and y > 0:
			new_direction = "south-west"
	elif abs(x) > abs(y):
		if x > 0:
			new_direction = "east"
		else:
			new_direction = "west"
	else:
		if y < 0:
			new_direction = "north"
		else:
			new_direction = "south"
	
	current_direction = new_direction

func _update_animation_state() -> void:
	if not anim_sprite:
		return
		
	# Update visual position based on z_pos
	# Note: z_pos is negative upwards
	anim_sprite.position.y = z_pos
	
	if z_pos < 0:
		# Jumping
		anim_sprite.play("jump_" + current_direction)
		return
		
	if is_attacking:
		anim_sprite.play("idle_" + current_direction)
		return
		
	if velocity.length() > 0:
		anim_sprite.play("walk_" + current_direction)
	else:
		anim_sprite.play("idle_" + current_direction)

func _attack() -> void:
	is_attacking = true
	velocity = Vector2.ZERO
	
	# Visual feedback: Rotate sprite
	if anim_sprite:
		var tween = create_tween()
		tween.tween_property(anim_sprite, "rotation_degrees", 30.0, 0.1)
		tween.tween_property(anim_sprite, "rotation_degrees", -30.0, 0.1)
		tween.tween_property(anim_sprite, "rotation_degrees", 0.0, 0.1)
		tween.tween_callback(func(): is_attacking = false)
	else:
		await get_tree().create_timer(0.3).timeout
		is_attacking = false
