extends Spatial

onready var room = {
	"furniture": {
		"wall": ["toilet", "shower"],
		"main": ["bed"],
		"center": []
	},
	"wall": [Vector2(-6, -6), Vector2(0.0, -8), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6)]
}
onready var furniture = {
	"toilet": {
		"node": load("res://rooms/room_kit/toilet.tscn"),
		"rect": Rect2(-0.5, -0.5, 1, 0.0)
	},
	"shower": {
		"node": load("res://rooms/room_kit/shower.tscn"),
		"rect": Rect2(-0.6, 0, 1.1, 0.0)
	},
	"bed": {
		"node": load("res://furniture/bed.tscn"),
		"rect": Rect2(-1, -1, 2, 2)
	}
}
onready var data = {
	"furniture": furniture,
	"room": room
}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var points = $furniture_pack.pack(data)
	for k in points.points:
		print(k)
		var node = data.furniture[k.item].node
		var nodei = node.instance()
		add_child(nodei)
		nodei.translation = Vector3(k.position.x, 0.0, k.position.y)
		nodei.rotation.y = -k.angle

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
