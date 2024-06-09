extends TileMap


@onready var sfx_player = $SFX
@onready var gui_rect = $Control/MenuBar
@onready var gui_coin = $Control/HBox/Coin
@onready var score_text = $Control/HBox/Score

@export var gui_rect_texture = []
@export var gui_coin_texture = []
@export var SFX = []

@export var gui_color : Array[Color]

var previous_tile_coords = null
var selected_tile : Array = []
var tile_rotated = 0

var mouse_position = null
var local_mouse_position = null
var tile_coords = null
var map_size = null

var mouse_control = true
var bulldozer = false

var background_layer = 0
var base_layer = 1
var built_layer = 2
var construct_layer = 3
var selector_layer = 4

enum TileRotation {
	ROTATE_0 = 0,
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE,
}

var Tile_dictionary = {
	"straight_road": Vector2i(0,13),
	"bent_road": Vector2i(0,17),
	"cross_road": Vector2i(0,19),
	"bulldozer": Vector2i(0,21),
	"road_car": Vector2i(0,15),
	"turn_car": Vector2i(0,23),
	"cross_car": Vector2i(0,25)
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if selected_tile.size() <= 0:
		select_tile(4)
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	if !mouse_control:
		tile_coords = Vector2i(34,21)
		set_cell(selector_layer, tile_coords, GLOBALVARIABLES.color, Vector2i(0,1))
	
func _process(_delta):	
	clear_map_layer(selector_layer)
	clear_map_layer(construct_layer)
	
	if Input.is_action_just_released("select_1"):
		select_tile(1)
	if Input.is_action_just_released("select_2"):
		select_tile(2)
	if Input.is_action_just_released("select_3"):
		select_tile(3)
	if Input.is_action_just_released("select_4"):
		select_tile(4)
	if Input.is_action_just_released("rotate_tile"):
		rotate_tile()
	if Input.is_action_just_released("place_tile"):
		place_tile()
		
	if Input.is_action_just_released("change_color"):
		change_color_scheme()
		
	if !mouse_control:	
		if Input.is_action_just_pressed("up"):
			tile_coords.y -= 1
		if Input.is_action_just_pressed("down"):
			tile_coords.y += 1
		if Input.is_action_just_pressed("left"):
			tile_coords.x -= 1
		if Input.is_action_just_pressed("right"):
			tile_coords.x += 1
		
	if tile_coords != null:
		draw_tile()


func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if event is InputEventMouseMotion and mouse_control:
		mouse_position = event.position
		local_mouse_position = to_local(mouse_position)
		tile_coords = local_to_map(local_mouse_position)
		
		map_size = get_used_rect().size
		
		if tile_coords.x >= 0 and tile_coords.x < map_size.x and tile_coords.y >= 0 and tile_coords.y < map_size.y:
			
			var tile_center = map_to_local(tile_coords) + Vector2(0.5,0.5) * 16
			var distance_to_center = tile_center.distance_to(local_mouse_position)
			var center_treshold = 1 * 16
			
			if distance_to_center <= center_treshold:
				previous_tile_coords = tile_coords
			
		elif previous_tile_coords:
				previous_tile_coords = null
				
func select_tile(tile : int):
	bulldozer = false		
	match tile:
		1:
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.ROAD,Tile_dictionary["straight_road"],tile_rotated, Vector2i(0,0),0] # Straight Road
		2:
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.TURN,Tile_dictionary["bent_road"],tile_rotated, Vector2i(0,0),0] # Bent Road
		3:
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.CROSS,Tile_dictionary["cross_road"],tile_rotated, Vector2i(0,0),0] # Cross Road
		4:
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.BULLDOZER,Tile_dictionary["bulldozer"],tile_rotated, Vector2i(0,0),0] # Bulldozer
			bulldozer = true

func place_tile():
	print(tile_coords)
	if not tile_coords:
		return
	if bulldozer:
		if GLOBALVARIABLES.money >= 100:
			
			update_money(-100)
			sfx_player.stream = SFX[0]
			sfx_player.play()
			set_cell(built_layer, tile_coords, -1)
	else:
		var price = 0
		if selected_tile[1] == Vector2i(0,13):
				price = 100
		if selected_tile[1] == Vector2i(0,17):
				price = 150
		if selected_tile[1] == Vector2i(0,19):
				price = 500
		
		if GLOBALVARIABLES.money >= price:
			update_money(-price)
			if get_cell_tile_data(built_layer, tile_coords) != null or get_cell_tile_data(base_layer, tile_coords) != null:
				return	
			sfx_player.stream = SFX[1]
			sfx_player.play()
			selected_tile[4] = tile_rotation()
			set_cell(built_layer, tile_coords, GLOBALVARIABLES.color, selected_tile[1], selected_tile[4])

	selected_tile[3] = tile_coords
	%PathHandler.calculate_paths(selected_tile)
	

func rotate_tile():
	tile_rotated = (tile_rotated + 1) % 4
	selected_tile[2] = tile_rotated
	
func tile_rotation() -> int:

	var current_rotation = 0
	
	match tile_rotated:
		0:
			current_rotation = TileRotation.ROTATE_0
		1:
			current_rotation = TileRotation.ROTATE_90
		2:
			current_rotation = TileRotation.ROTATE_180
		3:
			current_rotation = TileRotation.ROTATE_270

	return current_rotation
func clear_map_layer(layer: int):
	var used_rect = get_used_rect()
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			set_cell(layer, Vector2i(x, y), -1)

func draw_tile():
	set_cell(construct_layer, tile_coords, GLOBALVARIABLES.color, selected_tile[1], tile_rotation())
	set_cell(selector_layer, tile_coords, GLOBALVARIABLES.color, Vector2i(0,1))
	
func change_color_scheme():
	GLOBALVARIABLES.color = (GLOBALVARIABLES.color + 1) % 8
	var used_rect = get_used_rect()
	
	gui_rect.texture = gui_rect_texture[GLOBALVARIABLES.color]
	gui_coin.texture = gui_coin_texture[GLOBALVARIABLES.color]
	score_text.add_theme_color_override("font_color", Color(gui_color[GLOBALVARIABLES.color]))

	for layer in [background_layer, base_layer, built_layer]:
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
				var tile = get_cell_tile_data(layer, Vector2i(x, y))
				if tile != null:
					set_cell(layer, Vector2i(x, y), GLOBALVARIABLES.color, get_cell_atlas_coords(layer, Vector2i(x,y)), get_cell_alternative_tile(layer, Vector2i(x,y)))
	pass

func update_money(amount):
	GLOBALVARIABLES.money += amount
	if GLOBALVARIABLES.money <= 0:
		get_tree().quit()
	%Score.text = str(GLOBALVARIABLES.money)
