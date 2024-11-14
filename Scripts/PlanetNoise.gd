@tool
extends Resource
class_name PlanetNoise

@export var noise : FastNoiseLite = null : set = set_noise
@export var strength : float = 1.0 : set = set_strength
@export_range(1, 8, 1) var num_layers : int = 1 : set = set_num_layers
@export var base_roughness : float = 1.0 : set = set_base_roughness
@export var roughness : float = 2.0 : set = set_roughness
@export var persistence : float = 0.5 : set = set_persistence
@export var center : Vector3 = Vector3.ZERO : set = set_center
@export var min_height : float = 0.0 : set = set_min_height
@export var use_first_layer_as_mask : bool = false : set = set_use_mask



func evaluate(point : Vector3, mask_value: float = 1.0) -> float:
	if noise == null:
		return 0.0
	
	var noise_value: float = 0.0
	var frequency: float = base_roughness
	var amplitude: float = 1.0

	for i in num_layers:
		var noise_point = point * frequency + center
		var v = noise.get_noise_3dv(noise_point)

		noise_value += (v + 1.0) * 0.5 * amplitude

		frequency *= roughness
		amplitude *= persistence
	
	noise_value = maxf(0.0, noise_value - min_height)

	if use_first_layer_as_mask:
		noise_value *= pow(mask_value, 2.0)

	return noise_value * strength


func set_noise(value):
	noise = value
	emit_signal("changed")
	
	if noise != null and not noise.is_connected("changed", _on_noise_changed):
		noise.connect("changed", _on_noise_changed)


func set_strength(value):
	strength = value
	emit_signal("changed")


func set_num_layers(value):
	num_layers = value
	emit_signal("changed")


func set_base_roughness(value):
	base_roughness = value
	emit_signal("changed")


func set_roughness(value):
	roughness = value
	emit_signal("changed")


func set_persistence(value):
	persistence = value
	emit_signal("changed")


func set_center(value):
	center = value
	emit_signal("changed")


func set_min_height(value):
	min_height = value
	emit_signal("changed")


func set_use_mask(value):
	use_first_layer_as_mask = value
	emit_signal("changed")


func _on_noise_changed():
	emit_signal("changed")
