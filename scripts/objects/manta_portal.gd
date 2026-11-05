extends Area2D
## Manta: il mezzo di trasporto. Premendo SU ci sali e vai al livello indicato.

@export_file("*.tscn") var target_scene := "res://scenes/levels/level_01_reef.tscn"
@export var prompt := "Manta: premi SU per salire e immergerti!"

var _player_near := false
var _t := 0.0


func _ready() -> void:
	collision_layer = 8
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body is Player:
		_player_near = true
		GameState.say(prompt)


func _on_body_exited(body: Node) -> void:
	if body is Player:
		_player_near = false


func _process(delta: float) -> void:
	_t += delta
	$Sprite.position.y = sin(_t * 2.0) * 2.0
	if _player_near and Input.is_action_just_pressed(&"interact"):
		_player_near = false
		GameState.clear_checkpoint()
		GameState.go_to(target_scene)
