extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var tests : = AnimationParameterPlayback.new()
	print("Actions: ", tests.get_action_list())
	print("Parameters: ", tests.get_parameter_list())
	print("States: ", tests.get_state_list())
	print("List:")
	for k in tests.get_parameter_list():
		var pt = tests.get_parameter_tree(k)
		var states = tests.get_state_name_by_path(pt)
		print("Tree: ", pt, "States: ", states)
		print("main parents: ", tests.get_state_parent_list(states.main))
		print("main travel: ", tests.get_state_travel_list(states.main))
		print("secondary parents: ", tests.get_state_parent_list(states.secondary))
		print("secondary travel: ", tests.get_state_travel_list(states.secondary))
		print("playback: ", tests.get_parameter_playback_data(k, ""))
