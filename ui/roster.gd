extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var entries = []
func _ready():
	hide()
	$VBoxContainer/back.connect("pressed", self, "go_back")
	connect("visibility_changed", self, "visibility_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func go_back():
	hide()

func visibility_changed():
	if visible:
		for k in entries:
			$VBoxContainer.remove_child(k)
			k.queue_free()
		if !awareness.character_data.has(awareness.player_character):
			return
		for k in awareness.get_roster(awareness.player_character).keys():
			var chname = awareness.character_data[k].character_name
			var entry = HBoxContainer.new()
			var label = Label.new()
			label.text = chname
			var font : = DynamicFont.new()
			var font_data : = DynamicFontData.new()
			font_data.font_path = "res://fonts/DroidSansFallback.ttf"
			font.font_data = font_data
			font.size = 20
			label.add_font_override("font", font)
			entry.add_child(label)
			$VBoxContainer.add_child(entry)
			entries.push_back(entry)
