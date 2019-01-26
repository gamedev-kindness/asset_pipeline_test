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
var min_times = {
	"toilet": 4.0,
	"shower": 10.0,
}
func init(obj):
	awareness.at[obj].travel("Stand")
	if awareness.targets[obj].is_in_group("toilet"):
		awareness.targets[obj].get_parent().busy = true

func run(obj, delta):
	if awareness.at[obj].get_current_node() == "Stand":
		if awareness.distance(obj, awareness.targets[obj]) > 0.5:
			obj.global_transform = obj.global_transform.interpolate_with(awareness.targets[obj].global_transform, delta)
		else:
			obj.global_transform = awareness.targets[obj].global_transform
	return ""

func exit(obj):
	pass
