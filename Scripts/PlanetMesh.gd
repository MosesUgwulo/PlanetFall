@tool
extends MeshInstance3D
class_name PlanetMesh

var triangles = []
var vertices = []


func generate_planet(planet_data : PlanetData):
	generate_icosphere()
	generate_mesh(planet_data)

# Generate an icosphere
func generate_icosphere():
	vertices.clear()
	triangles.clear()

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

	for i in triangles.size():
		var triangle = triangles[i]

		for j in triangle.vertices.size():
			var vertex = vertices[triangle.vertices[(triangle.vertices.size() - 1) - j]]
			if planet_data.noise != null:
				vertex = vertex.normalized() * ((planet_data.noise.get_noise_3dv(vertex * planet_data.noise.frequency * planet_data.noise.fractal_octaves) + 1) * 0.5)

			surface_tool.add_vertex(vertex * planet_data.radius)

	surface_tool.index()
	surface_tool.generate_normals()

	var t = MeshDataTool.new()
	t.create_from_surface(surface_tool.commit(), 0)
	self.mesh = surface_tool.commit()


class Triangle:
	var vertices = []
	func _init(a, b, c):
		vertices.push_back(a)
		vertices.push_back(b)
		vertices.push_back(c)
