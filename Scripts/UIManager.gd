extends CanvasLayer

@export var planet : Planet

# ============================= NOISE SETTINGS =============================
@onready var noise_settings_btn : Button = get_node("RootControl/MarginContainer/Settings/Noise Settings Button/Noise Settings")
@onready var noise_settings_dropdown : HBoxContainer = get_node("RootControl/MarginContainer/Settings/Noise Settings Dropdown")
@onready var seed_line_edit : LineEdit = get_node("RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Seed Setting/Seed Value")
@onready var frequency_line_edit : LineEdit = get_node("RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Frequency Setting/Frequency LineEdit")
@onready var frequency_slider : HSlider = get_node("RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Frequency Setting/Frequency Value")
@onready var weighted_strength_line_edit : LineEdit = get_node("RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Weighted Strength Setting/Weighted Strength LineEdit")
@onready var weighted_strength_slider : HSlider = get_node("RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Weighted Strength Setting/Weighted Strength Value")


# ============================= BIOME SETTINGS =============================
@onready var biome_settings_btn : Button = get_node("RootControl/MarginContainer/Settings/Biome Settings Button/Biome Settings")
@onready var biome_settings_dropdown : HBoxContainer = get_node("RootControl/MarginContainer/Settings/Biome Settings Dropdown")

@onready var generateBtn : Button = get_node("RootControl/MarginContainer/Settings/GenerateBtnVBox/Generate Button")

# TODO: ADD TOOL TIPS TO EVERYTHING

# Editible values
# ============================= NOISE SETTINGS =============================
var seedValue : int = 0
var frequency : float = 0.01
var scale_factor : float = 1.0

var fractal_octaves : int = 5
var fractal_lacunarity : float = 2.0
var fractal_gain : float = 0.5
var fractal_weighted_strength : float = 0.0

var radius : float = 1.0
var subdivisions : int = 0



# Called when the node enters the scene tree for the first time.
func _ready():

	frequency_slider.min_value = 0.0001
	frequency_slider.max_value = 1.0
	frequency_slider.step = 0.0001
	frequency_slider.value = 0.01
	frequency_line_edit.text = str(frequency_slider.value)

	if planet and planet.get_child(0):

		planet.planet_data = PlanetData.new()
		seed_line_edit.text = str(seedValue)


		var mesh = planet.get_child(0) as PlanetMesh
		if mesh:
			mesh.generate_status_changed.connect(_on_generate_status_changed)

	noise_settings_dropdown.visible = false
	biome_settings_dropdown.visible = false
	


func _generate_planet():
	# ============================= NOISE SETTINGS =============================
	planet.planet_data.planet_noise.noise.seed = seedValue
	planet.planet_data.planet_noise.noise.frequency = frequency
	planet.planet_data.planet_noise.scale_factor = scale_factor

	planet.planet_data.planet_noise.noise.fractal_octaves = fractal_octaves
	planet.planet_data.planet_noise.noise.fractal_lacunarity = fractal_lacunarity
	planet.planet_data.planet_noise.noise.fractal_gain = fractal_gain
	planet.planet_data.planet_noise.noise.fractal_weighted_strength = fractal_weighted_strength


	planet.planet_data.radius = radius
	planet.planet_data.subdivisions = subdivisions
	
	planet._on_planet_changed()


# ============================= NOISE SETTINGS =============================
func _on_noise_settings_button_toggled():
	noise_settings_dropdown.visible = !noise_settings_dropdown.visible
	noise_settings_btn.text = "▼ Noise Settings" if noise_settings_dropdown.visible else "▶ Noise Settings"



func _on_noise_types_item_selected(index : int):
	match index:
		0:
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		1:
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		2:
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_CELLULAR
		3:
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_PERLIN
		4:
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
		5:
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_VALUE
		_:
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH



func _on_seed_value_text_changed(new_text):
	seedValue = hash(new_text)



func _on_frequency_value_changed(value : float):
	frequency_line_edit.text = str(value)
	frequency = value



func _on_frequency_line_edit_text_changed(new_text : String):
	frequency_slider.value = float(new_text)
	frequency = frequency_slider.value



func _on_frequency_line_edit_focus_exited():
	frequency_slider.value = float(frequency_line_edit.text)
	frequency = frequency_slider.value



func _on_scale_factor_value_changed(value : float):
	scale_factor = value



func _on_fractal_types_item_selected(index : int):
	match index:
		0:
			planet.planet_data.planet_noise.noise.fractal_type = FastNoiseLite.FRACTAL_NONE
		1:
			planet.planet_data.planet_noise.noise.fractal_type = FastNoiseLite.FRACTAL_FBM
		2:
			planet.planet_data.planet_noise.noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
		_:
			planet.planet_data.planet_noise.noise.fractal_type = FastNoiseLite.FRACTAL_FBM



func _on_octaves_value_changed(value : int):
	fractal_octaves = value



func _on_lacunarity_value_changed(value : float):
	fractal_lacunarity = value



func _on_gain_value_changed(value:float):
	fractal_gain = value



func _on_weighted_strength_line_edit_text_submitted(new_text : String):
	weighted_strength_slider.value = float(new_text)
	fractal_weighted_strength = weighted_strength_slider.value



func _on_weighted_strength_line_edit_focus_exited():
	weighted_strength_slider.value = float(weighted_strength_line_edit.text)
	fractal_weighted_strength = weighted_strength_slider.value



func _on_weighted_strength_value_changed(value : float):
	weighted_strength_line_edit.text = str(value)
	fractal_weighted_strength = value



# ============================= BIOME SETTINGS =============================
func _on_biome_settings_pressed():
	biome_settings_dropdown.visible = !biome_settings_dropdown.visible
	biome_settings_btn.text = "▼ Biome Settings" if biome_settings_dropdown.visible else "▶ Biome Settings"








func _on_radius_value_changed(value : float):
	radius = value
	


func _on_subdivisions_value_changed(value : int):
	subdivisions = value



func _on_generate_status_changed(is_generating : bool):
	if generateBtn:
		generateBtn.disabled = is_generating
		generateBtn.text = "Generating..." if is_generating else "Generate"


























