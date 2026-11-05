extends Area2D
## Perla: la valuta del gioco (si spende dalla Tartaruga mercante).

@export var value := 1

var _t := randf() * TAU
var _base_y := 0.0


func _ready() -> void:
	collision_layer = 8   # layer 4 "oggetti"
	collision_mask = 2
	_base_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_t += delta * 3.0
	position.y = _base_y + sin(_t) * 1.5


func _on_body_entered(body: Node) -> void:
	if body is Player:
		GameState.add_pearls(value)
		set_deferred(&"monitoring", false)
		var tw := create_tween()
		tw.tween_property(self, "position:y", position.y - 10.0, 0.2)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
		tw.tween_callback(queue_free)
