extends Node2D

var window
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func get_points():
	return $Area2D/CollisionPolygon2D.polygon
func can_grow():
	var overlapping = $Area2D.get_overlapping_areas()
	if overlapping.size() == 0:
		return true
	return false
func grow_square():
	pass
func grow_up():
	pass
func grow_down():
	pass
func grow_left():
	pass
func grow_right():
	pass
func grow():
	pass
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
