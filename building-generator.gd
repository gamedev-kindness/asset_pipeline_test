extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var rseed = 863210
const window_space = 4.5
const window_width = 2.0
onready var rnd = RandomNumberGenerator.new()
func create_room(w):
	var area = Area2D.new()
func _ready():
	rnd.seed = rseed
#	$Navigation2D.navpoly_add(nav, transform)

# Called every frame. 'delta' is the elapsed time since the previous frame.
enum  {
	STATE_INIT,
	STATE_FRONT_DOOR,
	STATE_WINDOW,
	STATE_ROOM,
	STATE_BUILD,
}
var state = STATE_INIT
var rooms = []
var outline

var room_types = [
	{
		"name": "kitchen",
		"probability": 0.1,
		"window": true,
		"min_size": 2.0,
		"min_area": 6.0,
		"private": false,
		"min_count": 2
	},
	{
		"name": "toilet",
		"probability": 0.2,
		"window": false,
		"min_size": 2.0,
		"min_area": 6.0,
		"private": true,
		"min_count": 2
	},
	{
		"name": "common",
		"probability": 0.3,
		"window": true,
		"min_size": 2.0,
		"min_area": 6.0,
		"private": true,
		"min_count": 0
	},
	{
		"name": "bedroom",
		"probability": 1.0,
		"window": true,
		"min_size": 2.0,
		"min_area": 12.0,
		"private": true,
		"min_count": 1
	}
]
var aabb = Rect2()
func pick_room_type():
	var prnd = rnd.randf()
	for k in room_types:
		if prnd <= k.probability:
			print(k.name)
			return k
	return null

var avoid_list = []
func valid_room_spawn(v):
	var space = get_world_2d().get_direct_space_state()
	var shape = Physics2DShapeQueryParameters.new()
	var shape_data = ConcavePolygonShape2D.new()
	var room = load("res://rooms/room.tscn").instance()
	shape_data.segments = room.get_points()
	room.queue_free()
	shape.set_shape(shape_data)
	shape.exclude.push_back($outside_walls)
	shape.collision_layer = 1
	shape.collide_with_areas = true
	shape.transform = Transform2D(0, v)
	shape.margin = 0.1
	var result = space.intersect_shape(shape, 4)
	var ret = true
	for k in result:
		print(k.collider)
		ret = false
	return ret

func _process(delta):
	if state == STATE_INIT:
		var nav = NavigationPolygonInstance.new()
		var navp = NavigationPolygon.new()
		outline = $outside_walls/CollisionPolygon2D.polygon
		navp.add_outline(outline)
		navp.make_polygons_from_outlines()
		nav.navpoly = navp
		add_child(nav)
		$Navigation2D.navpoly_add(navp, transform)
		for k in outline:
			aabb = aabb.expand(k)
		state = STATE_FRONT_DOOR
	elif state == STATE_FRONT_DOOR:
		var door_seg_start = rnd.randi() % (outline.size() - 1)
		var p1 = outline[door_seg_start]
		var p2 = outline[door_seg_start + 1]
		var seg_n = (p2 - p1)
		var door_pos = (p1 + p2) / 2.0
		var door = load("res://rooms/door.tscn").instance()
		add_child(door)
		door.position = door_pos
		door.look_at(door_pos + seg_n)
		avoid_list.push_back(door_pos)
		state = STATE_WINDOW
	elif state == STATE_WINDOW:
		for k in range(outline.size()):
			var p1 = outline[k]
			var p2 = outline[(k + 1) % outline.size()]
			var seg_n = (p2 - p1)
			var seg_length = (p2 - p1).length()
			var w_v = (p2 - p1).normalized()
			var w_b = fmod(seg_length, window_space) / 2.0
			var n_seg = int(seg_length / window_space)
			var tp = w_b + (window_space - window_width)/ 2.0
			for h in range(n_seg):
				var win_pos = p1 + w_v * (tp + window_width / 2.0)
				var ok = true
				for p in avoid_list:
					if p.distance_to(win_pos) < 2.1:
						ok = false
				if !ok:
					continue
				var window = load("res://rooms/window.tscn").instance()
				add_child(window)
				window.position = win_pos
				window.look_at(win_pos + seg_n)
				window.add_to_group("windows")
				window.seg_n = seg_n
				window.segment = k
				tp += window_space
		state = STATE_ROOM
	elif state == STATE_ROOM:
		var room_type = pick_room_type()
		var room_pos = Vector2(0, 0)
		var room_look = Vector2(1, 0)
		var room_valid = false
		var w
		if room_type.window:
			var windows = get_tree().get_nodes_in_group("windows")
			w = windows[randi() % windows.size()]
			if w.room == null:
				var n = -w.seg_n.tangent().normalized() * 2.0
				room_pos = w.position + n
				room_look = w.position + n * 2.0
				room_valid = true
		else:
			room_pos = $Navigation2D.get_closest_point(Vector2(rnd.randf() * aabb.size.x - aabb.position.x, rnd.randf() * aabb.size.y - aabb.position.y))
			print(aabb)
			room_look = room_pos + Vector2(1, 0)
			room_valid = true
		if !valid_room_spawn(room_pos):
			room_valid = false
		if room_valid:
			var room = load("res://rooms/room.tscn").instance()
			room.add_to_group("rooms")
			add_child(room)
			room.position = room_pos
			room.look_at(room_look)
			if w != null:
				w.room = room
				room.window = w
	elif state == STATE_BUILD:
		pass
