extends ReferenceRect
signal pressed
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func do_pressed():
	print(name + " pressed")
	emit_signal("pressed")

func _ready():
	$ColorRect/Polygon2D/TextureButton.connect("pressed", self, "do_pressed")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
