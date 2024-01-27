class_name Player
extends CharacterBody2D

signal died

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

@export var shoot_cooldown_time := 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var id : int
var _can_shoot := true
var _x_facing := 1
var _stored_nuts := 0

@onready var _shoot_cooldown_timer : Timer = $ShootCooldownTimer
@onready var _mouth : Node2D = $Mouth
@onready var _nut_pickup_area : Area2D = $NutPickupArea


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if _is_jump_input_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if _is_shoot_pressed() and _can_shoot and _stored_nuts > 0:
		_shoot()
	
	if _is_crouch_pressed():
		_crouch()

	var direction = _read_movement_input()
	if abs(direction) > 0.1:
		velocity.x = direction * SPEED
		_x_facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _is_jump_input_pressed() -> bool:
	# Player 0 can use the keyboard for testing
	if id == 0:
		if Input.is_key_pressed(KEY_SPACE):
			return true
	return Input.is_joy_button_pressed(id, JOY_BUTTON_A)


func _is_shoot_pressed() -> bool:
	if id == 0:
		if Input.is_key_pressed(KEY_Z):
			return true
	return Input.is_joy_button_pressed(id, JOY_BUTTON_X)


func _is_crouch_pressed()->bool:
	if id == 0:
		if Input.is_key_pressed(KEY_S):
			return true
	return Input.get_joy_axis(id, JOY_AXIS_LEFT_Y) < -0.1


func _read_movement_input() -> float:
	# Player zero can use the keyboard (for speed of testing)
	if id ==0:
		var direction := 0
		if Input.is_key_pressed(KEY_A):
			direction -= 1
		if Input.is_key_pressed(KEY_D):
			direction += 1
		if direction != 0:
			return direction
	return Input.get_joy_axis(id, JOY_AXIS_LEFT_X)


func _shoot()->void:
	assert(_can_shoot and _stored_nuts > 0)
	_can_shoot = false
	_stored_nuts -= 1
	
	var nut := preload("res://player/nut/nut.tscn").instantiate()
	nut.shooter = self
	nut.direction = Vector2(_x_facing, 0).rotated(-PI/8 * _x_facing)
	add_sibling(nut)
	nut.global_position = _mouth.global_position
	
	_shoot_cooldown_timer.start(shoot_cooldown_time)
	await _shoot_cooldown_timer.timeout
	_can_shoot = true


func _crouch()->void:
	for nut in _nut_pickup_area.get_overlapping_bodies():
		nut.pickup()
		_stored_nuts += 1


func hit()->void:
	if _stored_nuts > 0:
		_drop_nuts()
	else:
		died.emit()
		queue_free()


func _drop_nuts()->void:
	for i in _stored_nuts:
		var nut := preload("res://player/nut/nut.tscn").instantiate()
		nut.shooter = self
		nut.direction = Vector2.ZERO
		call_deferred("add_sibling", nut)
		nut.global_position = _mouth.global_position
