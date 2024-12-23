@tool
extends Resource
class_name PlanetNoise

# Noise generator for creating terrain variation
@export var noise : FastNoiseLite = null : set = set_noise

# Controls the height range of the noise
@export var amplitude : float = 1.0 : set = set_amplitude

# Controls the strength of the noise
@export var strength : float = 1.0 : set = set_strength

# Minimum height threshold for the noise to take effect
@export var min_height : float = 0.0 : set = set_min_height

# If true, uses the first noise layer as a mask for subsequent layers
@export var use_first_layer_as_mask : bool = false : set = set_use_mask

# Controls the scale / frequency of the noise
@export var scale_factor : float = 1.0 : set = set_scale_factor


# Setter functions that emit a signal when the noise parameters are changed
func set_noise(value):
    noise = value
    emit_signal("changed")
    
    if noise != null and not noise.is_connected("changed", _on_noise_changed):
        noise.connect("changed", _on_noise_changed)


func set_amplitude(value):
    amplitude = value
    emit_signal("changed")


func set_strength(value):
    strength = value
    emit_signal("changed")


func set_min_height(value):
    min_height = value
    emit_signal("changed")


func set_use_mask(value):
    use_first_layer_as_mask = value
    emit_signal("changed")


func set_scale_factor(value):
    scale_factor = value
    emit_signal("changed")


func _on_noise_changed():
    emit_signal("changed")