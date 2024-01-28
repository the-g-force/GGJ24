extends CharacterBody2D

const SPEED := 600.0

## The player who shot this nut.
##
## This is used to determine when the nut becomes "active" for hitting other things
var shooter : Node2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _rotations_per_second := randf_range(1.0, 4.0) * (-1 if randi() % 2 == 0 else 1)
var _players_hit := []
var direction := Vector2.ZERO :
	set(value):
		direction = value
		velocity = direction * SPEED


func _ready()->void:
	rotation = randf() * TAU


func _physics_process(delta:float)->void:
	if is_on_floor():
		velocity.x = 0
		set_collision_layer_value(2, false)
	else:
		rotation += _rotations_per_second * TAU * delta
	
	velocity.y += gravity * delta
	
	move_and_slide()


func _on_area_2d_body_exited(body):
	# Once the area passes out of the shooter, turn on collision with players.
	if body==shooter:
		set_collision_layer_value(2, true)


func pickup()->void:
	queue_free()


func _on_area_2d_body_entered(body:PhysicsBody2D)->void:
	if body is Player and body != shooter and not is_on_floor():
		if not _players_hit.has(body):
			body.hit()
			_players_hit.append(body)
