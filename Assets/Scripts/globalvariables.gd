extends Node

enum RESOURCE_TYPE{
    ORE,
    WOOD,
    OIL,
    METAL,
    PLANK,
    REFINED_OIL,
}

enum PURCHASE_TYPE {
    PURCHASE,
    SELL,
}

enum CONSTRUCTABLETILE {
	ROAD,
	TURN,
	CROSS,
	BULLDOZER,
}

enum LOCATION_TYPE {
    HOMEBASE,
    MINING,
    PRODUCTION,
    PATH,
}

enum COMPASS {
    EAST,
    NORTH,
    WEST,
    SOUTH,
}

var money : float = 0.0

var material_location_type : Dictionary = {
    Vector2i(0,3):[RESOURCE_TYPE.ORE,500]
}

func transaction_resource(resource : Resource_class, transaction_type : int) -> void:
    var transaction_value = (resource.resource_amount * resource.resource_value)
    
    match transaction_type:
        PURCHASE_TYPE.PURCHASE:
            money += transaction_value
        PURCHASE_TYPE.SELL:
            money -= transaction_value

