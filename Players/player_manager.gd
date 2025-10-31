extends Node

# Local reference to the player instance
var my_player: Player

func use_slot_data(slot_data: SlotData) -> void:
	# It's always my player that will use the item
	# If we want to affect other players, it's in the use() method that it will happen anyway
	slot_data.item_data.use(my_player)

func get_global_position() -> Vector2:
	return my_player.global_position
