extends Node3D

signal disappeared(tier)

@export_enum("Marche","Marche Rapide","Court","Galope","Fly") var category

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_class("CharacterBody3D"):
		return

	# Cas : tier égal -> obstacle cassé, puis disparition
	if body._current_tier == category:
		GlobalSignal.broke_an_obstacle.emit()
		_emit_disappear()
		queue_free()
	# Cas : tier supérieur -> trop rapide, pas d'xp, disparition
	elif body._current_tier > category:
		print("too fast! no exp")
		_emit_disappear()
		queue_free()
	# Cas : tier inférieur -> heurté mais reste en place
	else:
		GlobalSignal.bumped_into_an_obstacle.emit()
		print("too slow!")

# Petite méthode utilitaire pour émettre les signaux de disparition puis supprimer l'objet
func _emit_disappear() -> void:
	# Signal local : utile pour les connexions locales (par ex. le parent ou un contrôleur)
	GlobalSignal.check_name.emit(self.name)
	print(self.name)
	
