class_name Resource_class

var resource_type
var resource_amount
var resource_value

func _init(_resource_type : int, _resource_amount : int) -> void:
    resource_type = _resource_type
    resource_amount = _resource_amount
    set_resource_value()


func set_resource_value() -> void:

    match resource_type:
        [GLOBALVARIABLES.RESOURCE_TYPE.ORE, GLOBALVARIABLES.RESOURCE_TYPE.WOOD, GLOBALVARIABLES.RESOURCE_TYPE.WOOD]:
            resource_value = 500 * resource_amount
        [GLOBALVARIABLES.RESOURCE_TYPE.METAL, GLOBALVARIABLES.RESOURCE_TYPE.REFINED_OIL, GLOBALVARIABLES.RESOURCE_TYPE.PLANK]:
            resource_value = 1800 * resource_amount