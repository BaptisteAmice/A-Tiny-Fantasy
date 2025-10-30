extends CharacterBody2D
class_name Character

@export var target: Node2D
#@export var inventory_data: InventoryData

# Should be added manually in children, else it will crash
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_emote: AnimatedEmote = $AnimatedEmote


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
