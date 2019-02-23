extends BTTask
class_name BTIk


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
	obj.enable_sitting_ik()
func run(obj, delta):
	return BT_BUSY
func exit(obj, status):
	if status == BT_OK:
		obj.disable_sitting_ik()
