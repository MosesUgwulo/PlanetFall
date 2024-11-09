@tool
extends Resource
class_name PlanetData

@export var planet_noise : PlanetNoise : set = set_planet_noise
@export var radius : float = 1.0 : set = set_radius
@export_range(0, 4, 1) var subdivisions : float = 0 : set = set_subdivisions

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