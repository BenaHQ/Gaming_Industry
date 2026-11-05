extends Node
## Stato globale del gioco (autoload "GameState").
## Tiene perle, vita, chele acquistate, oggetti dello zaino e checkpoint,
## così sopravvivono ai cambi di scena.

signal pearls_changed(value: int)
signal health_changed(value: int, max_value: int)
signal claw_changed(claw: StringName)
signal backpack_changed
signal message(text: String)

## Chele: si cambiano in gioco (Q / E). "price" = costo dalla Tartaruga mercante.
const CLAWS := {
	&"pinza": {
		"name": "Chela Pinza", "damage": 1, "reach": 12.0, "breaks_rock": false, "price": 0,
		"texture": preload("res://assets/sprites/claw_pinza.png"),
	},
	&"tenaglia": {
		"name": "Chela Tenaglia", "damage": 1, "reach": 24.0, "breaks_rock": false, "price": 10,
		"texture": preload("res://assets/sprites/claw_tenaglia.png"),
	},
	&"martello": {
		"name": "Chela Martello", "damage": 2, "reach": 12.0, "breaks_rock": true, "price": 15,
		"texture": preload("res://assets/sprites/claw_martello.png"),
	},
}

## Oggetti dello zaino (backpack).
const BACKPACK := {
	&"dash": {"name": "Getto a reazione (Dash)", "texture": preload("res://assets/sprites/icon_dash.png")},
	&"deltaplano": {"name": "Deltaplano", "texture": preload("res://assets/sprites/icon_deltaplano.png")},
}

const BEACH_SCENE := "res://scenes/levels/beach_base.tscn"

var pearls := 0
var max_health := 3
var health := 3
var owned_claws: Array[StringName] = [&"pinza"]
var current_claw: StringName = &"pinza"
var backpack: Array[StringName] = []

## Checkpoint (impostato dal cavalluccio marino).
var checkpoint_scene := ""
var checkpoint_position := Vector2.ZERO

var _fade_rect: ColorRect
var _changing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_inputs()
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade_rect)


# ------------------------------------------------------------------ perle
func add_pearls(amount: int) -> void:
	pearls = maxi(0, pearls + amount)
	pearls_changed.emit(pearls)


func spend_pearls(amount: int) -> bool:
	if pearls < amount:
		return false
	add_pearls(-amount)
	return true


# ------------------------------------------------------------------- vita
func set_health(value: int) -> void:
	health = clampi(value, 0, max_health)
	health_changed.emit(health, max_health)


func restore_health() -> void:
	set_health(max_health)


# ------------------------------------------------------------------ chele
func has_claw(id: StringName) -> bool:
	return id in owned_claws


func unlock_claw(id: StringName, equip := true) -> void:
	if not has_claw(id):
		owned_claws.append(id)
	if equip:
		equip_claw(id)


func equip_claw(id: StringName) -> void:
	if has_claw(id):
		current_claw = id
		claw_changed.emit(current_claw)


func cycle_claw(direction: int) -> void:
	if owned_claws.size() <= 1:
		return
	var i := owned_claws.find(current_claw)
	equip_claw(owned_claws[wrapi(i + direction, 0, owned_claws.size())])


func claw_data() -> Dictionary:
	return CLAWS[current_claw]


# ------------------------------------------------------------------- zaino
func has_item(id: StringName) -> bool:
	return id in backpack


func unlock_item(id: StringName) -> void:
	if not has_item(id):
		backpack.append(id)
		backpack_changed.emit()


# -------------------------------------------------------------- messaggi
func say(text: String) -> void:
	message.emit(text)


# ------------------------------------------------------------ checkpoint
func set_checkpoint(scene_path: String, pos: Vector2) -> void:
	checkpoint_scene = scene_path
	checkpoint_position = pos


func clear_checkpoint() -> void:
	checkpoint_scene = ""


# -------------------------------------------------------- cambio scena
func go_to(scene_path: String) -> void:
	if _changing:
		return
	_changing = true
	var tw := create_tween()
	tw.tween_property(_fade_rect, "color:a", 1.0, 0.35)
	await tw.finished
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	tw = create_tween()
	tw.tween_property(_fade_rect, "color:a", 0.0, 0.35)
	_changing = false


func player_died() -> void:
	# Bozza: si ricomincia dal checkpoint con la vita piena, perdendo metà delle perle.
	add_pearls(-(pearls >> 1))
	restore_health()
	go_to(get_tree().current_scene.scene_file_path)


func new_game() -> void:
	pearls = 0
	max_health = 3
	health = 3
	owned_claws = [&"pinza"]
	current_claw = &"pinza"
	backpack = []
	clear_checkpoint()
	go_to(BEACH_SCENE)


# ---------------------------------------------------------------- input
func _setup_inputs() -> void:
	_add_action(&"move_left", [KEY_A, KEY_LEFT], [JOY_BUTTON_DPAD_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_add_action(&"move_right", [KEY_D, KEY_RIGHT], [JOY_BUTTON_DPAD_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_add_action(&"move_up", [KEY_W, KEY_UP], [JOY_BUTTON_DPAD_UP], JOY_AXIS_LEFT_Y, -1.0)
	_add_action(&"move_down", [KEY_S, KEY_DOWN], [JOY_BUTTON_DPAD_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	_add_action(&"jump", [KEY_SPACE, KEY_Z], [JOY_BUTTON_A])
	_add_action(&"attack", [KEY_J, KEY_X], [JOY_BUTTON_X])
	_add_action(&"dash", [KEY_K, KEY_C, KEY_SHIFT], [JOY_BUTTON_RIGHT_SHOULDER])
	_add_action(&"claw_prev", [KEY_Q], [JOY_BUTTON_LEFT_SHOULDER])
	_add_action(&"claw_next", [KEY_E], [JOY_BUTTON_Y])
	_add_action(&"interact", [KEY_W, KEY_UP], [JOY_BUTTON_B])
	_add_action(&"restart", [KEY_R], [JOY_BUTTON_BACK])
	_add_action(&"pause", [KEY_ESCAPE, KEY_P], [JOY_BUTTON_START])


func _add_action(action: StringName, keys: Array, buttons: Array, axis := -1, axis_value := 0.0) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.4)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
	for b in buttons:
		var jb := InputEventJoypadButton.new()
		jb.button_index = b
		InputMap.action_add_event(action, jb)
	if axis >= 0:
		var jm := InputEventJoypadMotion.new()
		jm.axis = axis
		jm.axis_value = axis_value
		InputMap.action_add_event(action, jm)
