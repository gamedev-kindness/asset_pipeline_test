extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var mi = MeshInstance.new()
	mi.mesh = $data.create_floor([Rect2(-20, -20, 10, 10), Rect2(-10, -10, 20, 20), Rect2(10, 10, 10, 10)], null)
	add_child(mi)
	var mi2 = MeshInstance.new()
	mi2.mesh = $data.create_walls([Rect2(-20, -20, 10, 10), Rect2(-10, -10, 20, 20), Rect2(10, 10, 10, 10)], {}, 3.0, null)
	add_child(mi2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
