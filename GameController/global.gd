extends Node

var game_controller: GameController
var client_config: ClientConfig
var localization: Localization

func _ready() -> void:
	client_config = ClientConfig.new()

func get_world_scene(can_be_null: bool = false) -> World:
	if not Global.game_controller.current_scene is World and not can_be_null:
		push_error("Current scene is not a World!")
		return null
	return Global.game_controller.current_scene as World


# TODO make a utils.gd file or something
func array_to_string(arr: Array[Variant]) -> String:
	return JSON.stringify(arr)
