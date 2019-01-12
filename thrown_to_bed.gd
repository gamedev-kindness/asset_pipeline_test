extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$female_2018/AnimationPlayer.play("female_animation")
	$male_g_2018/AnimationPlayer.play("male_animation")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
