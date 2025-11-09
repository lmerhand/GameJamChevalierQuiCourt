extends StaticBody3D
@export var audio_player : AudioStreamPlayer
@export var animation_tree : AnimationTree
var spectrum_instance
var _audio_lines_path := "res://Entity/EvilCastle/Voicelines/Punch"
var _audio_lines : Array
var _audio_timer : Timer

func _ready() -> void:
	spectrum_instance = AudioServer.get_bus_effect_instance(1,0)
	_audio_lines = get_voicelines(_audio_lines_path)
	_audio_timer = Timer.new()
	add_child(_audio_timer)
	_audio_timer.timeout.connect(audio_timer_randomizer)
	_audio_timer.timeout.connect(play_audio)
	audio_timer_randomizer()
	

func get_voicelines(path):
	var scene_loads = []

	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == "wav":
					var full_path = path.path_join(file_name)
					scene_loads.append(load(full_path))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return scene_loads
func audio_timer_randomizer():
	_audio_timer.start(randi_range(12,15))
func play_audio():
	$AudioStreamPlayer.stream = _audio_lines[randi_range(0,_audio_lines.size()-1)]
	$AudioStreamPlayer.play() 

func _process(delta: float) -> void:
	var freq_start := 1000.0
	var freq_end := 100.0
	var magnitude = spectrum_instance.get_magnitude_for_frequency_range(freq_start,freq_end,1).length()
	%AnimationTree.tree_root.set_blend_point_position(0,lerp(%AnimationTree.tree_root.get_blend_point_position(0), 3 * magnitude, 10*delta))
