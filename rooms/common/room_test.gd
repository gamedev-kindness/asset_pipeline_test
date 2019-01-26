extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$generate_room.angle_mesh = load("res://rooms/room_kit/solid_wall_angle.mesh")
	$generate_room.angle_transform = Transform()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
