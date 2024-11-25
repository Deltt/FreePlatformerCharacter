extends Node3D

var player : PlayerThirdPerson
@export var anim : AnimationPlayer
@export var animTree : AnimationTree
var state_machine : AnimationNodeStateMachinePlayback

func _ready() -> void:
	
	state_machine = animTree["parameters/playback"]
	
	if get_parent() != null:
		player = get_parent()
		

func _physics_process(_delta: float) -> void:
	
	if state_machine.get_current_node() == "Emote1":
		player.movement_modifier = move_toward(player.movement_modifier, 0, 5 * _delta)
		return
	else:
		player.movement_modifier = move_toward(player.movement_modifier, 1, 5 * _delta)
	
	if Input.is_key_pressed(KEY_E) || Input.is_joy_button_pressed(0, JOY_BUTTON_X):
		if !player.is_on_floor():
			return
		state_machine.travel("Emote1")
	
	if !player.is_on_floor():
		global_rotation = rotate_towards(global_rotation, player.movement_input_relative, 0.2 * get_physics_process_delta_time())
	else:
		global_rotation = rotate_towards(global_rotation, player.movement_input_relative, 12 * get_physics_process_delta_time())
		
	animTree.set("parameters/Grounded/Default/Idle_Walk/blend_position", player.movement.length() / player.base_speed)
	animTree.set("parameters/conditions/trigger_airborne", !player.is_on_floor())
	animTree.set("parameters/conditions/trigger_grounded", player.is_on_floor())
	
	if player.velocity.y <= 3:
		animTree.set("parameters/Airborne/conditions/trigger_jump_fall", true)
	else:
		animTree.set("parameters/Airborne/conditions/trigger_jump_fall", false)
	
func rotate_towards(current_rotation : Vector3, direction : Vector3, lerp_value : float) -> Vector3:
	if direction.length() < 0.1:
		return current_rotation
		
	var y_rotation : float = lerp_angle(current_rotation.y, atan2(direction.x, direction.z), lerp_value)
	var rotation_smoothed : Vector3 = Vector3(current_rotation.x, y_rotation, current_rotation.z)
	return rotation_smoothed
