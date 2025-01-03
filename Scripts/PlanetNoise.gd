@tool
extends Resource
class_name PlanetNoise

# Noise generator for creating terrain variation
@export var noise : FastNoiseLite = null : set = set_noise

# Controls the scale / frequency of the noise
@export var scale_factor : float = 1.0 : set = set_scale_factor


# Setter functions that emit a signal when the noise parameters are changed
func set_noise(value):
    noise = value
    emit_signal("changed")
    
    if noise != null and not noise.is_connected("changed", _on_noise_changed):
        noise.connect("changed", _on_noise_changed)


func set_scale_factor(value):
    scale_factor = value
    emit_signal("changed")


func _on_noise_changed():
    emit_signal("changed")