extends Enemy
## Medusa: fluttua su e giù. Punge: non si può pestare, va colpita con la chela.

@export var bob_height := 24.0
@export var bob_speed := 1.6
@export var drift := 10.0


func _move(_delta: float) -> void:
	position.y = start_position.y + sin(time * bob_speed) * bob_height
	position.x = start_position.x + sin(time * bob_speed * 0.5) * drift
	sprite.frame = int(time * 3.0) % 2


func can_be_stomped() -> bool:
	return false
