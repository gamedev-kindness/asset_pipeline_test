extends VehicleBody
signal arrived
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var state = 0
func _ready():
	engine_force = 500.0
	brake = 0.0
	$AnimationPlayer.play("closed_doors")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(state):
		0:
			var l = linear_velocity
			l.y = 0.0
			if l.length() > 5.0:
				engine_force = 0.0
			elif l.length() < 1.0:
				engine_force = 500.0
			if $right.is_colliding():
				steering += PI / 12.0 * delta
			if $left.is_colliding():
				steering += -PI / 12.0 * delta
			if !$left.is_colliding() && !$right.is_colliding():
				steering *= (1.0 - delta)
			steering = clamp(steering, -PI / 3.0, PI / 3.0)
			for stop in get_tree().get_nodes_in_group("bus_stop"):
				var p1 = global_transform.origin
				var p2 = stop.global_transform.origin
				if p1.distance_to(p2) < 10.0:
					state = 1
					engine_force *= (1.0 - delta)
					steering = 0.0
					brake = 30.0
		1:
			var l = linear_velocity
			l.y = 0.0
			if l.length() < 0.2:
				$AnimationPlayer.play("open_doors")
				state = 2
				emit_signal("arrived")
	