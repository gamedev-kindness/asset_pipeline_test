extends Spatial

export var outside_wall_mesh: Mesh = Mesh.new()
export var internal_wall1: PackedScene
export var internal_wall4: PackedScene
export var internal_floor: PackedScene
export var internal_angle: PackedScene
export var internal_door: PackedScene
export var toilet: PackedScene
export var shower: PackedScene
export var bed: PackedScene
export var door_to_door_material: Material
export var kitchen_cabinet: PackedScene

var outline = [Vector2(-25, -25), Vector2(0, -26), Vector2(25, -25), Vector2(25, 25), Vector2(-25, 25)]
var doors = [Vector2(-10, 0)]

var wall_width = 2.0

var rnd

var room_classes = {
	"bathroom": {
		"name": "bathroom",
		"private": true,
		"min_area": 3,
		"max_area": 60,
		"wall_item_probability": 0.1,
		"wall_items": ["toilet", "shower"]
	},
	"bedroom": {
		"name": "bedroom",
		"private": true,
		"min_area": 8,
		"max_area": 60,
		"wall_item_probability": 0.0,
		"wall_items": [],
		"main_area_items": ["bed"]
	},
	"kitchen": {
		"name": "kitchen",
		"private": false,
		"min_area": 6,
		"max_area": 35,
		"wall_item_probability": 0.3,
		"wall_items": ["kitchen_cabinet"],
		"main_area_items": []
		
	},
	"living_room": {
		"name": "living_room",
		"private": false,
		"min_area": 16,
		"max_area": 60,
		"wall_item_probability": 0.0,
		"wall_items": [],
		"main_area_items": []
	},
	"classroom": {
		"name": "classroom",
		"private": false,
		"min_area": 40,
		"max_area": 120,
		"wall_item_probability": 0.0,
		"wall_items": [],
		"main_area_items": []
	},
}

onready var items = {
	"bed": {
		"area": 2.0,
		"model": bed
	},
	"toilet": {
		"area": 1.0,
		"model": toilet
	},
	"shower": {
		"area": 2.5,
		"model": shower
	},
	"kitchen_cabinet": {
		"area": 0.5,
		"model": kitchen_cabinet
	}
}

func classify_room(room):
	var matching_rooms = []
	var mandatory_rooms = ["bedroom", "bathroom", "kitchen", "classroom"]
	var public = false
	if room.exits.size() > 1:
		public = true
	for k in room_classes.keys():
		if room.rect.get_area() >= room_classes[k].min_area && room.rect.get_area() <= room_classes[k].max_area:
			if public && (!room_classes[k].private):
				matching_rooms.push_back(room_classes[k])
			elif (!public) && room_classes[k].private:
				matching_rooms.push_back(room_classes[k])
			matching_rooms.push_back(room_classes[k])
	if matching_rooms.size() == 0:
		return null
	for m in mandatory_rooms:
		var ok = false
		for h in rooms.keys():
			var r = rooms[h]
			if !r.has("class") || r.class == null:
				continue
			if r.class == room_classes[m]:
				ok = true
				break
		if !ok && room_classes[m] in matching_rooms:
			return room_classes[m]
				
		
	var ret =  matching_rooms[rnd.randi() % matching_rooms.size()]
	print(ret, " ", public, " ", room.exits)
	return ret

func build_navigation():
	var id = 0
	var start_ids = []
	var end_ids = []
	print("building navigation")
	for p in get_tree().get_nodes_in_group("nav"):
		var curve = p.curve
		start_ids.push_back(id)
		for pt in range(curve.get_point_count()):
			awareness.astar.add_point(id, p.global_transform.xform(curve.get_point_position(pt)))
			if pt > 0:
				awareness.astar.connect_points(id - 1, id)
			id += 1
		end_ids.push_back(id - 1)
	for sid in start_ids:
		var p1 = awareness.astar.get_point_position(sid)
		for pt  in range(id):
			if sid == pt:
				continue
			var p2 = awareness.astar.get_point_position(pt)
			var d = p1.distance_squared_to(p2)
			if d < 2.0:
				awareness.astar.connect_points(sid, pt)
	for eid in end_ids:
		var p1 = awareness.astar.get_point_position(eid)
		for pt  in range(id):
			if eid == pt:
				continue
			var p2 = awareness.astar.get_point_position(pt)
			var d = p1.distance_squared_to(p2)
			if d < 2.0:
				awareness.astar.connect_points(eid, pt)
	print("building navigation done ", awareness.astar.get_available_point_id())

func build_outline():
	for m in range(outline.size()):
		var p1 = outline[m]
		p1 = Vector2(p1.x , p1.y)
		var p2 = outline[(m + 1) % outline.size()]
		p2 = Vector2(p2.x , p2.y)
		var dir = (p2 - p1).normalized()
		var p = p1
		while p.distance_to(p2) >= wall_width:
			var pos = p + dir * (wall_width / 2.0)
			var actual_pos = Vector3(pos.x, 1.3, pos.y)
			var sp = MeshInstance.new()
			sp.mesh = outside_wall_mesh
			add_child(sp)
			sp.translation = actual_pos
			sp.rotation.y = -(p2 - p1).angle()
			p += dir * wall_width
var rooms = {}
func get_rect_segments(r: Rect2) -> Array:
		var width_x = r.size.x
		var width_y = r.size.y
		var p1 = r.position
		var p2 = r.position + Vector2(width_x, 0.0)
		var p3 = r.position + Vector2(width_x, width_y)
		var p4 = r.position + Vector2(0, width_y)
		var wall_segment1 = [p1, p2]
		var wall_segment2 = [p2, p3]
		var wall_segment3 = [p3, p4]
		var wall_segment4 = [p4, p1]
		return [wall_segment1, wall_segment2, wall_segment3, wall_segment4]
enum {ELEMENT_FLOOR, ELEMENT_ANGLE, ELEMENT_WALL, ELEMENT_DOOR}
func get_room_door(room1, room2):
	var p
	var wall_no = -1
	var p1 = room1.rect.position + room1.rect.size / 2.0
	var p2 = room2.rect.position + room2.rect.size / 2.0
	for wall_id in range(room1.walls.size()):
		var s1 = room1.walls[wall_id].segment[0]
		var s2 = room1.walls[wall_id].segment[1]
		p = Geometry.segment_intersects_segment_2d(p1, p2, s1, s2)
		if p:
			wall_no = wall_id
			break
	if !p:
		return null
	else:
		return {"position": p, "wall": wall_no}
func build_room_data():
	for r in $random_split.rects:
		var width_x = int(r.size.x + 0.5)
		var width_y = int(r.size.y + 0.5)
		var room = {
			"rect": r,
			"x": width_x,
			"y": width_y,
			"exits": [],
			"walls": [],
			"grid": []
		}
		var segments = get_rect_segments(r)
		for s in segments:
			var wall_data = {}
			wall_data.segment = s
			room.walls.push_back(wall_data)
			var seg_angle = (s[1] -s[0]).angle()
			wall_data.seg_angle = seg_angle
		room.grid.resize(width_x * width_y)
		var wall_id = 0
		for h in range(width_y):
			for i in range(width_x):
				var element = ELEMENT_WALL
				var angle = 0.0
				if h in [0, width_y - 1] && i in [0, width_x - 1]:
					element = ELEMENT_ANGLE
					if h == 0 && i == 0:
						angle = PI
						wall_id = 2
					elif h == width_y - 1 && i == width_x - 1:
						angle = 0
						wall_id = 3
					if i == 0 && h == width_y - 1:
						angle = -PI / 2.0
						wall_id = 1
					elif i == width_x - 1 && h == 0:
						angle = PI / 2.0
						wall_id = 0
				elif h in [0, width_y - 1] && i in range(width_x):
					element = ELEMENT_WALL
					if h == 0:
						angle = PI
						wall_id = 0
					elif h == width_y - 1:
						angle = 0
						wall_id = 3
				elif i in [0, width_x - 1] && h in range(width_y):
					element = ELEMENT_WALL
					if i == 0:
						angle = -PI / 2.0
						wall_id = 1
					elif i == width_x - 1:
						angle = PI / 2.0
						wall_id = 2
				else:
					element = ELEMENT_FLOOR
					angle = 0.0
					wall_id = 0
				room.grid[h * width_x + i] = {
					"element": element,
					"angle": angle,
					"wall_id": wall_id,
					"seg_angle": room.walls[wall_id].seg_angle
				}
				print("angle: ", angle, " seg_angle: ", room.walls[wall_id].seg_angle, "element: ", element, "wall_id: ", wall_id)
		rooms[r] = room
var door_pairing = {}
func build_door_data():
	for d in $random_split.door_data:
		if !rooms.has(d.a):
			print("bad rect ", d.a)
		if !rooms.has(d.b):
			print("bad rect ", d.b)
		var back_route_exists = false
		for nd in $random_split.door_data:
			if d.a == nd.b && d.b == nd.a:
				back_route_exists = true
		if back_route_exists:
			continue
		var new_data = d.duplicate()
		new_data.a = d.b
		new_data.b = d.a
		$random_split.door_data.push_back(new_data)

func get_exit_positions(r, t):
	var room1 = rooms[r]
	var room2 = rooms[t]
	var exit1
	var exit2
	for k in room1.exits:
		if k.other == t:
			exit1 = k
			break
	for k in room2.exits:
		if k.other == r:
			exit2 = k
			break
	if exit1 == null || exit2 == null:
		return []
	return [exit1, exit2]
func classify_rooms():
	for k in rooms.keys():
		rooms[k].class = classify_room(rooms[k])

func build_room_connection_pairs():
	for d in $random_split.door_data:
		if d.a == d.b:
			continue
		var r = d.a
		var t = d.b
		var exits = get_exit_positions(r, t)
		if exits.size() > 0:
			var p1 = r.position + Vector2(exits[0].door_x, exits[0].door_y)
			var p2 = t.position + Vector2(exits[1].door_x, exits[1].door_y)
			print("build pair: ", p1, " ", p2, p1.distance_to(p2))
			var mesh = $geometry_gen.create_room_connection(p1, p2, 1.0, 2.0, null, null, null)
			var mi = MeshInstance.new()
			mi.mesh = mesh
			add_child(mi)
			var sb = StaticBody.new()
			add_child(sb)
			var col = CollisionShape.new()
			var colmesh = mesh.create_trimesh_shape()
			col.shape = colmesh
			sb.add_child(col)
func add_exit(r: Rect2, t: Rect2) -> void:
	var room = rooms[r]
	var door_data = get_room_door(rooms[r], rooms[t])
	if !door_data:
		return
	if room.x == 0 || room.y == 0:
		return
	var exit_data = {}
	var p = door_data.position
	exit_data.wall_id = door_data.wall
	exit_data.position = p
	exit_data.rel_pos = p - r.position
	exit_data.other = t
	exit_data.current = r
	var door_x = int(clamp(exit_data.rel_pos.x, 0.0, room.x - 1))
	var door_y = int(clamp(exit_data.rel_pos.y, 0.0, room.y - 1))
	exit_data.door_x = door_x
	exit_data.door_y = door_y
	room.grid[door_y * room.x + door_x].element = ELEMENT_DOOR
	rooms[r].exits.push_back(exit_data)
func build_door_grid_data():
	for d in $random_split.door_data:
		if d.a == d.b:
			continue
#		var exit_data = {}
		var r = d.a
		var t = d.b
		if r == null || t == null:
			continue
		add_exit(r, t)

func build_rooms():
	for r in $random_split.rects:
		var room = rooms[r]
		var width_x = room.x
		var width_y = room.y
		
		for h in range(width_y):
			for i in range(width_x):
				var angle = room.grid[h * width_x + i].angle
				var wall = false
				var wall_angle = false
				var door = false
				match(room.grid[h * width_x + i].element):
					ELEMENT_ANGLE:
						wall_angle = true
					ELEMENT_WALL:
						wall = true
					ELEMENT_DOOR:
						door = true
				if wall:
					var wall_model = internal_wall1.instance()
					add_child(wall_model)
					wall_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					wall_model.rotation.y = angle
					if room.class:
						if rnd.randf() < room.class.wall_item_probability:
							var item = room.class.wall_items[rnd.randi() % room.class.wall_items.size()]
							var model = items[item].model.instance()
							add_child(model)
							var offset = Vector3(0.0, 0, -0.1)
							var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
							model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h) + tf
							model.rotation.y = PI + angle
				elif door:
					var door_model = internal_door.instance()
					add_child(door_model)
					door_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					door_model.rotation.y = angle
				elif wall_angle:
					var angle_model = internal_angle.instance()
					add_child(angle_model)
					angle_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					angle_model.rotation.y = angle
					print(angle)
				else:
					var floor_model = internal_floor.instance()
					add_child(floor_model)
					floor_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					floor_model.rotation.y = angle
		if room.class && room.class == room_classes.bedroom:
			var dim_x = int(r.size.x / 2.0 / 1.8)
			var dim_y = int(r.size.y / 2.0 / 1.8)
			for th in range(dim_x):
				for tg in range(dim_y):
					var pos = Vector3(th - float(dim_x) / 2.0 + (rnd.randf() - 0.5) * 0.25, 0.0, tg - float(dim_y) / 2.0 + (rnd.randf() - 0.5) * 0.25) * 2.5
					var bed_model = bed.instance()
					add_child(bed_model)
					bed_model.translation = Vector3(r.position.x + r.size.x / 2.0, 0.0, r.position.y + r.size.y / 2.0) + pos

# Called when the node enters the scene tree for the first time.
func plan_complete():
	state = 1
	print("complete: ", $random_split.rects.size(), " ", $random_split.door_data.size())

var state = 0
func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.seed = OS.get_unix_time()
	$random_split.rnd = rnd
	$random_split.outline = outline
	$random_split.doors = doors
	$random_split.connect("complete", self, "plan_complete")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(state):
		1:
			build_outline()
			state = 2
		2:
			build_room_data()
			state = 3
		3:
			build_door_data()
			state = 4
		4:
			state = 5
		5:
			build_door_grid_data()
			build_room_connection_pairs()
			state = 6
		6:
			classify_rooms()
			build_rooms()
			state = 7
		7:
			build_navigation()
			state = 8
		8:
			for k in get_tree().get_nodes_in_group("beds"):
				k.emit_signal("spawn")
			state = 9
