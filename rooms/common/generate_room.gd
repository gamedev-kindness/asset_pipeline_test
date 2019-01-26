extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var size = Vector2()
var angle_mesh: Mesh
var angle_transform: Transform
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var current_size = Vector2(3, 3)
var grid_size = 1
func _process(delta):
	var angles = [0, PI/2, PI, -PI/2]
	var positions = [Vector2(1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(-1, 1)]
	for a in range(4):
		var mi = MeshInstance.new()
		add_child(mi)
		mi.mesh = angle_mesh
		mi.transform = angle_transform * Transform(Quat(Vector3(0, 1, 0), angles[a]))
		mi.transform.origin += Transform(Quat(Vector3(0, 1, 0), angles[a])).xform(Vector3(1, 0, 1)) + Vector3(positions[a].x, 0, positions[a].y)
