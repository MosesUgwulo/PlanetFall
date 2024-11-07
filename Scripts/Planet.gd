@tool
extends Node

@export var planet_data : PlanetData : set = set_planet_data
@export var planet_mesh : PlanetMesh

func set_planet_data(value):
	planet_data = value
	planet_mesh.generate_planet(planet_data)

	if planet_data != null and not planet_data.is_connected("changed", _on_planet_changed):
		planet_data.connect("changed", _on_planet_changed)


# Called when the node enters the scene tree for the first time.
func _ready():
	_on_planet_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_planet_changed():
	planet_mesh.generate_planet(planet_data)
