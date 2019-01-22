extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var character
func go_back():
	hide()
func visibility_changed():
	pass
#	if awareness.player_character == null:
#		return
#	if visible:
#		hide()
#	else:
#		show()
func _ready():
	hide()
	connect("visibility_changed", self, "visibility_changed")
	$vb/back_button.connect("pressed", self, "go_back")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		for c in $vb.get_children():
			if c.name == "back_button":
				continue
			c.queue_free()
		for s in awareness.stats[awareness.player_character].keys():
			var data = load("res://ui/stat_data.tscn").instance()
			data.set_stat_name(s)
			data.set_stat_value(awareness.stats[awareness.player_character][s])
			$vb.add_child(data)
		$vb.update()
