extends BTConditional
class_name BTCondOtherStateMachine

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var state_machine_path: String = "playback"
export var state_machine_state: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func run(obj, delta):
	if obj.other == null:
		return BT_ERROR
	if awareness.at[obj.other][state_machine_path].is_playing():
		if awareness.at[state_machine_path].get_current_node() == state_machine_state:
			return BT_OK
	return BT_ERROR
