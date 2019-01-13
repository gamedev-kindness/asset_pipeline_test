extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var actuator_disable = 0.1
var awareness_disable = 0.1
var actuator_bodies = []
var awareness_bodies = []
func _ready():
	$actuator.monitorable = false
	$actuator.monitoring = false
	$awareness.monitorable = false
	$awareness.monitoring = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
var loop_count = 0
var time_count = 0.0
func _physics_process(delta):
	if time_count > 1.0:
		time_count = 0.0
		$actuator.monitoring = true
		$awareness.monitoring = true
		loop_count = 0
	loop_count += 1
	if loop_count == 3 && $actuator.monitoring:
		actuator_bodies = $actuator.get_overlapping_bodies()
		$actuator.monitoring = false
	if loop_count == 3 && $awareness.monitoring:
		awareness_bodies = $awareness.get_overlapping_bodies()
		$awareness.monitoring = false
	time_count += delta
func get_actuator_body(group):
	if actuator_bodies.size() == 0:
		return null
	print(actuator_bodies.size())
	var ret
	var dst = -1
	for b in actuator_bodies:
		if !b.is_in_group(group) || b == get_parent():
			print("excluding: ", b.name)
			continue
		print(b.name)
		var ndst = get_parent().translation.distance_to(b.translation)
		if dst < 0 || dst > ndst:
			dst = ndst
			ret = b
	return ret
