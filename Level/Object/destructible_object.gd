extends Node3D

signal disappeared(tier)

@export_enum("Marche","Marche Rapide","Court","Galope","Fly") var category
@export var mesh : Node3D
@export var particles : PackedScene = preload("res://VFX/explosion_feuille.tscn")

@export var height: float = 3
@export var duration: float = 5.0
var player : CharacterBody3D
var time_passed := 0.0
#func _process(delta: float) -> void:
	#if not player:
		#return
	#time_passed += delta
	#var t = clamp(time_passed / duration, 0.0, 1.0)
	## Linear horizontal interpolation
	#var x = lerp(mesh.global_position.x, mesh.global_position.x+player.velocity.x*3, t)
	#var z = lerp(mesh.global_position.z, mesh.global_position.z+player.velocity.z*3, t)
	## Parabolic vertical interpolation
	## 4 * height * t * (1 - t) makes a nice arc (peaks at t=0.5)
	#var y = lerp(mesh.global_position.y, mesh.global_position.y + player.velocity.y, t) + (1 * height * t * (1 - t))
	#
	#mesh.global_position = Vector3(x, y, z)
	#if time_passed >= 0.5:
		#queue_free()

func _animation_destroy():
	for child in get_children():
		if child == $Area3D:
			$Area3D.queue_free()
		if child.is_class("CollisionShape3D"):
			child.disabled = true
	set_process(true)
	var new_particle = particles.instantiate()
	new_particle.emitting = true
	add_child(new_particle)
	#fire particle
	var tween = create_tween()
	tween.tween_property(mesh,"scale",Vector3(0.0001,0.0001,0.0001),0.01)
	tween.tween_callback(self.queue_free)
	#tween.parallel()
	#tween.tween_property(mesh,"rotation",Vector3(randf_range(0,10),randf_range(0,10),randf_range(0,10)),1)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_class("CharacterBody3D"):
		return

	# Cas : tier égal -> obstacle cassé, puis disparition
	if body._current_tier == category:
		GlobalSignal.broke_an_obstacle.emit(category)
		_emit_disappear()
		queue_free()
	# Cas : tier supérieur -> trop rapide, pas d'xp, disparition
	elif body._current_tier > category:
		print("too fast! no exp")
		GlobalSignal.broke_an_obstacle.emit(category)
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
	
