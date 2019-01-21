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
	if Input.is_action_pressed("inventory") && !settings.console_enabled:
		if !visible && settings.game_input_enabled:
			$VBoxContainer/ViewportContainer/Viewport/inventory_scene.rebuild()
			show()
			settings.game_input_enabled = false
			settings.inventory_enabled = true
		else:
			hide()
			$VBoxContainer/ViewportContainer/Viewport/inventory_scene.cleanup()
			settings.game_input_enabled = true
			settings.inventory_enabled = false
		cooldown += 0.2
