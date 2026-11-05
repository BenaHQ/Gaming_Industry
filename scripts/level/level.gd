extends Node2D
class_name Level
## Costruisce un livello a partire da una mappa ASCII (proprietà "map"
## modificabile dall'Inspector). Comodo per prototipare: si disegna il
## livello con i caratteri e si preme Play. In futuro si potrà passare a
## TileMapLayer dipinte a mano nell'editor.
##
## LEGENDA
##   #  roccia            =  sabbia            X  roccia crepata (Martello)
##   ^  riccio di mare    c  corallo (decor)   k  alga (decor)
##   S  partenza          o  perla             T  tesoro conchiglia (fine)
##   p  pesce palla       m  medusa            r  piranha
##   D  zaino: dash       G  zaino: deltaplano
##   L  chela tenaglia    H  chela martello
##   C  cavalluccio (checkpoint)  M  tartaruga mercante   A  manta (porta al livello)

const TILE := 16
const SOLID := {"#": Vector2i(0, 0), "=": Vector2i(2, 0)}
const SOLID_TOP := {"#": Vector2i(1, 0), "=": Vector2i(3, 0)}
const DECOR := {"c": Vector2i(4, 0), "k": Vector2i(5, 0)}

const SCENES := {
	"o": preload("res://scenes/objects/pearl.tscn"),
	"p": preload("res://scenes/enemies/pufferfish.tscn"),
	"m": preload("res://scenes/enemies/jellyfish.tscn"),
	"r": preload("res://scenes/enemies/piranha.tscn"),
	"X": preload("res://scenes/objects/breakable_rock.tscn"),
	"^": preload("res://scenes/objects/urchin.tscn"),
	"T": preload("res://scenes/objects/treasure_shell.tscn"),
	"C": preload("res://scenes/objects/seahorse_checkpoint.tscn"),
	"M": preload("res://scenes/npc/turtle_merchant.tscn"),
	"A": preload("res://scenes/objects/manta_portal.tscn"),
}
const POWERUP_SCENE := preload("res://scenes/objects/powerup.tscn")
const POWERUPS := {
	"D": ["backpack", &"dash"],
	"G": ["backpack", &"deltaplano"],
	"L": ["claw", &"tenaglia"],
	"H": ["claw", &"martello"],
}
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

@export var level_name := "Livello"
@export var underwater := true
@export_file("*.tscn") var next_scene := "res://scenes/levels/beach_base.tscn"
@export var top_color := Color(0.15, 0.45, 0.7)
@export var bottom_color := Color(0.02, 0.08, 0.2)
@export_multiline var map := ""

var tiles: TileMapLayer
var player: Player
var size_in_tiles := Vector2i.ZERO
var spawn_point := Vector2.ZERO


func _ready() -> void:
	_build_background()
	tiles = TileMapLayer.new()
	tiles.name = "Tiles"
	tiles.tile_set = _make_tileset()
	add_child(tiles)
	var entities := Node2D.new()
	entities.name = "Entities"
	add_child(entities)
	spawn_point = _parse_map(entities)
	_spawn_player(spawn_point)
	add_child(HUD_SCENE.instantiate())
	if underwater:
		_add_ambient_bubbles()
	GameState.say(level_name)


# ------------------------------------------------------------- tileset
func _make_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(TILE, TILE)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 0)
	var src := TileSetAtlasSource.new()
	src.texture = preload("res://assets/sprites/tiles.png")
	src.texture_region_size = Vector2i(TILE, TILE)
	ts.add_source(src, 0)
	var h := TILE / 2.0
	var square := PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
	for x in 6:
		var coords := Vector2i(x, 0)
		src.create_tile(coords)
		if x <= 3:  # roccia e sabbia sono solide, corallo e alga no
			var td := src.get_tile_data(coords, 0)
			td.add_collision_polygon(0)
			td.set_collision_polygon_points(0, 0, square)
	return ts


# ------------------------------------------------------------- mappa
func _parse_map(entities: Node2D) -> Vector2:
	var lines := map.replace("\r", "").strip_edges(false, true).split("\n")
	# Rimuove eventuali righe vuote iniziali.
	while lines.size() > 0 and lines[0].strip_edges() == "":
		lines.remove_at(0)
	var spawn := Vector2(TILE * 2, TILE * 2)
	var width := 0
	for y in lines.size():
		var line: String = lines[y]
		width = maxi(width, line.length())
		for x in line.length():
			var ch := line[x]
			var cell := Vector2i(x, y)
			var center := Vector2(x * TILE + TILE / 2.0, y * TILE + TILE / 2.0)
			if SOLID.has(ch):
				var above := lines[y - 1][x] if y > 0 and x < lines[y - 1].length() else " "
				var is_top := not SOLID.has(above) and above != "X"
				tiles.set_cell(cell, 0, SOLID_TOP[ch] if is_top else SOLID[ch])
			elif DECOR.has(ch):
				tiles.set_cell(cell, 0, DECOR[ch])
			elif ch == "S":
				spawn = center
			elif POWERUPS.has(ch):
				var pu := POWERUP_SCENE.instantiate()
				pu.kind = POWERUPS[ch][0]
				pu.item_id = POWERUPS[ch][1]
				pu.position = center
				entities.add_child(pu)
			elif SCENES.has(ch):
				var node: Node2D = SCENES[ch].instantiate()
				node.position = center
				if ch == "C":
					node.level_path = scene_file_path
				if ch == "T":
					node.next_scene = next_scene
				entities.add_child(node)
	size_in_tiles = Vector2i(width, lines.size())
	return spawn


func _spawn_player(spawn: Vector2) -> void:
	player = PLAYER_SCENE.instantiate()
	player.underwater = underwater
	if GameState.checkpoint_scene == scene_file_path:
		spawn = GameState.checkpoint_position
	player.position = spawn
	add_child(player)
	player.set_camera_limits(Rect2i(Vector2i.ZERO, size_in_tiles * TILE))


func _physics_process(_delta: float) -> void:
	# Caduto fuori dal livello.
	if player and is_instance_valid(player) and player.position.y > size_in_tiles.y * TILE + 64:
		player.take_damage(1, player.position)
		if GameState.health > 0:
			player.position = GameState.checkpoint_position if GameState.checkpoint_scene == scene_file_path else spawn_point
			player.velocity = Vector2.ZERO


# --------------------------------------------------------------- sfondo
func _build_background() -> void:
	var layer := CanvasLayer.new()
	layer.name = "Background"
	layer.layer = -10
	add_child(layer)
	var grad := Gradient.new()
	grad.set_color(0, top_color)
	grad.set_color(1, bottom_color)
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)
	tex.width = 8
	tex.height = 180
	var rect := TextureRect.new()
	rect.texture = tex
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(rect)
	if underwater:
		# Raggi di luce dall'alto.
		for i in 4:
			var ray := Polygon2D.new()
			var x := 40.0 + i * 80.0
			ray.polygon = PackedVector2Array([Vector2(x, 0), Vector2(x + 18, 0), Vector2(x - 20, 180), Vector2(x - 50, 180)])
			ray.color = Color(0.7, 0.9, 1.0, 0.06)
			layer.add_child(ray)
	else:
		var sun := Polygon2D.new()
		var pts := PackedVector2Array()
		for i in 16:
			pts.append(Vector2(260, 40) + Vector2.from_angle(i * TAU / 16.0) * 18.0)
		sun.polygon = pts
		sun.color = Color(1.0, 0.92, 0.55)
		layer.add_child(sun)


func _add_ambient_bubbles() -> void:
	var bubbles := CPUParticles2D.new()
	bubbles.name = "AmbientBubbles"
	bubbles.amount = 40
	bubbles.lifetime = 8.0
	bubbles.preprocess = 8.0
	bubbles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	bubbles.emission_rect_extents = Vector2(size_in_tiles.x * TILE / 2.0, 8)
	bubbles.position = Vector2(size_in_tiles.x * TILE / 2.0, size_in_tiles.y * TILE)
	bubbles.direction = Vector2(0, -1)
	bubbles.spread = 10.0
	bubbles.gravity = Vector2(0, -8)
	bubbles.initial_velocity_min = 10.0
	bubbles.initial_velocity_max = 25.0
	bubbles.scale_amount_min = 1.0
	bubbles.scale_amount_max = 2.5
	bubbles.color = Color(0.8, 0.95, 1.0, 0.35)
	bubbles.z_index = -1
	add_child(bubbles)
