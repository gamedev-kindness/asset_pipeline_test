extends BaseAction

class_name ActionMissionary1
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	sequence = ["Missionary1_1;feet_ik=off", "Missionary1_2;tears=on"]
	

func init_action():
	var xform = Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0))
	character_list[1].global_transform = (character_list[0].global_transform * xform).orthonormalized()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
