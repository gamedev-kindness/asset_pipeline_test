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
	awareness.at[obj].travel("Sleep")

func run(obj, delta):
	# Forcing AI wakeup/sleeping - need tunables
	if awareness.action_cooldown.has(obj):
		if awareness.action_cooldown[obj] > 0.0:
			awareness.action_cooldown[obj] -= delta
			return ""
	if awareness.at[obj].get_current_node() == "Sleep":
		if awareness.day_hour > 0.0 && awareness.day_hour < 22:
			if randf() > 0.95:
				obj.get_node("main_shape").disabled = false
				return "SelectTarget"


func exit(obj):
	pass
