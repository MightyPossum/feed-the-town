extends TileMap
var previous_tile_coords = null
var selected_tile = null
var tile_rotated = 0

var mouse_position = null
var local_mouse_position = null
var tile_coords = null
var map_size = null

var mouse_control = true

enum TileRotation {
	ROTATE_0 = 0,
	ROTATE_90 = TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_180 = TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_FLIP_H,
	ROTATE_270 = TileSetAtlasSource.TRANSFORM_FLIP_V | TileSetAtlasSource.TRANSFORM_TRANSPOSE,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if selected_tile == null:
		select_tile(4)
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if !mouse_control:
		tile_coords = Vector2i(10,10)
		set_cell(3, tile_coords, 0, Vector2i(0,1))
	pass # Replace with function body.
	
func _process(delta):	
	
	if Input.is_action_just_released("select_1"):
		select_tile(1)
		clear_map_layer(2)
		set_cell(2, tile_coords, 0, selected_tile, tile_rotation())
	if Input.is_action_just_released("select_2"):
		select_tile(2)
		clear_map_layer(2)
		set_cell(2, tile_coords, 0, selected_tile, tile_rotation())
	if Input.is_action_just_released("select_3"):
		select_tile(3)
		clear_map_layer(2)
		set_cell(2, tile_coords, 0, selected_tile, tile_rotation())
	if Input.is_action_just_released("select_4"):
		select_tile(4)
		clear_map_layer(2)
		set_cell(2, tile_coords, 0, selected_tile, tile_rotation())
	if Input.is_action_just_released("rotate_tile"):
		rotate_tile()
		clear_map_layer(2)
		set_cell(2, tile_coords, 0, selected_tile, tile_rotation())
	if Input.is_action_just_released("place_tile"):
		place_tile(selected_tile)
		
	if !mouse_control:	
		if Input.is_action_just_pressed("up"):
			tile_coords.y -= 1
			clear_map_layer(3)
			clear_map_layer(2)
			set_cell(3, tile_coords, 0, Vector2i(0,1))
		if Input.is_action_just_pressed("down"):
			tile_coords.y += 1
			clear_map_layer(3)
			clear_map_layer(2)
			set_cell(3, tile_coords, 0, Vector2i(0,1))
		if Input.is_action_just_pressed("left"):
			tile_coords.x -= 1
			clear_map_layer(3)
			clear_map_layer(2)
			set_cell(3, tile_coords, 0, Vector2i(0,1))
		if Input.is_action_just_pressed("right"):
			tile_coords.x += 1
			clear_map_layer(3)
			clear_map_layer(2)
			set_cell(3, tile_coords, 0, Vector2i(0,1))


func _input(event):
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
				if previous_tile_coords and previous_tile_coords != tile_coords:
					set_cell(3,previous_tile_coords, -1)
					set_cell(2,previous_tile_coords, -1)
				set_cell(3, tile_coords, 0, Vector2i(0,1))
				set_cell(2, tile_coords, 0, selected_tile, tile_rotation())
			
				previous_tile_coords = tile_coords
			
		elif previous_tile_coords:
				set_cell(3,previous_tile_coords, -1)
				set_cell(2,previous_tile_coords, -1)
				previous_tile_coords = null
	
	else:
		set_cell(2, tile_coords, 0, selected_tile, tile_rotation())
		
				
func select_tile(tile : int):
	match tile:
		1:
			selected_tile = Vector2i(0,13)
		2:
			selected_tile = Vector2i(0,17)
		3:
			selected_tile = Vector2i(0,19)
		4:
			selected_tile = Vector2i(0,21)

func place_tile(tile : Vector2i):
	if tile_rotated:
			set_cell(1, tile_coords, 0, selected_tile, tile_rotation())
	else:
		set_cell(1, tile_coords, 0, selected_tile)
	pass

func rotate_tile():
	tile_rotated = (tile_rotated + 1) % 4
	set_cell(2, tile_coords, 0, selected_tile, tile_rotation())	
	
func tile_rotation():
	
	match tile_rotated:
		0:
			return TileRotation.ROTATE_0
		1:
			return TileRotation.ROTATE_90
		2:
			return TileRotation.ROTATE_180
		3:
			return TileRotation.ROTATE_270
func clear_map_layer(layer: int):
	var used_rect = get_used_rect()
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			set_cell(layer, Vector2i(x, y), -1)
	pass