extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var mtf = Transform()
var opos = Transform()
var move_to_target = false
var move_from_target = false
func run(delta, obj, cam):
	mtf = mtf.looking_at(obj.target.tps_target.global_transform.origin,Vector3(0, 1, 0))
	mtf = mtf.orthonormalized()
	var ct = obj.global_transform
	var cc = cam.global_transform
	mtf.origin = cc.origin
	cam.global_transform = cam.global_transform.interpolate_with(mtf, delta)
	opos.origin = obj.target.tps_target.global_transform.origin
	if obj.global_transform.origin.distance_to(obj.target.tps_target.global_transform.origin) > 2.0:
		move_to_target = true
	elif obj.global_transform.origin.distance_to(obj.target.tps_target.global_transform.origin) < 1.5:
		move_to_target = false
	elif obj.global_transform.origin.distance_to(obj.target.tps_target.global_transform.origin) < 1.0:
		move_to_target = false
		move_from_target = true
	if move_to_target:
		obj.global_transform = obj.global_transform.interpolate_with(opos, delta * 0.1)
	elif move_from_target:
		var nt = Transform()
		var v = obj.global_transform.origin - obj.target.tps_target.global_transform.origin
		nt.origin = v
		opos *= nt
		obj.global_transform = obj.global_transform.interpolate_with(opos, delta)
