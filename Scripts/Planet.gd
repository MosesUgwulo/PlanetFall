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
		if mesh and mesh.material_override and planet_data and planet_data.noise_layers.size() > 0:

			var noise = planet_data.noise_layers[0].noise

			var noise_texture = NoiseTexture2D.new()
			noise_texture.noise = noise
			noise_texture.seamless = true
			noise_texture.width = 512
			noise_texture.height = 512

			mesh.material_override.set_shader_parameter("noise", noise_texture)

			mesh.generate_planet(planet_data)

