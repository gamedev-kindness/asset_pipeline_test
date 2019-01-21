extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

func process_command(c):
	print("command:", c)
	$VBoxContainer/RichTextLabel.text += c
	$VBoxContainer/LineEdit.text = ""


func _ready():
	$VBoxContainer/LineEdit.connect("text_entered", self, "process_command")
	connect("visibility_changed", self, "visibility_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
var cooldown = 0.0
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
		return
	if Input.is_action_pressed("console"):
		if visible:
			$VBoxContainer/LineEdit.text = ""
			hide()
		else:
			show()
		cooldown += 0.1
func visibility_changed():
	if visible:
		settings.game_input_enabled = false
		cooldown = 0.15
	else:
		settings.game_input_enabled = true
		cooldown = 0.15
