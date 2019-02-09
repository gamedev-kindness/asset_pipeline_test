extends BTTask
class_name BTPlayAnimationState
export var sequence : = ""
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
	var playback
	var anim
	if sequence.find(",") >= 0:
		var data = sequence.split(",")
		if data.size() < 2:
			return BT_ERROR
		playback = awareness.at[obj]["parameters/" + data[0] + "/playback"]
		anim = data[1]
	else:
		playback = awareness.at[obj]["parameters/playback"]
		anim = sequence
	playback.travel(anim)
	get_state(obj).playback = playback
	get_state(obj).anim = anim
func run(obj, delta):
	if get_state(obj).playback.get_current_node() != get_state(obj).anim:
		return BT_BUSY
	else:
		return BT_OK