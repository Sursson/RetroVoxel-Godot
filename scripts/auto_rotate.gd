extends Node3D
## Rotates in degrees per second around the Y axis
@export var rotation_speed = 50 

func _process(delta):
	rotation_degrees.y += rotation_speed * delta
