class_name Player
extends CharacterBody2D

signal died

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

@export var shoot_cooldown_time := 0.5
@export var stun_duration := 2.5

## How much along the axis counts as pressing down
@export var pickup_axis_threshold := 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var id : int
var _can_shoot := true
var _x_facing := 1
var _stored_nuts := 0
var _stunned := false
var _crouching := false:
	set(value):
		_crouching = value
		_standing_sprite.visible = not _crouching
		_standing_collision_shape.set_deferred("disabled", _crouching)
		_crouching_sprite.visible = _crouching
		_crouching_collision_shape.set_deferred("disabled", not _crouching)

@onready var _shoot_cooldown_timer : Timer = $ShootCooldownTimer
@onready var _mouth : Node2D = $Mouth
@onready var _nut_pickup_area : Area2D = $NutPickupArea
@onready var _sprite_holder := $SpriteHolder
@onready var _standing_sprite := $SpriteHolder/StandingSprite
@onready var _standing_collision_shape := $CollisionShape2D
@onready var _crouching_sprite := $SpriteHolder/CrouchingSprite
@onready var _crouching_collision_shape := $CrouchingCollisionShape2D
@onready var state_machine = $AnimationTree["parameters/playback"]


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if not _stunned:
		if _is_jump_input_pressed() and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if _is_shoot_pressed() and _can_shoot and _stored_nuts > 0:
			_shoot()
		
		if _is_crouch_pressed() and is_on_floor():
			_crouch()
		else:
			_crouching = false

		if not _crouching:
			var direction = _read_movement_input()
			if abs(direction) > 0.1:
				velocity.x = direction * SPEED
				_x_facing = sign(direction)
				_sprite_holder.scale.x = _x_facing
				state_machine.travel("run")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if velocity.x == 0:
					state_machine.travel("idle")

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
	return Input.get_joy_axis(id, JOY_AXIS_LEFT_Y) > pickup_axis_threshold


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
	_crouching = true
	for nut in _nut_pickup_area.get_overlapping_bodies():
		nut.pickup()
		_stored_nuts += 1


func hit()->void:
	# Always stand up when hit
	_crouching = false
	
	if _stored_nuts > 0:
		_drop_nuts()
		stun()
	else:
		died.emit()
		queue_free()


func stun() -> void:
	_stunned = true
	$AnimationPlayer.play("stunned")
	await $AnimationPlayer.animation_finished
	_stunned = false


func _drop_nuts()->void:
	for i in _stored_nuts:
		var nut := preload("res://player/nut/nut.tscn").instantiate()
		nut.shooter = self
		nut.direction = Vector2.ZERO
		call_deferred("add_sibling", nut)
		nut.global_position = _mouth.global_position
	_stored_nuts = 0
