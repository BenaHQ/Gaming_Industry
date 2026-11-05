extends Enemy
## Piranha: pattuglia e, se vede Granchietto davanti a sé alla stessa altezza,
## parte alla carica.

@export var patrol_distance := 48.0
@export var speed := 30.0
@export var charge_speed := 120.0
@export var sight_range := 96.0

enum State { PATROL, CHARGE, REST }

var state := State.PATROL
var _dir := 1.0
var _state_timer := 0.0


func _move(delta: float) -> void:
	_state_timer -= delta
	match state:
		State.PATROL:
			position.x += _dir * speed * delta
			if absf(position.x - start_position.x) > patrol_distance:
				_dir = -signf(position.x - start_position.x)
			_look_for_player()
		State.CHARGE:
			position.x += _dir * charge_speed * delta
			if _state_timer <= 0.0:
				state = State.REST
				_state_timer = 0.8
		State.REST:
			if _state_timer <= 0.0:
				state = State.PATROL
				start_position.x = position.x
	position.y = lerpf(position.y, start_position.y, 2.0 * delta)
	sprite.flip_h = _dir < 0.0
	sprite.frame = 1 if state == State.CHARGE or int(time * 4.0) % 4 == 0 else 0


func _look_for_player() -> void:
	var player := facing_player()
	if player == null:
		return
	var to := player.global_position - global_position
	if absf(to.y) < 16.0 and absf(to.x) < sight_range and signf(to.x) == _dir:
		state = State.CHARGE
		_state_timer = 0.7
