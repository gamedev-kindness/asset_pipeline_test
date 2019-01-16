extends Spatial
signal character
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
enum {STATE_INIT, STATE_CHECK_CLOSE, STATE_CHECK_ACTIVE, STATE_RAYCAST_UPDATE}
var state = STATE_INIT
var cooldown = 0.0
var max_obj_sight_distance = 50.0
var max_character_sight_distance = 12.0
var characters = []
var objects = []
var active_items = []
var character_nodes = []
var item_nodes = []
var active_angle = PI
var max_active_distance = 1.4
var raycasts = []

func _ready():
	state = STATE_INIT
	for r in get_children():
		if r in RayCast:
			r.add_exception(get_parent())
			raycasts.push_back(r)

func distance(n1: Spatial, n2: Spatial) -> float:
	return n1.global_transform.origin.distance_to(n2.global_transform.origin)

func _physics_process(delta):
	if cooldown > 0.01:
		cooldown -= delta
		return
	if state == STATE_INIT:
		character_nodes = get_tree().get_nodes_in_group("characters")
		item_nodes = get_tree().get_nodes_in_group("pickup")
		state = STATE_CHECK_CLOSE
	elif state == STATE_CHECK_CLOSE:
		for c in character_nodes:
			if !c in characters && c != get_parent():
				if distance(get_parent(), c) < max_character_sight_distance:
					emit_signal("character", c)
					characters.push_back(c)
		for c in item_nodes:
			if !c in objects:
				if distance(get_parent(), c) < max_obj_sight_distance:
					emit_signal("pickup", c)
					objects.push_back(c)
		state = STATE_RAYCAST_UPDATE
	elif state == STATE_RAYCAST_UPDATE:
		for r in raycasts:
			r.force_raycast_update()
		state = STATE_CHECK_ACTIVE
	elif state == STATE_CHECK_ACTIVE:
		var dir1 = get_parent().global_transform.basis[2]
		var pos1 = get_parent().global_transform.origin
		var p1 = Vector2(dir1.x, dir1.z)
		for c in characters + objects:
			if ! c in active_items:
				if distance(get_parent(), c) < max_active_distance:
					var pos2 = c.global_transform.origin - pos1
					var p2 = Vector2(pos2.x, pos2.z)
					if abs(p1.angle_to(p2)) < active_angle / (2.0 + distance(get_parent(), c)):
						active_items.push_back(c)
		if active_items.size() > 0:
			print(active_items.size())
		state = STATE_INIT
		cooldown = 1.0
	cooldown -= delta
func get_actuator_body(group):
	var ret
	var dst = -1
	print("awareness: active_items:")
	for i in active_items:
		print(i.name)
	if (active_items.size() == 0):
		print("Nothing")
		print("all characters:", characters)
		print("all objects: ", objects)
		for mc in characters:
			print("me:", get_parent().name, " character: ", mc, " name: ", mc.name, " distance: ", distance(get_parent(), mc))
	for o in active_items:
		if o.is_in_group(group):
			if dst < 0 || distance(get_parent(), o) < dst:
				dst = distance(get_parent(), o)
				ret = o
	return ret
