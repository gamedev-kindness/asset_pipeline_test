extends Node
class_name AIState
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func tree():
	return get_tree()
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func init(obj):
	pass
func exit(obj, status):
	pass
func run(obj, delta):
	pass