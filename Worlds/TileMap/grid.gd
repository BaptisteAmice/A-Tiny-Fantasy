extends TileMapLayer
class_name TileMapGrid


func _ready() -> void:
	Global.game_controller.mouse_controller.tilemap_grid = self
