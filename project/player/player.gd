class_name Player
extends CharacterBody2D

signal died

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const CHEEK_SIZES := [0, 8, 12, 14]

const STUN_SOUNDS := [
	"res://player/stun1.wav",
	"res://player/stun2.wav",
	"res://player/stun3.wav",
	"res://player/stun4.wav",
	"res://player/stun5.wav",
]

@export var shoot_cooldown_time := 0.5
@export var stun_duration := 2.5

## How much along the axis counts as pressing down
@export var pickup_axis_threshold := 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var id : int
var _max_nuts := CHEEK_SIZES.size() - 1
var _can_shoot := true
var _x_facing := 1 :
	set(value):
		_x_facing = value
		_sprite_holder.scale.x = _x_facing
var _stored_nuts := 0:
	set(value):
		_stored_nuts = value
		for cheek in _cheeks:
			cheek.radius = CHEEK_SIZES[_stored_nuts]
var _stunned := false
var _crouching := false:
	set(value):
		_crouching = value
		_standing_sprite.visible = not _crouching
		_standing_collision_shape.set_deferred("disabled", _crouching)
		_crouching_sprite.visible = _crouching
		_crouching_collision_shape.set_deferred("disabled", not _crouching)
var _dead := false

@onready var _shoot_cooldown_timer : Timer = $ShootCooldownTimer
@onready var _mouth : Sprite2D = $SpriteHolder/StandingSprite/Mouth
@onready var _nut_appear_location : Marker2D = $SpriteHolder/StandingSprite/Mouth/Marker2D
@onready var _nut_pickup_area : Area2D = $NutPickupArea
@onready var _sprite_holder := $SpriteHolder
@onready var _standing_sprite := $SpriteHolder/StandingSprite
@onready var _standing_collision_shape := $CollisionShape2D
@onready var _crouching_sprite := $SpriteHolder/CrouchingSprite
@onready var _crouching_collision_shape := $CrouchingCollisionShape2D
@onready var _state_machine = $AnimationTree["parameters/playback"]
@onready var _cheeks := [
	$SpriteHolder/StandingSprite/Cheek_Right,
	$SpriteHolder/StandingSprite/Cheek_Left,
	$SpriteHolder/CrouchingSprite/Cheek_Right,
	$SpriteHolder/CrouchingSprite/Cheek_Left,
]


func _ready():
	$PlayerIdLabel.text = "P%d" % (id+1)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if not _stunned and not _dead:
		if _is_jump_input_pressed() and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if _is_crouch_pressed() and is_on_floor():
			_crouch()
			velocity.x = 0
		else:
			_crouching = false
			
				
		if _is_shoot_pressed()\
			and _can_shoot\
			and _stored_nuts > 0\
			and not _crouching:
			_shoot()

		if not _crouching:
			var direction = _read_movement_input()
			if abs(direction) > 0.1:
				velocity.x = direction * SPEED
				_x_facing = sign(direction)
				_state_machine.travel("run")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if velocity.x == 0:
					_state_machine.travel("idle")

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
	
	_shoot_cooldown_timer.start(shoot_cooldown_time)
	
	await create_tween().tween_property(_mouth, "percent_length", 1.0, 0.1).set_trans(Tween.TRANS_QUAD).finished
	var nut := preload("res://player/nut/nut.tscn").instantiate()
	nut.shooter = self
	nut.direction = Vector2(_x_facing, 0).rotated(-PI/8 * _x_facing)
	add_sibling(nut)
	nut.global_position = _nut_appear_location.global_position
	
	create_tween().tween_property(_mouth, "percent_length", 0.0, 0.1).set_trans(Tween.TRANS_QUAD)
	
	await _shoot_cooldown_timer.timeout
	_can_shoot = true


func _crouch()->void:
	_crouching = true
	for nut in _nut_pickup_area.get_overlapping_bodies():
		if _stored_nuts < _max_nuts:
			nut.pickup()
			_stored_nuts += 1


func hit()->void:
	if _dead:
		return
	
	# Always stand up and stop when hit
	_crouching = false
	velocity.x = 0
	
	if _stored_nuts > 0:
		_drop_nuts()
		stun()
	else:
		died.emit()
		_state_machine.travel("death")
		_dead = true


func stun() -> void:
	$StunSound.stream = load(STUN_SOUNDS.pick_random())
	$StunSound.play()
	_stunned = true
	_state_machine.travel("stunned")
	# Wait until the stunned animation is finished
	while await $AnimationTree.animation_finished != "stunned":
		pass
	_stunned = false
	_state_machine.travel("idle")


func _drop_nuts()->void:
	for i in _stored_nuts:
		var nut := preload("res://player/nut/nut.tscn").instantiate()
		nut.shooter = self
		nut.direction = Vector2.ZERO
		call_deferred("add_sibling", nut)
		nut.global_position = _mouth.global_position
	_stored_nuts = 0


func _play_foot_sound_if_on_ground() -> void:
	if is_on_floor():
		var pitch_scale := randfn(1.0, 0.2)
		$FootSound.pitch_scale = pitch_scale
		$FootSound.play()
