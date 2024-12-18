@tool
extends Resource
class_name PlanetBiome

@export var gradientTexture: GradientTexture1D : set = set_gradient
@export var start_height : float : set = set_start_height

func set_gradient(value):
    gradientTexture = value
    emit_signal("changed")
    if gradientTexture != null and not gradientTexture.is_connected("changed", _on_data_changed):
        gradientTexture.connect("changed", _on_data_changed)


func set_start_height(value):
    start_height = value
    emit_signal("changed")


func _on_data_changed():
    emit_signal("changed")
