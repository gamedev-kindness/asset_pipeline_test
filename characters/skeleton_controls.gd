extends Skeleton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var foot_ik_l: SkeletonIK
var foot_ik_r: SkeletonIK
func set_feet_ik(mode):
	if mode:
		foot_ik_l.start()
		foot_ik_r.start()
	else:
		foot_ik_l.stop()
		foot_ik_r.stop()
func _ready():
	foot_ik_l = SkeletonIK.new()
	add_child(foot_ik_l)
	foot_ik_r = SkeletonIK.new()
	add_child(foot_ik_r)
	foot_ik_l.root_bone = "upperleg02_L"
	foot_ik_l.tip_bone = "foot_L"
	foot_ik_l.target_node = $foot_ik_l.get_path()
	foot_ik_l.stop()
	foot_ik_r.root_bone = "upperleg02_R"
	foot_ik_r.tip_bone = "foot_R"
	foot_ik_r.target_node = $foot_ik_r.get_path()
	foot_ik_l.stop()
	
	var base = get_parent()
	base.connect("setfeet_ik", self, "set_feet_ik")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
