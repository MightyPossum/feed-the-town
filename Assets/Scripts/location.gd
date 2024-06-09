class_name location

var location_type : int
var location_resource_abundance : int
var fetched_resource : int
var location_resource_type
var location_coords : Vector2i
var location_tile
var location_car_tile
var location_rotation : int

var location_cost
var is_predetermined_location : bool

var east : bool
var north : bool
var west : bool
var south : bool

func _init(_location_type : int, _location_resource_abundance : int, _location_resource_type, _location_coords : Vector2i, _east:bool, _north:bool, _west:bool, _south:bool, _location_tile, _location_rotation:int, _location_car_tile) -> void:
    location_type = _location_type
    location_resource_abundance = _location_resource_abundance
    location_resource_type = _location_resource_type
    location_coords = _location_coords
    east = _east
    north = _north
    west = _west
    south = _south
    location_tile = _location_tile
    location_rotation = _location_rotation
    location_car_tile = _location_car_tile

    if [GLOBALVARIABLES.LOCATION_TYPE.MINING, GLOBALVARIABLES.LOCATION_TYPE.PRODUCTION].has(location_type):
        is_predetermined_location = true
        location_cost = 150
    elif location_type == GLOBALVARIABLES.LOCATION_TYPE.HOMEBASE:
        is_predetermined_location = true
        location_cost = 150
    else:
        is_predetermined_location = false
        location_cost = 150

func can_connect(neighbor_side : int) -> bool:
    var allowed_connection : bool = false
    match neighbor_side:
        GLOBALVARIABLES.COMPASS.EAST:
            if west:
                allowed_connection = true
        GLOBALVARIABLES.COMPASS.NORTH:
            if south:
                allowed_connection = true
        GLOBALVARIABLES.COMPASS.WEST:
            if east:
                allowed_connection = true
        GLOBALVARIABLES.COMPASS.SOUTH:
            if north:
                allowed_connection = true

    return allowed_connection

func increment_abundance():
    location_resource_abundance += 1
    if location_resource_abundance > 3:
        location_resource_abundance = 3


func decrement_abundance():
    location_resource_abundance -= 1
    if location_resource_abundance < 0:
        location_resource_abundance = 0