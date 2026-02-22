extends Command
class_name CommandTeleport

func _init(src: Node2D, targ: Vector2) -> void:
	super(src, targ)
	
func execute() -> String:
	if not (source is Node2D):
		push_error("Source must be a Node2D")
		return "Source must be a Node2D"
	var node: Node2D = source as Node2D
	node.global_position = target
	var x_str: String = str(node.global_position.x)
	var y_str: String = str(node.global_position.y)
	return "Teleported " + node.name + " to " + x_str + " " + y_str
	
