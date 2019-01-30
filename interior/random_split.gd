extends Node
signal complete

var outline = []
var rects = []
var queue = []
var min_size = 9.0
var min_area = 20.0
var max_area = 200.0

var tree = {}

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
	if data.get_area() > max_area || ((data.get_area() > min_area * 2.0) && randf() > 0.65):
		if randf() > 0.5:
			r1 = Rect2(data.position, Vector2(data.size.x, data.size.y / 2.0))
			r2 = Rect2(data.position + Vector2(0, data.size.y / 2.0), Vector2(data.size.x, data.size.y / 2.0))
		else:
			r1 = Rect2(data.position, Vector2(data.size.x / 2.0, data.size.y))
			r2 = Rect2(data.position + Vector2(data.size.x / 2.0, 0), Vector2(data.size.x / 2.0, data.size.y))
		var d1 = r1.size.x / r1.size.y
		if d1 > 1.0 / 3.0 && d1 < 3.0:
			queue.push_back(r1)
			queue.push_back(r2)
			tree[data].children = [r1, r2]
			tree[r1] = {"rect": r1, "children": [], "parent": data}
			tree[r2] = {"rect": r2, "children": [], "parent": data}
		else:
			queue.push_back(data)
	else:
		rects.push_back(data)

var border_rects = []

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

var grow_rects = []
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
		if data.rect.get_area() < min_area * 0.4:
			return
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
var doors = []
#var corridoor_queue = []
#func build_corridoor(p1, p2):
#	var mp1 = Vector2(p1.x, p2.y)
#	var mp2 = Vector2(p2.x, p1.y)
#	if point_in_polygon(mp1, outline):
#		corridoor_queue.push_back([p1, mp1, p2])
#	if point_in_polygon(mp2, outline):
#		corridoor_queue.push_back([p1, mp2, p2])

#func build_corridoors():
#	for k in doors:
#		var dst = -1.0
#		var entry
#		for r in rects:
#			var ndst = k.transform.origin.distance_to(r.position + r.size / 2.0)
#			if dst < 0 || ndst < dst:
#				dst = ndst
#				entry = r
#		dst = -1
#		var corridoor
#		for mr in rects:
#			if mr == entry:
#				continue
#			var ndst = (mr.position + mr.size / 2.0).distance_to(entry.position + entry.size / 2.0)
#			if ndst > dst:
#				dst = ndst
#				corridoor =  [mr.position + mr.size / 2.0, entry.position + entry.size / 2.0]
#			build_corridoor(corridoor[0], corridoor[1])

var corridoors = []
#func process_corridoors():
#	while corridoor_queue.size() > 0:
#		var data = corridoor_queue[0]
#		corridoor_queue.pop_front()
#		var discard = false
#		for seg in range(outline.size()):
#			var s1 = outline[seg]
#			var s2 = outline[(seg + 1) % outline.size()]
#			if Geometry.segment_intersects_segment_2d(data[0], data[1], s1, s2):
#				discard = true
#				break
#			elif Geometry.segment_intersects_segment_2d(data[1], data[2], s1, s2):
#				discard = true
#				break
#		if !discard:
#			corridoors.push_back(data)

var door_positions = []
var door_data = []
func build_doors():
	for pt in tree.keys():
		if tree[pt].parent == null:
			continue
		var parent = tree[tree[pt].parent]
		for h in parent.children:
			if h == pt:
				continue
			var p1 = pt.position + pt.size / 2.0
			var p3 = tree[h].rect.position + tree[h].rect.size / 2.0
			if !point_in_polygon(p1, outline):
				continue
			if !point_in_polygon(p3, outline):
				continue
			var p2 = Vector2(p1.x, p3.y)
			if pt in rects && h in rects:
				door_positions.push_back(p3.linear_interpolate(p1, 0.5))
				var d = {
					"a": pt,
					"b": h,
					"pos": p3.linear_interpolate(p1, 0.5)
				}
				door_data.push_back(d)
			else:
				corridoors.push_back([p1, p2, p3])

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

var rooms = []
func _process(delta):
	if state == 0:
		state = 4
		var first_rect = Rect2()
		for k in outline:
			first_rect = first_rect.expand(k)
		queue.push_back(first_rect)
		while queue.size() > 0:
			process_queue()
		discard_rects()
		init_grown_rects()
		while grow_rects.size() > 0:
			shrink_rects()
		build_doors()
#		build_corridoors()
#		process_corridoors()
		var astar = AStar.new()
		var id = 0
		for r1 in rects:
				var p1 = r1.position + r1.size / 2.0
				astar.add_point(id, Vector3(p1.x, 0.0, p1.y))
				id = id + 1
		for h in range(id):
			for i in range(id):
				if h == i:
					continue
				astar.connect_points(h, i, true)
	if state == 4:
		for t in rooms:
			if t.doors.size() > 0:
				print(t)
		emit_signal("complete")
		state = 5
