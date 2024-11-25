extends CharacterBody3D

class_name PlayerThirdPerson

@export_range(0, 1) var air_control_modifier : float = 1
@export var walk_speed : float = 6.0
@export var jump_velocity : float = 8.5
@export var gravity_scale : float = 1

var base_speed : float
var movement_input : Vector3
var movement_input_relative : Vector3
var movement : Vector3
var gravity : Vector3
var movement_modifier : float = 1

func _ready() -> void:
	base_speed = walk_speed

func _physics_process(_delta: float) -> void:
	
	get_movement_input()
	generate_movement()
	add_gravity()
	velocity = Vector3(movement.x, velocity.y, movement.z)
	
	if (Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_BUTTON_A)) and is_on_floor():
		velocity.y = jump_velocity
	elif Input.is_key_pressed(KEY_V) or Input.is_joy_button_pressed(0, JOY_BUTTON_Y):
		velocity.y = jump_velocity * 1.8
	
	move_and_slide()
	
func get_movement_input() -> void:
	
	var horizontal : float = 0
	var vertical : float = 0
	
	if abs(Input.get_joy_axis(0, JOY_AXIS_LEFT_X)) >= 0.1 or abs(Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)) >= 0.1:
		horizontal = -Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		vertical = -Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		movement_input = Vector3(horizontal, 0, vertical)
	else:
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			horizontal += 1
			
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			horizontal -= 1
			
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			vertical += 1
			
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			vertical -= 1
			
		movement_input = Vector3(horizontal, 0, vertical).normalized()
	
	movement_input_relative = get_viewport().get_camera_3d().global_basis * Vector3(-movement_input.x, 0, -movement_input.z)

func generate_movement() -> void:
	
	var speed = self.walk_speed
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_B):
		speed *= 1.5
	
	if is_on_floor():
		movement = movement.lerp(movement_input_relative * speed, 15 * get_physics_process_delta_time())
		movement = movement.move_toward(movement_input_relative * speed, 0.01)
	else:
		movement = movement.lerp(movement_input_relative * speed, 2 * get_physics_process_delta_time() * air_control_modifier)
		
	movement *= movement_modifier

func add_gravity() -> void:
	
	if !is_on_floor():
		velocity += get_gravity() * get_physics_process_delta_time() * gravity_scale
	else:
		velocity = Vector3.ZERO
