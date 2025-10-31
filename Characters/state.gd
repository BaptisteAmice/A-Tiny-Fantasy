extends Node
class_name State

@warning_ignore("unused_signal") # Used by subclasses
signal transitioned

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
