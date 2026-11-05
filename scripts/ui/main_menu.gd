extends Control
## Schermata del titolo.

var _t := 0.0

@onready var crab: TextureRect = $Crab


func _ready() -> void:
	$VBox/Play.pressed.connect(GameState.new_game)
	$VBox/Quit.pressed.connect(get_tree().quit)
	$VBox/Play.grab_focus()


func _process(delta: float) -> void:
	_t += delta
	crab.position.y = 70.0 + sin(_t * 3.0) * 3.0
