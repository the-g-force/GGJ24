extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0

@export var shoot_cooldown_time := 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var id : int
var _can_shoot := true
var _x_facing := 1

@onready var _shoot_cooldown_timer : Timer = $ShootCooldownTimer
@onready var _mouth : Node2D = $Mouth


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_joy_button_pressed(id, JOY_BUTTON_A) and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_joy_button_pressed(id, JOY_BUTTON_X) and _can_shoot:
		_shoot()

	var direction = Input.get_joy_axis(id, JOY_AXIS_LEFT_X)
	if abs(direction) > 0.1:
		velocity.x = direction * SPEED
		_x_facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _shoot()->void:
	assert(_can_shoot)
	_can_shoot = false
	
	var nut := preload("res://player/nut/nut.tscn").instantiate()
	add_sibling(nut)
	nut.global_position = _mouth.global_position
	nut.apply_central_impulse(Vector2(_x_facing, 0).rotated(-PI/8 * _x_facing) * 500)
	
	_shoot_cooldown_timer.start(shoot_cooldown_time)
	await _shoot_cooldown_timer.timeout
	_can_shoot = true


func _draw()->void:
	draw_rect(Rect2(-40, -160, 80, 160), Color.ORANGE)
