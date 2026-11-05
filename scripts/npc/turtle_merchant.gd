extends Area2D
## Tartaruga mercante: alla base sulla spiaggia vende chele in cambio di perle.
## Premi SU vicino a lei per vedere l'offerta, ripremi per comprare.

var _player_near := false
var _offer: StringName = &""


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player_near = true
		GameState.say("Tartaruga: Benvenuto nella mia bottega! (SU per parlare)")


func _on_body_exited(body: Node) -> void:
	if body is Player:
		_player_near = false
		_offer = &""


func _process(_delta: float) -> void:
	if not _player_near or not Input.is_action_just_pressed(&"interact"):
		return
	if _offer == &"":
		_offer = _next_offer()
		if _offer == &"":
			GameState.say("Tartaruga: Hai già tutte le mie chele. Torna quando avrò merce nuova!")
			return
		var data: Dictionary = GameState.CLAWS[_offer]
		GameState.say("Tartaruga: %s per %d perle. SU di nuovo per comprare." % [data["name"], data["price"]])
	else:
		var data: Dictionary = GameState.CLAWS[_offer]
		if GameState.spend_pearls(data["price"]):
			GameState.unlock_claw(_offer)
			GameState.say("Tartaruga: Affare fatto! Equipaggiata: %s." % data["name"])
		else:
			GameState.say("Tartaruga: Ti servono %d perle, ne hai %d." % [data["price"], GameState.pearls])
		_offer = &""



func _next_offer() -> StringName:
	for id in GameState.CLAWS:
		if not GameState.has_claw(id):
			return id
	return &""
