extends MultiplayerSpawner
class_name MultiplayerSpawnerOfPlayer

@export var network_player: PackedScene
@onready var world_path: String = ".."


func _ready() -> void:
	Global.game_controller.network_manager.multiplayer_spawner = self # to be accessable from everywhere

@rpc("any_peer", "call_remote", "reliable")
func request_spawn(selected_name: String) -> void:
	if not multiplayer.is_server(): return
	# This function is called *on the server* by the client
	var peer_id: int = multiplayer.get_remote_sender_id()
	print("Client", peer_id, "requested spawn of character", selected_name)
	var spawned_player: Player =  spawn_player(peer_id, selected_name)

	if spawned_player == null:
		push_error("spawn_player returned null!")
		return
	
	# Make sure the node is in the tree before sending the path of the instantiated player
	_send_spawned_player_path(peer_id, spawned_player)

# validate spawn to client
func _send_spawned_player_path(peer_id: int, player: Player) -> void:
	rpc_id(peer_id, "receive_spawned_player", player.get_path())

# Client receives spawned player response from server
@rpc("authority", "call_remote")
func receive_spawned_player(player_path: NodePath) -> void :
	var player: Player = get_node(player_path) as Player
	print("Received spawned player:", player)
	Global.game_controller.network_manager.logged_players.append(player)
	Global.game_controller.network_manager.print_player_lists()
	
func spawn_player(peer_id: int, selected_name: String) -> Player:
	print("trying to spawn")
	if !multiplayer.is_server(): 
		push_error("Only the server should call the function spawn_player")
		return
	var player: Player = network_player.instantiate()
	player.name = str(peer_id) # crucial
	# Restore data if saved
	print("selected name: " + selected_name)
	var saved_state: Variant = Global.game_controller.network_manager.registered_players.get(selected_name, null)
	if saved_state == null: # TODO
		push_error("No saved state found for character: " + selected_name)
		return null 

	# The node should be added to the scene tree before loading data
	var parent_node: Node = get_node(spawn_path)
	parent_node.add_child(player)
	# Load saved data
	player.load(saved_state)
	
	print("character spawned")
	return player
