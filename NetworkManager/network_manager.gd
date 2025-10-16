extends Node
class_name NetworkManager

const IP_ADDRESS: String = "localhost"
const PORT: int = 42069
var peer: ENetMultiplayerPeer
var multiplayer_spawner : MultiplayerSpawnerOfPlayer

var registered_players: Dictionary = {}
var logged_players: Array[Player] = []

func print_player_lists() -> void:
	print("Registered Players names: ", registered_players.keys())
	print("Logged Players: ")
	for player: Player in logged_players:
		print(player) 


func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	var save_data: Dictionary = Global.game_controller.save_manager.load_data_from_file()
	registered_players = save_data.get("players", {})
	
	#TODO load world data

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func close_server() -> void : # todo test
	if multiplayer.is_server() and multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close() # TODO to test
		multiplayer.multiplayer_peer = null

func disconnect_client() -> void:
	multiplayer.multiplayer_peer.disconnect_peer(1)

func register_player(player_name: String) -> void :
	# Create temp new player
	var new_player: Player = Global.game_controller.PLAYER.instantiate()
	Global.game_controller.current_scene.add_child(new_player)
	# Set it's name and other custom var
	new_player.player_name = player_name
	# Save it in the list in memory (not in the file, should save the world for that)
	registered_players[player_name] = new_player.save()
	# Free the new player
	new_player.queue_free()
	
func get_player(registered_player_name: String) -> Dictionary :
	return registered_players.get(registered_player_name, null)
