class_name Command
var source: Node
var target: Node

func _init(src: Node, targ: Node) -> void:
	source = src
	target = targ
	
func execute() -> void:
	pass
