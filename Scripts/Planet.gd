@tool
extends Node

@export var planet_data : PlanetData : set = set_planet_data

func set_planet_data(value):
	planet_data = value
	_on_planet_changed()

	if planet_data != null and not planet_data.is_connected("changed", _on_planet_changed):
		planet_data.connect("changed", _on_planet_changed)


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_planet_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_planet_changed():
	if get_child_count() > 0:
		var mesh = get_child(0) as PlanetMesh
		if mesh and mesh.material_override:
			
			mesh.material_override.set_shader_parameter("water_height", planet_data.water_height)
			mesh.material_override.set_shader_parameter("grass_height", planet_data.grass_height)
			mesh.material_override.set_shader_parameter("hill_height", planet_data.hill_height)
			mesh.material_override.set_shader_parameter("mountain_height", planet_data.mountain_height)
			mesh.generate_planet(planet_data)

