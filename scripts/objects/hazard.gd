extends Area2D
## Ostacolo che fa danno al contatto (es. riccio di mare).

@export var damage := 1


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is Player:
			body.take_damage(damage, global_position)
