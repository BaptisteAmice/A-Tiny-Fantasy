extends Node
class_name GameController

var current_scene: Node
var removed_scenes: Dictionary = {}

@onready var save_manager: SaveManager = $SaveManager
@onready var network_manager: NetworkManager = $NetworkManager

const PLAYER: PackedScene = preload("uid://d08gn81f5b74p")


func _ready() -> void:
	Global.game_controller = self
	change_scene("res://Menus/main_menu.tscn")

func change_scene(new_scene: String) -> void:
	if not current_scene == null:
		current_scene.queue_free() # remove node entirely
		
	var new_scene_instance: Node = null
	if removed_scenes.has(new_scene):
		new_scene_instance = removed_scenes[new_scene]
		removed_scenes.erase(new_scene)
		print_debug("Reusing scene")
	else:
		var scene_res: PackedScene = load(new_scene)
		new_scene_instance = scene_res.instantiate()
		print_debug("not Reusing scene")
	self.add_child(new_scene_instance)
	current_scene = new_scene_instance
