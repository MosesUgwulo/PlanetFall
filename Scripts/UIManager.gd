extends CanvasLayer

@export var planet : Planet

@onready var generateBtn : Button = $"RootControl/MarginContainer/Settings/GenerateBtnVBox/Generate Button"
@onready var seedLineEdit : LineEdit = $"RootControl/MarginContainer/Settings/Seed Setting/Seed Value"
@onready var popupPanel : PopupPanel = $"Control/PopupPanel"
@onready var noise_layers_vbox : VBoxContainer = $"Control/PopupPanel/Control/ScrollContainer/VBoxContainer"


# Editible values
var seedValue : int = 0
var radius : float = 1.0
var subdivisions : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if planet and planet.get_child(0):
		popupPanel.visible = false
		planet.planet_data = PlanetData.new()
		seedLineEdit.text = str(seedValue)

		var mesh = planet.get_child(0) as PlanetMesh
		if mesh:
			mesh.generate_status_changed.connect(_on_generate_status_changed)


func _generate_planet():
	planet.planet_data.radius = radius
	planet.planet_data.subdivisions = subdivisions
	seedValue = hash(seedLineEdit.text)
	planet.noise_seed = seedValue
	planet._on_planet_changed()
	


func _on_radius_value_changed(value : float):
	radius = value
	


func _on_subdivisions_value_changed(value : int):
	subdivisions = value


func _on_generate_status_changed(is_generating : bool):
	if generateBtn:
		generateBtn.disabled = is_generating
		generateBtn.text = "Generating..." if is_generating else "Generate"



func _on_add_noise_layer_button_pressed():
	popupPanel.visible = true


func _add_layer():
	var label = Label.new()
	label.text = "Noise Layer " + str(noise_layers_vbox.get_child_count() + 1)
	noise_layers_vbox.add_child(label)
