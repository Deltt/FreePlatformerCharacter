extends Node3D

class_name CameraThirdPerson

@export var pivot_y : Node3D
@export var pivot_x : Node3D
@export var camera_arm : SpringArm3D
@export var camera : Camera3D
@export var mouse_sensitivity : float = 1
@export var controller_sensitivity : float = 2
@export var max_angle_up : float = 20
@export var max_angle_down : float = 60
@export var camera_sway : bool = true
@export var sway_strength : float = 1

var player : PlayerThirdPerson;
var mouse_input : Vector2;

func _ready() -> void:
	player = get_parent()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	
	if event is InputEventMouseMotion:
		mouse_input = event.relative

func _physics_process(_delta: float) -> void:
	
	global_rotation = Vector3.ZERO
	
	rotate_with_mouse()
	
	clamp_camera_rotation()
	
func rotate_with_mouse() -> void:
	
	mouse_input *= mouse_sensitivity
	
	if abs(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)) >= 0.05:
		mouse_input.x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * controller_sensitivity
		
	if abs(Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)) >= 0.05:
		mouse_input.y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * controller_sensitivity
	
	if(mouse_input.x != 0):
		pivot_y.rotate_y(-mouse_input.x * get_physics_process_delta_time())
	else:
		if camera_sway:
			sway_camera()
		
	if(mouse_input.y != 0):
		pivot_x.rotate_x(-mouse_input.y * get_physics_process_delta_time())
		
	mouse_input = Vector2.ZERO
	
func clamp_camera_rotation() -> void:
	
	pivot_x.rotation_degrees.x = clampf(pivot_x.rotation_degrees.x,
								max(-max_angle_down, -90),
								min(max_angle_up, 90))

func sway_camera() -> void:
	var relative_x_velocity = camera.global_basis.x.dot(player.velocity)
	pivot_y.rotate_y(relative_x_velocity * -0.12 * sway_strength * get_physics_process_delta_time())
