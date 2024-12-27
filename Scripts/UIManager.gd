extends CanvasLayer

@export var planet : Planet
var planet_data : PlanetData
var radius : int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _on_button_1_pressed():
	print("Button 1 Pressed")


func _generate_planet():
	# planet.planet_data.radius = radius
	print(planet.planet_data.radius)
	# planet._on_planet_changed()
	


func _on_planet_radius_options_item_selected(index:int):
	var currently_selected = index

	if currently_selected == 0:
		radius = 5
	elif currently_selected == 1:
		radius = 10
	elif currently_selected == 2:
		radius = 15


