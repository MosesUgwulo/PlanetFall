@tool
extends Resource
class_name PlanetNoise

@export var noise : FastNoiseLite = null : set = set_noise

func set_noise(value):
    noise = value
    emit_signal("changed")

    if noise != null and not noise.is_connected("changed", _on_noise_changed):
        noise.connect("changed", _on_noise_changed)

func _on_noise_changed():
    emit_signal("changed")