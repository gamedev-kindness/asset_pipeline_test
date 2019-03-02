extends GraphNode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var data = {}
func _ready():
	pass # Replace with function body.

func set_action_name(n):
	$Label.text = n
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
