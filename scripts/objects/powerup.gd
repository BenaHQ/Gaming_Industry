extends Area2D
## Potenziamento dentro una bolla: sblocca una chela o un oggetto dello zaino.
## kind = "claw" oppure "backpack"; item_id = chiave in GameState.CLAWS / BACKPACK.

@export_enum("claw", "backpack") var kind := "backpack"
@export var item_id: StringName = &"dash"

const HINTS := {
	&"dash": "Getto a reazione! Premi K / Shift per scattare (anche in aria).",
	&"deltaplano": "Deltaplano! Tieni premuto SALTO mentre cadi per planare.",
	&"tenaglia": "Chela Tenaglia: colpisce più lontano. Q / E per cambiare chela.",
	&"martello": "Chela Martello: rompe le rocce crepate e sgonfia i pesci palla!",
}

var _t := 0.0

@onready var icon: Sprite2D = $Icon


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	if _already_owned():
		queue_free()
		return
	icon.texture = (GameState.CLAWS if kind == "claw" else GameState.BACKPACK)[item_id]["texture"]
	body_entered.connect(_on_body_entered)


func _already_owned() -> bool:
	return GameState.has_claw(item_id) if kind == "claw" else GameState.has_item(item_id)


func _process(delta: float) -> void:
	_t += delta
	$Bubble.scale = Vector2.ONE * (1.0 + sin(_t * 4.0) * 0.06)
	icon.position.y = sin(_t * 2.0) * 1.5


func _on_body_entered(body: Node) -> void:
	if not (body is Player):
		return
	if kind == "claw":
		GameState.unlock_claw(item_id)
	else:
		GameState.unlock_item(item_id)
	GameState.say(HINTS.get(item_id, "Nuovo potenziamento!"))
	set_deferred(&"monitoring", false)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.8, 1.8), 0.2)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(queue_free)
