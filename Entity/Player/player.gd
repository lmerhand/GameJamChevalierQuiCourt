extends CharacterBody3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.20

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 30.0
@export var rotation_speed := 12.0

var current_speed : float
var camera_rotation_weight = 1

var _camera_input_direction = Vector2.ZERO
var _last_movement_direction := Vector3.BACK

@onready var _camera : Camera3D = %Camera3D
@onready var _skin : MeshInstance3D = %Skin
@onready var _camera_pivot: Node3D = %CameraPivot

func _ready() -> void:
	GlobalSignal.broke_an_obstacle.connect(speed_up)

func _input(event: InputEvent) -> void:
	#activates the mouth for camera rotation
	if event.is_action_pressed("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_released("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	#gets the mouth movement for futur calculations
	var is_camera_motion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	#turns the camera according to the mouse drag
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 6.0, PI / 3.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	#player movements
	var raw_input := Input.get_vector("left","right","up","down")
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

func speed_up(acc : float):
	move_speed += acc
	acceleration += acc
#acceleration on slope
#calculates speed
