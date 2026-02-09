extends Camera2D

# アイソメトリック視点の設定
@export var iso_angle: float = 30.0  # カメラの傾き角度（度）
@export var zoom_level: float = 1.5
@export var zoom_step: float = 0.2
@export var min_zoom: float = 0.5
@export var max_zoom: float = 4.0

func _ready() -> void:
	# カメラを斜めアングルに設定
	rotation_degrees = iso_angle
	zoom = Vector2(zoom_level, zoom_level)
	make_current()
	
	# ズーム用入力アクションを登録
	_ensure_zoom_actions()

func _process(_delta: float) -> void:
	# プレイヤーを追従
	var player: Node2D = get_node_or_null("../Player")
	if player:
		global_position = player.global_position
	
	# ズームイン（+ キー） → 画面を近づける（zoom を小さく）
	if InputMap.has_action("zoom_in") and Input.is_action_just_pressed("zoom_in"):
		var z: float = clamp(zoom.x - zoom_step, min_zoom, max_zoom)
		zoom = Vector2(z, z)
		zoom_level = z
	
	# ズームアウト（- キー） → 画面を遠ざける（zoom を大きく）
	if InputMap.has_action("zoom_out") and Input.is_action_just_pressed("zoom_out"):
		var z: float = clamp(zoom.x + zoom_step, min_zoom, max_zoom)
		zoom = Vector2(z, z)
		zoom_level = z

func _ensure_zoom_actions() -> void:
	# zoom_in: + / Numpad +
	if not InputMap.has_action("zoom_in"):
		InputMap.add_action("zoom_in")
		var ev_zi_main: InputEventKey = InputEventKey.new()
		ev_zi_main.keycode = KEY_EQUAL
		InputMap.action_add_event("zoom_in", ev_zi_main)
		var ev_zi_np: InputEventKey = InputEventKey.new()
		ev_zi_np.keycode = KEY_KP_ADD
		InputMap.action_add_event("zoom_in", ev_zi_np)
	
	# zoom_out: - / Numpad -
	if not InputMap.has_action("zoom_out"):
		InputMap.add_action("zoom_out")
		var ev_zo_main: InputEventKey = InputEventKey.new()
		ev_zo_main.keycode = KEY_MINUS
		InputMap.action_add_event("zoom_out", ev_zo_main)
		var ev_zo_np: InputEventKey = InputEventKey.new()
		ev_zo_np.keycode = KEY_KP_SUBTRACT
		InputMap.action_add_event("zoom_out", ev_zo_np)
