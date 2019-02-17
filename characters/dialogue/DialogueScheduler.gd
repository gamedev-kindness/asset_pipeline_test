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
			["#greetings#", [], ["greeting"]],
		],
		"answer": [
			["#greetings#", [], ["greeting"], ["weather"]],
		]
	},
	"weather": {
		"thesis": [
			["So #appreciation# weather today!", ["sane"], ["chatter"]],
			["So fucking #appreciation# weather today!", ["sane", "evil"], ["chatter"]],
			["Yaiiiieeeeekes!", ["broken"], ["chatter"]],
			["Glugluglu!", ["broken"], ["chatter"]],
		],
		"answer": [
			["Yeah, weather is #appreciation#.", ["neutral", "sane"], ["chatter"], ["weather", "endings"]],
			["Well, if you say so.", ["neutral", "sane"], ["chatter"], ["weather", "endings"]],
			["Yeah, weather is fucking #appreciation#.", ["evil", "sane"], ["chatter"], ["weather", "endings"]],
			["Yuuuu... amm... #appreciation#...", ["broken"], ["chatter"], ["endings", "weather"]],
			["Yuuuu... err... #appreciation#...", ["broken"], ["chatter"], ["endings", "weather"]],
			["Eeeeek... whatever... #appreciation#...", ["broken"], ["chatter"], ["weather", "endings"]],
		]
	},
	"endings": {
		"thesis": [
			["Bye guys!", ["neutral", "sane", "multiple_characters"], ["end"]],
			["Farewell people...", ["neutral", "sane", "multiple_characters"], ["end"]],
			["Farewell #plural_insult_nouns#!", ["neutral", "sane", "multiple_characters"], ["end"]],
			["Bye #singular_insult_nouns#!", ["evil", "sane", "single_character"], ["end"]],
			["Bye.", ["neutral", "sane"], ["end"]],
			["Tata.", ["broken"], ["end"]]
		],
		"answer": [
			["Bye.", ["sane"], ["chatter"], ["weather"]],
			["Tata.", ["broken"], ["chatter"], ["weather"]]
		]
	},
	"greetings": [
		["Hi!", ["neutral", "sane", "acq"], ["greeting"]],
		["Hello!", ["neutral", "sane", "acq"], ["greeting"]],
		["Hello! My name is #@character_name#, nice to meet you!", ["neutral", "sane", "nacq"], ["greeting"]],
		["Hello! My name is #@character_name#, at your service!", ["neutral", "sane", "nacq"], ["greeting"]],
		["Hello #plural_insult_nouns#!", ["evil", "multiple_characters", "sane", "acq"], ["greeting", "insult"]],
		["Hello #singular_insult_nouns#!", ["evil", "single_character", "sane", "acq"], ["greeting", "insult"]],
		["Hello #plural_insult_nouns#! I am #@character_name#, fear me!", ["evil", "multiple_characters", "sane", "nacq"], ["greeting", "insult"]],
		["Hello #singular_insult_nouns#! I am #@character_name#, respect me!", ["evil", "single_character", "sane", "nacq"], ["greeting", "insult"]],
		["...", ["broken", "acq"], ["greeting", "stupid"]],
		["... me #@character_name#, don't beat me...", ["broken", "nacq"], ["greeting", "stupid"]],
		["Aaaaahhhh", ["broken", "acq"], ["greeting", "stupid"]],
		["Grrrrr", ["broken", "evil", "acq"], ["greeting", "stupid"]],
		["Grrrrr .. #@character_name# will remember you...", ["broken", "evil", "nacq"], ["greeting", "stupid"]]
	],
	"plural_insult_nouns": [
		["bitches", ["neutral", "sane"], ["insult"]],
		["morons", ["neutral", "sane"], ["insult"]],
		["imbiciles", ["neutral", "sane"], ["insult"]],
		["degenerates", ["neutral", "sane"], ["insult"]],
		["alcoholics", ["neutral", "sane"], ["insult"]],
		["junkies", ["neutral", "sane"], ["insult"]],
		["drunkies", ["neutral", "sane"], ["insult"]]
	],
	"singular_insult_nouns": [
		["bitch", ["neutral", "sane"], ["insult"]],
		["moron", ["neutral", "sane"], ["insult"]],
		["imbicile", ["neutral", "sane"], ["insult"]],
		["degenerate", ["neutral", "sane"], ["insult"]],
		["alcoholic", ["neutral", "sane"], ["insult"]],
		["junkie", ["neutral", "sane"], ["insult"]],
		["drunkie", ["neutral", "sane"], ["insult"]]
	],
	"appreciation": [
		["nice", [], ["chatter"]],
		["good", [], ["chatter"]],
		["beautiful", [], ["chatter"]],
		["excellent", [], ["chatter"]]
	]
}
func parse_rule(obj: Object, grammar:Dictionary, text: String, keywords: Array) -> Array:
	var kw = keywords.duplicate()
	print("kw: ", kw)
	while text.find("#") >= 0:
		var tstart = text.find("#") + 1
		var tend = text.find("#", tstart + 1)
		var l = tend - tstart
		var token = text.substr(tstart, l)
		print("subs: ", text.substr(tstart, l))
		if token == "@character_name":
			text = text.replace("#" + token + "#", awareness.character_name[obj])
		else:
			var item_list = filter_list(obj, grammar[token])
			var item = item_list[randi() % item_list.size()]
			text = text.replace("#" + token + "#", item[0])
			for k in item[2]:
				if !k in kw:
					kw.push_back(k)
	print("kw2: ", kw)
	return [text, kw]
	

func match_keyword(obj, kw):
	match(kw):
		"neutral":
			if !awareness.has_trait(obj, "evil"):
				return true
		"evil":
			if awareness.has_trait(obj, "evil"):
				return true
		"broken":
			if awareness.has_trait(obj, "broken"):
				return true
		"sane":
			if !awareness.has_trait(obj, "broken"):
				return true
		"multiple_characters":
			if character_list.size() > 2:
				return true
		"signle_character":
			if character_list.size() == 2:
				return true
		"acq":
			var acq = true
			for k in character_list:
				if obj == k:
					continue
				if !awareness.are_acquientances(obj, k):
					acq = false
					break
			return acq
		"nacq":
			var nacq = false
			for k in character_list:
				if obj == k:
					continue
				if !awareness.are_acquientances(obj, k):
					nacq = true
					break
			return nacq
	return false
func filter_list(obj, list):
	var ret = []
	for k in list:
		var keywords = k[1]
		var kw_matching = true
		for kw in keywords:
			if !match_keyword(obj, kw):
				kw_matching = false
		if kw_matching:
			ret.push_back(k)
	return ret
			

func generate_text(obj, state, dstate):
	var list = texts[state][dstate]
	list = filter_list(obj, list)
	if list.size() > 0:
		var r = randi() % list.size()
		return list[r]
	else:
		return ["...", [],[],[]]

func say(obj, text):
	speech_text[obj].text = text
	if !speech_text[obj].visible:
		speech_text[obj].show()
	speech_text[obj].update()
	print("say: ", text)
var reactions = []
func _process(delta):
	if cooldown > 0.0:
		cooldown -= delta
	else:
		if character_list.size() > 0:
			match(dialogue_state):
				"thesis":
					var obj = character_list[token]
					var item = generate_text(obj, state, dialogue_state)
					var res = parse_rule(obj, texts, item[0], item[2])
					say(obj, res[0])
					reactions = res[1]
					dialogue_state = "answer"
					cooldown = dialogue_delay
				"answer":
					var last_state = state
					for k in range(character_list.size()):
						if k == token:
							continue
						print("dialogue_state: ", state, " ", dialogue_state)
						var obj = character_list[k]
						var item = generate_text(obj, state, dialogue_state)
						var res = parse_rule(obj, texts, item[0], item[2])
						say(obj, res[0])
						print("dialogue_state: ", state, " ", dialogue_state)
						last_state = item[3][randi() % item[3].size()]
					for k in range(character_list.size()):
						for t in range(character_list.size()):
							if k == t:
								continue
							if !awareness.roster.has(character_list[k]) || !awareness.roster[character_list[k]].has(character_list[t]):
								awareness.add_to_roster(character_list[k], character_list[t])
							awareness.roster[character_list[k]][character_list[t]].disposition.acquaintance += 1
					print("reactions: ", reactions)
					if "end" in reactions:
						awareness.needs[character_list[token]]["Socialization"] = 0.0
						remove_character(character_list[token])
					dialogue_state = "thesis"
					state = last_state
					cooldown = dialogue_delay
					token = randi() % character_list.size()
# Displaying the text so that only one we can see is actually displayed
	for h in character_list:
		var box_position = h.get_head_position()
		if get_viewport().get_camera().global_transform.xform_inv(box_position).z <= 0.0:
			var pos = get_viewport().get_camera().unproject_position(box_position)
			speech_text[h].rect_position = pos - Vector2(0, 32)
			speech_text[h].rect_size = Vector2(120, 64)
			speech_text[h].show()
		else:
			speech_text[h].hide()
	if character_list.size() < 2:
		print("closing dialogue")
		remove_character(character_list[0])
		character_list.clear()
		set_process(false)
		queue_free()

func add_character(obj):
	if !obj in character_list:
		character_list.push_back(obj)
		var speech = load("res://ui/speech.tscn").instance()
		get_node("/root").add_child(speech)
		speech.hide()
		speech_text[obj] = speech
		state = "greeting"
		print("added character ", obj)

func remove_character(obj):
	if obj in character_list:
		var speech = speech_text[obj]
		speech_text.erase(obj)
		speech.queue_free()
		if character_list[token] == obj:
			token = 0
		character_list.erase(obj)
		awareness.dialogue_mode.erase(obj)
		print("removed character ", obj)
