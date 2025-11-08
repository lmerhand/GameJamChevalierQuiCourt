extends CharacterBody3D

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0

var current_speed : float

@onready var _camera : Camera3D = %Camera3D
@onready var _skin : MeshInstance3D = %Skin

#movement right left up down

#acceleration on slope

#calculates speed
