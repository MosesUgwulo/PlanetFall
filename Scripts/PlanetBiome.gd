@tool
extends Resource
class_name PlanetBiome

"""
A resource that stores the biome data for a planet
"""

@export var gradientTexture: GradientTexture1D : set = set_gradient
@export var start_height : float : set = set_start_height

func set_gradient(value):

    """
    Setter for gradientTexture that ensures proper signal connections
    and triggers planet updates when the gradient texture is changed
    """

    gradientTexture = value
    emit_signal("changed")
    if gradientTexture != null and not gradientTexture.is_connected("changed", _on_data_changed):
        gradientTexture.connect("changed", _on_data_changed)


func set_start_height(value):

    """
    Setter for start_height that sends a signal
    and triggers planet updates when the start height is changed
    """

    start_height = value
    emit_signal("changed")


func _on_data_changed():

    """
    Called when the gradient texture is changed
    """
    
    emit_signal("changed")
