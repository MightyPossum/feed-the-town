extends TileMap
var previous_tile_coords = null


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = event.position
		var local_mouse_position = to_local(mouse_position)
		var tile_coords = local_to_map(local_mouse_position)
		
		var map_size = get_used_rect().size
		
		if tile_coords .x >= 0 and tile_coords.x < map_size.x and tile_coords.y >= 0 and tile_coords.y < map_size.y:
			
			var tile_center = map_to_local(tile_coords) + Vector2(0.5,0.5) * 16
			var distance_to_center = tile_center.distance_to(local_mouse_position)
			var center_treshold = 0.9 * 16
			
			if distance_to_center <= center_treshold:			
				if previous_tile_coords and previous_tile_coords != tile_coords:
					set_cell(2,previous_tile_coords, -1)
				set_cell(2, tile_coords, 0, Vector2i(0,1))
			
				previous_tile_coords = tile_coords
			
		elif previous_tile_coords:
				set_cell(2,previous_tile_coords, -1)
				previous_tile_coords = null
