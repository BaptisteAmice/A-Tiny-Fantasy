extends ItemDataUsable
class_name ItemDataTerrain

@export var terrain_id: Constants.TERRAINS

func use(_target: Node) -> void:
	#todo if no ground place ground else place wall
	Global.get_world_scene().world_tile_map.place_wall_at_mouse(terrain_id)
