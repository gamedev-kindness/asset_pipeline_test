extends Node
class_name DialogueScheduler

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var character_list = []
var speech_text = {}
var dialogue_delay = 3.0
var cooldown = 0.0
var token = 0
func _ready():
	print("Dialogue started")

# Called every frame. 'delta' is the elapsed time since the previous frame.
var state = "greeting"
var dialogue_state = "thesis"

var texts = {
	"greeting": {
		"thesis": [
			["Hi!", ["neutral"], ["greeting"]],
			["Hello!", ["neutral"], ["greeting"]],
			["Hello bitches!", ["evil"], ["greeting", "insult"]]
		],
		"answer": [
			["Hi!", ["neutral"], ["greeting"]],
			["Hello!", ["neutral"], ["greeting"]],
			["Greetings!", ["neutral"], ["greeting"]]
		]
	}
}

func generate_text(obj, state, dstate):
	var list = texts[state][dstate]
	var r = randi() % list.size()
	return list[r][0]

func say(obj, text):
	speech_text[obj].text = text
	if !speech_text[obj].visible:
		speech_text[obj].show()
	speech_text[obj].update()
	print("say: ", text)
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	else:
		if character_list.size() > 0:
			match(dialogue_state):
				"thesis":
					var obj = character_list[token]
					say(obj, generate_text(obj, state, dialogue_state))
					dialogue_state = "answer"
					cooldown = dialogue_delay
				"answer":
					for k in range(character_list.size()):
						if k == token:
							continue
						var obj = character_list[k]
						say(obj, generate_text(obj, state, dialogue_state))
						dialogue_state = "thesis"
					cooldown = dialogue_delay
					token = randi() % character_list.size()
	for h in character_list:
		var box_position = h.get_head_position()
		var pos = get_viewport().get_camera().unproject_position(box_position)
		speech_text[h].rect_position = pos - Vector2(0, 32)
		speech_text[h].rect_size = Vector2(120, 64)

func add_character(obj):
	if !obj in character_list:
		character_list.push_back(obj)
		var speech = load("res://ui/speech.tscn").instance()
		get_node("/root").add_child(speech)
		speech.hide()
		speech_text[obj] = speech
