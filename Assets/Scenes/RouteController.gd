extends Node2D

var moving : bool = true
var routes : Dictionary
var current_paths : Dictionary
var location_dictionary : Dictionary


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
        #print(start_location)
        #print(routes[start_location])
        for end_location in routes[start_location]:
            if not current_paths.has(start_location):
                current_paths[start_location] = {"current_location": routes[start_location][end_location].front(),"end_location":routes[start_location][end_location].back(),"path":routes[start_location][end_location].duplicate(),"static_end_location":end_location}
                print('Adding a path to traverse')
    
    for path_start_vector in current_paths:
        #print(path_start_vector)

        #print(current_paths[path_start_vector]["path"])
        var current_location = current_paths[path_start_vector]["path"].pop_front()
        var previous_location = current_paths[path_start_vector]["current_location"]
        var end_location = current_paths[path_start_vector]["end_location"]

        var at_first_location : bool = false
        var at_last_location : bool = false

        if [GLOBALVARIABLES.LOCATION_TYPE.HOMEBASE, GLOBALVARIABLES.LOCATION_TYPE.MINING, GLOBALVARIABLES.LOCATION_TYPE.PRODUCTION].has(location_dictionary[current_location].location_type):
            print("at a factory")
        
        if current_location == previous_location:
            print("This is the first location")
            at_first_location = true
        elif current_location == end_location:
            print("We have arrived at our destination")
            at_last_location = true

        if not at_first_location:
            pass
            print("removing vehicle")
            #remove vehicle from previous location
        print("adding Vehicle")
        #add vehicle to current location

        print("Went from " + str(previous_location) + " to " + str(current_location))

        if at_last_location:
            print('Erasing the path')
            print(" ")
            print("**************************** REVERSING ****************************")
            print("START LOCATION: " + str(path_start_vector))
            print("END LOCATION: " + str(end_location))
            print("THE PATH: " + str(routes[path_start_vector][current_paths[path_start_vector]["static_end_location"]]))
            print("****************************  ****************************")

            routes[path_start_vector][current_paths[path_start_vector]["static_end_location"]].reverse()
            current_paths.erase(path_start_vector)
        else:
            current_paths[path_start_vector]["current_location"] = current_location

    
    moving = true