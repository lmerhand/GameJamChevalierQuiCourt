extends TextureRect
@export var textures : Array[Texture]

var tier_to_texture = {0:0, 1:2, 2:4, 3:6, 4:8}
var half_tier_to_texture = {0:1, 1:3, 2:5, 3:7, 4:7}

func _ready() -> void:
	GlobalSignal.changed_tier.connect(update_texture)
	GlobalSignal.changed_half_tier.connect(update_half_texture)

func update_texture(tier):
	texture = textures[tier_to_texture[tier]]
func update_half_texture(tier):
	texture = textures[half_tier_to_texture[tier]]
