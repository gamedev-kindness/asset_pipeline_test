extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

var spawns = [
	{
		"name": "item",
		"obj": load("res://inventory/pickable.tscn")
	},
	{
		"name": "male",
		"obj": load("res://characters/male_2018.tscn")
	},
	{
		"name": "female",
		"obj": load("res://characters/female_2018.tscn")
	}
]

func do_spawn(obj):
	if obj in content.characters.keys():
		var i = content.characters[obj].obj.instance()
		get_node("/root").add_child(i)
		var offset = Vector3(0, 0, -1)
		var offset_moved = awareness.player_character.global_transform.xform(offset)
		i.global_transform.origin = offset_moved
		i.global_transform.basis = awareness.player_character.global_transform.basis
	if obj in content.items.keys():
		var i = content.items[obj].obj.instance()
		get_node("/root").add_child(i)
		var offset = Vector3(0, 0, -1)
		var offset_moved = awareness.player_character.global_transform.xform(offset)
		i.global_transform.origin = offset_moved
		i.global_transform.basis = awareness.player_character.global_transform.basis

func process_command(c: String):
	print("command:", c)
	$VBoxContainer/RichTextLabel.text += c + "\n"
	$VBoxContainer/LineEdit.text = ""
	var cmdtmp = c.split(" ")
	var command = cmdtmp[0]
	var args = []
	for k in range(1, cmdtmp.size()):
		args.push_back(cmdtmp[k])
	if args.size() == 0:
		command = c
	var d = $VBoxContainer/RichTextLabel
	match(command):
		"spawn":
			do_spawn(args[0])
		"items":
			$VBoxContainer/RichTextLabel.append_bbcode("[b]Active items[/b]\n")
			if awareness.active_items.has(awareness.player_character):
				$VBoxContainer/RichTextLabel.text += ""
				for i in awareness.active_items[awareness.player_character]:
					$VBoxContainer/RichTextLabel.text += str(i) + " :  " + i.name + "\n"
				$VBoxContainer/RichTextLabel.text += "\n"
			$VBoxContainer/RichTextLabel.append_bbcode("[b]All items[/b]\n")
			$VBoxContainer/RichTextLabel.text += "\n"
			for i in awareness.objects:
				$VBoxContainer/RichTextLabel.text += str(i) + " :  " + i.name + "\n"
				$VBoxContainer/RichTextLabel.text += str(i.transform) + "\n"
				$VBoxContainer/RichTextLabel.text += "distance: " + str(awareness.distance(awareness.player_character, i)) + "\n"
			$VBoxContainer/RichTextLabel.text += "\n"
		"inv":
			d.append_bbcode("[b]Inventory[/b]\n")
			var items = awareness.inventory[awareness.player_character]
			for i in items:
				d.text += i + "\n"

func _ready():
	$VBoxContainer/LineEdit.connect("text_entered", self, "process_command")
	connect("visibility_changed", self, "visibility_changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
var cooldown = 0.0
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
		return
	if Input.is_action_just_released("console"):
		if visible:
			$VBoxContainer/LineEdit.text = ""
			hide()
			cooldown = 0.1
		else:
			show()
			$VBoxContainer/LineEdit.text = ""
			cooldown = 0.05
			
func visibility_changed():
	if visible:
		settings.game_input_enabled = false
		$VBoxContainer/LineEdit.grab_focus()
		settings.console_enabled = true
	else:
		settings.game_input_enabled = true
		settings.console_enabled = false