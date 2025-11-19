extends Node
class_name WindowManager

var created_process_ids: Array[int] = []

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Kill created processes before quitting
		close_created_processes(true)
		get_tree().quit() # default behavior

func close_created_processes(save_if_server: bool) -> void:
	for pid: int in created_process_ids:
		print("Killing created process %d" % pid)
		OS.kill(pid)
	created_process_ids.clear()
