extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var spawned = false
var cooldown = 3.0
var scene
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cur
	if spawned:
		return
	if !scene:
		return
	if cooldown > 0.1:
		cooldown -= delta
		return
	for c in get_tree().get_nodes_in_group("characters"):
		if c.posessed:
			cur = c
	if cur == null:
		cooldown = 3.0
		return
	if cur.global_transform.origin.distance_to(global_transform.origin) < 5.0:
		var root = get_node("/root")
		var c = scene.instance()
		root.add_child(c)
		c.global_transform = global_transform
		spawned = true
		queue_free()
	cooldown = 3.0
