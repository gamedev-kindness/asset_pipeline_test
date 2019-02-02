extends Node
signal complete

var outline = []
var rects = []
var queue = []
var min_size = 4.0
var min_area = 10.0
var max_area = 160.0

var tree = {}
var rnd

var border_rects = []
var rooms = []
var grow_rects = []

var doors = []
var corridoors = []
var door_positions = []
var door_data = []
var split_probability = 0.3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var state = 0
func _ready():
	pass

func point_in_polygon(point, poly):
	var tris = Geometry.triangulate_polygon(poly)
	for p in range(0, tris.size(), 3):
		var p1 = poly[tris[p]]
		var p2 = poly[tris[p + 1]]
		var p3 = poly[tris[p + 2]]
		if Geometry.point_is_inside_triangle(point, p1, p2, p3):
			return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process_queue():
	if queue.size() == 0:
		return
	var data = queue[0]
	queue.pop_front()
	if !tree.has(data):
		tree[data] = {"rect": data, "children": [], "parent": null}
	if data.get_area() <= min_area:
		rects.push_back(data)
		return
	if data.size.x <= min_size:
		rects.push_back(data)
		return
	if data.size.y <= min_size:
		rects.push_back(data)
		return

	var r1
	var r2
	if data.get_area() > max_area || ((data.get_area() > min_area * 1.5) && rnd.randf() < split_probability):
		var split = 0.5 + (rnd.randf() - 0.5) * 0.4
		if rnd.randf() > 0.5:
			r1 = Rect2(data.position, Vector2(data.size.x, data.size.y * split))
			r2 = Rect2(data.position + Vector2(0, data.size.y * split), Vector2(data.size.x, data.size.y * split))
		else:
			r1 = Rect2(data.position, Vector2(data.size.x * split, data.size.y))
			r2 = Rect2(data.position + Vector2(data.size.x * split, 0), Vector2(data.size.x * split, data.size.y))
		var d1 = r1.size.x / r1.size.y
		var d2 = r2.size.x / r2.size.y
		var passed = true
		if d1 < 1.0 / 3.0 || d1 > 3.0:
			passed = false
		if d2 < 1.0 / 3.0 || d2 > 3.0:
			passed = false
		if r1.get_area() < min_area:
			passed = false
		if r2.get_area() < min_area:
			passed = false
		if r1.size.x < min_size || r1.size.y < min_size:
			passed = false
		if r2.size.x < min_size || r2.size.y < min_size:
			passed = false
		if passed:
			queue.push_back(r1)
			queue.push_back(r2)
			tree[data].children = [r1, r2]
			tree[r1] = {"rect": r1, "children": [], "parent": data}
			tree[r2] = {"rect": r2, "children": [], "parent": data}
		else:
			print("can't split ", data)
			queue.push_back(data)
	else:
		rects.push_back(data)

func discard_rects():
	var discard_rects = []
	for k in rects:
		var correct_points = 0
		var point = k.position
		if point_in_polygon(point + k.size / 2.0, outline):
			correct_points += 1
		if point_in_polygon(point, outline):
			correct_points += 1
		if point_in_polygon(point + k.size, outline):
			correct_points += 1
		if point_in_polygon(point + Vector2(k.size.x, 0.0), outline):
			correct_points += 1
		if point_in_polygon(point + Vector2(0.0, k.size.y), outline):
			correct_points += 1
		if correct_points < 2:
			discard_rects.push_back(k)
		elif correct_points < 5:
			border_rects.push_back({"rect": k, "orig": k})
			discard_rects.push_back(k)
	while discard_rects.size() > 0:
		rects.erase(discard_rects[0])
		discard_rects.pop_front()

func init_grown_rects():
	var max_area = 0
	var grow_data = []
	while border_rects.size() > 0:
		var data = border_rects[0]
		border_rects.pop_front()
		if max_area < data.rect.get_area():
			max_area = data.rect.get_area()
		grow_data.push_back(data)
	print(max_area)
	while grow_data.size() > 0:
		var data = grow_data[0]
		grow_data.pop_front()
		var pgrow = data.rect.get_area() / max_area
		grow_rects.push_back({"rect": data.rect, "orig": data.orig, "probability": pgrow})
func closest_point_on_outline(p):
	var dst = -1
	var np = Vector2()
	for k in range(outline.size()):
		var p1 = outline[k]
		var p2 = outline[(k + 1) % outline.size()]
		var snp = Geometry.get_closest_point_to_segment_2d(p, p1, p2)
		if dst < 0 || p.distance_to(snp) < dst:
			dst = p.distance_to(snp)
			np = snp
	return np
func shrink_rects():
	if grow_rects.size() > 0:
		var data = grow_rects[0]
		grow_rects.pop_front()
		var point1 = data.rect.position
		var point2 = data.rect.position + Vector2(data.rect.size.x, 0)
		var point3 = data.rect.position + Vector2(0, data.rect.size.y)
		var point4 = data.rect.position + data.rect.size
		var change = 0.04
		if data.rect.get_area() < min_area:
			rects.push_back(data.rect)
			update_rect(data.orig, data.rect)
		if !point_in_polygon(point1, outline):
			if !point_in_polygon(point2, outline) && !point_in_polygon(point3, outline):
				data.rect.position += Vector2(change, change)
				data.rect.size -= Vector2(change, change)
			elif !point_in_polygon(point2, outline):
				data.rect.position += Vector2(0, change)
				data.rect.size -= Vector2(0, change)
			elif !point_in_polygon(point3, outline):
				data.rect.position += Vector2(change, 0)
				data.rect.size -= Vector2(change, 0)
			else:
				# Use distance to contour instead of this
				var dp = closest_point_on_outline(point1) - point1
				dp.x = abs(dp.x)
				dp.y = abs(dp.y)
				if dp.x > dp.y:
					data.rect.position += Vector2(change, 0)
					data.rect.size -= Vector2(change, 0)
				else:
					data.rect.position += Vector2(0, change)
					data.rect.size -= Vector2(0, change)
			grow_rects.push_back(data)
		elif !point_in_polygon(point2, outline):
			if !point_in_polygon(point1, outline) && !point_in_polygon(point4, outline):
				data.rect.position += Vector2(-change, change)
				data.rect.size -= Vector2(change, change)
			elif !point_in_polygon(point1, outline):
				data.rect.position += Vector2(0, change)
				data.rect.size -= Vector2(0, change)
			elif !point_in_polygon(point4, outline):
				data.rect.position += Vector2(0, 0)
				data.rect.size -= Vector2(change, 0)
			else:
				# Use distance to contour instead of this
				var dp = closest_point_on_outline(point2) - point2
				dp.x = abs(dp.x)
				dp.y = abs(dp.y)
				if dp.x > dp.y:
					data.rect.position += Vector2(0, 0)
					data.rect.size -= Vector2(change, 0)
				else:
					data.rect.position += Vector2(0, change)
					data.rect.size -= Vector2(0, change)
			grow_rects.push_back(data)
		elif !point_in_polygon(point3, outline):
			if !point_in_polygon(point1, outline) && !point_in_polygon(point4, outline):
				data.rect.position += Vector2(change, 0.0)
				data.rect.size -= Vector2(change, change)
			elif !point_in_polygon(point1, outline):
				data.rect.position += Vector2(change, 0)
				data.rect.size -= Vector2(change, 0)
			elif !point_in_polygon(point4, outline):
				data.rect.position += Vector2(0, 0)
				data.rect.size -= Vector2(0, change)
			else:
				# Use distance to contour instead of this
				var dp = closest_point_on_outline(point3) - point3
				dp.x = abs(dp.x)
				dp.y = abs(dp.y)
				if dp.x > dp.y:
					data.rect.position += Vector2(change, 0)
					data.rect.size -= Vector2(change, 0)
				else:
					data.rect.position += Vector2(0, 0)
					data.rect.size -= Vector2(0, change)
			grow_rects.push_back(data)
		elif !point_in_polygon(point4, outline):
			if !point_in_polygon(point2, outline) && !point_in_polygon(point3, outline):
				data.rect.position += Vector2(0, 0)
				data.rect.size -= Vector2(change, change)
			elif !point_in_polygon(point3, outline):
				data.rect.position += Vector2(0, 0)
				data.rect.size -= Vector2(change, 0)
			elif !point_in_polygon(point2, outline):
				data.rect.position += Vector2(0, 0)
				data.rect.size -= Vector2(0, change)
			else:
				# Use distance to contour instead of this
				var dp = closest_point_on_outline(point4) - point4
				dp.x = abs(dp.x)
				dp.y = abs(dp.y)
				if dp.x > dp.y:
					data.rect.position += Vector2(0, 0)
					data.rect.size -= Vector2(change, 0)
				else:
					data.rect.position += Vector2(0, 0)
					data.rect.size -= Vector2(0, change)
			grow_rects.push_back(data)
		else:
			rects.push_back(data.rect)
			update_rect(data.orig, data.rect)
func is_leaf(r):
	return tree[r].children.size() == 0
var astar: AStar
func build_door_astar():
	astar = AStar.new()
	var id = 0
	for pt1 in tree.keys():
		astar.add_point(id, Vector3(pt1.position.x + pt1.size.x / 2.0, 0.0, pt1.position.y + pt1.size.y / 2.0))
		id += 1

func path_needed(r1, r2):
	var sp1 = Vector3(r1.position.x + r1.size.x / 2.0, 0.0, r1.position.y + r1.size.y / 2.0)
	var sp2 = Vector3(r2.position.x + r2.size.x / 2.0, 0.0, r2.position.y + r2.size.y / 2.0)
	var id1 = astar.get_closest_point(sp1)
	var id2 = astar.get_closest_point(sp2)
	var path = astar.get_id_path(id1, id2)
	return path.size() == 0
func path_add(r1, r2):
	var sp1 = Vector3(r1.position.x + r1.size.x / 2.0, 0.0, r1.position.y + r1.size.y / 2.0)
	var sp2 = Vector3(r2.position.x + r2.size.x / 2.0, 0.0, r2.position.y + r2.size.y / 2.0)
	var id1 = astar.get_closest_point(sp1)
	var id2 = astar.get_closest_point(sp2)
	astar.connect_points(id1, id2)
func good_path(r1, r2):
	var min_x1 = r1.position.x
	var max_x1 = r1.position.x + r1.size.x
	var min_x2 = r2.position.x
	var max_x2 = r2.position.x + r2.size.x
	var min_y1 = r1.position.y
	var max_y1 = r1.position.y + r1.size.y
	var min_y2 = r2.position.y
	var max_y2 = r2.position.y + r2.size.y
	var min_x = max(min_x1, min_x2)
	var max_x = min(max_x1, max_x2)
	var min_y = max(min_y1, min_y2)
	var max_y = min(max_y1, max_y2)
	if min_x > max_x && min_y > max_y:
		return false
	if max_x - min_x < 3 && max_y - min_y < 3:
		return false
	return true
		
func get_path_count(r):
	var data = {}
	for d in door_data:
		if d.a == null || d.b == null:
			continue
		if d.a == d.b:
			continue
		if data.has(d.a):
			if !d.b in data[d.a]:
				data[d.a].push_back(d.b)
		else:
			data[d.a] = [d.b]
		if data.has(d.b):
			if !d.a in data[d.b]:
				data[d.b].push_back(d.a)
		else:
			data[d.b] = [d.a]
	if data.has(r):
		return data[r].size()
	else:
		return 0
	
func build_doors():
	for pt1 in tree.keys():
		for pt2 in tree.keys():
			if pt1 == pt2:
				continue
			if tree[pt1].parent == tree[pt2].parent:
				var p1 = pt1.position + pt1.size / 2.0
				var p2 = pt2.position + pt2.size / 2.0
				var pos = p1.linear_interpolate(p2, 0.5)
				if get_path_count(pt1) == 0 || get_path_count(pt2) == 0 || path_needed(pt1, pt2):
					if is_leaf(pt1) && is_leaf(pt2) && pt1 in rects && pt2 in rects && good_path(pt1, pt2):
						var d = {
							"a": pt1,
							"b": pt2,
							"pos": pos
						}
						door_positions.push_back(pos)
						door_data.push_back(d)
						path_add(pt1, pt2)
	for pt1 in tree.keys():
		for pt2 in tree.keys():
			if pt1 == pt2:
				continue
			if tree[pt1].parent != tree[pt2].parent:
				var p1 = pt1.position + pt1.size / 2.0
				var p2 = pt2.position + pt2.size / 2.0
				var pos = p1.linear_interpolate(p2, 0.5)
				if get_path_count(pt1) == 0 || get_path_count(pt2) == 0 || path_needed(pt1, pt2):
					if is_leaf(pt1) && is_leaf(pt2) && pt1 in rects && pt2 in rects && adjacent(pt1, pt2) && good_path(pt1, pt2):
						var d = {
							"a": pt1,
							"b": pt2,
							"pos": pos
						}
						door_positions.push_back(pos)
						door_data.push_back(d)
						path_add(pt1, pt2)

func update_rect(orig, new):
	var parent = tree[orig].parent
	var children = tree[orig].children
	if parent != null:
		tree[parent].children.erase(orig)
		tree[parent].children.push_back(new)
	tree[orig].rect = new
	tree[new] = {}
	tree[new].parent = parent
	tree[new].rect = new
	tree[new].children = children
	for k in children:
		tree[k].parent = new

func adjacent(r1, r2):
	var margin = 1.5
	var margin_x = min(r1.size.x / 2.0, margin)
	var margin_y = min(r1.size.y / 2.0, margin)
	# right
	var nrect1 = Rect2(r1.position + Vector2(0.0, margin_y), r1.size + Vector2(margin, -margin_y))
	# left
	var nrect2 = Rect2(r1.position - Vector2(margin_x, margin_y), r1.size + Vector2(margin, -margin_y))
	# up
	var nrect3 = Rect2(r1.position - Vector2(margin_x, margin), r1.size + Vector2(-margin_x, margin))
	# down
	var nrect4 = Rect2(r1.position - Vector2(margin_x, margin), r1.size + Vector2(-margin_x, margin))
	var ret = false
	for h in [nrect1, nrect2, nrect3, nrect4]:
		if h.encloses(r2) || h.intersects(r2) || r2.encloses(h) || r2.intersects(h):
			return true
	return ret
func _process(delta):
	match(state):
		0:
			print("init")
			border_rects.clear()
			rooms.clear()
			grow_rects.clear()
			doors.clear()
			corridoors.clear()
			door_positions.clear()
			door_data.clear()
			var first_rect = Rect2()
			for k in outline:
				first_rect = first_rect.expand(k)
			queue.push_back(first_rect)
			state = 1
		1:
			if queue.size() > 0:
				process_queue()
				print("queue size: ", queue.size())
			else:
				state = 2
		2:
			print("discard rects")
			discard_rects()
			state = 3
		3:
			init_grown_rects()
			state = 4
		4:
			if grow_rects.size() > 0:
				shrink_rects()
			else:
				state = 5
		5:
			var good = false
			for r in rects:
				if r.get_area() > max_area * 0.5:
					good = true
					break
			if !good:
				print("discarded max")
				split_probability *= 0.8
				max_area *= 1.02
				min_area *= 0.98
				state = 0
			good = false
			for r in rects:
				if r.get_area() < min_area * 1.5:
					good = true
					break
			if !good:
				print("discarded min")
				split_probability *= 1.5
				max_area *= 0.98
				min_area *= 1.02
				state = 0
			if good:
				print("building astar data")
				build_door_astar()
				print("building doors")
				build_doors()
				state = 6
		6:
			state = 7
		7:
			print("completed room set")
			emit_signal("complete")
			state = 8
