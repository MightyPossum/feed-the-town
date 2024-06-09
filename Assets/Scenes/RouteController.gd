extends Node2D

var moving : bool = true
var routes : Dictionary
var current_paths : Dictionary
var location_dictionary : Dictionary

@onready var tile_map = get_tree().root.get_node("Map")


func _physics_process(_delta: float) -> void:
	if moving:
		moving = false  
		await get_tree().create_timer(1).timeout
		move_along()

func _ready() -> void:
	routes = GLOBALVARIABLES.travel_routes
	location_dictionary = GLOBALVARIABLES.location_dictionary

func move_along():
	for start_location in routes:
		for end_location in routes[start_location]:
			var set_path = false
			if current_paths.has(start_location):
				print("same start")
				print(end_location)
				if current_paths[start_location].has(end_location):
						print('path exist and to the same end')
						set_path = false
				else:
					set_path = true
			else:
				print('path no exist')
				set_path = true

			if set_path:
				print("adding path")
				print(start_location)
				print(end_location)
				if not current_paths.has(start_location):
					current_paths[start_location] = {}

				current_paths[start_location][end_location] = {
					"current_location": routes[start_location][end_location].front(),
					"end_location":routes[start_location][end_location].back(),
					"path":routes[start_location][end_location].duplicate(),
					"replaced_tile":null,
					"start_location":routes[start_location][end_location].front()
					}

	
	for path_start_vector in current_paths:
		for path_end_vector in current_paths[path_start_vector]:
			#print(routes[path_start_vector])
			#if routes[path_start_vector][current_paths[path_start_vector]["end_location"]].is_empty():
			#	current_paths.erase(path_start_vector)
			#	if not [GLOBALVARIABLES.LOCATION_TYPE.HOMEBASE, GLOBALVARIABLES.LOCATION_TYPE.MINING, GLOBALVARIABLES.LOCATION_TYPE.PRODUCTION].has(location_dictionary[current_paths[path_start_vector]["current_location"]].location_type):
			#		tile_map.set_cell(2, current_paths[path_start_vector]["current_location"], GLOBALVARIABLES.color, location_dictionary[current_paths[path_start_vector]["current_location"]].location_tile, location_dictionary[current_paths[path_start_vector]["current_location"]].location_rotation)
			print(current_paths[path_start_vector])
			print(current_paths[path_start_vector][path_end_vector])
			var current_location = current_paths[path_start_vector][path_end_vector]["path"].pop_front()
			var previous_location = current_paths[path_start_vector][path_end_vector]["current_location"]
			var end_location = current_paths[path_start_vector][path_end_vector]["end_location"]
			var start_location = current_paths[path_start_vector][path_end_vector]["start_location"]
			var at_first_location : bool = false
			var at_last_location : bool = false

			if [GLOBALVARIABLES.LOCATION_TYPE.HOMEBASE, GLOBALVARIABLES.LOCATION_TYPE.MINING, GLOBALVARIABLES.LOCATION_TYPE.PRODUCTION].has(location_dictionary[current_location].location_type):
				print("at a factory")
			
			if current_location == previous_location:
				at_first_location = true
			elif current_location == end_location:
				at_last_location = true

			if previous_location != current_location and previous_location != start_location:
				tile_map.set_cell(2, previous_location, GLOBALVARIABLES.color, location_dictionary[previous_location].location_tile, location_dictionary[previous_location].location_rotation)
			
			if not at_last_location and not at_first_location:
				tile_map.set_cell(2, current_location, GLOBALVARIABLES.color, location_dictionary[current_location].location_car_tile, location_dictionary[current_location].location_rotation)

			if at_last_location:
				routes[path_start_vector][path_end_vector].reverse()
				current_paths[path_start_vector].erase(path_end_vector)
			else:
				current_paths[path_start_vector][path_end_vector]["current_location"] = current_location

	
	moving = true
