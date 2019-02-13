extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func create_horiz_surface(surf: SurfaceTool, r: Rect2, height: float, step: float, invert: bool):
		var xes = []
		var yes = []
		var x0 = r.position.x
		var y0 = r.position.y
		var n = Vector3(0, 1, 0)
		while r.position.x + r.size.x - x0 > step:
			xes.push_back(x0)
			x0 += step
		while r.position.y + r.size.y - y0 > step:
			yes.push_back(y0)
			y0 += step
		if xes.size() == 0:
			xes.push_back(r.position.x)
		if yes.size() == 0:
			yes.push_back(r.position.y)
		xes.push_back(r.position.x + r.size.x)
		yes.push_back(r.position.y + r.size.y)
		for s in range(xes.size() - 1):
			for t in range(yes.size() - 1):
				var tp0 = Vector3(xes[s], height, yes[t])
				var tp1 = Vector3(xes[s], height, yes[t + 1])
				var tp2 = Vector3(xes[s + 1], height, yes[t + 1])
				var tp3 = Vector3(xes[s + 1], height, yes[t])
				var tri1 = [tp0, tp2, tp1]
				var tri2 = [tp0, tp3, tp2]
				if invert:
					tri1.invert()
					tri2.invert()
				for sp in tri1 + tri2:
					surf.add_normal(n)
					surf.add_uv(Vector2(sp.x / 3.0, sp.z / 3.0))
					surf.add_vertex(sp)
func create_wall_segment(surf: SurfaceTool, sp1: Vector2, sp2: Vector2, step: float, heights: Array):
	var xes = []
	var p = sp1
	var dir = (sp2 - sp1).normalized()
	var side = dir.tangent()
	while p.distance_to(sp2) > step:
		xes.push_back(p)
		p += dir * step
		assert xes.size() < 5000
	if xes.size() == 0:
		xes.push_back(sp1)
	xes.push_back(sp2)
	for t in range(xes.size() - 1):
		for h in range(0, heights.size(), 2):
			var tp0 = Vector3(xes[t].x, heights[h], xes[t].y)
			var tp1 = Vector3(xes[t].x, heights[h + 1], xes[t].y)
			var tp2 = Vector3(xes[t + 1].x, heights[h + 1], xes[t + 1].y)
			var tp3 = Vector3(xes[t + 1].x, heights[h], xes[t + 1].y)
			var n = Vector3(side.x, 0.0, side.y)
			var tri1 = [tp0, tp1, tp2]
			var tri2 = [tp0, tp2, tp3]
			for sp in tri1 + tri2:
				surf.add_normal(n)
				surf.add_uv(Vector2(sp.x / 3.0, sp.y / 3.0))
				surf.add_vertex(sp)


func create_walls(rects: Array, rooms: Dictionary, height: float, walls_mat: Material, step: float) -> Array:
	var state = 0
	var old_state = 0
	var meshes = []
	for xr in rects:
		var walls_surf = SurfaceTool.new()
		var mdt_walls = MeshDataTool.new()
		var mesh = ArrayMesh.new()
		walls_surf.begin(Mesh.PRIMITIVE_TRIANGLES)
		var r = Rect2(xr.position + Vector2(0.1, 0.1), xr.size - Vector2(0.2, 0.2))
		var p0 = r.position
		var p1 = r.position + Vector2(r.size.x, 0)
		var p2 = r.position + r.size
		var p3 = r.position + Vector2(0, r.size.y)
		var poly = [p0, p1, p2, p3]
		for seg in range(poly.size()):
			var sp1 = poly[seg]
			var sp2 = poly[(seg + 1) % poly.size()]
			
			var dir = (sp2 - sp1).normalized()
			var side = dir.tangent()
			var p = sp1
			var room = rooms[xr]
			var path = [sp1]
			var path_region = []
			var exits = []
			path_region.push_back(0)
			if sp1.x == sp2.x:
				for k in room.exits:
					if abs(k.position.x - sp1.x) < 0.11 && k.position.y > min(sp1.y, sp2.y) && k.position.y < max(sp1.y, sp2.y):
						var tpos = Vector2(sp1.x, k.position.y)
#						exits.push_back(tpos - dir * 0.5)
						exits.push_back(tpos)
#						exits.push_back(tpos + dir * 0.5)
#						print("\t||| added: ", k.position, " -> ", tpos, " sp1: ", sp1)
			elif sp1.y == sp2.y:
				for k in room.exits:
					if abs(k.position.y - sp1.y) < 0.11 && k.position.x > min(sp1.x, sp2.x) && k.position.x < max(sp1.x, sp2.x):
						var tpos = Vector2(k.position.x, sp1.y)
#						exits.push_back(tpos - dir * 0.5)
						exits.push_back(tpos)
#						exits.push_back(tpos + dir * 0.5)
#						print("\t--- added: ", k.position, " -> ", tpos, " sp1: ", sp1)
#			print("exits size: ", exits.size())
			for k in range(exits.size()):
				for l in range(exits.size()):
					if k == l:
						continue
					if sp1.distance_to(exits[k]) < sp1.distance_to(exits[l]):
						var tmp = exits[l]
						exits[l] = exits[k]
						exits[k] = tmp
			var exits_unique = []
			for h in range(exits.size()):
				var ok = true
				for g in range(exits_unique.size()):
					if exits[h].distance_to(exits_unique[g]) < 0.1:
						ok = false
						break
				if ok:
					exits_unique.push_back(exits[h])
			for m in exits_unique:
				var can_add = true
				var dl = 0.5
				var de = 0.4
				var dst = 0.0
				for r in range(path.size()):
					dst = m.distance_to(path[r])
					if dst < dl + 0.1:
						can_add = false
						break
				if can_add:
					path.push_back(m - dir * dl)
					path_region.push_back(0)
					path.push_back(m - dir * de)
					path_region.push_back(1)
					path.push_back(m + dir * de)
					path_region.push_back(0)
					path.push_back(m + dir * dl)
					path_region.push_back(0)
					var door_rect = Rect2(m - dir * de, Vector2())
					door_rect = door_rect.expand(m - dir *de)
					print("1:", door_rect)
					door_rect = door_rect.expand(m + dir *de)
					print("2:", door_rect)
					door_rect = door_rect.expand(m - dir *de + side * 0.1)
					print("3:", door_rect)
					door_rect = door_rect.expand(m - dir *de + side * 0.1)
					print("4:", door_rect)
					create_horiz_surface(walls_surf, door_rect, 2.0, 0.2, true)
					create_horiz_surface(walls_surf, door_rect, 0.0, 0.2, false)
					create_wall_segment(walls_surf, m - dir * de, m - dir * de + side * 0.1, step, [0.0, 1.0, 1.0, 2.0])
					create_wall_segment(walls_surf, m + dir * de + side * 0.1, m + dir * de, step, [0.0, 1.0, 1.0, 2.0])
				else:
					print("can't add door, dst: ", dst)
			path.push_back(sp2)
			path_region.push_back(0)
			var re = []
			assert path.size() < 24
			assert path.size() == path_region.size()
			
			for tn in range(path.size() - 1):
				var heights = []
				if path_region[tn] == 0:
					heights = [0.0, 1.0, 1.0, 2.0, 2.0, height]
					create_wall_segment(walls_surf, path[tn], path[tn + 1], step, heights)
				elif path_region[tn] == 1:
					heights = [2.0, height]
					create_wall_segment(walls_surf, path[tn], path[tn + 1], step, heights)

		walls_surf.generate_normals()
		walls_surf.index()
		mdt_walls.create_from_surface(walls_surf.commit(), 0)
		mdt_walls.set_material(walls_mat)
		mdt_walls.commit_to_surface(mesh)
		meshes.push_back(mesh)
	return meshes

func create_floor(rects: Array, floor_mat: Material) -> ArrayMesh:
	var floor_surf = SurfaceTool.new()
	var mdt_floor = MeshDataTool.new()
	var mesh = ArrayMesh.new()
	floor_surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for xr in rects:
		var xes = []
		var yes = []
		var r = Rect2(xr.position + Vector2(0.1, 0.1), xr.size - Vector2(0.2, 0.2))
		var x0 = r.position.x
		var y0 = r.position.y
		var n = Vector3(0, 1, 0)
		while r.position.x + r.size.x - x0 > 0.1:
			xes.push_back(x0)
			x0 += 0.2
		while r.position.y + r.size.y - y0 > 0.1:
			yes.push_back(y0)
			y0 += 0.2
		xes.push_back(r.position.x + r.size.x)
		yes.push_back(r.position.y + r.size.y)
		for s in range(xes.size() - 1):
			for t in range(yes.size() - 1):
				var tp0 = Vector3(xes[s], 0.0, yes[t])
				var tp1 = Vector3(xes[s], 0.0, yes[t + 1])
				var tp2 = Vector3(xes[s + 1], 0.0, yes[t + 1])
				var tp3 = Vector3(xes[s + 1], 0.0, yes[t])
				var tri1 = [tp0, tp2, tp1]
				var tri2 = [tp0, tp3, tp2]
				for sp in tri1 + tri2:
					floor_surf.add_normal(n)
					floor_surf.add_uv(Vector2(sp.x / 3.0, sp.z / 3.0))
					floor_surf.add_vertex(sp)
		
	floor_surf.generate_normals()
	floor_surf.index()
	mdt_floor.create_from_surface(floor_surf.commit(), 0)
	mdt_floor.set_material(floor_mat)
	mdt_floor.commit_to_surface(mesh)
	return mesh


func get_walls_mesh(p1: Vector2, p2: Vector2, width: float, height: float) -> ArrayMesh:
	var dir = (p2 - p1).normalized()
	var side = dir.tangent()
	var p = p1
	var zs = []
	while (p2 - p).length() > 0.1:
		zs.push_back(p)
		p += dir * 0.1
	if zs.size() == 0:
		zs.push_back(p1)
	zs.push_back(p2)
	var walls_surf = SurfaceTool.new()
	walls_surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for t in range(zs.size() - 1):
		for m in [-0.5, 0.5]:
			var lp = zs[t] + m * side
			var lpn =  zs[t + 1] + m * side
			var tp0 = Vector3(lp.x, 0.0, lp.y)
			var tp1 = Vector3(lp.x, 2.0, lp.y)
			var tp2 = Vector3(lpn.x, 2.0, lpn.y)
			var tp3 = Vector3(lpn.x, 0.0, lpn.y)
			var n = (tp0 - tp1).cross(tp2 - tp1)
			var tri1 = []
			var tri2 = []
			if m > 0.0:
				tri1 = [tp0, tp1, tp2]
				tri2 = [tp0, tp2, tp3]
			else:
				tri1 = [tp0, tp2, tp1]
				tri2 = [tp0, tp3, tp2]
			for sp in tri1 + tri2:
				walls_surf.add_normal(n)
				walls_surf.add_uv(Vector2(sp.z / 3.0, sp.y / 3.0))
				walls_surf.add_vertex(sp)
	walls_surf.generate_normals()
	walls_surf.index()
	var mesh = walls_surf.commit()
	print("surfaces:", mesh.get_surface_count())
	return mesh
#func create_room_connection(p1: Vector2, p2: Vector2, width: float, height: float, walls_mat: Material, floor_mat: Material, ceiling_mat:Material):
#	var depth = (p2 - p1).length()
#	var mesh = ArrayMesh.new()
#	var floor_surf = SurfaceTool.new()
#	var ceiling_surf = SurfaceTool.new()
#	var mdt_walls = MeshDataTool.new()
#	var mdt_floor = MeshDataTool.new()
#	var mdt_ceiling = MeshDataTool.new()
#	var p = p1
#	var zs = []
#	var dir = (p2 - p1).normalized()
#	var side = dir.tangent()
#	while (p2 - p).length() > 0.1:
#		zs.push_back(p)
#		p += dir * 0.1
#	if zs.size() == 0:
#		zs.push_back(p1)
#	zs.push_back(p2)
#	floor_surf.begin(Mesh.PRIMITIVE_TRIANGLES)
#	for t in range(zs.size() - 1):
#		var lp = zs[t] - 0.5 * side
#		var rp = zs[t] + 0.5 * side
#		var nlp = zs[t + 1] - 0.5 * side
#		var nrp = zs[t + 1] + 0.5 * side
#		var tp0 = Vector3(lp.x, 0.0, lp.y)
#		var tp1 = Vector3(rp.x, 0.0, rp.y)
#		var tp2 = Vector3(nrp.x, 0.0, nrp.y)
#		var tp3 = Vector3(nlp.x, 0.0, nlp.y)
#		var n = Vector3(0, 1, 0)
#		var tri1 = [tp0, tp1, tp2]
#		var tri2 = [tp0, tp2, tp3]
#		for p in tri1 + tri2:
#			floor_surf.add_normal(n)
#			floor_surf.add_uv(Vector2(p.x / 3.0, p.z / 3.0))
#			floor_surf.add_vertex(p)
#	ceiling_surf.begin(Mesh.PRIMITIVE_TRIANGLES)
#	for t in range(zs.size() - 1):
#		var lp = zs[t] - 0.5 * side
#		var rp = zs[t] + 0.5 * side
#		var nlp = zs[t + 1] - 0.5 * side
#		var nrp = zs[t + 1] + 0.5 * side
#		var tp0 = Vector3(lp.x, 0.0, lp.y)
#		var tp1 = Vector3(rp.x, 0.0, rp.y)
#		var tp2 = Vector3(nrp.x, 0.0, nrp.y)
#		var tp3 = Vector3(nlp.x, 0.0, nlp.y)
#		var n = Vector3(0, -1, 0)
#		var tri1 = [tp0, tp2, tp1]
#		var tri2 = [tp0, tp3, tp2]
#		for p in tri1 + tri2:
#			ceiling_surf.add_normal(n)
#			ceiling_surf.add_uv(Vector2(p.x / 3.0, p.z / 3.0))
#			ceiling_surf.add_vertex(p)
#	for r in [floor_surf, ceiling_surf]:
#		r.generate_normals()
#		r.index()
#	var tmp = get_walls_mesh(p1, p2, width, height)
#	mdt_walls.create_from_surface(tmp, 0)
#	mdt_walls.set_material(walls_mat)
#	mdt_walls.commit_to_surface(mesh)
#	mdt_floor.create_from_surface(floor_surf.commit(), 0)
#	mdt_floor.set_material(floor_mat)
#	mdt_floor.commit_to_surface(mesh)
#	mdt_ceiling.create_from_surface(ceiling_surf.commit(), 0)
#	mdt_ceiling.set_material(ceiling_mat)
#	mdt_ceiling.commit_to_surface(mesh)
#	return mesh
