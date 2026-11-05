extends Area2D
## Tesoro di fine livello: una conchiglia che si apre.

@export var reward := 10
@export var next_scene := "res://scenes/levels/beach_base.tscn"

var opened := false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if opened or not (body is Player):
		return
	opened = true
	$Sprite.frame = 1
	GameState.add_pearls(reward)
	GameState.say("Hai trovato il tesoro della conchiglia! +%d perle" % reward)
	GameState.clear_checkpoint()
	await get_tree().create_timer(2.5).timeout
	GameState.go_to(next_scene)
