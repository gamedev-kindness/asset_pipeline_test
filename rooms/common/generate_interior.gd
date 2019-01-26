extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var grid_size = 0.2
var rnd
var graph = {
	"start": "floor",
	"floor": {
		"polygon": [Vector2(-10, -10), Vector2(0, -20), Vector2(10, -10), Vector2(10, 10), Vector2(-10, 10)],
		"contains": ["block"],
		"multiple": true,
		"window": false,
	},
	"block": {
		"min_area": 16.0,
		"contains": ["private", "public", "hallway"],
		"multiple": false,
		"window": true,
	},
	"private": {
		"min_area": 8.0,
		"contains": ["bathroom", "toilet", "bedroom"],
		"multiple": true,
	},
	"public": {
		"min_area": 8.0,
		"contains": ["kitchen", "livingroom", "diningroom"],
		"multiple": true,
	},
}
func grid_to_point(element, x, y):
	var ret = Vector2(element.rect.position.x + (x - 1) * grid_size + grid_size / 2.0, element.rect.position.y + (y - 1) * grid_size + grid_size / 2.0)
	return ret
func point_to_grid(element, x, y):
	var retx = int((x - element.rect.position.x) / grid_size + 0.5) + 1
	var rety = int((x - element.rect.position.x) / grid_size + 0.5) + 1
	return Vector2(retx, rety)
var start_element = {"room": "floor", "polygon": graph.floor.polygon, "id": 0, "parent_id": -1, "position": Vector2(), "window": false}
func build_rect():
	rooms.clear()
	if queue.size() == 0:
		return
	var item = queue[0]
	queue.pop_front()
	var poly = item.polygon
	var rect = Rect2()
	for p in poly:
		rect = rect.expand(p)
	print("position: ", rect.position, " size:", rect.size)
	item.rect = rect
	item.area = rect.get_area()
	queue.push_back(item)
func set_grid(r, x, y, p):
	var gp = grid_to_point(r, x, y)
	r.grid[y * r.grid_width + x] = p
func get_grid(r, x, y):
	var gp = grid_to_point(r, x, y)
	return r.grid[y * r.grid_width + x]
func build_grid():
	if queue.size() == 0:
		return
	var item = queue[0]
	queue.pop_front()
	var r = item
	var grid_width = int(r.rect.size.x / grid_size + 0.5) + 2
	var grid_height = int(r.rect.size.y / grid_size + 0.5) + 2
	r.grid_width = grid_width
	r.grid_height = grid_height
	print(grid_height)
	print(grid_width)
	print(grid_height * grid_width)
	r.grid = []
	r.grid.resize(grid_height * grid_width)
	var tris = Geometry.triangulate_polygon(r.polygon)
	for yy in range(grid_height):
		for xx in range(grid_width):
				var point = grid_to_point(r, xx, yy)
				var in_polygon = false
				for p in range(0, tris.size(), 3):
					var p1 = r.polygon[tris[p]]
					var p2 = r.polygon[tris[p + 1]]
					var p3 = r.polygon[tris[p + 2]]
					var cvec1 = Vector2(grid_size / 8.0, 0)
					var cvec2 = Vector2(0, grid_size / 8.0)
					var vecs = [Vector2(), cvec1, -cvec1, cvec2, -cvec2, cvec1 + cvec2, -cvec1, -cvec2]
					for vv in vecs:
						if Geometry.point_is_inside_triangle(point, p1 + vv, p2 + vv, p3 + vv):
							in_polygon = true
							break
						if in_polygon:
							break
				if in_polygon:
					set_grid(r, xx, yy, 0)
				else:
					set_grid(r, xx, yy, 1)
	queue.push_back(r)
func rasterize_grid():
	if queue.size() == 0:
		return
	var item = queue[0]
	queue.pop_front()
	var r = item
	while get_tree().get_nodes_in_group("grid_raster").size() > 0:
		get_tree().get_nodes_in_group("grid_raster")[0].queue_free()
	var mesh = CubeMesh.new()
	mesh.size = Vector3(grid_size, 3.0, grid_size)
	for yy in range(r.grid_width):
		for xx in range(r.grid_width):
			if get_grid(r, xx, yy) > 0:
				var point = grid_to_point(r, xx, yy)
				var mi = MeshInstance.new()
				mi.mesh = mesh
				var point3 = Vector3(point.x, 1.3, point.y)
				add_child(mi)
				mi.add_to_group("grid_raster")
				mi.translation = point3
	queue.push_back(r)
var rnd_seed = 878473594759
func _ready():
	rnd = RandomNumberGenerator.new()
	rnd.seed = rnd_seed
	print("done")
# Called every frame. 'delta' is the elapsed time since the previous frame.
var queue = [start_element]
var rooms = []
func get_random_pos(r):
	while true:
		var posx = r.rect.size.x * rnd.randf() + r.rect.position.x
		var posy = r.rect.size.y * rnd.randf() + r.rect.position.y
		var tris = Geometry.triangulate_polygon(r.polygon)
		var in_polygon = false
		var point = Vector2(posx, posy)
		for p in range(0, tris.size(), 3):
			var p1 = graph.floor.polygon[tris[p]]
			var p2 = graph.floor.polygon[tris[p + 1]]
			var p3 = graph.floor.polygon[tris[p + 2]]
			if Geometry.point_is_inside_triangle(point, p1, p2, p3):
				in_polygon = true
				return point
var room_id = 2
func spawn_rooms():
	if queue.size() == 0:
		return
	var item = queue[0]
	queue.pop_front()
	var room_src = graph[item.room].contains
	if graph[item.room].multiple:
		var rem_area = item.area
		while rem_area > 0.0:
			for r in room_src:
				var room_data = {"room": r, "id": room_id, "parent_id": item.id, "position": get_random_pos(item), "window": graph[item.room].window}
				rooms.push_back(room_data)
				rem_area -= graph[r].min_area * 10.0
				room_id += 1
var correction = 0.02
func apply_distance(r):
	for ro in rooms:
		if r.position.distance_to(ro.position) < sqrt(graph[r.room].min_area) + 1.0:
			r.position += (r.position - ro.position) * correction
func apply_window(r):
	var dst
	var pv
	for p in graph.floor.polygon:
		if pv == null:
			pv = p
			dst = r.position.distance_to(p)
			continue
		if dst > r.position.distance_to(p):
			dst = r.position.distance_to(p)
			pv = p
	r.position += (pv - r.position) * correction
func apply_poly(r):
	var dst
	var pv
	for p in graph.floor.polygon:
		if pv == null:
			pv = p
			dst = r.position.distance_to(p)
			continue
		if dst > r.position.distance_to(p):
			dst = r.position.distance_to(p)
			pv = p
	if r.position.distance_to(pv) < sqrt(graph[r.room].min_area) + 1.0:
		r.position += (r.position - pv) * correction

func apply_constraints():
	for r in rooms:
		apply_distance(r)
		if graph[r.room].window:
			apply_window(r)
		apply_poly(r)
var check_count = 0
func check_constraints():
	for r in rooms:
		var dst
		var pv
		for p in graph.floor.polygon:
			if pv == null:
				pv = p
				dst = r.position.distance_to(p)
				continue
			if dst > r.position.distance_to(p):
				dst = r.position.distance_to(p)
				pv = p
		if !r.position.distance_to(pv) < sqrt(graph[r.room].min_area) + 1.0:
			if check_count <= 0:
				rooms.erase(r)
				check_count += 20
			return false
		if graph[r.room].window:
			if !r.position.distance_to(pv) > sqrt(graph[r.room].min_area) - 1.0:
				if check_count <= 0:
					rooms.erase(r)
					check_count += 20
				return false
		for t in rooms:
			if t.position.distance_to(r.position) < sqrt(graph[r.room].min_area) + 1.0:
				if check_count <= 0:
					rooms.erase(r)
					check_count += 20
				return false
	return true

func grow_rooms():
	pass
enum {STATE_BUILD_RECT, STATE_BUILD_GRID, STATE_RASTERIZE_GRID, STATE_SPAWN_ROOMS, STATE_CONSTRAINTS, STATE_GROW_ROOMS}
var state = STATE_BUILD_RECT
func _process(delta):
	match(state):
		STATE_BUILD_RECT:
			build_rect()
			state = STATE_BUILD_GRID
		STATE_BUILD_GRID:
			build_grid()
			state = STATE_RASTERIZE_GRID
		STATE_RASTERIZE_GRID:
			rasterize_grid()
			state = STATE_SPAWN_ROOMS
		STATE_SPAWN_ROOMS:
			spawn_rooms()
			check_count = 120
			state = STATE_CONSTRAINTS
		STATE_CONSTRAINTS:
			print(rooms.size())
			print(check_count)
#			print(rooms)
			for t in range(200):
				apply_constraints()
			check_count -= 1
			if check_constraints():
				print("constraints ok")
				state = STATE_GROW_ROOMS
		STATE_GROW_ROOMS:
			grow_rooms()
			rasterize_grid()
