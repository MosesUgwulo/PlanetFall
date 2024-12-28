extends CanvasLayer

@export var planet : Planet

# Editible values
var radius : float
var subdivisions : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _generate_planet():
	planet.planet_data.radius = radius
	planet.planet_data.subdivisions = subdivisions
	planet._on_planet_changed()
	


func _on_radius_value_changed(value : float):
	radius = value
	


func _on_subdivisions_value_changed(value : int):
	subdivisions = value
