@tool
extends Resource
class_name PlanetBiome

@export var gradientTexture: GradientTexture1D : set = set_gradient

func set_gradient(value):
    gradientTexture = value
    emit_signal("changed")
    if gradientTexture != null and not gradientTexture.is_connected("changed", _on_data_changed):
        gradientTexture.connect("changed", _on_data_changed)


func _on_data_changed():
    emit_signal("changed")
