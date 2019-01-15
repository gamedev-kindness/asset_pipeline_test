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
