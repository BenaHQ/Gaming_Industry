extends Area2D
class_name Enemy
## Base per tutti i nemici marini. I nemici sono Area2D mosse via codice
## (nuotano, quindi niente gravità). Le sottoclassi implementano _move().

const PEARL_SCENE := preload("res://scenes/objects/pearl.tscn")

@export var max_hp := 1
@export var contact_damage := 1
@export var pearl_drop := 1

var hp := 1
var start_position := Vector2.ZERO
var time := 0.0

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	hp = max_hp
	start_position = position
	add_to_group(&"enemies")
	collision_layer = 4   # layer 3 "nemici"
	collision_mask = 2    # layer 2 "giocatore"


func _physics_process(delta: float) -> void:
	time += delta
	_move(delta)
	for body in get_overlapping_bodies():
		if body is Player:
			body.on_enemy_contact(self)


## Da sovrascrivere nelle sottoclassi.
func _move(_delta: float) -> void:
	pass


func can_be_stomped() -> bool:
	return true


func can_be_hit(_claw: StringName) -> bool:
	return true


func take_hit(damage: int, from_position: Vector2, claw: StringName) -> void:
	if not can_be_hit(claw):
		_clink()
		return
	hp -= damage
	var tw := create_tween()
	sprite.modulate = Color(3, 3, 3)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	position.x += signf(global_position.x - from_position.x) * 6.0
	if hp <= 0:
		die()


func _clink() -> void:
	var tw := create_tween()
	tw.tween_property(sprite, "position:x", 2.0, 0.04)
	tw.tween_property(sprite, "position:x", -2.0, 0.04)
	tw.tween_property(sprite, "position:x", 0.0, 0.04)


func die() -> void:
	set_physics_process(false)
	set_deferred(&"monitoring", false)
	for i in pearl_drop:
		var pearl := PEARL_SCENE.instantiate()
		get_parent().add_child(pearl)
		pearl.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 2))
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.4, 0.2), 0.15)
	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.tween_callback(queue_free)


func facing_player() -> Player:
	return get_tree().get_first_node_in_group(&"player") as Player
