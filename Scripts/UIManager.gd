extends CanvasLayer

@export var planet : Planet

# ============================= NOISE SETTINGS =============================
@onready var noise_settings_btn : Button = $"RootControl/MarginContainer/Settings/Noise Settings Button/Noise Settings"
@onready var noise_settings_dropdown : HBoxContainer = $"RootControl/MarginContainer/Settings/Noise Settings Dropdown"
@onready var seedLineEdit : LineEdit = $"RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Seed Setting/Seed Value"
@onready var frequencyLineEdit : LineEdit = $"RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Frequency Setting/Frequency LineEdit"
@onready var frequencySlider : HSlider = $"RootControl/MarginContainer/Settings/Noise Settings Dropdown/Noise Settings Container/Frequency Setting/Frequency Value"

@onready var generateBtn : Button = $"RootControl/MarginContainer/Settings/GenerateBtnVBox/Generate Button"

# TODO: ADD TOOL TIPS TO EVERYTHING

# Editible values
var seedValue : int = 0
var frequency : float = 0.01
var scaleFactor : float = 1.0
var radius : float = 1.0
var subdivisions : int = 0



# Called when the node enters the scene tree for the first time.
func _ready():

	frequencySlider.min_value = 0.0001
	frequencySlider.max_value = 1.0
	frequencySlider.step = 0.0001
	frequencySlider.value = 0.01
	frequencyLineEdit.text = str(frequencySlider.value)

	if planet and planet.get_child(0):

		planet.planet_data = PlanetData.new()
		seedLineEdit.text = str(seedValue)


		var mesh = planet.get_child(0) as PlanetMesh
		if mesh:
			mesh.generate_status_changed.connect(_on_generate_status_changed)

	noise_settings_dropdown.visible = false
	


func _generate_planet():
	planet.planet_data.planet_noise.noise.seed = seedValue
	planet.planet_data.planet_noise.noise.frequency = frequency
	planet.planet_data.planet_noise.scale_factor = scaleFactor

	planet.planet_data.radius = radius
	planet.planet_data.subdivisions = subdivisions
	
	planet._on_planet_changed()



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
	frequencyLineEdit.text = str(value)
	frequency = value



func _on_frequency_line_edit_text_changed(new_text : String):
	frequencySlider.value = float(new_text)
	frequency = frequencySlider.value



func _on_frequency_line_edit_focus_exited():
	frequencySlider.value = float(frequencyLineEdit.text)
	frequency = frequencySlider.value



func _on_scale_factor_value_changed(value : float):
	scaleFactor = value



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
	planet.planet_data.planet_noise.noise.fractal_octaves = value




func _on_lacunarity_value_changed(value : float):
	planet.planet_data.planet_noise.noise.fractal_lacunarity = value













func _on_radius_value_changed(value : float):
	radius = value
	


func _on_subdivisions_value_changed(value : int):
	subdivisions = value



func _on_generate_status_changed(is_generating : bool):
	if generateBtn:
		generateBtn.disabled = is_generating
		generateBtn.text = "Generating..." if is_generating else "Generate"












