extends Area2D
class_name InteractableArea

# todo add shader when first in list

@export var interact_text: String = "default"

func player_interact() -> void:
	print("player_interact to override")
