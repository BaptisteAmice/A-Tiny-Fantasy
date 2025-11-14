extends ItemData
class_name ItemDataUsable

@export var heal_value: int
@export var consumable: bool = true

func use(_target: Node) -> void:
	pass
	
func heal(target: Node) -> void:
	if heal_value != 0:
		if target.has_method("heal"):
			@warning_ignore("unsafe_method_access") # checked above
			target.heal(heal_value)
		else:
			push_error("Target '%s' does not have a 'heal' method" % target.name)
