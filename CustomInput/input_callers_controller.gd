extends Node
class_name InputCallersController

@export var actions: Array[String] = [
	"left",
	"right",
	"up",
	"down",
	"left_click",
	"left_click",
	"scroll_up",
	"scroll_down",
	"mouse_move_left",
	"mouse_move_right",
	"mouse_move_up",
	"mouse_move_down"
]

var input_callers: Array[InputCaller] = []

func _ready() -> void:
	for action: String in actions:
		var new_caller : InputCaller = InputCaller.new()
		new_caller.action_name = action
		input_callers.append(new_caller)
