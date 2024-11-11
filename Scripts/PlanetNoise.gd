@tool
extends Resource
class_name PlanetNoise

@export var noise : FastNoiseLite = null : set = set_noise
@export var amplitude : float = 1.0 : set = set_amplitude
@export var min_height : float = 0.0 : set = set_min_height
@export var use_first_layer_as_mask : bool = false : set = set_use_mask
@export var scale_factor : float = 1.0 : set = set_scale_factor


func set_noise(value):
    noise = value
    emit_signal("changed")
    
    if noise != null and not noise.is_connected("changed", _on_noise_changed):
        noise.connect("changed", _on_noise_changed)


func set_amplitude(value):
    amplitude = value
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