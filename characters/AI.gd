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
func run(delta, obj, tree):
		var sm: AnimationNodeStateMachinePlayback = tree["parameters/playback"]
		var next = "Stand"
		if navigating:
			next = "Navigate"
		if sleeping:
			next = "Sleep"
#		print(next)
		sm.travel(next)
		if sm.get_current_node() == "Navigate":
			var tf_turn = Transform(Quat(Vector3(0, 1, 0), PI * dir * delta))
			obj.orientation *= tf_turn
		change_count += delta
		if change_count > change_frequency && !sleeping:
			dir = randf() * 1.2 - 0.6
			change_count = 0.0
			if randf() > 0.7:
				navigating = true
			else:
				navigating = false
		if change_count > change_frequency * 2.0 + 2.0 * randf() && sleeping:
			if randf() > 0.8:
				sleeping = false
				obj.get_node("main_shape").disabled = false