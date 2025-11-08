extends CharacterBody3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.15

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 30.0
@export var rotation_speed := 12.0

var current_speed : float

var _palliers_max = {0:2, 1:10, 2:10, 3:10, 4:10}
var _current_palliers = {0:0, 1:0, 2:0, 3:0, 4:0}
var _current_objects_destroyed = 0
var _current_pallier = 0

var _camera_new_fov = 75.0
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
	#_camera_pivot.rotation.x += _camera_input_direction.y * delta
	#_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 3.0, PI / 12.0)
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
	_camera.fov = lerp(_camera.fov, _camera_new_fov, delta)
	
func speed_up():
	if _current_objects_destroyed+1 == _palliers_max[_current_pallier]:
		move_speed = 10
		acceleration += 10
		_camera_new_fov = clamp(_camera_new_fov* 1.1,75.0,179.0)
		_current_objects_destroyed = 1
		_current_pallier =clamp(_current_pallier + 1, 0, 4)
	else:
		_current_objects_destroyed += 1
	_current_palliers[_current_pallier] = _current_objects_destroyed
