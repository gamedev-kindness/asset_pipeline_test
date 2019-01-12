extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$female1001/AnimationPlayer.play("default")
	$player001/AnimationPlayer.play("grab_from_back")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
