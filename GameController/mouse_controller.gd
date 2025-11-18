extends Node2D
class_name MouseController

var virtual_mouse_position: Vector2


# follow the mouse when it moves in the window
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var event_mouse_pos : InputEventMouseMotion = event
		virtual_mouse_position = get_global_mouse_position()

# can be moved by other means
func slide_virtual_mouse_to_position(target_position: Vector2, duration: float) -> void:
	virtual_mouse_position = target_position
