extends Control

#todo synchronize with server time -> on connection and each day change
# todo save time

var hours: int = 0
var minutes: int = 0
@onready var time_label: Label = $TimeLabel
@onready var day_label: Label = $DayLabel
@onready var time_animation_player: AnimationPlayer = $TimeAnimationPlayer

var day_counter: int = 0 : 
	set(day): 
		day_counter = day
		day_label.text = "Day %d" % day_counter

func _physics_process(_delta: float) -> void:
	var current_time: float = time_animation_player.current_animation_position
	var total_time: float = time_animation_player.current_animation_length
	
	var minute_passed: float = (current_time/total_time) * (24*60)
	hours = int(minute_passed / 60)
	minutes = int(minute_passed) % 60
	time_label.text = "%02d:%02d" % [hours, minutes]

func next_day() -> void:
	day_counter += 1
	
func save() -> Dictionary: #todo test save and load
	var data : Dictionary = {
		"day": day_counter,
		"time_animation_position": time_animation_player.current_animation_position
	}
	return data
	
func load(data: Dictionary) -> void:
	var data_day_int: int = data.day
	day_counter = data_day_int
	var data_aniamtion_pos_float: float = data.time_animation_position
	time_animation_player.seek(data_aniamtion_pos_float, true)
	
	
