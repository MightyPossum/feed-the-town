extends Node2D

var location_dictionary : Dictionary = {}
var path_dictionary : Dictionary = {}
var neighbor_dictionary : Dictionary
var defined_locations : Array = []

func _ready() -> void:

	location_dictionary[Vector2i(34,20)] = location.new(GLOBALVARIABLES.LOCATION_TYPE.HOMEBASE, 0, null, Vector2i(34,20), true, true, true, true)
	location_dictionary[Vector2i(26,27)] = location.new(GLOBALVARIABLES.LOCATION_TYPE.MINING, 100, GLOBALVARIABLES.RESOURCE_TYPE.ORE, Vector2i(26,27), true, true, true, true)
	location_dictionary[Vector2i(45,18)] = location.new(GLOBALVARIABLES.LOCATION_TYPE.PRODUCTION, 100, GLOBALVARIABLES.RESOURCE_TYPE.METAL, Vector2i(45,18), true, true, true, true)

	neighbor_dictionary[Vector2i(34,20)] = {} # Home Base
	neighbor_dictionary[Vector2i(26,27)] = {} # Production 1
	neighbor_dictionary[Vector2i(45,18)] = {} # Production 1

	defined_locations.append(Vector2i(34,20))
	defined_locations.append(Vector2i(26,27))
	defined_locations.append(Vector2i(45,18))



func calculate_paths(selected_tile : Array):

	if not location_dictionary.has(selected_tile[3]):
		location_dictionary[selected_tile[3]] = location.new(GLOBALVARIABLES.LOCATION_TYPE.PATH, 0, null, selected_tile[3], false, false, false, false)
	
	if not neighbor_dictionary.has(selected_tile[3]):
		neighbor_dictionary[selected_tile[3]] = {}
	
	if selected_tile[0] == GLOBALVARIABLES.CONSTRUCTABLETILE.ROAD:
		if selected_tile[2] == 0 or selected_tile[2] == 2:
			location_dictionary[selected_tile[3]].east = true
			location_dictionary[selected_tile[3]].west = true
		elif selected_tile[2] == 1 or selected_tile[2] == 3:
			location_dictionary[selected_tile[3]].north = true
			location_dictionary[selected_tile[3]].south = true
			

		check_connect_locations(location_dictionary[selected_tile[3]])
		#east, north, west, south
	elif selected_tile[0] == GLOBALVARIABLES.CONSTRUCTABLETILE.TURN:
		match selected_tile[2]:
			0: 
				location_dictionary[selected_tile[3]].north = true
				location_dictionary[selected_tile[3]].west = true
			1: 
				location_dictionary[selected_tile[3]].north = true
				location_dictionary[selected_tile[3]].east = true
			2: 
				location_dictionary[selected_tile[3]].east = true
				location_dictionary[selected_tile[3]].south = true
			3: 
				location_dictionary[selected_tile[3]].south = true
				location_dictionary[selected_tile[3]].west = true

		check_connect_locations(location_dictionary[selected_tile[3]])

	elif selected_tile[0] == GLOBALVARIABLES.CONSTRUCTABLETILE.CROSS:
		location_dictionary[selected_tile[3]].north = true
		location_dictionary[selected_tile[3]].west = true
		location_dictionary[selected_tile[3]].south = true
		location_dictionary[selected_tile[3]].east = true

		check_connect_locations(location_dictionary[selected_tile[3]])

	elif selected_tile[0] == GLOBALVARIABLES.CONSTRUCTABLETILE.BULLDOZER:
		remove_tile_from_paths(selected_tile[3])

	# Check any potential paths
	for start_vector in defined_locations:
		for end_vector in defined_locations:
			if start_vector != end_vector and location_dictionary[start_vector].location_type != location_dictionary[end_vector].location_type:
				var dijkstra_result = dijkstra(start_vector, end_vector)
				if dijkstra_result.size() > 1 and dijkstra_result.path.front() == start_vector:
					print(end_vector)
					print(dijkstra_result.path)


func check_connect_locations(_location : location):
	var test_vector : Vector2i
	var current_vector : Vector2i = _location.location_coords
	if _location.north:
		test_vector = Vector2i(current_vector.x, current_vector.y-1)
		try_connect(current_vector, test_vector, GLOBALVARIABLES.COMPASS.NORTH)
	if _location.south:
		test_vector = Vector2i(current_vector.x, current_vector.y+1)
		try_connect(current_vector, test_vector, GLOBALVARIABLES.COMPASS.SOUTH)
	if _location.west:
		test_vector = Vector2i(current_vector.x-1, current_vector.y)
		try_connect(current_vector, test_vector, GLOBALVARIABLES.COMPASS.WEST)
	if _location.east:
		test_vector = Vector2i(current_vector.x+1, current_vector.y)
		try_connect(current_vector, test_vector, GLOBALVARIABLES.COMPASS.EAST)
		
func try_connect(current_vector, test_vector, compass_int):
	if neighbor_dictionary.has(test_vector):

		var connection_succeeded : bool = false

		if location_dictionary[test_vector].can_connect(compass_int) and not neighbor_dictionary[test_vector].has(current_vector):
			neighbor_dictionary[test_vector][current_vector] = 150
			connection_succeeded = true
		if not neighbor_dictionary[current_vector].has(test_vector) and connection_succeeded: 
			neighbor_dictionary[current_vector][test_vector] = 150


func remove_tile_from_paths(tile_vector : Vector2i):
	if neighbor_dictionary.has(tile_vector):
		for connected_vector in neighbor_dictionary[tile_vector]:
			neighbor_dictionary[connected_vector].erase(tile_vector)

	neighbor_dictionary.erase(tile_vector)
	location_dictionary.erase(tile_vector)

	


# define a function that implements Dijkstra's algorithm
func dijkstra(start, end):
	# check if the starting node is in the graph and has neighbors
	if not neighbor_dictionary.has(start) or len(neighbor_dictionary[start]) == 0:
		return {}

	# initialize the cost and visited arrays
	var cost = {}
	var visited = {}
	var previous = {}
	var queue = []
	var infinity = 100000000000
	
	for node in neighbor_dictionary:
		cost[node] = infinity
		visited[node] = false
		previous[node] = null

	# set the cost of the starting node to zero and add it to the queue
	cost[start] = 0
	queue.append(start)

	# loop while the queue is not empty
	while len(queue) > 0:
		# get the node with the lowest cost from the queue
		var current = null
		var current_cost = infinity
		
		for node in queue:
			if cost[node] < current_cost:
				current = node
				current_cost = cost[node]

		# mark the current node as visited and remove it from the queue
		visited[current] = true
		if current in queue:
			queue.erase(current)

		# update the cost of each neighbor of the current node
		for neighbor in neighbor_dictionary[current]:
			if not visited[neighbor]:
				var new_cost = cost[current] + neighbor_dictionary[current][neighbor]
				if new_cost < cost[neighbor]:
					cost[neighbor] = new_cost
					previous[neighbor] = current
					queue.append(neighbor)
					
	# build the shortest path from the start node to the end node
	var path = []
	var current_node = end
	while current_node != null:
		path.insert(0, current_node)
		current_node = previous[current_node]

	# return the cost array
	return { "cost": cost, "path": path }