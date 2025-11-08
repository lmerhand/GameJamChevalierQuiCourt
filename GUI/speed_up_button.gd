extends Button

func _on_pressed() -> void:
	GlobalSignal.broke_an_obstacle.emit()
