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


# Array of biomes used to generate the terrain
@export_group("Biomes")
@export var biomes : Array[PlanetBiome] : set = set_biomes
@export var biome_noise : FastNoiseLite : set = set_biome_noise
@export var biome_amplitude : float = 1.0 : set = set_biome_amplitude
@export var biome_offset : float = 1.0 : set = set_biome_offset
@export_range(0.0, 1.0) var biome_blend : float = 1.0 : set = set_biome_blend


@export_group("Terrain")
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

		
		var height = lerp(min_terrain_height, max_terrain_height, threshold)
		heights.push_back(height)


	# generate_gradient_colors_for_terrain_levels(thresholds, noise_layers[0].noise.seed)
	
	for point in points_on_sphere:

		var noise_value = calculate_noise(point)
		minVal = min(minVal, noise_value)
		maxVal = max(maxVal, noise_value)

	

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


func calculate_biome_noise(point_on_sphere: Vector3) -> float:
	"""
	Calculates the biome noise value
	"""
	if biome_noise == null:
		return 0.0
	var sample_point = point_on_sphere * 100.0
	var biome_noise_val = biome_noise.get_noise_3dv(sample_point)
	
	# convert noise value to range [0, 1]
	return (biome_noise_val + 1.0) * 0.5


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
		
		var final_point = point * radius * (1.0 + height)

		var base_radius = point * radius
		var height_difference = final_point.length() - base_radius.length()

		# print("Height difference: ", height_difference)
 
		min_height = min(min_height, height_difference)
		max_height = max(max_height, height_difference)

		final_points.push_back(final_point)

	return final_points



# func generate_gradient_colors_for_terrain_levels(thresholds: Array[float], noise_seed: int) -> void:
# 	if biome and biome.gradientTexture:
# 		var gradient = biome.gradientTexture.gradient

# 		while gradient.get_point_count() > 1:
# 			gradient.remove_point(1)

# 		var rng = RandomNumberGenerator.new()
# 		rng.seed = noise_seed

# 		var first_colour = Color(rng.randf_range(0, 1), rng.randf_range(0, 1), rng.randf_range(0, 1), 1.0)
# 		gradient.set_color(0, first_colour)

# 		for i in range(thresholds.size() - 1):
# 			var threshold = thresholds[i]

# 			var random_colour = Color(rng.randf_range(0, 1), rng.randf_range(0, 1), rng.randf_range(0, 1), 1.0)
# 			gradient.add_point(threshold, random_colour)


func update_biome_texture() -> ImageTexture:
	var image_texture = ImageTexture.new()
	var dynamic_image = Image.new()
	var height : int = biomes.size()

	if biomes.size() > 0 and biomes[0] != null and biomes[0].gradientTexture != null:
		
		if height > 0:
			var data: PackedByteArray = []
			var width: int = biomes[0].gradientTexture.get_width()
			
			for biome in biomes:

				if biome == null or biome.gradientTexture == null:
					continue
				
				var image = biome.gradientTexture.get_image()
				data.append_array(image.get_data())

			dynamic_image = Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, data)
			image_texture.set_image(dynamic_image)
			image_texture.resource_name = "GradientTexture"
		
		return image_texture

	return image_texture



func biome_at_height(points_on_sphere : Array[Vector3]) -> Array[float]:
	var biome_percent : Array[float] = []

	if biomes.size() == 0:
		return biome_percent

	for point in points_on_sphere:
		var height_percent : float = (point.y + 1.0) / 2.0

		var noise_value = calculate_biome_noise(point)
		height_percent += (noise_value - biome_offset) * biome_amplitude

		var num_biomes : float = biomes.size()
		var biome_index : float = 0.0
		var blend_range : float = biome_blend / 2.0 + 0.0001

		for i in range(num_biomes):
			if biomes[i] == null:
				continue

			var dst : float = height_percent - biomes[i].start_height
			var weight = clamp(inverse_lerp(-blend_range, blend_range, dst), 0.0, 1.0)
			biome_index *= (1.0 - weight)
			biome_index += i * weight
		
		biome_percent.push_back(biome_index / max(1.0, num_biomes - 1.0))
	
	return biome_percent



func set_noise_layers(value):

	"""
	Setter for noise_layers that ensures proper signal connections
	"""

	noise_layers = value
	emit_signal("changed")

	for noise_layer in noise_layers:
		if noise_layer != null and not noise_layer.is_connected("changed", _on_data_changed):
			noise_layer.connect("changed", _on_data_changed)


func set_biomes(value):

	biomes = value
	emit_signal("changed")
	
	for biome in biomes:
		if biome == null:
			PlanetBiome.new()
			
	
	for biome in biomes:
		if biome != null and not biome.is_connected("changed", _on_data_changed):
			biome.connect("changed", _on_data_changed)


func set_biome_noise(value):
	biome_noise = value
	emit_signal("changed")
	
	if biome_noise != null and not biome_noise.is_connected("changed", _on_data_changed):
		biome_noise.connect("changed", _on_data_changed)


func set_biome_amplitude(value):
	biome_amplitude = value
	emit_signal("changed")


func set_biome_offset(value):
	biome_offset = value
	emit_signal("changed")


func set_biome_blend(value):
	biome_blend = value
	emit_signal("changed")


func set_radius(value):
	radius = value
	emit_signal("changed")


func set_subdivisions(value):
	subdivisions = value
	emit_signal("changed")


func _on_data_changed():
	emit_signal("changed")


func reset_height():

	"""
	Resets the min and max height tracking for the planet
	"""
	
	min_height = INF
	max_height = -INF


func smoothstep(edge0: float, edge1: float, x: float) -> float:
	var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)
