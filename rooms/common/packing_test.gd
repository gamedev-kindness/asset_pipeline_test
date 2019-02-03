extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _draw():
	for r in $pack_test.tree.keys():
		draw_rect(r, Color(1, 0, 0, 1), false)
	for r in $pack_test.result:
		var n = r.name
		var item
		for m in $pack_test.items:
			if m.name == n:
				item = m
				break
		var rect = Rect2(r.pos - item.rect.size / 2.0, item.rect.size)
		draw_rect(rect, Color(0, 1, 0, 1), false)
