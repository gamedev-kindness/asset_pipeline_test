extends BTComposite
class_name BTSelector
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
	for c in get_children():
		var status = c._execute(obj, delta)
		if status != BT_ERROR:
			return status
	return BT_ERROR
