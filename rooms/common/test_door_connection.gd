extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var p1 = Vector2(-10, -10)
var p2 = Vector2(10, 10)
func _ready():
	var m1 = load("res://rooms/room_kit/test_wall1_material.tres")
	var m2 = load("res://rooms/room_kit/test_floor_material.tres")
	var m3 = load("res://rooms/room_kit/test_floor_material.tres")
	var mesh = create_room_connection(p1, p2, 1.0, 2.0, null, null, null)
	var mi = MeshInstance.new()
	mi.mesh = mesh
	add_child(mi)
func create_room_connection(p1: Vector2, p2: Vector2, width: float, height: float, walls_mat: Material, floor_mat: Material, ceiling_mat:Material):
	var depth = (p2 - p1).length()
	var mesh = ArrayMesh.new()
	var walls_surf = SurfaceTool.new()
	var floor_surf = SurfaceTool.new()
	var ceiling_surf = SurfaceTool.new()
	var mdt_walls = MeshDataTool.new()
	var mdt_floor = MeshDataTool.new()
	var mdt_ceiling = MeshDataTool.new()
	var p = p1
	var zs = []
	var dir = (p2 - p1).normalized()
	var side = dir.tangent()
	while (p2 - p).length() > 0.1:
		zs.push_back(p)
		p += dir * 0.1
	zs.push_back(p2)
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
	floor_surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for t in range(zs.size() - 1):
		var lp = zs[t] - 0.5 * side
		var rp = zs[t] + 0.5 * side
		var nlp = zs[t + 1] - 0.5 * side
		var nrp = zs[t + 1] + 0.5 * side
		var tp0 = Vector3(lp.x, 0.0, lp.y)
		var tp1 = Vector3(rp.x, 0.0, rp.y)
		var tp2 = Vector3(nrp.x, 0.0, nrp.y)
		var tp3 = Vector3(nlp.x, 0.0, nlp.y)
		var n = Vector3(0, 1, 0)
		var tri1 = [tp0, tp1, tp2]
		var tri2 = [tp0, tp2, tp3]
		for p in tri1 + tri2:
			floor_surf.add_normal(n)
			floor_surf.add_uv(Vector2(p.x / 3.0, p.z / 3.0))
			floor_surf.add_vertex(p)
	ceiling_surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for t in range(zs.size() - 1):
		var lp = zs[t] - 0.5 * side
		var rp = zs[t] + 0.5 * side
		var nlp = zs[t + 1] - 0.5 * side
		var nrp = zs[t + 1] + 0.5 * side
		var tp0 = Vector3(lp.x, 0.0, lp.y)
		var tp1 = Vector3(rp.x, 0.0, rp.y)
		var tp2 = Vector3(nrp.x, 0.0, nrp.y)
		var tp3 = Vector3(nlp.x, 0.0, nlp.y)
		var n = Vector3(0, -1, 0)
		var tri1 = [tp0, tp2, tp1]
		var tri2 = [tp0, tp3, tp2]
		for p in tri1 + tri2:
			ceiling_surf.add_normal(n)
			ceiling_surf.add_uv(Vector2(p.x / 3.0, p.z / 3.0))
			ceiling_surf.add_vertex(p)
	for r in [walls_surf, floor_surf, ceiling_surf]:
		r.generate_normals()
		r.index()
	mdt_walls.create_from_surface(walls_surf.commit(), 0)
	mdt_walls.set_material(walls_mat)
	mdt_walls.commit_to_surface(mesh)
	mdt_floor.create_from_surface(floor_surf.commit(), 0)
	mdt_floor.set_material(floor_mat)
	mdt_floor.commit_to_surface(mesh)
	mdt_ceiling.create_from_surface(ceiling_surf.commit(), 0)
	mdt_ceiling.set_material(ceiling_mat)
	mdt_ceiling.commit_to_surface(mesh)
	return mesh

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
