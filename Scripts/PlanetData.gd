@tool
extends Resource
class_name PlanetData

# Array of noise layers used to generate the terrain
@export var noise_layers : Array[PlanetNoise] : set = set_noise_layers

# Base radius of the planet
@export var radius : float = 1.0 : set = set_radius

# Number of times to subdivide the base icosphere (higher values = more detail)
@export_range(0, 6, 1) var subdivisions : float = 0 : set = set_subdivisions

@export var use_stepped_terrain: bool = false


# Constants for tracking min and max height of the planet for shader parameters
var min_height : float = INF
var max_height : float = -INF

@export var num_terrain_levels: int = 4 
@export var min_terrain_height: float = 0.0
@export var max_terrain_height: float = 1.0

func points_on_planet(points_on_sphere : Array[Vector3]) -> Array[Vector3]:
	
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
		return points_on_sphere.map(func(p): return p * radius)
	
	
	var total_elevations = calculate_total_elevations(points_on_sphere)


	return calculate_final_points(points_on_sphere, total_elevations)


func calculate_total_elevations(points_on_sphere: Array[Vector3]) -> Array[float]:

	"""
	Calculates the total elevation from all noise layers
	"""
	
	if use_stepped_terrain:
		return calculate_stepped_terrain(points_on_sphere)
	else:
		return calculate_continous_terrain(points_on_sphere)


func calculate_continous_terrain(points_on_sphere: Array[Vector3]) -> Array[float]:

	var base_elevation := 0.0
	var first_layer := 0.0
	var total_elevation: Array[float] = []
	
	# Process first noise layer (can be used as a mask for subsequent layers)
	if noise_layers.size() > 0 and noise_layers[0] != null and noise_layers[0].noise != null:

		for point in points_on_sphere:
			first_layer = calculate_noise(point)

			# print("First layer: ", first_layer)

			# Calculate base elevation
			base_elevation = first_layer * noise_layers[0].amplitude
			base_elevation = max(0.0, base_elevation - noise_layers[0].min_height)
			base_elevation *= noise_layers[0].strength

			total_elevation.push_back(base_elevation)

	# print("Total elevation: ", total_elevation)
	# total_elevation = snapped(total_elevation, 0.2)

	# for i in range(1, noise_layers.size()):
	# 	var layer_elevation = calculate_layer_elevation(point_on_sphere, i, first_layer, base_elevation)
		
	# 	layer_elevation = snapped(layer_elevation, 0.2)
	# 	total_elevation += layer_elevation

	return total_elevation



func calculate_stepped_terrain(points_on_sphere: Array[Vector3]) -> Array[float]:
	
	if noise_layers[0] == null or noise_layers[0].noise == null:
		var zeros: Array[float] = []
		zeros.resize(points_on_sphere.size())
		zeros.fill(0.0)
		return zeros
	
	var minVal = INF
	var maxVal = -INF
	var elevations: Array[float] = []

	# Generate terrain level thresholds and heights
	var thresholds: Array[float] = []
	var heights: Array[float] = []


	for i in range(num_terrain_levels):
		var threshold = float(i + 1) / float(num_terrain_levels)
		thresholds.push_back(threshold)
		# print("Threshold: ", threshold)

		var height = lerp(min_terrain_height, max_terrain_height, threshold)
		heights.push_back(height)

	
	for point in points_on_sphere:

		var noise_value = calculate_noise(point)
		minVal = min(minVal, noise_value)
		maxVal = max(maxVal, noise_value)

	# print("Min: ", minVal, " Max: ", maxVal)

	for point in points_on_sphere:
		var normalisedMagnitude = (calculate_noise(point) - minVal) / (maxVal - minVal)

		var normalisedPoint = point.normalized() * normalisedMagnitude

		var elevation = normalisedPoint.length()

		# print("elevation: ", elevation) 

		# Elevation thresholds
		var final_height = heights[0]
		for i in range(thresholds.size()):
			if elevation <= thresholds[i]:
				final_height = heights[i]
				# print("final_height: ", final_height)
				break
		
		elevations.push_back(final_height)
	
	
	return elevations
	



func calculate_noise(point_on_sphere: Vector3) -> float:
	"""
	Calculates the first noise layer value
	"""
	var sample_point = point_on_sphere * noise_layers[0].scale_factor
	var first_noise = noise_layers[0].noise.get_noise_3dv(sample_point)

		# convert noise value to range [0, 1]
	return (first_noise + 1.0) * 0.5



func calculate_layer_elevation(point_on_sphere: Vector3, layer_index: int, first_layer: float, base_elevation: float) -> float:

	"""
	Calculates the elevation from a specific noise layer
	"""

	var layer := noise_layers[layer_index]

	

	if layer == null or layer.noise == null:
		return 0.0
	
	var mask := 1.0

	# Apply first layer as mask if enabled
	if layer.use_first_layer_as_mask:
		mask = pow(first_layer, 1.0)

		if base_elevation <= 0:
			return 0.0
	
	# Sample noise and apply elevation
	var sample_point = point_on_sphere * layer.scale_factor
	var noise_val = layer.noise.get_noise_3dv(sample_point)

	noise_val = (noise_val + 1.0) * 0.5

	noise_val = noise_val * layer.amplitude * mask
	noise_val = max(0.0, noise_val - layer.min_height)
	noise_val *= layer.strength

	return noise_val

	

func calculate_final_points(points_on_sphere: Array[Vector3], heights: Array[float]) -> Array[Vector3]:
	"""
	Calculates the final point on the planet's surface based on the terrain height
	Updates min and max height values for shader parameters
	"""
	var final_points: Array[Vector3] = []

	for i in range(points_on_sphere.size()):
		var point = points_on_sphere[i]
		var height = heights[i]

		var elevation_mult = 1.0 + (height * 0.5)

		var final_point = point * radius * elevation_mult

		var max_radius = radius * (1.0 + 0.5)

		var normalised_point = final_point * (1.0 / max_radius)

		var scaled_radius = normalised_point * radius
 
		min_height = min(min_height, scaled_radius.length())
		max_height = max(max_height, scaled_radius.length())

		final_points.push_back(scaled_radius)

	return final_points



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
