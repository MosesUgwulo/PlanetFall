@tool
extends Resource
class_name PlanetData

@export var planet_noise : PlanetNoise : set = set_planet_noise
@export var radius : float = 1.0 : set = set_radius
@export_range(0, 6, 1) var subdivisions : float = 0 : set = set_subdivisions


func point_on_planet(point_on_sphere : Vector3) -> Vector3:
	if planet_noise == null or planet_noise.noise == null:
		return point_on_sphere * radius
	
	var noise_val = planet_noise.noise.get_noise_3dv(point_on_sphere * planet_noise.noise.frequency * planet_noise.noise.fractal_octaves)

	noise_val = (noise_val + 1) * 0.5

	noise_val = noise_val * planet_noise.amplitude
	noise_val = max(0.0, noise_val - planet_noise.min_height)

	return point_on_sphere * radius * (noise_val + 1.0)


func set_planet_noise(value):
	planet_noise = value
	emit_signal("changed")

	if planet_noise != null and not planet_noise.is_connected("changed", _on_noise_changed):
		planet_noise.connect("changed", _on_noise_changed)


func _on_noise_changed():
	emit_signal("changed")
	

func set_radius(value):
	radius = value
	emit_signal("changed")


func set_subdivisions(value):
	subdivisions = value
	emit_signal("changed")