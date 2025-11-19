extends OptionButton

enum  INPUT_CALLERS_CONTROLLER_TYPE {
	NONE = 0,
	RANDDOM = 1,
	TWITCH = 2
}

const INPUT_CALLERS_CONTROLLER_RANDOM = preload("uid://gbeec3vxdxxj")

func _ready() -> void:
	_remove_input_caller_controller()
	for type: String in INPUT_CALLERS_CONTROLLER_TYPE.keys():
		var new_id: int = INPUT_CALLERS_CONTROLLER_TYPE[type]
		add_item(type, new_id)

func _remove_input_caller_controller() -> void:
	if Global.game_controller.input_caller_controller != null:
		Global.game_controller.input_caller_controller.queue_free()
		Global.game_controller.input_caller_controller = null
		Global.game_controller.mouse_controller.virtual_cursor.hide() # virtual cursor only needed if controlled with other means than the mouse

func _on_item_selected(index: int) -> void:
	var new_input_caller_controller: InputCallersController
	match index:
		INPUT_CALLERS_CONTROLLER_TYPE.NONE:
			_remove_input_caller_controller()
		INPUT_CALLERS_CONTROLLER_TYPE.RANDDOM:
			new_input_caller_controller = INPUT_CALLERS_CONTROLLER_RANDOM.new()
			Global.game_controller.mouse_controller.virtual_cursor.show() # virtual cursor only needed if controlled with other means than the mouse
		INPUT_CALLERS_CONTROLLER_TYPE.TWITCH:
			_remove_input_caller_controller()
			Global.game_controller.mouse_controller.virtual_cursor.show() # virtual cursor only needed if controlled with other means than the mouse
			#todo
			
	if new_input_caller_controller != null:
		Global.game_controller.input_caller_controller = new_input_caller_controller
		Global.game_controller.add_child(new_input_caller_controller)
			
