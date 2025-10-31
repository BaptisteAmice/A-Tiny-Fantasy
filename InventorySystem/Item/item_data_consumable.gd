extends ItemData
class_name ItemDataConsumable

@export var heal_value: int

func use(target: Node) -> void:
	if heal_value != 0:
		if target.has_method("heal"):
			@warning_ignore("unsafe_method_access") # checked above
			target.heal(heal_value)
		else:
			push_error("Target '%s' does not have a 'heal' method" % target.name)
