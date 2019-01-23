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
	print("Entering ", name)
	awareness.at[obj].travel("Navigate")

func run(obj, delta):
	if awareness.action_cooldown.has(obj):
		if awareness.action_cooldown[obj] > 0.0:
			awareness.action_cooldown[obj] -= delta
			return ""
	var dir = 0.0
	if awareness.at[obj].get_current_node() == "Navigate":
		var tf_turn = Transform(Quat(Vector3(0, 1, 0), PI * dir * delta))
		obj.orientation *= tf_turn
		dir = randf() * 1.2 - 0.6
		return ""


func exit(obj):
	print("Exiting ", name)
