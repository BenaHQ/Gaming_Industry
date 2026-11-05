extends Enemy
## Pesce palla: pattuglia lentamente e ogni tanto si gonfia.
## Gonfio è coperto di spine: non si può pestare né colpire,
## tranne con la Chela Martello che lo sgonfia di colpo.

@export var patrol_distance := 32.0
@export var speed := 14.0
@export var puff_every := 2.6
@export var puff_duration := 1.4

var puffed := false
var _dir := 1.0
var _puff_timer := 0.0

@onready var shape: CircleShape2D = $CollisionShape2D.shape


func _ready() -> void:
	super()
	_puff_timer = puff_every * randf_range(0.5, 1.0)


func _move(delta: float) -> void:
	_puff_timer -= delta
	if _puff_timer <= 0.0:
		_set_puffed(not puffed)
		_puff_timer = puff_duration if puffed else puff_every
	if not puffed:
		position.x += _dir * speed * delta
		if absf(position.x - start_position.x) > patrol_distance:
			_dir = -signf(position.x - start_position.x)
	position.y = start_position.y + sin(time * 2.0) * 2.0
	sprite.flip_h = _dir < 0.0


func _set_puffed(value: bool) -> void:
	puffed = value
	sprite.frame = 1 if puffed else 0
	shape.radius = 10.0 if puffed else 6.0


func can_be_stomped() -> bool:
	return not puffed


func can_be_hit(claw: StringName) -> bool:
	return not puffed or GameState.CLAWS.get(claw, {}).get("breaks_rock", false)
