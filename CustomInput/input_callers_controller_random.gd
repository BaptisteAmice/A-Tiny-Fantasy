extends InputCallersController
class_name InputCallersControllerRandom

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var last_call_time : float = Time.get_unix_time_from_system()
var sleeping_time : float = 0.1 # seconds

func _process(_delta: float) -> void:
	if Time.get_unix_time_from_system()- last_call_time - sleeping_time < 0:
		return
	last_call_time = Time.get_unix_time_from_system()


	var index: int = rng.randi_range(0, input_callers.size()-1)
	print(index)
	var caller: InputCaller = input_callers[index]
	caller.trigger_press(0.1)
