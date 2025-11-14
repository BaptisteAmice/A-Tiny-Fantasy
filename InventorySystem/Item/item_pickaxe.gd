extends ItemDataUsable
class_name ItemDataPickaxe

func use(_target: Node) -> void:
	#todo play animation and sound, try to hit bases on direction toward mouse relative to player 
	#todo remove durability to tile, detroy it if it reaches 0

	#todo temp
	Global.get_world_scene().world_tile_map.remove_wall_at_mouse()
