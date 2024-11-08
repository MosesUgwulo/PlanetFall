@tool
extends Resource
class_name PlanetData

@export var noise : FastNoiseLite = null : set = set_noise
@export var radius : float = 1.0 : set = set_radius
@export_range(0, 4, 1) var subdivisions : float = 0 : set = set_subdivisions

func set_noise(value):
	noise = value
	emit_signal("changed")
	

func set_radius(value):
	radius = value
	emit_signal("changed")

func set_subdivisions(value):
	subdivisions = value
	emit_signal("changed")