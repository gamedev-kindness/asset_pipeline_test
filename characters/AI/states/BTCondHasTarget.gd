extends BTConditional
class_name BTCondHasTarget

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func run(obj, delta):
	if awareness.targets.has(obj):
#		print(name, " ", obj.name, " has target")
		return BT_OK
	else:
#		print(name, " ", obj.name, " no target")
		return BT_ERROR
		