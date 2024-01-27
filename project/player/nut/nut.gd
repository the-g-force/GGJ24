extends CharacterBody2D

const SPEED := 600.0

## The player who shot this nut.
##
## This is used to determine when the nut becomes "active" for hitting other things
var shooter : Node2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction := Vector2.ZERO :
	set(value):
		direction = value
		velocity = direction * SPEED


func _physics_process(delta:float)->void:
	if is_on_floor():
		velocity.x = 0
		set_collision_layer_value(2, false)
	
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
		body.hit()
