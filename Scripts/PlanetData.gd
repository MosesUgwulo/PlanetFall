@tool
extends Resource
class_name PlanetData

@export var noise_layers : Array[PlanetNoise] : set = set_noise_layers
@export var radius : float = 1.0 : set = set_radius
@export_range(0, 6, 1) var subdivisions : float = 0 : set = set_subdivisions

# MAKE A SEPERATE BRANCH

func point_on_planet(point_on_sphere : Vector3) -> Vector3:
	if noise_layers.is_empty():
		return point_on_sphere * radius


	var first_layer_raw := 0.0
	var total_elevation = 0.0

	if noise_layers[0] != null:
		first_layer_raw = noise_layers[0].evaluate(point_on_sphere)
		total_elevation = first_layer_raw
	
	for i in range(1, noise_layers.size()):
		var layer := noise_layers[i]
		if layer == null:
			continue
		
		var noise_value = layer.evaluate(point_on_sphere, first_layer_raw)
		total_elevation += noise_value
	
	return point_on_sphere * radius * (1.0 + total_elevation)


func set_noise_layers(value):
	noise_layers = value
	emit_signal("changed")

	for layer in noise_layers:
		if layer != null and not layer.is_connected("changed", _on_noise_changed):
			layer.connect("changed", _on_noise_changed)


func set_radius(value):
	radius = value
	emit_signal("changed")


func set_subdivisions(value):
	subdivisions = value
	emit_signal("changed")


func _on_noise_changed():
	emit_signal("changed")
