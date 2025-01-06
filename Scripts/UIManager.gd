extends CanvasLayer

@export var planet : Planet

@onready var generateBtn : Button = $"RootControl/MarginContainer/Settings/GenerateBtnVBox/Generate Button"
@onready var seedLineEdit : LineEdit = $"RootControl/MarginContainer/Settings/Seed Setting/Seed Value"
@onready var popupPanel : PopupPanel = $"Control/PopupPanel"
@onready var scaleFactorSpinBox : SpinBox = $"Control/PopupPanel/Control/MarginContainer/VBoxContainer/Scale Factor Setting/Scale Factor Value"

@onready var toggle_button : Button = $"Control/PopupPanel/Control/MarginContainer/VBoxContainer/Toggle Settings"
@onready var content : VBoxContainer = $"Control/PopupPanel/Control/MarginContainer/VBoxContainer/Content"


# Editible values
var scaleFactor : float = 100.0
var seedValue : int = 0
var radius : float = 1.0
var subdivisions : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if planet and planet.get_child(0):

		planet.planet_data = PlanetData.new()
		seedLineEdit.text = str(seedValue)


		var mesh = planet.get_child(0) as PlanetMesh
		if mesh:
			mesh.generate_status_changed.connect(_on_generate_status_changed)

	content.visible = false

	


func _generate_planet():
	planet.planet_data.radius = radius
	planet.planet_data.subdivisions = subdivisions
	seedValue = hash(seedLineEdit.text)
	planet.noise_seed = seedValue
	planet.planet_data.planet_noise.noise.seed = seedValue
	planet.planet_data.planet_noise.scale_factor = scaleFactor
	print("scale factor: ", scaleFactor)
	planet._on_planet_changed()
	


func _on_radius_value_changed(value : float):
	radius = value
	


func _on_subdivisions_value_changed(value : int):
	subdivisions = value


func _on_generate_status_changed(is_generating : bool):
	if generateBtn:
		generateBtn.disabled = is_generating
		generateBtn.text = "Generating..." if is_generating else "Generate"



func _on_noise_settings_button_toggled():
	content.visible = !content.visible
	toggle_button.text = "▼ Noise Settings" if content.visible else "▶ Noise Settings"


func _on_edit_noise_layer_button_pressed():
	popupPanel.visible = true


func _on_noise_types_item_selected(index : int):
	match index:
		0:
			print("Simplex")
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		1:
			print("Simplex Smooth")
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		2:
			print("Cellular")
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_CELLULAR
		3:
			print("Perlin")
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_PERLIN
		4:
			print("Value Cubic")
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
		5:
			print("Value")
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_VALUE
		_:
			print("Unknown")
			planet.planet_data.planet_noise.noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH



func _on_scale_factor_value_changed(value:float):
	scaleFactor = value
