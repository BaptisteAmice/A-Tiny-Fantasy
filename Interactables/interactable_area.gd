extends Area2D
class_name InteractableArea

# todo add shader when first in list

@export var interact_text: String = "default"
@export var visual: Node2D
const INTERACTABLE_OUTLINE: Resource = preload("uid://6q6c104hftk4")

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
		
		
