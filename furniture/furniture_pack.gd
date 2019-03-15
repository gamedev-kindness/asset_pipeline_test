extends Node
class_name FurniturePack
onready var rnd = RandomNumberGenerator.new()
const grid_size = 0.5

func _ready():
	rnd.seed = OS.get_unix_time()

static func split_x(r: Rect2, amount: float) -> Array:
	var r1 = Rect2(r.position, Vector2(amount, r.size.y))
	var r2 = Rect2(r.position + Vector2(amount, 0), Vector2(r.size.x - amount, r.size.y))
	return [r1, r2]

static func split_y(r: Rect2, amount: float) -> Array:
	var r1 = Rect2(r.position, Vector2(r.size.x, amount))
	var r2 = Rect2(r.position + Vector2(0, amount), Vector2(r.size.x, r.size.y - amount))
	return [r1, r2]

func select_one(options: Array) -> String:
	return options[rnd.randi() % options.size()]

func grid_key(p: Vector2) -> int:
	var px = int(p.x / grid_size)
	var py = int(p.y / grid_size)
	return py * 1000 + px

func fill_grid(grid: Dictionary, r: Rect2) -> void:
	var x = r.position.x
	var y = r.position.y
	while x < r.position.x + r.size.x:
		while y < r.position.y + r.size.y:
			grid[grid_key(Vector2(x, y))] = 1
			x += grid_size / 2.0
			y += grid_size / 2.0

func can_place(grid: Dictionary, r: Rect2) -> bool:
	var x = r.position.x
	var y = r.position.y
	while x < r.position.x + r.size.x:
		while y < r.position.y + r.size.y:
			if grid.has(grid_key(Vector2(x, y))):
				return false
			x += grid_size / 2.0
			y += grid_size / 2.0
	return true
const margin = 0.5
const margin_width = 2.0
func pack(d:Dictionary) -> Dictionary:
	var wall_furniture =  d.room.furniture.wall
	var main_furniture =  d.room.furniture.main
	var center_furniture =  d.room.furniture.center
	var wall = d.room.wall
	var wall_points = []
	var grid = {}
	var out_rect : = Rect2()
	for seg in range(wall.size()):
		var p1 = wall[seg]
		var p2 = wall[(seg + 1) % wall.size()]
		out_rect = out_rect.expand(p1)
		var size = p1.distance_to(p2)
		var p = p1
		var dir = (p2 - p1).normalized()
		var n = dir.tangent().normalized()
		while size > 0:
			if p == p1:
				if size > margin_width:
					p += dir * margin
					size -= margin * 2.0
#			if p.distance_to(p1) > margin_width && p.distance_to(p2) < margin:
#				break
			var selected = select_one(wall_furniture)
			var item = d.furniture[selected]
			var width = item.rect.size.x
			var depth = item.rect.size.y
			var step = dir * width
			var actual_pos = p + step * 0.5 - n * depth * 0.5 - dir * item.rect.position.x - n * item.rect.position.y
			var angle = dir.angle()
			size -= width
			if size > 0:
				var check_rect = Rect2(actual_pos - item.rect.size * 0.5, item.rect.size)
				if can_place(grid, check_rect):
					fill_grid(grid, check_rect)
					wall_points.push_back({"item": selected, "position": actual_pos, "angle": angle})
			p += step
	if main_furniture.size() > 0:
		if out_rect.size.x > 2 && out_rect.size.y >= 2:
			out_rect.grow(-1.0)
		for t in range(10 + rnd.randi() % 100):
			var selected = select_one(main_furniture)
			var item = d.furniture[selected]
			var width = item.rect.size.x
			var depth = item.rect.size.y
			var pos = out_rect.position + Vector2(rnd.randf() * out_rect.size.x, rnd.randf() * out_rect.size.y) - item.rect.position
			var check_rect = Rect2(pos - item.rect.size * 0.5, item.rect.size)
			var angles = [0, PI / 2.0, PI, -PI / 2.0]
			var angle_no = rnd.randi() % angles.size()
			var angle = angles[angle_no]
			if can_place(grid, check_rect):
				fill_grid(grid, check_rect)
				wall_points.push_back({"item": selected, "position": pos, "angle": angle})
	print("s")
	return {"points": wall_points}
