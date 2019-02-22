extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
onready var startpos: Vector3 = $the_bus.global_transform.origin
func _ready():
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	print("Initial state: ", awareness.at.keys().size())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var v = $the_bus.linear_velocity
	if $the_bus.global_transform.origin.length() > 100:
		$the_bus.global_transform.origin = startpos
		$the_bus.linear_velocity = v
#	print("vel: ", v)
#	print("pos: ", $the_bus.global_transform.origin)
		
