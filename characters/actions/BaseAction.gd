extends Node

class_name BaseAction
var character_list = []
var sequence = []
var direction = "ALL"
var collisions = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func init_action():
	pass

func add_character(obj):
	assert obj != null
	if !obj in character_list && character_list.size() < sequence.size():
		if collisions:
			for k in character_list:
				k.add_collision_exception_with(obj)
				obj.add_collision_exception_with(k)
		character_list.push_back(obj)
		print("added character ", obj)

func remove_character(obj):
	if obj in character_list:
		character_list.erase(obj)
		if collisions:
			for k in character_list:
				k.remove_collision_exception_with(obj)
				obj.remove_collision_exception_with(k)
		awareness.action_mode.erase(obj)
		print("removed character ", obj)
var state = 0
func _process(delta):
	if sequence.size() != character_list.size():
		return
	match(state):
		0:
			init_action()
			for k in range(character_list.size()):
				var at = awareness.at[character_list[k]]
				var s = sequence[k]
				var lines
				if s.find(";") >= 0:
					lines = s.split(";")
				else:
					lines = [s]
				for l in lines:
					if l == "tears=on":
						character_list[k].enable_tears()
					elif l == "tears=off":
						character_list[k].disable_tears()
					elif l == "feet_ik=on":
						character_list[k].emit_signal("set_feet_ik", true)
					elif l == "feet_ik=off":
						character_list[k].emit_signal("set_feet_ik", false)
					else:
						if l.find(",") >= 0:
							var pdata = l.split(",")
							var playback = "parameters/" + pdata[0] + "/playback"
							var what = pdata[1]
							print(name, ": ", k, ": animation: ", playback, "=", what) 
							at[playback].travel(what)
						else:
							var playback = "parameters/playback"
							var what = l
							print(name, ": ", k, ": animation: ", playback, "=", what) 
							at[playback].travel(what)
			state = 1
