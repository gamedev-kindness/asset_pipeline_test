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
	pass
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
#	var male = load("res://characters/male_2018.tscn")
#	var female = load("res://characters/female_2018.tscn")
#	ps = [male, female]
#	for m in range(5):
#		var c = ps[randi() % ps.size()].instance()
#		add_child(c)
#		c.translation = Vector3(float(m) * pow(-1, m), 0, randf() * 2.5)
#		if m == 0:
#			c.posessed = true
#			camera_target = c

# Called every frame. 'delta' is the elapsed time since the previous frame.
var fps_camera = false
var cooldown = 0.0
var posessed = false
func _process(delta):
#	if camera_target != null:
#		if !fps_camera:
#			pass
##			$Camera.look_at(camera_target.translation + Vector3(0, 1.4, 0), Vector3(0, 1, 0))
##			if Input.is_action_pressed("change_view") && cooldown < 0.1:
##				$Camera.current = false
##				fps_camera = true
##				camera_target.enable_fps_camera()
##				cooldown = 1.5
##				print("fps camera")
#		else:
#			if Input.is_action_pressed("change_view") && cooldown < 0.1:
#				$Camera.current = true
#				fps_camera = false
#				camera_target.disable_fps_camera()
#				cooldown = 1.0
#				print("tps camera")
#	else:
	if !posessed:
		var chars = get_tree().get_nodes_in_group("characters")
		for ch in chars:
			print(ch.name)
			if ch.name.begins_with("male"):
				ch.posessed = true
				print("posessed: ", ch.name)
#				camera_target = ch
				posessed = true
				break
#	if cooldown > delta:
#		cooldown -= delta
