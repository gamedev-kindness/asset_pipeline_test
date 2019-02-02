extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
enum {MODE_TPS, MODE_FPS}
var target
func _ready():
	target = get_parent()
	$base/cam_control/Camera.current = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
var mode = MODE_TPS
var active = false
var old_rotation = 0.0
var rotx = 0.0
var roty = 0.0
var mouse_look = true
var mode_cooldown = 0.0
func _unhandled_input(event):
	if event is InputEventMouseMotion && mouse_look:
		rotx += event.relative.x * 0.5
		roty -= event.relative.y * 0.5
		roty = clamp(roty, -3.0, 3.0)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT && event.pressed:
			if mode_cooldown < 0.01:
				mouse_look = !mouse_look
				mode_cooldown = 0.2
func _process(delta):
	if mode_cooldown >= delta:
		mode_cooldown -= delta
	else:
		mode_cooldown = 0.0
	# Camera look
	var mtf = $base/cam_control/Camera.global_transform
	mtf = mtf.looking_at(target.tps_target.global_transform.origin,Vector3(0, 1, 0))
	mtf = mtf.orthonormalized()
	var cc = $base/cam_control/Camera.global_transform
	mtf.origin = cc.origin
	$base/cam_control/Camera.global_transform = $base/cam_control/Camera.global_transform.interpolate_with(mtf, delta)
	# Rotation damping
	var new_rotation = get_parent().rotation.y
	var diff = new_rotation - old_rotation
	rotation.y -= diff / ((1.0 + delta) * 1.1)
	old_rotation = new_rotation
	rotation.y += rotx * delta
	$base/cam_control.rotation.x = clamp($base/cam_control.rotation.x + roty * delta, -PI / 2.5, PI / 2.5)
	$base/cam_control.global_transform = $base/cam_control.global_transform.orthonormalized()
	rotx = 0.0
	roty = 0.0
	if Input.is_action_pressed("up_control"):
		rotation.y *= (1.0 - delta * 0.5)
	else:
		rotation.y *= (1.0 - delta * 0.1)
	if mode_cooldown >= delta:
		mode_cooldown -= delta

#	return
#	if !active:
#		for ch in get_tree().get_nodes_in_group("characters"):
#			if ch.posessed:
#				target = ch
#				break
#	if target != null:
#			active = true
#			print("active")
#	if active:
#		if mode == MODE_TPS:
#			$tps_camera.run(delta, self, $Camera)
#		elif mode == MODE_TPS:
#			$fps_camera.run(delta, self, $Camera)
func _physics_process(delta):
	if target:
		var space = get_world().direct_space_state
		var data = space.intersect_ray(target.tps_target.global_transform.origin, $base/cam_control/Camera.global_transform.origin)
		if data:
			if data.collider is StaticBody:
				var pos = data.position
				var cpos = $base/cam_control/Camera.global_transform.origin
				if pos.distance_to(cpos) > 2.0:
					$base.global_transform.origin = pos
#					var tf = Transform()
#					tf.origin = pos + (pos - cpos).normalized() * 0.5 + Vector3(0, 0.3, 0)
#					tf.basis = $Camera.global_transform.basis
#					$Camera.global_transform = tf
				else:
					$base.global_transform.origin = $base.global_transform.origin.linear_interpolate(pos, delta)
#					var tf = Transform()
#					tf.origin = pos + (pos - cpos).normalized() * 0.5 + Vector3(0, 0.3, 0)
#					tf.basis = $Camera.global_transform.basis
#					$Camera.global_transform = tf
		var floor_detect = space.intersect_ray($base/cam_control/Camera.global_transform.origin, $base/cam_control/Camera.global_transform.origin + Vector3(0, -1.1, 0))
		if !floor_detect.empty():
			var pos = floor_detect.position
			$base.global_transform.origin = $base.global_transform.origin.linear_interpolate($base/cam_control/Camera.global_transform.origin + Vector3(0, 0.5, 0), delta * 0.3)
		
