extends SpinBox

var is_dragging : bool = false
var drag_start_position : Vector2 = Vector2.ZERO
var initial_value : float = 0.0
var drag_sensitivity : float = 1
var drag_distance : float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	var line_edit = get_line_edit()
	line_edit.gui_input.connect(_on_gui_input)
	line_edit.selecting_enabled = false

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:

				# Start Dragging
				is_dragging = true
				drag_start_position = event.position
				initial_value = value
				drag_distance = 0.0

				# This prevents text editing while dragging
				get_line_edit().release_focus()
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

				# Prevent the event from propagating
				get_viewport().set_input_as_handled()
			else:
				# Stop Dragging
				is_dragging = false
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	elif event is InputEventMouseMotion and is_dragging:
		# Calculate the accumulated drag distance and update the value
		drag_distance += event.relative.x
		var new_value = initial_value + (drag_distance * drag_sensitivity)


		# Clamp the value to the min and max
		new_value = clamp(new_value, min_value, max_value)

		# Round the value to the step if step is not 0
		if step != 0:
			new_value = round(new_value / step) * step
		
		value = new_value
	
func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

