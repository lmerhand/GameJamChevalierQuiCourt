extends Node3D
@export_enum("Marche","Marche Rapide","Court","Galope","Fly") var category

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_class("CharacterBody3D"):
		if body._current_tier == category:
			GlobalSignal.broke_an_obstacle.emit()
			self.queue_free()
		elif body._current_tier > category:
			print("too fast! no exp")
			self.queue_free()
		else:
			GlobalSignal.bumped_into_an_obstacle.emit()
			print("too slow!")
