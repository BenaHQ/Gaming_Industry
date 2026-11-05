extends Area2D
## Cavalluccio marino: l'aiutante. Fa da checkpoint e dà consigli.

@export_multiline var hint := "Ciao Granchietto! Se finisci le forze, ripartirai da qui."

## Impostato dal livello che lo crea.
var level_path := ""
var active := false


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	if GameState.checkpoint_scene == level_path and GameState.checkpoint_position.distance_to(position) < 4.0:
		_activate(false)


func _on_body_entered(body: Node) -> void:
	if body is Player and not active:
		_activate(true)


func _activate(announce: bool) -> void:
	active = true
	$Sprite.frame = 1
	GameState.set_checkpoint(level_path, position)
	if announce:
		GameState.restore_health()
		GameState.say("Cavalluccio: " + hint)
