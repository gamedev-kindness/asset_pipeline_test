extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var change_frequency = 10.0
var change_count = 0.0
var dir = 0.0
var navigating = false
var sleeping = true

var state = 0
var init = false
func run(delta, obj, tree):
	var sm: AnimationNodeStateMachinePlayback = tree["parameters/playback"]
	awareness.at[obj] = sm
#	var next = "Stand"
#	if navigating:
#		next = "Navigate"
#	if sleeping:
#		next = "Sleep"
#	sm.travel(next)
	# Forcing AI wakeup/sleeping - need tunables
	var stateobj = $states.get_children()[state]
	if !init:
		stateobj.init(obj)
		init = true
	var next_state_s = stateobj.run(obj, delta)
	var old_state = state
	for n in range($states.get_child_count()):
		if $states.get_children()[n].name == next_state_s:
			state = n
			break
	if old_state != state:
		$states.get_children()[old_state].exit(obj)
		$states.get_children()[state].init(obj)
	