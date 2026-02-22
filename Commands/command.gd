class_name Command
var source: Variant
var target: Variant

func _init(src: Variant, targ: Variant) -> void:
	source = src
	target = targ
	
func execute() -> String:
	return "execute() method not implemented for this command!"
