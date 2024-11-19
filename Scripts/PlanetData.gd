@tool
extends Resource
class_name PlanetData

# Array of noise layers used to generate the terrain
@export var noise_layers : Array[PlanetNoise] : set = set_noise_layers

# Base radius of the planet
@export var radius : float = 1.0 : set = set_radius

# Number of times to subdivide the base icosphere (higher values = more detail)
@export_range(0, 6, 1) var subdivisions : float = 0 : set = set_subdivisions

# Height thresholds for different terrain types
@export var water_height : float = 0.0
@export var grass_height : float = 0.1
@export var hill_height : float = 0.2
@export var mountain_height : float = 0.3

# Constants for tracking min and max height of the planet for shader parameters
var min_height : float = INF
var max_height : float = -INF


func point_on_planet(point_on_sphere : Vector3) -> Vector3:

	"""
	Calculates the final position of a point on the planet's surface
	taking into account the noise layers and terrain height thresholds
	Parameters:
		point_on_sphere: A normalised point on the unit sphere
	Returns:
		The final position of the point on the planet's surface
	"""

	# Return basic sphere if no noise layers are present
	if noise_layers.is_empty():
		return point_on_sphere * radius
	
	var base_elevation := 0.0
	var first_layer := 0.0

	# Process first noise layer (can be used as a mask for subsequent layers)
	if noise_layers.size() > 0 and noise_layers[0] != null and noise_layers[0].noise != null:
		
		var sample_point = point_on_sphere * noise_layers[0].scale_factor
		var first_noise = noise_layers[0].noise.get_noise_3dv(sample_point)

		# convert noise value to range [0, 1]
		first_layer = (first_noise + 1.0) * 0.5

		# Calculate base elevation
		base_elevation = first_layer * noise_layers[0].amplitude
		base_elevation = max(0.0, base_elevation - noise_layers[0].min_height)

		base_elevation *= noise_layers[0].strength

	var total_elevation := base_elevation

	# Process subsequent noise layers
	for i in range(1, noise_layers.size()):

		var layer := noise_layers[i]
		if layer == null or layer.noise == null:
			continue
		
		var mask := 1.0

		# Apply first layer as mask if enabled
		if layer.use_first_layer_as_mask:
			mask = first_layer
			mask = pow(mask, 2.0)

			if base_elevation <= 0:
				continue
		
		# Sample noise and apply elevation
		var sample_point = point_on_sphere * layer.scale_factor
		var noise_val = layer.noise.get_noise_3dv(sample_point)

		noise_val = (noise_val + 1.0) * 0.5
		noise_val = noise_val * layer.amplitude * mask
		noise_val = max(0.0, noise_val - layer.min_height)

		noise_val *= layer.strength

		total_elevation += noise_val
	
	# Determine terrain types based on elevation
	# var height = 0.0

	# if total_elevation < 0.25:
	# 	height = water_height
	# elif total_elevation < 0.5:
	# 	height = grass_height
	# elif total_elevation < 0.75:
	# 	height = hill_height
	# else:
	# 	height = mountain_height

	# Calculate final point
	var final_point = point_on_sphere * radius * (total_elevation + 1.0)

	min_height = min(min_height, final_point.length())
	max_height = max(max_height, final_point.length())

	return final_point


func set_noise_layers(value):

	"""
	Setter for noise_layers that ensures proper signal connections
	"""

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


func reset_height():

	"""
	Resets the min and max height tracking for the planet
	"""
	
	min_height = INF
	max_height = -INF