extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
var cooldown = 0.0
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
		return
	if Input.is_action_pressed("inventory"):
		if !visible:
			show()
			settings.game_input_enabled = false
		else:
			hide()
			settings.game_input_enabled = true
		cooldown += 0.2
