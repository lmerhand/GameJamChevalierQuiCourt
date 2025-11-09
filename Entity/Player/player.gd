extends CharacterBody3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.15

@export_group("Movement")
@export var move_speed := 3.0
@export var acceleration := 30.0
@export var rotation_speed := 12.0

var current_speed : float

var shake_intensity : float = 0.0
var active_shake_time: float = 0.0

var shake_decay: float = 5.0

var shake_time: float = 0.0
var shake_time_speed: float = 20.0

var noise = FastNoiseLite.new()

var bumped : bool = false

var _tiers_max = {0:2, 1:10, 2:10, 3:10, 4:10}
var _current_tiers = {0:0, 1:0, 2:0, 3:0, 4:0}
var _current_objects_destroyed = 0
var _current_tier = 0

var _camera_new_fov = 75.0
var _camera_input_direction = Vector2.ZERO
var _last_movement_direction := Vector3.BACK

@onready var _camera : Camera3D = %Camera3D
@onready var _skin := %Skin
@onready var _camera_pivot: Node3D = %CameraPivot

func _ready() -> void:
	GlobalSignal.broke_an_obstacle.connect(speed_up)
	GlobalSignal.bumped_into_an_obstacle.connect(bumping)

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
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, -PI / 3.0, PI / 12.0)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	#player movements
	if bumped == false:
		var raw_input := Input.get_vector("left","right","up","down")
		var forward := _camera.global_basis.z
		var right := _camera.global_basis.x
		
		var move_direction := forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()
	
		velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
		%Particles.get_process_material().gravity = velocity
		move_and_slide()
		
		if move_direction.length() > 0.2:
			_last_movement_direction = move_direction
		var ground_speed := velocity.length()
		if _skin.get_node("AnimationPlayer").speed_scale >= 1.0 and ground_speed > 0.0:
			_skin.run()
		elif _skin.get_node("AnimationPlayer").speed_scale <= 1.0 and ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)
	_camera.fov = lerp(_camera.fov, _camera_new_fov, delta)
	
	if !is_on_floor():
		velocity.y += get_gravity().y
	
	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		
		_camera.v_offset = noise.get_noise_2d(shake_time, 0) * shake_intensity
		_camera.h_offset = noise.get_noise_2d(0, shake_time) * shake_intensity
		shake_intensity = max(shake_intensity - shake_decay * delta, 0)
	else:
		_camera.h_offset = lerp(_camera.h_offset, 0.0, 10.5 * delta)
		_camera.v_offset = lerp(_camera.v_offset, 0.0, 10.5 * delta)

func speed_up(tier):
	if _current_tier == 0:
		screen_shake(0.8,0.05)
		_freeze_frame(0.05,0.5)
	else:
		screen_shake(1, 0.05)
		_freeze_frame(0.05, 1.0)
	if _current_tier == tier:
		if _current_objects_destroyed+1 == _tiers_max[_current_tier]: #speed up!
			move_speed *= 3
			acceleration += 6
			_camera_new_fov = clamp(_camera_new_fov * 1.3, 75.0, 70.0)
			_skin.get_node("AnimationPlayer").speed_scale += 0.1
			_current_objects_destroyed = 1
			_current_tier = clamp(_current_tier + 1, 0, 4)
			GlobalSignal.changed_tier.emit(_current_tier)
		else:
			if _current_objects_destroyed+1 == _tiers_max[_current_tier]/2: #if the tier is halfway done
				GlobalSignal.changed_half_tier.emit(_current_tier)
			_current_objects_destroyed += 1
		_current_tiers[_current_tier] = _current_objects_destroyed

func _freeze_frame(timescale, duration):
	Engine.time_scale = timescale
	await get_tree().create_timer(duration * timescale).timeout
	Engine.time_scale = 1.0
func screen_shake(intensity: int, time: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	shake_intensity = intensity
	active_shake_time = time
	shake_time = 0.0


func bumping():
	screen_shake(1, 0.05)
	_freeze_frame(0.05, 1.0)
	bumped = true
	_skin.bump()
	await get_tree().create_timer(0.5).timeout
	bumped = false
