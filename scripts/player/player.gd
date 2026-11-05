extends CharacterBody2D
class_name Player
## Granchietto: il protagonista.
## - Movimento platform con coyote time e jump buffer.
## - Sott'acqua: gravità ridotta + "bracciate" (salti extra in acqua).
## - Chele intercambiabili (Q / E) con danno, portata e abilità diverse.
## - Zaino: Dash (getto a reazione) e Deltaplano (tieni premuto salto in caduta).

signal died

## Impostato dal livello: cambia la fisica fra spiaggia e fondale.
@export var underwater := true

const PHYSICS := {
	false: {"gravity": 900.0, "max_fall": 320.0, "jump": -290.0, "speed": 95.0, "accel": 900.0, "friction": 1100.0, "dash": 260.0},
	true: {"gravity": 380.0, "max_fall": 110.0, "jump": -190.0, "speed": 75.0, "accel": 500.0, "friction": 450.0, "dash": 210.0},
}
const COYOTE_TIME := 0.1
const JUMP_BUFFER := 0.12
const SWIM_STROKES := 2            # salti extra disponibili sott'acqua
const DASH_TIME := 0.16
const DASH_COOLDOWN := 0.5
const GLIDE_FALL_SPEED := 28.0
const ATTACK_TIME := 0.18
const ATTACK_COOLDOWN := 0.28
const INVULNERABLE_TIME := 1.0
const STOMP_BOUNCE := -200.0

var facing := 1
var _coyote := 0.0
var _jump_buffer := 0.0
var _strokes_left := 0
var _dash_timer := 0.0
var _dash_cooldown := 0.0
var _can_air_dash := true
var _attack_timer := 0.0
var _attack_cooldown := 0.0
var _invulnerable := 0.0
var _anim_time := 0.0
var _gliding := false
var _dead := false

@onready var sprite: Sprite2D = $Sprite
@onready var claw: Sprite2D = $Claw
@onready var glider: Sprite2D = $Glider
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	add_to_group(&"player")
	GameState.claw_changed.connect(_on_claw_changed)
	_on_claw_changed(GameState.current_claw)


func p(key: String) -> float:
	return PHYSICS[underwater][key]


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_tick_timers(delta)
	_handle_claw_input()

	var dir := Input.get_axis(&"move_left", &"move_right")
	if dir != 0.0 and _attack_timer <= 0.0:
		facing = 1 if dir > 0.0 else -1

	if is_on_floor():
		_coyote = COYOTE_TIME
		_strokes_left = SWIM_STROKES
		_can_air_dash = true

	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer = JUMP_BUFFER

	if _dash_timer > 0.0:
		velocity = Vector2(facing * p("dash"), 0.0)
	else:
		_apply_gravity(delta)
		_apply_horizontal(dir, delta)
		_try_jump()
		_try_dash()

	if Input.is_action_just_pressed(&"attack"):
		_try_attack()

	move_and_slide()
	_update_visuals(delta, dir)


func _tick_timers(delta: float) -> void:
	_coyote -= delta
	_jump_buffer -= delta
	_dash_timer -= delta
	_dash_cooldown -= delta
	_attack_timer -= delta
	_attack_cooldown -= delta
	_invulnerable -= delta


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		_gliding = false
		return
	_gliding = GameState.has_item(&"deltaplano") and Input.is_action_pressed(&"jump") and velocity.y > 0.0
	var max_fall := GLIDE_FALL_SPEED if _gliding else p("max_fall")
	var g := p("gravity")
	# Salto a intensità variabile: rilasciando presto si sale meno.
	if velocity.y < 0.0 and not Input.is_action_pressed(&"jump"):
		g *= 2.0
	velocity.y = minf(velocity.y + g * delta, max_fall)


func _apply_horizontal(dir: float, delta: float) -> void:
	var speed := p("speed") * (1.3 if _gliding else 1.0)
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * speed, p("accel") * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, p("friction") * delta)


func _try_jump() -> void:
	if _jump_buffer <= 0.0:
		return
	if _coyote > 0.0:
		velocity.y = p("jump")
	elif underwater and _strokes_left > 0:
		# Bracciata: un piccolo salto extra in acqua.
		_strokes_left -= 1
		velocity.y = p("jump") * 0.8
		_spawn_bubbles(3)
	else:
		return
	_jump_buffer = 0.0
	_coyote = 0.0


func _try_dash() -> void:
	if not GameState.has_item(&"dash") or not Input.is_action_just_pressed(&"dash"):
		return
	if _dash_cooldown > 0.0 or (not is_on_floor() and not _can_air_dash):
		return
	_dash_timer = DASH_TIME
	_dash_cooldown = DASH_COOLDOWN
	if not is_on_floor():
		_can_air_dash = false
	_spawn_bubbles(5)


# ---------------------------------------------------------------- chele
func _handle_claw_input() -> void:
	if Input.is_action_just_pressed(&"claw_next"):
		GameState.cycle_claw(1)
	elif Input.is_action_just_pressed(&"claw_prev"):
		GameState.cycle_claw(-1)


func _on_claw_changed(id: StringName) -> void:
	var data: Dictionary = GameState.CLAWS[id]
	claw.texture = data["texture"]
	var shape := hitbox_shape.shape as RectangleShape2D
	shape.size = Vector2(data["reach"] + 6.0, 14.0)


func _try_attack() -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_timer = ATTACK_TIME
	_attack_cooldown = ATTACK_COOLDOWN
	var data := GameState.claw_data()
	var reach: float = data["reach"]
	hitbox.position = Vector2(facing * (6.0 + reach * 0.5), 1.0)
	# Animazione della chela che scatta in avanti.
	var tw := create_tween()
	tw.tween_property(claw, "position:x", facing * (8.0 + reach), ATTACK_TIME * 0.4)
	tw.tween_property(claw, "position:x", facing * 8.0, ATTACK_TIME * 0.6)
	# Aspetta un frame di fisica così l'Area2D aggiorna le sovrapposizioni.
	await get_tree().physics_frame
	var targets: Array = []
	targets.append_array(hitbox.get_overlapping_areas())
	targets.append_array(hitbox.get_overlapping_bodies())
	for target in targets:
		if target.has_method(&"take_hit"):
			target.take_hit(data["damage"], global_position, GameState.current_claw)


# ---------------------------------------------------------------- danni
func on_enemy_contact(enemy: Node2D) -> void:
	if _dead:
		return
	var from_above := velocity.y > 0.0 and global_position.y < enemy.global_position.y - 4.0
	if from_above and enemy.has_method(&"can_be_stomped") and enemy.can_be_stomped():
		enemy.take_hit(1, global_position, &"stomp")
		velocity.y = STOMP_BOUNCE
		_strokes_left = SWIM_STROKES
		return
	var dmg: int = enemy.get(&"contact_damage") if "contact_damage" in enemy else 1
	take_damage(dmg, enemy.global_position)


func take_damage(amount: int, from_position: Vector2) -> void:
	if _invulnerable > 0.0 or _dead or _dash_timer > 0.0:
		return
	_invulnerable = INVULNERABLE_TIME
	GameState.set_health(GameState.health - amount)
	var away := signf(global_position.x - from_position.x)
	if away == 0.0:
		away = -facing
	velocity = Vector2(away * 160.0, -150.0)
	if GameState.health <= 0:
		_die()


func _die() -> void:
	_dead = true
	died.emit()
	var tw := create_tween()
	tw.tween_property(self, "rotation", PI, 0.4)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
	await tw.finished
	GameState.player_died()


# -------------------------------------------------------------- grafica
func _update_visuals(delta: float, dir: float) -> void:
	_anim_time += delta
	sprite.flip_h = facing < 0
	claw.flip_h = facing < 0
	if _attack_timer <= 0.0:
		claw.position = Vector2(facing * 8.0, 1.0 + (sin(_anim_time * 6.0) * 0.6 if dir == 0.0 else 0.0))
	if not is_on_floor():
		sprite.frame = 3
	elif absf(velocity.x) > 5.0:
		sprite.frame = 1 + int(_anim_time * 10.0) % 2
	else:
		sprite.frame = 0
	glider.visible = _gliding
	modulate.a = 0.4 if (_invulnerable > 0.0 and int(_invulnerable * 20.0) % 2 == 0) else 1.0


func _spawn_bubbles(amount: int) -> void:
	if not underwater:
		return
	var parts := CPUParticles2D.new()
	parts.one_shot = true
	parts.amount = amount
	parts.lifetime = 0.8
	parts.explosiveness = 0.9
	parts.direction = Vector2(0, -1)
	parts.spread = 60.0
	parts.gravity = Vector2(0, -60)
	parts.initial_velocity_min = 10.0
	parts.initial_velocity_max = 30.0
	parts.scale_amount_min = 1.0
	parts.scale_amount_max = 2.0
	parts.color = Color(0.8, 0.95, 1.0, 0.8)
	get_parent().add_child(parts)
	parts.global_position = global_position + Vector2(0, 6)
	parts.emitting = true
	parts.finished.connect(parts.queue_free)


func set_camera_limits(rect: Rect2i) -> void:
	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y
	camera.reset_smoothing()
