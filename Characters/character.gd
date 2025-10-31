extends CharacterBody2D
class_name Character

@export var target: Node2D
#@export var inventory_data: InventoryData

# Should be added manually in children, else it will crash
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_emote: AnimatedEmote = $AnimatedEmote

func _ready() -> void:
	test_if_child_scene_path_is_in_multiplayer_spawner()
	test_if_child_is_in_persist_group()
	
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

func target_player() -> void:
	if not multiplayer.is_server(): return
	var players: Array[Player] = Global.game_controller.network_manager.get_local_connected_players()

	if players.is_empty():
		target = null
		return

	var nearest_player: Node2D = null
	var nearest_distance: float = INF

	for player: Player in players:
		if not player is Node2D:
			continue
		var dist: float = global_position.distance_to(player.global_position)
		if dist < nearest_distance:
			nearest_distance = dist
			nearest_player = player

	target = nearest_player
