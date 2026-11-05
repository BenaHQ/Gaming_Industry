extends CanvasLayer
## HUD: cuori, perle, chela equipaggiata, zaino e messaggi a fumetto.
## Gestisce anche pausa (Esc/P) e riavvio rapido (R).

const HEARTS := preload("res://assets/sprites/hearts.png")
const PEARL := preload("res://assets/sprites/pearl.png")

var _hearts_box: HBoxContainer
var _pearl_label: Label
var _claw_icon: TextureRect
var _claw_label: Label
var _backpack_box: HBoxContainer
var _message: Label
var _message_panel: PanelContainer
var _pause_label: Label
var _msg_timer := 0.0


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	GameState.health_changed.connect(func(_v: int, _m: int) -> void: _refresh_hearts())
	GameState.pearls_changed.connect(func(v: int) -> void: _pearl_label.text = "x %d" % v)
	GameState.claw_changed.connect(func(_c: StringName) -> void: _refresh_claw())
	GameState.backpack_changed.connect(_refresh_backpack)
	GameState.message.connect(_show_message)
	_refresh_hearts()
	_pearl_label.text = "x %d" % GameState.pearls
	_refresh_claw()
	_refresh_backpack()


func _build() -> void:
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "top", "right", "bottom"]:
		root.add_theme_constant_override("margin_" + side, 4)
	add_child(root)

	var top := HBoxContainer.new()
	top.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	top.add_theme_constant_override("separation", 8)
	root.add_child(top)

	_hearts_box = HBoxContainer.new()
	_hearts_box.add_theme_constant_override("separation", 1)
	top.add_child(_hearts_box)

	var pearl_icon := TextureRect.new()
	pearl_icon.texture = PEARL
	pearl_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	top.add_child(pearl_icon)
	_pearl_label = _label(top)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)

	_backpack_box = HBoxContainer.new()
	top.add_child(_backpack_box)
	_claw_icon = TextureRect.new()
	_claw_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	top.add_child(_claw_icon)
	_claw_label = _label(top)

	_message_panel = PanelContainer.new()
	_message_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	_message_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.05, 0.12, 0.85)
	style.border_color = Color(0.9, 0.85, 0.6)
	style.set_border_width_all(1)
	style.set_content_margin_all(4)
	_message_panel.add_theme_stylebox_override("panel", style)
	_message_panel.visible = false
	root.add_child(_message_panel)
	_message = _label(_message_panel)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.custom_minimum_size = Vector2(260, 0)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_pause_label = Label.new()
	_pause_label.text = "PAUSA\nEsc: riprendi   R: ricomincia livello"
	_pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pause_label.add_theme_font_size_override("font_size", 10)
	_pause_label.add_theme_constant_override("outline_size", 3)
	_pause_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_pause_label.visible = false
	root.add_child(_pause_label)


func _label(parent: Node) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 8)
	l.add_theme_constant_override("outline_size", 2)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	parent.add_child(l)
	return l


func _refresh_hearts() -> void:
	for c in _hearts_box.get_children():
		c.queue_free()
	for i in GameState.max_health:
		var atlas := AtlasTexture.new()
		atlas.atlas = HEARTS
		atlas.region = Rect2(0 if i < GameState.health else 8, 0, 8, 8)
		var t := TextureRect.new()
		t.texture = atlas
		_hearts_box.add_child(t)


func _refresh_claw() -> void:
	var data := GameState.claw_data()
	_claw_icon.texture = data["texture"]
	_claw_label.text = data["name"]


func _refresh_backpack() -> void:
	for c in _backpack_box.get_children():
		c.queue_free()
	for id in GameState.backpack:
		var t := TextureRect.new()
		t.texture = GameState.BACKPACK[id]["texture"]
		t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		_backpack_box.add_child(t)


func _show_message(text: String) -> void:
	_message.text = text
	_message_panel.visible = true
	_msg_timer = 3.5


func _process(delta: float) -> void:
	if _msg_timer > 0.0:
		_msg_timer -= delta
		if _msg_timer <= 0.0:
			_message_panel.visible = false
	if Input.is_action_just_pressed(&"pause"):
		get_tree().paused = not get_tree().paused
		_pause_label.visible = get_tree().paused
	if Input.is_action_just_pressed(&"restart"):
		get_tree().paused = false
		GameState.restore_health()
		GameState.go_to(get_tree().current_scene.scene_file_path)
