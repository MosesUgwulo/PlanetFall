@tool
extends MeshInstance3D
class_name PlanetMesh

var triangles = []
var vertices = []

func _ready():
	vertices.clear()
	triangles.clear()
	mesh = null


func generate_planet(planet_data : PlanetData):
	planet_data.reset_height()

	vertices.clear()
	triangles.clear()
	mesh = null

	

	generate_icosphere()
	subdivide_icosphere(planet_data)
	generate_mesh(planet_data)

# Generate an icosphere
func generate_icosphere():
	
	var t = (1.0 + sqrt(5.0)) / 2.0

	# Vertices
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
	
	# Faces
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

# Generate a mesh from the vertices and triangles
func generate_mesh(planet_data : PlanetData):

	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	var vertex_heights = {}
	for vertex_idx in vertices.size():
		var vertex = vertices[vertex_idx].normalized()
		var height = planet_data.point_on_planet(vertex).length()
		vertex_heights[vertex_idx] = height
	
	for triangle in triangles:
		for i in range(3):
			var current_idx = triangle.vertices[i]
			var next_idx = triangle.vertices[(i + 1) % 3]

			var current_height = vertex_heights[current_idx]
			var next_height = vertex_heights[next_idx]

			if abs(current_height - next_height) > 0.01:
				var avg_height = (current_height + next_height) / 2.0
				vertex_heights[current_idx] = lerp(current_height, avg_height, 0.5)
				vertex_heights[next_idx] = lerp(next_height, avg_height, 0.5)

	for i in triangles.size():
		var triangle = triangles[i]

		# Calculate the face normals
		var a = vertices[triangle.vertices[0]]
		var b = vertices[triangle.vertices[1]]
		var c = vertices[triangle.vertices[2]]

		var height_a = vertex_heights[triangle.vertices[0]]
		var height_b = vertex_heights[triangle.vertices[1]]
		var height_c = vertex_heights[triangle.vertices[2]]
		
		var displaced_a = a.normalized() * planet_data.radius * (height_a + 1.0)
		var displaced_b = b.normalized() * planet_data.radius * (height_b + 1.0)
		var displaced_c = c.normalized() * planet_data.radius * (height_c + 1.0)

		var normal = (displaced_b - displaced_a).cross(displaced_c - displaced_a).normalized()

		for j in range(3):
			var vertex = vertices[triangle.vertices[2 - j]].normalized()
			var height = vertex_heights[triangle.vertices[2 - j]]
			var displaced_vertex = vertex * planet_data.radius * (height + 1.0)

			surface_tool.set_normal(normal)
			surface_tool.add_vertex(displaced_vertex)

	surface_tool.index()

	if material_override:
		material_override.set_shader_parameter("min_height", planet_data.min_height)
		material_override.set_shader_parameter("max_height", planet_data.max_height)

	var t = MeshDataTool.new()
	t.create_from_surface(surface_tool.commit(), 0)
	self.mesh = surface_tool.commit()

# Subdivide the icosphere
func subdivide_icosphere(planet_data : PlanetData):

	var cache = {}

	for i in planet_data.subdivisions:
		var new_triangle = []

		for triangle in triangles:
			var a = triangle.vertices[0]
			var b = triangle.vertices[1]
			var c = triangle.vertices[2]

			var ab = get_middle_point(cache, a, b)
			var bc = get_middle_point(cache, b, c)
			var ca = get_middle_point(cache, c, a)

			new_triangle.push_back(Triangle.new(a, ab, ca))
			new_triangle.push_back(Triangle.new(b, bc, ab))
			new_triangle.push_back(Triangle.new(c, ca, bc))
			new_triangle.push_back(Triangle.new(ab, bc, ca))

		triangles = new_triangle

# Get the middle point between two vertices
func get_middle_point(cache : Dictionary, a, b):
	var smaller = min(a, b)
	var greater = max(a, b)
	var key = (smaller << 16) + greater

	if cache.has(key):
		return cache.get(key)

	var point_a = vertices[a]
	var point_b = vertices[b]
	var middle = lerp(point_a, point_b, 0.5).normalized()
	var ret = vertices.size()
	vertices.push_back(middle)
	cache[key] = ret
	return ret

# Triangle class
class Triangle:
	var vertices = []
	func _init(a, b, c):
		vertices.push_back(a)
		vertices.push_back(b)
		vertices.push_back(c)
