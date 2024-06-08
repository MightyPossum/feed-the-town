extends TileMap


@onready var sfx_player = $SFX
@onready var gui_rect = $Control/NinePatchRect
@onready var gui_coin = $Control/HBoxContainer/Coin
@export var gui_rect_texture = []
@export var gui_coin_texture = []
@export var SFX = []
var previous_tile_coords = null
var selected_tile : Array = []
var tile_rotated = 0
var color = 0

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

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if selected_tile.size() <= 0:
		select_tile(4)
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	if !mouse_control:
		tile_coords = Vector2i(34,21)
		set_cell(selector_layer, tile_coords, color, Vector2i(0,1))
	
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
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.ROAD,Vector2i(0,13),tile_rotated, Vector2i(0,0)]
		2:
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.TURN,Vector2i(0,17),tile_rotated, Vector2i(0,0)]
		3:
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.CROSS,Vector2i(0,19),tile_rotated, Vector2i(0,0)]
		4:
			selected_tile = [GLOBALVARIABLES.CONSTRUCTABLETILE.BULLDOZER,Vector2i(0,21),tile_rotated, Vector2i(0,0)]
			bulldozer = true

func place_tile():
	
	if not tile_coords:
		return
	print(tile_coords)
	if bulldozer:
		sfx_player.stream = SFX[0]
		sfx_player.play()
		set_cell(built_layer, tile_coords, -1)
	else:
		if get_cell_tile_data(built_layer, tile_coords) != null or get_cell_tile_data(base_layer, tile_coords) != null:
			return	
		sfx_player.stream = SFX[1]
		sfx_player.play()
		set_cell(built_layer, tile_coords, color, selected_tile[3], tile_rotation())

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
	set_cell(construct_layer, tile_coords, color, selected_tile[1], tile_rotation())
	set_cell(selector_layer, tile_coords, color, Vector2i(0,1))
	
func change_color_scheme():
	color = (color + 1) % 8
	
	var used_rect = get_used_rect()
	
	gui_rect.texture = gui_rect_texture[color]
	gui_coin.texture = gui_coin_texture[color]

	for layer in [background_layer, base_layer, built_layer]:
		for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
			for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
				var tile = get_cell_tile_data(layer, Vector2i(x, y))
				if tile != null:
					set_cell(layer, Vector2i(x, y), color, get_cell_atlas_coords(layer, Vector2i(x,y)), get_cell_alternative_tile(layer, Vector2i(x,y)))
	pass
