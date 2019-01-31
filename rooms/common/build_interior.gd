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

var outline = [Vector2(-10, -20), Vector2(0, -21), Vector2(10, -20), Vector2(10, 20), Vector2(-10, 20)]
var doors = [Vector2(-10, 0)]

var wall_width = 2.0

var rnd

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
		room.grid.resize(width_x * width_y)
		for h in range(width_y):
			for i in range(width_x):
				var element = ELEMENT_WALL
				var angle = 0.0
				if h in [0, width_y - 1] && i in [0, width_x - 1]:
					element = ELEMENT_ANGLE
					if h == 0 && i == 0:
						angle = PI
					elif h == width_y - 1 && i == width_x - 1:
						angle = 0
					if i == 0 && h == width_y - 1:
						angle = -PI / 2.0
					elif i == width_x - 1 && h == 0:
						angle = PI / 2.0
				elif h in [0, width_y - 1] && i in range(width_x):
					element = ELEMENT_WALL
					if h == 0:
						angle = PI
					elif h == width_y - 1:
						angle = 0
				elif i in [0, width_x - 1] && h in range(width_y):
					element = ELEMENT_WALL
					if i == 0:
						angle = -PI / 2.0
					elif i == width_x - 1:
						angle = PI / 2.0
				else:
					element = ELEMENT_FLOOR
					angle = 0.0
				room.grid[h * width_x + i] = {
					"element": element,
					"angle": angle
				}
		rooms[r] = room
#				if element == ELEMENT_WALL:
#					for d in $random_split.door_data:
#						if (Vector2(r.position.x + i, r.position.y + h)).distance_to(d.pos) < 1.0:
#							door = true
#							wall = false
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
		
	for d in $random_split.door_data:
		if d.a == d.b:
			continue
		var exit_data = {}
		var r = d.a
		var t = d.b
		var p1 = r.position + r.size / 2.0
		var p2 = t.position + t.size / 2.0
		var room = rooms[r]
		var door_data = get_room_door(rooms[r], rooms[t])
		if !door_data:
			continue
		var p = door_data.position
		exit_data.wall_id = door_data.wall
		exit_data.position = p
		rooms[r].exits.push_back(exit_data)
#		var have_door = false
#		var dst = 100.0
#		var np = p - r.position
#		var npos = Vector2(np.x, np.y)
#		var door_pt = Vector2()
#		var wall
#		for h in range(rooms[r].y):
#			for i in range(rooms[r].x):
#				if rooms[r].grid[h * rooms[r].x + i].element == ELEMENT_WALL:
#					match(door_data.wall):
#						0:
#							npos += Vector2(0.0, 0.0)
#						1:
#							npos += Vector2(-0.5, 0.0)
#						2:
#							npos += Vector2(0.5, -0.5)
##						3:
##							npos += Vector2(0.0, 0.0)
#					var ndst = npos.distance_to(Vector2(i, h))
#					if ndst < 1.0:
#						rooms[r].grid[h * rooms[r].x + i].element = ELEMENT_DOOR
#						have_door = true
#					else:
#						if dst > ndst:
#							dst = ndst
#							door_pt = npos - Vector2(i, h)
#							wall = door_data.wall
#		if !have_door:
#			var nr = Rect2(r.position, r.size)
#			nr.size.x = int(nr.size.x + 0.5)
#			nr.size.y = int(nr.size.y + 0.5)
#			print("room rect", r, "/ ", nr, " has no door ", exit_data, " dst:", dst, " npos: ", door_pt, " wall: ", wall)


func build_rooms():
	for r in $random_split.rects:
		var room = rooms[r]
		var width_x = room.x
		var width_y = room.y
#		r.position.x = int(r.position.x * 0.5 - 0.5) * 2.0
#		r.position.y = int(r.position.y * 0.5 - 0.5) * 2.0
#		r.size.x = int(r.size.x * 0.5) * 2.0
#		r.size.y = int(r.size.y * 0.5) * 2.0
		
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
#				if h in [0, width_y - 1] && i in [0, width_x - 1]:
#					wall_angle = true
#					if h == 0 && i == 0:
#						angle = PI
#					elif h == width_y - 1 && i == width_x - 1:
#						angle = 0
#					if i == 0 && h == width_y - 1:
#						angle = -PI / 2.0
#					elif i == width_x - 1 && h == 0:
#						angle = PI / 2.0
#				elif h in [0, width_y - 1] && i in range(width_x):
#					wall = true
#					if h == 0:
#						angle = PI
#					elif h == width_y - 1:
#						angle = 0
#				elif i in [0, width_x - 1] && h in range(width_y):
#					wall = true
#					if i == 0:
#						angle = -PI / 2.0
#					elif i == width_x - 1:
#						angle = PI / 2.0
#				if wall:
#					for d in $random_split.door_data:
#						if (Vector2(r.position.x + i, r.position.y + h)).distance_to(d.pos) < 1.0:
#							door = true
#							wall = false
				if wall:
					var wall_model = internal_wall1.instance()
					add_child(wall_model)
					wall_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					wall_model.rotation.y = angle
					if rnd.randf() > 0.98:
						var toilet_model = toilet.instance()
						add_child(toilet_model)
						var offset = Vector3(0.0, 0, -0.1)
						var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
						toilet_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h) + tf
						toilet_model.rotation.y = PI + angle
					elif rnd.randf() > 0.995:
						var shower_model = shower.instance()
						add_child(shower_model)
						var offset = Vector3(0.0, 0, -0.1)
						var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
						shower_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h) + tf
						shower_model.rotation.y = PI + angle
				elif door:
					for d in $random_split.door_data:
						if (Vector2(r.position.x + i, r.position.y + h)).distance_to(d.pos) < 0.5:
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
#					var offset = Vector3(-0.5, 0, -0.5)
#					var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
					floor_model.translation = Vector3(r.position.x + i, 0.0, r.position.y + h)
					floor_model.rotation.y = angle
		var bed_model = bed.instance()
		add_child(bed_model)
		bed_model.translation = Vector3(r.position.x + r.size.x / 2.0, 0.0, r.position.y + r.size.y / 2.0)
#		var p1 = r.position
#		var p2 = r.position + Vector2(r.size.x, 0)
#		var p3 = r.position + Vector2(r.size.x, r.size.y)
#		var p4 = r.position + Vector2(0, r.size.y)
#		var points = [p1, p2, p3, p4]
#		var angles = [PI, PI / 2.0, 0, -PI / 2.0]
#		for k in range(points.size()):
#			var pa1 = points[k]
#			var pa2 = points[(k + 1) % points.size()]
#			var angle = angles[k]
#			var p = pa1
#			var dir = (pa2 - pa1).normalized()
#			while p.distance_to(pa2) >= 1.0:
#				var wall = internal_wall1.instance()
#				var pos = p
#				var actual_pos = Vector3(pos.x, 0.0, pos.y)
#				add_child(wall)
#				var offset = Vector3(-1, 0, -1)
#				var tf = Transform(Quat(Vector3(0, 1, 0), angle)) * offset
#				wall.translation = actual_pos + tf
#				wall.rotation.y = angles[k]
#				p += dir
			
		
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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
			build_rooms()
			state = 4
		4:
			build_navigation()
			state = 5
		5:
			for k in get_tree().get_nodes_in_group("beds"):
				k.emit_signal("spawn")
			state = 6
