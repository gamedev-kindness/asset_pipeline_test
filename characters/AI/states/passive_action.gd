extends AIState

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func init(obj):
	print("entering passive action behavior")
func run(obj, delta):
	print("running passive action behavior")
	return ""
func exit(obj):
	print("leaving passive action behavior")
