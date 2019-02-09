extends BTConditional
class_name BTTargetDistanceLessCheck
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var max_distance: float = 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func run(obj, delta):
	if awareness.targets.has(obj):
		if awareness.distance(obj, awareness.targets[obj]) <= max_distance:
			return BT_OK
	return BT_ERROR
