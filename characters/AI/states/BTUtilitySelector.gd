extends BTComposite
class_name BTUtilitySelector
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var dchildren = {}
func _ready():
	for k in get_children():
		dchildren[k.name] = k

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func run(obj, delta):
	var best = 0.0
	var current
	if get_state(obj).has("current"):
		current = get_state(obj).current
	var u = ""
	for k in awareness.utilities.keys():
		var cur = awareness.get_utility(obj, k)
		if cur > best:
			best = cur
			u = k
	if u == "":
		return BT_ERROR
	var child
	if awareness.utilities[u].has("behavior"):
		child = awareness.utilities[u].behavior
	elif awareness.utilities[u].has("tag"):
		child = awareness.utilities[u].tag
	if current != null:
		if current != child:
			awareness.targets.erase(obj)
			current = child
			print(obj.name, " switch from ", current, " to ", child)
			get_state(obj).current = child
	else:
		get_state(obj).current = child
	
	return dchildren[child]._execute(obj, delta)
