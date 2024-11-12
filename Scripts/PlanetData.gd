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
	
	var base_elevation := 0.0
	var first_layer_raw := 0.0

	if noise_layers.size() > 0 and noise_layers[0] != null and noise_layers[0].noise != null:
		
		var sample_point = point_on_sphere * noise_layers[0].scale_factor
		var first_noise = noise_layers[0].noise.get_noise_3dv(sample_point)

		first_layer_raw = (first_noise + 1.0) * 0.5

		base_elevation = first_layer_raw * noise_layers[0].amplitude
		base_elevation = max(0.0, base_elevation - noise_layers[0].min_height)
	
	var total_elevation := base_elevation

	for i in range(1, noise_layers.size()):

		var layer := noise_layers[i]
		if layer == null or layer.noise == null:
			continue
		
		var mask := 1.0

		if layer.use_first_layer_as_mask:
			mask = first_layer_raw
			mask = pow(mask, 2.0)

			if base_elevation <= 0:
				continue
		
		var sample_point = point_on_sphere * layer.scale_factor
		var noise_val = layer.noise.get_noise_3dv(sample_point)

		noise_val = (noise_val + 1.0) * 0.5
		noise_val = noise_val * layer.amplitude * mask
		noise_val = max(0.0, noise_val - layer.min_height)

		total_elevation += noise_val

	return point_on_sphere * radius * (total_elevation + 1.0)


func set_noise_layers(value):
	noise_layers = value
	emit_signal("changed")

	for noise_layer in noise_layers:
		if noise_layer != null and not noise_layer.is_connected("changed", _on_noise_changed):
			noise_layer.connect("changed", _on_noise_changed)


func set_radius(value):
	radius = value
	emit_signal("changed")


func set_subdivisions(value):
	subdivisions = value
	emit_signal("changed")


func _on_noise_changed():
	emit_signal("changed")