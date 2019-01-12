extends AnimationPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	for v in get_animation_list():
		if v.ends_with("loop"):
			var anim = get_animation(v)
			anim.loop = true
