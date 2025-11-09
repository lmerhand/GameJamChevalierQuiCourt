extends Node3D

func move():
	$AnimationPlayer.play("Walk")

func idle():
	$AnimationPlayer.play("Idle")

func run():
	$AnimationPlayer.play("Run")
