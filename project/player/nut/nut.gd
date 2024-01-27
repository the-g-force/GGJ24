extends RigidBody2D

## The player who shot this nut.
##
## This is used to determine when the nut becomes "active" for hitting other things
var shooter : Node2D

func _draw():
	var radius :float = $CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, Color.SADDLE_BROWN)


func _on_area_2d_body_exited(body):
	# Once the area passs out of the shooter, turn on collision with players.
	if body==shooter:
		set_collision_layer_value(2, true)
