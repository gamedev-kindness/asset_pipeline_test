extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
var spawned = false

func _process(delta):
	if !spawned:
		var pickable = load("res://inventory/pickable.tscn")
		var num = 1 + randi() % 5
		var root = get_node("/root")
		for r in range(num):
			var i = pickable.instance()
			root.add_child(i)
			i.global_transform.origin = global_transform.origin + Vector3(randf() * 20.0, 1.8, randf() * 20.0)
			print("spawning to: ", global_transform.origin + Vector3(randf() * 20.0, 1.8, randf() * 20.0))
		spawned = true
		set_process(false)