@tool
extends Node

# Reference to the planet data resource
@export var planet_data : PlanetData : set = set_planet_data
@export var noise_seed : int = 0

func set_planet_data(value):

	"""
	Setter for planet_data that ensures proper signal connections
	and triggers planet updates when the planet data is changed
	"""

	planet_data = value
	_on_planet_changed()

	if planet_data != null and not planet_data.is_connected("changed", _on_planet_changed):
		planet_data.connect("changed", _on_planet_changed)


# Called when the node enters the scene tree for the first time.
func _ready():

	"""
	Initializes randomized planet data when the node is ready
	and updates the planet mesh
	"""
	# _initialize_planet_data()

	_on_planet_changed()


func _initialize_planet_data():
	
	"""
	Initializes randomized planet data for testing purposes
	only if the game is not running in the editor
	"""
	if not Engine.is_editor_hint():
		if planet_data and planet_data.noise_layers.size() > 0 and planet_data.noise_layers[0].noise:

			planet_data.noise_layers[0].noise.seed = noise_seed

			var rng = RandomNumberGenerator.new()
			rng.seed = noise_seed

			planet_data.num_terrain_levels = rng.randi_range(4, 8)
			planet_data.max_terrain_height = rng.randf_range(1.0, 3.0)
			planet_data.noise_layers[0].noise.fractal_weighted_strength = rng.randf_range(0.0, 1.0)
			planet_data.noise_layers[0].noise.fractal_octaves = rng.randi_range(1, 10)
			planet_data.noise_layers[0].noise.fractal_lacunarity = rng.randf_range(-1.0, 1.0)
			planet_data.noise_layers[0].noise.fractal_gain = rng.randf_range(0.0, 1.0)
			planet_data.subdivisions = rng.randi_range(5, 6)
			planet_data.noise_layers[0].scale_factor = rng.randf_range(50, 100)
			planet_data.noise_layers[0].noise.frequency = rng.randf_range(0.01, 0.02)


func _on_planet_changed():

	"""
	Handles updates when the planet data resource is changed
	and regenerates the planet mesh
	"""

	if get_child_count() > 0:
		var mesh = get_child(0) as PlanetMesh
		if mesh and mesh.material_override:
			
			# print("=====================================")
			# print("Min height: ", planet_data.min_height)
			# print("Max height: ", planet_data.max_height)
			# print("Num terrain levels: ", planet_data.num_terrain_levels)
			# print("Max terrain height: ", planet_data.max_terrain_height)
			# print("Fractal weighted strength: ", planet_data.noise_layers[0].noise.fractal_weighted_strength)
			# print("Fractal octaves: ", planet_data.noise_layers[0].noise.fractal_octaves)
			# print("Fractal lacunarity: ", planet_data.noise_layers[0].noise.fractal_lacunarity)
			# print("Fractal gain: ", planet_data.noise_layers[0].noise.fractal_gain)
			# print("Subdivisions: ", planet_data.subdivisions)
			# print("Scale factor: ", planet_data.noise_layers[0].scale_factor)
			# print("Frequency: ", planet_data.noise_layers[0].noise.frequency)

			mesh.generate_planet(planet_data)

