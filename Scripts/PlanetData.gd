@tool
extends Resource
class_name PlanetData

@export var noise_layers : Array[PlanetNoise] : set = set_noise_layers
@export var radius : float = 1.0 : set = set_radius
@export_range(0, 6, 1) var subdivisions : float = 0 : set = set_subdivisions

@export var water_height : float = 0.0
@export var grass_height : float = 0.1
@export var hill_height : float = 0.2
@export var mountain_height : float = 0.3

var min_height : float = INF
var max_height : float = -INF

# MAKE A SEPERATE BRANCH

func point_on_planet(point_on_sphere : Vector3) -> Vector3:
	if noise_layers.is_empty():
		return point_on_sphere * radius
	
	var height = get_vertex_height(point_on_sphere)
	var final_point = point_on_sphere * radius * (height + 1.0)

	min_height = min(min_height, final_point.length())
	max_height = max(max_height, final_point.length())

	return final_point


func get_vertex_height(vertex: Vector3) -> float:
	if noise_layers.is_empty() or noise_layers[0] == null or noise_layers[0].noise == null:
		
		return 0.0

	var sample_point = vertex * noise_layers[0].scale_factor
	var noise_value = noise_layers[0].noise.get_noise_3dv(sample_point)
	var terrain_level = (noise_value + 1.0) * 0.5


	if terrain_level < 0.25:
		return water_height
	elif terrain_level < 0.5:
		return grass_height
	elif terrain_level < 0.75:
		return hill_height
	else:
		return mountain_height

func set_noise_layers(value):
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
	min_height = INF
	max_height = -INF