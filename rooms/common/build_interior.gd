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

var outline = [Vector2(-50, -15), Vector2(0, -17), Vector2(50, -15), Vector2(50, 15), Vector2(-50, 15)]
var doors = [Vector2(-10, 0)]

var wall_width = 2.0

var rnd
var door_pairing = {}

var room_classes = {
	"bathroom": {
		"name": "bathroom",
		"private": true,
		"min_area": 3,
		"max_area": 40,
		"wall_item_probability": 0.1,
		"wall_items": ["toilet", "shower"]
	},
	"bedroom": {
		"name": "bedroom",
		"private": true,
		"min_area": 8,
		"max_area": 80,
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
#			matching_rooms.push_back(room_classes[k])
	if matching_rooms.size() == 0:
		return null
	for m in mandatory_rooms:
		var ok = false
		for h in $random_split.rooms.keys():
			var r = $random_split.rooms[h]
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
func check_room_classes():
	var mandatory_rooms = ["bedroom", "bathroom", "kitchen", "classroom"]
	var m_classes = []
	for k in mandatory_rooms:
		m_classes.push_back(room_classes[k])
	for c in m_classes:
		var ok = false
		for k in $random_split.rooms.keys():
			if $random_split.rooms[k].class == c:
				ok = true
				break
		if !ok:
			return false
	return true	

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
enum {ELEMENT_FLOOR, ELEMENT_ANGLE, ELEMENT_WALL, ELEMENT_DOOR}
#func fix_foom_exits():
#	for r1 in rooms.keys():
#		for r2 in rooms.keys():
#			if r1 == r2:
#				continue
#			for e1 in range(rooms[r1].exits.size()):
#				for e2 in range(rooms[r2].exits.size()):
#					var me1 = rooms[r1].exits[e1].position
#					var me2 = rooms[r2].exits[e2].position
#					if me1.distance_to(me2) < 1.0:
#						var np = me1.linear_interpolate(me2, 0.5)
#						rooms[r1].exits[e1].position = np
#						rooms[r2].exits[e2].position = np
func classify_rooms():
	for k in $random_split.rooms.keys():
		$random_split.rooms[k].class = classify_room($random_split.rooms[k])
#var room_connections = []
#func build_room_connection_pairs():
#	print("door data size:", $random_split.door_data.size())
#	for d in $random_split.door_data:
#		if d.a == d.b:
#			continue
#		var r = d.a
#		var t = d.b
#		var exits = $random_split.get_exit_positions(r, t)
#		if exits.size() > 0:
##			var p1 = r.position + Vector2(exits[0].door_x, exits[0].door_y)
##			var p2 = t.position + Vector2(exits[1].door_x, exits[1].door_y)
#			var p1 = r.position + exits[0].rel_pos
#			var p2 = t.position + exits[1].rel_pos
#			print("build pair: ", p1, " ", p2, p1.distance_to(p2))
##			var mesh = $geometry_gen.create_room_connection(p1, p2, 1.0, 2.0, null, null, null)
##			var mi = MeshInstance.new()
##			mi.mesh = mesh
##			add_child(mi)
##			var sb = StaticBody.new()
##			add_child(sb)
##			var col = CollisionShape.new()
##			var colmesh = mesh.create_trimesh_shape()
##			col.shape = colmesh
##			sb.add_child(col)
##			room_connections.push_back(mi)
##			room_connections.push_back(sb)

#func clear_connections():
#	for m in room_connections:
#		m.queue_free()
#	room_connections.clear()


func build_room_floors():
	print("rect count: ", $random_split.rects.size())
	var floor_mesh = $geometry_gen.create_floor($random_split.rects, load("res://rooms/room_kit/test_floor_material.tres"))
	var floor_mi = MeshInstance.new()
	floor_mi.mesh = floor_mesh
	add_child(floor_mi)
	var sb = StaticBody.new()
	add_child(sb)
	var col = CollisionShape.new()
	var colmesh = floor_mesh.create_trimesh_shape()
	col.shape = colmesh
	sb.add_child(col)
func build_room_walls():
	var walls_meshes = $geometry_gen.create_walls($random_split.rects, $random_split.rooms, 2.8, load("res://rooms/room_kit/test_wall1_material.tres"), 0.5)
	for k in walls_meshes:
		var walls_mi = MeshInstance.new()
		walls_mi.mesh = k
		add_child(walls_mi)
	var sb = StaticBody.new()
	add_child(sb)
	for k in walls_meshes:
		var col = CollisionShape.new()
		var colmesh = k.create_trimesh_shape()
		col.shape = colmesh
		sb.add_child(col)
func build_rooms():
	var id = 0
	for r in $random_split.rects:
		print("room: ", id)
		var room = $random_split.rooms[r]
		var width_x = room.x
		var width_y = room.y
		print("room: ", id, "size: ", width_x, " ", width_y)
		
#		for h in range(width_y):
#			for i in range(width_x):
#				var angle = room.grid[h * width_x + i].angle
#				var wall = false
#				var wall_angle = false
#				var door = false
#				match(room.grid[h * width_x + i].element):
#					ELEMENT_ANGLE:
#						wall_angle = true
#						var angle_model = internal_angle.instance()
#						add_child(angle_model)
#						angle_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
#						angle_model.rotation.y = angle
#					ELEMENT_WALL:
#						wall = true
#						var wall_model = internal_wall1.instance()
#						add_child(wall_model)
#						wall_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
#						wall_model.rotation.y = angle
#						if room.class:
#							if rnd.randf() < room.class.wall_item_probability:
#								var item = room.class.wall_items[rnd.randi() % room.class.wall_items.size()]
#								var model = items[item].model.instance()
#								add_child(model)
#								var offset = Vector3(0.0, 0, -0.1)
#								var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
#								model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h) + tf
#								model.rotation.y = PI + angle
#					ELEMENT_DOOR:
#						door = true
#						var door_model = internal_door.instance()
#						add_child(door_model)
#						door_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
#						door_model.rotation.y = angle
#					_:
#						var floor_model = internal_floor.instance()
#						add_child(floor_model)
#						floor_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
#						floor_model.rotation.y = angle
#						print("p6")
		print("room infill: ", id, "size: ", width_x, " ", width_y)
		var center = r.position + r.size * 0.5
		if room.class && room.class == room_classes.bedroom && r.size.x >= 3.0 && r.size.y >= 3.0:
			var room_width = r.size.x
			var room_height = r.size.y
			var bed_width = 2.8
			var bed_height = 2.8
			var x_count = int((room_width - 1.0) / bed_width)
			var y_count = int((room_height - 1.0) / bed_height)
			var start_pos = Vector3(center.x - (x_count * bed_width) * 0.5 + bed_width * 0.5, 0.0, center.y - (y_count * bed_height) * 0.5 + bed_height * 0.5)
			for th in range(x_count):
				for tg in range(y_count):
					var pos = start_pos + Vector3(th * bed_width, 0.0, tg * bed_height)
					var bed_model = bed.instance()
					add_child(bed_model)
					bed_model.translation = pos
					if r.size.y > r.size.x:
						bed_model.rotation.y = -PI / 2.0
		elif room.class && room.class == room_classes.bathroom && r.size.x >= 1.0 && r.size.y >= 1.0:
			var pos = Vector3()
			var toilet_model = toilet.instance()
			add_child(toilet_model)
			toilet_model.translation = Vector3(r.position.x + r.size.x / 2.0, 0.0, r.position.y + r.size.y / 2.0) + pos
			if r.size.y > r.size.x:
				toilet_model.rotation.y = -PI / 2.0
#		elif room.class && room.class == room_classes.bedroom:
#			var pos = Vector3()
#			var bed_model = bed.instance()
#			add_child(bed_model)
#			bed_model.translation = Vector3(r.position.x + r.size.x / 2.0, 0.0, r.position.y + r.size.y / 2.0) + pos
#			if r.size.y > r.size.x:
#				bed_model.rotation.y = -PI / 2.0
			print("room complete: ", id, "size: ", width_x, " ", width_y)
		for e in room.exits:
			var nav = Path.new()
			add_child(nav)
			nav.add_to_group("nav")
			var p = e.position
			while p.distance_to(center) > 0.1:
				nav.curve.add_point(Vector3(p.x, 0.0, p.y))
				p += (center - p).normalized() * 0.1
			nav.curve.add_point(Vector3(center.x, 0.0, center.y))
		id += 1

# Called when the node enters the scene tree for the first time.
func plan_complete():
	state = 1
	print("complete: ", $random_split.rects.size(), " ", $random_split.door_data.size())

var state = -1
func _ready():
	rnd = RandomNumberGenerator.new()
	$random_split.connect("complete", self, "plan_complete")
	$random_split.rnd = rnd
	$random_split.outline = outline
	$random_split.doors = doors


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(state):
		0:
			print("reset values")
			rnd.seed = OS.get_unix_time()
			$random_split.state = 0
			$random_split.rooms.clear()
			door_pairing.clear()
#			clear_connections()
			print("waiting for signal")
			state = -1

		1:
			state = 2
		2:
			state = 3
		3:
			state = 4
		4:
			state = 5
		5:
#			print("room connections")
#			fix_foom_exits()
#			build_room_connection_pairs()
			state = 6
		6:
			classify_rooms()
			if !check_room_classes():
				print("discarded classify")
				state = 0
			else:
				state = 7
		7:
			print("building room floors")
			build_room_floors()
			print("building room walls")
			build_room_walls()
			state = 8
		8:
			print("building rooms")
			build_rooms()
			state = 9
		9:
#			classify_rooms()
#			if !check_room_classes():
#				print("discarded classify")
#				state = 0
			state = 10
		10:
			if get_tree().get_nodes_in_group("beds").size() < 2:
				print("discarded character count")
				state = 0
			build_navigation()
			state = 11
		11:
			build_outline()
			charman.main_scene = self
			state = 12
