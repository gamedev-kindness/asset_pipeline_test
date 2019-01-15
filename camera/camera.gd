extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
enum {MODE_TPS, MODE_FPS}
var target
func _ready():
	for ch in get_tree().get_nodes_in_group("characters"):
		if ch.posessed:
			target = ch
			break
	$Camera.add_collision_exception_with(target)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
var mode = MODE_TPS
var active = false
func _process(delta):
	if !active:
		for ch in get_tree().get_nodes_in_group("characters"):
			if ch.posessed:
				target = ch
				break
		if target != null:
			active = true
			print("active")
	if active:
		if mode == MODE_TPS:
			$tps_camera.run(delta, self, $Camera)
		elif mode == MODE_TPS:
			$fps_camera.run(delta, self, $Camera)
func _physics_process(delta):
	if target:
		var space = get_world().direct_space_state
		var data = space.intersect_ray(target.tps_target.global_transform.origin, $Camera.global_transform.origin, [$Camera])
		if data:
			if data.collider is StaticBody:
				var pos = data.position
				var cpos = $Camera.global_transform.origin
				if pos.distance_to(cpos) > 2.0:
					var tf = Transform()
					tf.origin = pos + (pos - cpos).normalized() * 0.5 + Vector3(0, 0.3, 0)
					tf.basis = $Camera.global_transform.basis
					$Camera.global_transform = tf
				else:
					var tf = Transform()
					tf.origin = pos + (pos - cpos).normalized() * 0.5 + Vector3(0, 0.3, 0)
					tf.basis = $Camera.global_transform.basis
					$Camera.global_transform = $Camera.global_transform.interpolate_with(tf, delta)	