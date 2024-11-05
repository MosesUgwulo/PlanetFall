@tool
extends Resource
class_name PlanetData

@export var noise : FastNoiseLite = null : set = set_noise

@export var radius : float = 1.0 : set = set_radius

func set_noise(value):
	noise = value
	emit_changed()
	

func set_radius(value):
	radius = value
	emit_changed()