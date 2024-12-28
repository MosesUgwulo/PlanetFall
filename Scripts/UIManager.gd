extends CanvasLayer

@export var planet : Planet

@onready var generateBtn : Button = $RootControl/MarginContainer/Settings/GenerateBtnVBox/Button

# Editible values
var radius : float
var subdivisions : int

# Called when the node enters the scene tree for the first time.
func _ready():
	if planet and planet.get_child(0):
		var mesh = planet.get_child(0) as PlanetMesh
		if mesh:
			mesh.generate_status_changed.connect(_on_generate_status_changed)


func _generate_planet():
	planet.planet_data.radius = radius
	planet.planet_data.subdivisions = subdivisions
	planet._on_planet_changed()
	


func _on_radius_value_changed(value : float):
	radius = value
	


func _on_subdivisions_value_changed(value : int):
	subdivisions = value


func _on_generate_status_changed(is_generating : bool):
	if generateBtn:
		generateBtn.disabled = is_generating
		generateBtn.text = "Generating..." if is_generating else "Generate"
