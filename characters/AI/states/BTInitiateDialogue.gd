extends BTTask
class_name BTInitiateDialogue
export var target_distance : = 1.5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_character_by_target(target):
	return target.get_parent().get_parent()
func init(obj):
	if awareness.targets.has(obj) && awareness.distance(obj, awareness.targets[obj]) < target_distance:
		get_state(obj).character = get_character_by_target(awareness.targets[obj])
		awareness.at[obj]["parameters/playback"].travel("Stand")
func run(obj, delta):
	if awareness.targets.has(obj) && awareness.distance(obj, awareness.targets[obj]) < target_distance:
		print(name + ": distance: ", awareness.distance(obj, awareness.targets[obj]))
		# TODO: make proper conditions here
		var dialogue
		if awareness.dialogue_mode.has(obj):
			dialogue = awareness.dialogue_mode[obj]
		elif awareness.dialogue_mode.has(get_state(obj).character):
			dialogue = awareness.dialogue_mode[get_state(obj).character]
		else:
			dialogue = DialogueScheduler.new()
			get_node("/root").add_child(dialogue)
		if !awareness.dialogue_mode.has(obj):
			awareness.dialogue_mode[obj] = dialogue
			dialogue.add_character(obj)
		if !awareness.dialogue_mode.has(get_state(obj).character):
			awareness.dialogue_mode[get_state(obj).character] = dialogue
			dialogue.add_character(get_state(obj).character)
		# TODO: Use animations to turn properly for proper facing
		var center = Vector3()
		for k in dialogue.character_list:
			center = center.linear_interpolate(k.global_transform.origin, 0.5)
		obj.look_at(center, Vector3(0, 1, 0))
		return BT_OK
	else:
		return BT_ERROR
func exit(obj):
	awareness.targets.erase(obj)
