extends Label
class_name MessageLabel

var creation_time: int

func set_creation_time(time: int) -> void:
	creation_time = time

func get_creation_time() -> int:
	return creation_time

func is_expired(current_time: int, max_display_seconds: int) -> bool:
	return (current_time - creation_time) > (max_display_seconds * 1000)
