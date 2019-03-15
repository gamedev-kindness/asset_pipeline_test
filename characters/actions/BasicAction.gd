extends Node
class_name BasicAction
var min_count = 2
var max_count = 2
var pb_start = ""
var pb_end = ""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var character_list = []
var collisions = true
onready var anim = AnimationParameterPlayback.new()
func _ready():
	pass # Replace with function body.
enum {STATE_INIT, STATE_PLAY, STATE_LEAVE}
var state = STATE_INIT

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func end_signal(obj):
	print("SIGNAL ACTION ENDED")
	remove_character(obj)
func add_character(obj):
	assert obj != null
	assert state == STATE_INIT
	if !obj in character_list:
		if collisions:
			for k in character_list:
				k.add_collision_exception_with(obj)
				obj.add_collision_exception_with(k)
		character_list.push_back(obj)
		awareness.action_mode[obj] = self
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
		if character_list.size() < min_count:
			finish()
func play():
	assert character_list.size() <= max_count
	assert character_list.size() >= min_count
	for k in character_list:
		var at: AnimationTree = awareness.at[k]
		at.add_user_signal("end", ["obj"])
		at.connect("end", self, "end_signal")
	anim.play(character_list[0], character_list[1], pb_start)
	state = STATE_PLAY

func finish():
		for k in character_list:
			for l in character_list:
				if k == l:
					continue
				k.remove_collision_exception_with(l)
				l.remove_collision_exception_with(k)
				awareness.action_mode.erase(k)
		character_list.clear()
		queue_free()
