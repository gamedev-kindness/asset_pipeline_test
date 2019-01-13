extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
#var anim1:AnimationPlayer
#var anim2:AnimationPlayer
var ps = []
var camera_target
func _ready():
#	anim2 = $"female_2018/female_2018/AnimationPlayer"
#	anim1 = $"male_2018/male_g_2018/AnimationPlayer"
#	var anim_list_1 = anim1.get_animation_list()
#	var anim_list_2 = anim2.get_animation_list()
#	var animation1:Animation = anim1.get_animation(anim_list_1[3])
#	var animation2:Animation = anim2.get_animation(anim_list_2[3])
#	print(anim_list_1)
#	print(anim_list_2)
#	print(animation1.track_get_path(0))
#	print(animation1.track_get_path(1))
#	print(animation2.track_get_path(0))
#	print(animation2.track_get_path(1))
#	$male_2018.posessed = true
	var male = load("res://characters/male_2018.tscn")
	var female = load("res://characters/female_2018.tscn")
	ps = [male, female]
	for m in range(5):
		var c = ps[randi() % ps.size()].instance()
		add_child(c)
		c.translation = Vector3(float(m) * pow(-1, m), 0, randf() * 2.5)
		if m == 0:
			c.posessed = true
			camera_target = c

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera_target != null:
		$Camera.look_at(camera_target.translation + Vector3(0, 1.4, 0), Vector3(0, 1, 0))
