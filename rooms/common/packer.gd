extends Node

#var items = [Rect2(-1, -1, 3, 3)]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

func can_split(item: Rect2, rect: Rect2) -> bool:
	if rect.size.x <= item.size.x:
		return false
	if rect.size.y <= item.size.y:
		return false
	return true
func split_rect(item: Rect2, rect: Rect2) -> Dictionary:
	if can_split(item, rect):
		# right part
		var r1 = Rect2(rect.position.x + item.size.x, rect.position.y, rect.size.x - item.size.x, item.size.y)
		var r2 = Rect2(rect.position.x, rect.position.y + item.size.y, rect.size.x, rect.size.y - item.size.y)
		return {
			"result": [r1, r2],
			"pos": rect.position + item.size / 2.0
		}
	return {}
func add_item(tree: Dictionary, item: Rect2, outline: Rect2):
	var smallest_rect = outline
	for t in tree.keys():
		if can_split(item, t):
			if smallest_rect.get_area() > t.get_area():
				smallest_rect = t
	var r = split_rect(item, smallest_rect)
	tree.erase(smallest_rect)
	for h in r.result:
		tree[h] = {
			"rect": h
		}
	return r.pos
func pack_items(items: Array, rect: Rect2):
	var tree = {}
	tree[rect] = {
		"rect": rect
	}
	var result = []
	for pt in items:
		result.push_back({"pos": add_item(tree, pt.rect, rect), "name": pt.name})
	return {"result": result, "tree": tree}
	
func _ready():
	pass
