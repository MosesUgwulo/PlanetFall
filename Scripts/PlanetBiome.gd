@tool
extends Resource
class_name PlanetBiome

@export var gradient: GradientTexture1D : set = set_gradient

func set_gradient(value):
    gradient = value
    emit_signal("changed")
    if gradient != null and not gradient.is_connected("changed", _on_data_changed):
        gradient.connect("changed", _on_data_changed)


func _on_data_changed():
    emit_signal("changed")
