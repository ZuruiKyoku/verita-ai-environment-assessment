extends Node

var paused := false
signal paused_changed

func _ready():
	set_paused(false)

func set_paused(_paused : bool) -> void:
	paused = _paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _paused else Input.MOUSE_MODE_CAPTURED
	paused_changed.emit(paused)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			paused = !paused
			set_paused(paused)
