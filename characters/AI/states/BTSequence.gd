extends BTComposite
class_name BTSequence
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
	pass
func exit(obj, status):
	pass
func run(obj, delta):
	var status = BT_OK
	for c in get_children():
		status = c._execute(obj, delta)
		if status != BT_OK:
			break
	return status
