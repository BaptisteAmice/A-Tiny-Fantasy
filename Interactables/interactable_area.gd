extends Area2D
class_name InteractableArea

@export var interact_text: String = "default"
@export var visual: Node2D
const INTERACTABLE_OUTLINE: Resource = preload("uid://6q6c104hftk4")

func _ready() -> void:
	test_if_child_scene_path_is_in_multiplayer_spawner()
	test_if_child_is_in_persist_group()

######## Test la validité des neuds enfants #########

func test_if_child_scene_path_is_in_multiplayer_spawner() -> void:
	if not multiplayer.is_server(): return # less work for the clients
	if Global.get_world_scene(true) == null: return # don't do it if the world isn't loaded yet
	#throw error if type of child not in the spawner
	var spawner : MultiplayerSpawner = Global.get_world_scene().multiplayer_spawner
	if spawner == null:
		push_error("MultiplayerSpawner not found in world scene")
		return
	var this_scene : String = scene_file_path
	var registered : bool = false
	for i: int in spawner.get_spawnable_scene_count():
		if spawner.get_spawnable_scene(i) == this_scene:
			registered = true
			break
	if not registered:
		push_error("%s is not registered in MultiplayerSpawner!" % this_scene)

func test_if_child_is_in_persist_group() -> void:
	if not multiplayer.is_server(): return # less work for clients
	# Ensure node belongs to group "persist"
	if not is_in_group("Persist"):
		push_error("%s is NOT in the 'Persist' group!" % name)

#######################################


func player_interact() -> void:
	print("player_interact to override")

func has_visual() -> bool:
	return visual != null

func activate_shader() -> void:
	if has_visual():
		visual.material = INTERACTABLE_OUTLINE
func deactivate_shader() -> void:
	if has_visual():
		visual.material = null
		
		
