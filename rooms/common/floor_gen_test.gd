extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var mi = MeshInstance.new()
	mi.mesh = $data.create_floor([Rect2(-10, -10, 10, 10), Rect2(0, 0, 10, 10)], null)
	add_child(mi)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
