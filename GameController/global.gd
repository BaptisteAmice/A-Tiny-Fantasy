extends Node

var game_controller: GameController

func get_world_scene() -> World:
	if not Global.game_controller.current_scene is World:
		push_error("Current scene is not a World!")
		return null
	return Global.game_controller.current_scene as World


# TODO make a utils.gd file or something
func array_to_string(arr: Array[Variant]) -> String:
	return JSON.stringify(arr)
