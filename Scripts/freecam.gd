extends Camera3D

@export var acceleration : float = 25.0
@export var move_speed : float = 5.0
@export var mouse_sensitivity : float = 300.0


var velocity : Vector3 = Vector3.ZERO
var look_angles : Vector2 = Vector2.ZERO
var current_speed : float = move_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	look_angles.y = clamp(look_angles.y, PI / -2, PI / 2)
	set_rotation(Vector3(look_angles.y, look_angles.x, 0))
	var direction = updateDirection()

	if direction.length_squared() > 0:
		velocity += direction * acceleration * delta
	
	if velocity.length() > current_speed:
		velocity = velocity.normalized() * current_speed
	
	translate(velocity * delta)



func _input(event):
	# Mouse Rotation
	if event is InputEventMouseMotion:
		look_angles -= event.relative / mouse_sensitivity

	if Input.is_action_just_pressed("unlock_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_pressed("speed_up_cam"):
		current_speed = move_speed * 3
	else:
		current_speed = move_speed
	
	



func updateDirection() -> Vector3:
	var dir = Vector3()

	if Input.is_action_pressed("move_forward"):
		dir += Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		dir += Vector3.BACK
	if Input.is_action_pressed("move_left"):
		dir += Vector3.LEFT
	if Input.is_action_pressed("move_right"):
		dir += Vector3.RIGHT
	if Input.is_action_pressed("move_up"):
		dir += Vector3.UP
	if Input.is_action_pressed("move_down"):
		dir += Vector3.DOWN
	
	if dir == Vector3.ZERO:
		velocity = Vector3.ZERO
	
	return dir.normalized()