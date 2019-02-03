extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var result = []
var tree = {}
var items = [
	{
		"name": "bed",
		"rect": Rect2(-1, -1, 2, 2)
	},
	{
		"name": "toilet",
		"rect": Rect2(-0.25, -0.25, 0.5, 0.5)
	},
	{
		"name": "shower",
		"rect": Rect2(-0.25, -0.25, 1, 1)
	}
]
func _ready():
	var outline = Rect2(0, 0, 10, 10)
	var r = $packer.pack_items(items, outline)
	result = r.result
	tree = r.tree
	
