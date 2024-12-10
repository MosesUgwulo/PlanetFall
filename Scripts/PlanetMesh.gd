@tool
extends MeshInstance3D
class_name PlanetMesh

# Array to store data for the planet
var triangles = [] # Stores triangle face data
var vertices = [] # Stores vertex positions


func _ready():
	# Clears any existing mesh data when the node is ready
	vertices.clear()
	triangles.clear()
	mesh = null


func generate_planet(planet_data : PlanetData):

	"""
	Main function to generate the planet mesh using the planet data provided
	Parameters:
		planet_data: Contains the parameters for planet generation (noise layers, radius, terrain heights, etc...)
	"""

	# planet_data.randomise_levels()

	# Reset min and max height tracking in planet data
	planet_data.reset_height()

	# Clears any existing mesh data
	vertices.clear()
	triangles.clear()
	mesh = null

	# Generate the planet in three steps:
	# 1. Generate the base icosphere
	generate_icosphere()
	# 2. Subdivide the icosphere for more detail
	subdivide_icosphere(planet_data)
	# 3. Generate the final mesh with some form of displacement based on the noise layers
	generate_mesh(planet_data)


func generate_icosphere():
	
	"""
	Creates a basic icosphere, which serves as the base shape for the planet
	Reference: https://github.com/codatproduction/Solar-system
	"""

	# Golden ratio used for icosphere vertex calculation
	var t = (1.0 + sqrt(5.0)) / 2.0

	# Create 12 vertices of an icosahedron
	# All vertices are normalised to create a sphere
	vertices.push_back(Vector3(-1,  t,  0).normalized())
	vertices.push_back(Vector3(1, t, 0).normalized())
	vertices.push_back(Vector3(-1, -t, 0).normalized())
	vertices.push_back(Vector3(1, -t, 0).normalized())
	vertices.push_back(Vector3(0, -1, t).normalized())
	vertices.push_back(Vector3(0, 1, t).normalized())
	vertices.push_back(Vector3(0, -1, -t).normalized())
	vertices.push_back(Vector3(0, 1, -t).normalized())
	vertices.push_back(Vector3(t, 0, -1).normalized())
	vertices.push_back(Vector3(t, 0, 1).normalized())
	vertices.push_back(Vector3(-t, 0, -1).normalized())
	vertices.push_back(Vector3(-t, 0, 1).normalized())
	
	# Create 20 triangular faces connecting the 12 vertices
	triangles.push_back(Triangle.new(0, 11, 5))
	triangles.push_back(Triangle.new(0, 5, 1))
	triangles.push_back(Triangle.new(0, 1, 7))
	triangles.push_back(Triangle.new(0, 7, 10))
	triangles.push_back(Triangle.new(0, 10, 11))
	triangles.push_back(Triangle.new(1, 5, 9))
	triangles.push_back(Triangle.new(5, 11, 4))
	triangles.push_back(Triangle.new(11, 10, 2))
	triangles.push_back(Triangle.new(10, 7, 6))
	triangles.push_back(Triangle.new(7, 1, 8))
	triangles.push_back(Triangle.new(3, 9, 4))
	triangles.push_back(Triangle.new(3, 4, 2))
	triangles.push_back(Triangle.new(3, 2, 6))
	triangles.push_back(Triangle.new(3, 6, 8))
	triangles.push_back(Triangle.new(3, 8, 9))
	triangles.push_back(Triangle.new(4, 9, 5))
	triangles.push_back(Triangle.new(2, 4, 11))
	triangles.push_back(Triangle.new(6, 2, 10))
	triangles.push_back(Triangle.new(8, 6, 7))
	triangles.push_back(Triangle.new(9, 8, 1))


func generate_mesh(planet_data : PlanetData):

	"""
	Generates the final mesh using the vertices and triangles
	Applies height displacement based on planet_data passed in
	"""

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	var points_to_process: Array[Vector3] = []

	# Process each triangle
	for triangle in triangles:
		for vertex_index in triangle.vertices:
			points_to_process.push_back(vertices[vertex_index].normalized())

	var displaced_points = planet_data.points_on_planet(points_to_process)
		
	var point_index = 0
	for triangle in triangles:

		var displaced_a = displaced_points[point_index]
		var displaced_b = displaced_points[point_index + 1]
		var displaced_c = displaced_points[point_index + 2]

		# Calculate face normal for lighting
		var normal = (displaced_b - displaced_a).cross(displaced_c - displaced_a).normalized()

		# Add vertices in reverse order - manual for now
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(displaced_c)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(displaced_b)
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(displaced_a)
		
		point_index += 3

	surface_tool.index()

	# Update shader parameters with min and max height ranges
	if material_override:
		material_override.set_shader_parameter("min_height", planet_data.min_height)
		material_override.set_shader_parameter("max_height", planet_data.max_height)

	# Create the final mesh
	var t = MeshDataTool.new()
	t.create_from_surface(surface_tool.commit(), 0)
	self.mesh = surface_tool.commit()


func subdivide_icosphere(planet_data : PlanetData):

	"""
	Subdivides the icosphere to add more detail to the planet mesh
	The number of subdivisions is controlled by the planet_data.subdivisions
	Reference: https://github.com/codatproduction/Solar-system
	"""
	
	# Cache to store middle points between vertices to avoid duplication
	var cache = {}

	# Perform subdivision for specificed number of times
	for i in planet_data.subdivisions:
		var new_triangle = []

		# Process each triangle
		for triangle in triangles:
			var a = triangle.vertices[0]
			var b = triangle.vertices[1]
			var c = triangle.vertices[2]

			# Get the middle points of each edge
			var ab = get_middle_point(cache, a, b)
			var bc = get_middle_point(cache, b, c)
			var ca = get_middle_point(cache, c, a)

			# Create four new triangles from the original triangle
			new_triangle.push_back(Triangle.new(a, ab, ca))
			new_triangle.push_back(Triangle.new(b, bc, ab))
			new_triangle.push_back(Triangle.new(c, ca, bc))
			new_triangle.push_back(Triangle.new(ab, bc, ca))

		triangles = new_triangle


func get_middle_point(cache : Dictionary, a, b):

	"""
	Calculates and caches the middle point between two vertices
	Returns the index of the middle point vertex
	Referece: https://github.com/codatproduction/Solar-system
	"""

	var smaller = min(a, b)
	var greater = max(a, b)
	var key = (smaller << 16) + greater

	# Return cached value if it exists
	if cache.has(key):
		return cache.get(key)

	# Calculate a new middle point 
	var point_a = vertices[a]
	var point_b = vertices[b]
	var middle = lerp(point_a, point_b, 0.5).normalized()

	# Add new vertex and cache it
	var ret = vertices.size()
	vertices.push_back(middle)
	cache[key] = ret
	return ret

# Class to represent a triangle face with 3 vertices

class Triangle:
	var vertices = []
	func _init(a, b, c):
		vertices.push_back(a)
		vertices.push_back(b)
		vertices.push_back(c)
