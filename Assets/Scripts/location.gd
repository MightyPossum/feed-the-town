class_name location

var location_type : int
var location_resource_abundance : int
var location_resource_type
var location_coords : Vector2i

var east : bool
var north : bool
var west : bool
var south : bool

func _init(_location_type : int, _location_resource_abundance : int, _location_resource_type, _location_coords : Vector2i, _east:bool, _north:bool, _west:bool, _south:bool) -> void:
    location_type = _location_type
    location_resource_abundance = _location_resource_abundance
    location_resource_type = _location_resource_type
    location_coords = _location_coords
    east = _east
    north = _north
    west = _west
    south = _south

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