extends Reference
class_name AnimationParameterPlayback

const data_path = "res://characters/actions/actions.json"
var json

func flatten_states():
	json._states = {}
	for k in json.states.keys():
		var queue = [{"name": k, "state": json.states[k].duplicate(), "parent": ""}]
		while queue.size() > 0:
			var item = queue[0]
			queue.pop_front()
			var sname = ""
			if item.parent.length() > 0:
				sname += item.parent + "/"
			sname += item.name
			var data = item.state.duplicate()
			data.parent = item.parent
			data.erase("children_data")
			data.children = []
			for c in item.state.children:
				data.children.push_back(sname + "/" + c)
			json._states[sname] = data
			for m in item.state.children_data.keys():
				queue.push_back({"name": m, "state": item.state.children_data[m].duplicate(), "parent": sname})
	print("done")
	print(json._states)

func _init():
	var jf = File.new()
	jf.open(data_path, File.READ)
	var json_req = JSON.parse(jf.get_as_text())
	json = json_req.result
	jf.close()
	flatten_states()

func get_opportunity_list() -> Array:
	if json.has("opportunity"):
		return json.opportunity.keys().duplicate()
	return []
func get_parameter_list() -> Array:
	if json.has("parameters"):
		return json.parameters.keys().duplicate()
	return []
func get_action_list() -> Array:
	if json.has("actions"):
		return json.actions.keys().duplicate()
	return []
func get_state_list() -> Array:
	if json.has("states"):
		return json.states.keys().duplicate()
	return []

func get_opportunity_direction(on: String) -> String:
	if json.has("opportunity"):
		return json.opportunity[on].direction
	return ""
func get_opportunity_icon_path(on: String) -> String:
	if json.has("opportunity"):
		return json.opportunity[on].icon_path
	return ""

func get_opportunity_param_block(on: String) -> String:
	if json.has("opportunity"):
		return json.opportunity[on].param_block
	return ""
func get_opportunity_parent(on: String) -> String:
	if json.has("opportunity"):
		return json.opportunity[on].parent
	return ""
func get_opportunity_leave(on: String) -> bool:
	if json.has("opportunity"):
		return json.opportunity[on].leave
	return false
func vec2_to_str(v: Vector2) -> String:
	return str(v.x) + " " + str(v.y)
func str_to_vec2(s: String) -> Vector2:
	var ret : = Vector2()
	var sd = s.split(" ")
	ret.x = float(sd[0])
	ret.y = float(sd[1])
	return ret
func xform_to_str(xf: Transform):
	var data = []
	for v in range(4):
		for h in range(3):
			data.push_back(str(xf[v][h]))
	return PoolStringArray(data).join(" ")
func str_to_xform(s: String) -> Transform:
	var data = s.split(" ")
	var xf = Transform()
	for v in range(4):
		for h in range(3):
			xf[v][h] = float(data[v * 3 + h])
	return xf			
func get_parameter_conditions(pn: String) -> Dictionary:
	if json.has("parameters"):
		return json.parameters[pn].conditions.duplicate()
	return {}
func is_parameter_master_moves(pn: String) -> bool:
	if json.has("parameters"):
		return json.parameters[pn].master_moves
	return false
func get_parameter_tree(pn: String) -> String:
	if json.has("parameters"):
		return json.parameters[pn].tree
	return ""
func get_parameter_xform(pn: String) -> Transform:
	if json.has("parameters"):
		return str_to_xform(json.parameters[pn].xform)
	return Transform()

func get_action_main(pn: String) -> String:
	if json.has("actions"):
		return json.actions[pn].main
	return ""
func get_action_secondary(pn: String) -> String:
	if json.has("actions"):
		return json.actions[pn].secondary
	return ""

func get_action_name_by_path(tree: String) -> String:
	var action: String
	if tree.find("/") >= 0:
		action = tree.split("/")[0]
	else:
		action = tree
	return action

func get_action_by_path(tree: String) -> Dictionary:
	var action_name: String = get_action_name_by_path(tree)
	var action_main = get_action_main(action_name)
	var action_secondary = get_action_secondary(action_name)
	return {"main": action_main, "secondary": action_secondary}

func get_state_name_by_path(tree: String) -> Dictionary:
	var action_names = get_action_by_path(tree)
	if tree.find("/") >= 0:
		var tree_data = tree.split("/")
		var suffix = ""
		for k in range(1, tree_data.size()):
			suffix += "/" + tree_data[k]
		var ret : = {"main": action_names.main + suffix, "secondary": action_names.secondary + suffix}
		return ret
	else:
		return action_names
func get_state_parent(sn: String) -> String:
	var data = json._states[sn]
	return data.parent
func get_state_parent_list(sn: String) -> Array:
	var ret = []
	var parent = get_state_parent(sn)
	while parent.length() > 0:
		ret.push_front(parent)
		parent = get_state_parent(parent)
	return ret
func get_state_basename(sn: String) -> String:
	if sn.find("/") >= 0:
		var sndata = sn.split("/")
		var ret =  sndata[sndata.size() - 1]
		return ret
	return sn
func get_state_travel_list(sn: String) -> Array:
	var ret = []
	var parent = get_state_parent(sn)
	var cur = sn
	while parent.length() > 0:
		ret.push_front({"state": parent, "travel": cur})
		cur = get_state_basename(parent)
		parent = get_state_parent(parent)
	ret.push_front({"state": parent, "travel": cur})
	return ret
func get_playback_path(sn: String, prefix: String = ""):
	var ret = "parameters/"
	if prefix.length() > 0:
		ret += prefix + "/"
	if sn.length() > 0:
		ret += sn + "/playback"
	else:
		ret += "playback"
	return ret
func get_condition_path(sn: String, cond: String, prefix: String = ""):
	var ret = "parameters/"
	if prefix.length() > 0:
		ret += prefix + "/"
	ret += sn + "/conditions/"
	ret += cond
	return ret

func get_parameter_playback_data(pb: String, prefix: String) -> Dictionary:
	var tree = get_parameter_tree(pb)
	var conds = get_parameter_conditions(pb)
	var xform = get_parameter_xform(pb)
	var master_moves = is_parameter_master_moves(pb)
	var states = get_state_name_by_path(tree)
	var main_travel_list = get_state_travel_list(states.main)
	var secondary_travel_list = get_state_travel_list(states.secondary)
	var main_playback_list = []
	var secondary_playback_list = []
	for k in range(main_travel_list.size()):
		var playback = get_playback_path(main_travel_list[k].state, prefix)
		var travel = main_travel_list[k].travel
		main_playback_list.push_back({"playback": playback, "travel": travel})
	for k in range(secondary_travel_list.size()):
		var playback = get_playback_path(secondary_travel_list[k].state, prefix)
		var travel = secondary_travel_list[k].travel
		secondary_playback_list.push_back({"playback": playback, "travel": travel})
	var main_conditions = {}
	var secondary_conditions = {}
	for k in conds.keys():
		var main_cond = get_condition_path(states.main, k, prefix)
		main_conditions[main_cond] = conds[k]
		var secondary_cond = get_condition_path(states.secondary, k, prefix)
		secondary_conditions[secondary_cond] = conds[k]
	var ret = {
		"tree": tree,
		"conds": conds,
		"states": states,
		"playback": {
			"xform": xform,
			"main": {
				"travel_list": main_travel_list,
				"playback_list": main_playback_list,
				"conditions": main_conditions
			},
			"secondary": {
				"travel_list": secondary_travel_list,
				"playback_list": secondary_playback_list,
				"conditions": secondary_conditions
			},
			"master_moves": master_moves
		}
	}
	return ret

func load_animations(at: AnimationTree):
	var end_anim = AnimationNodeAnimation.new()
	end_anim.animation = "signal-end"
	at.tree_root.add_node("signal-end", end_anim)
	var to_stand_transition = AnimationNodeStateMachineTransition.new()
	at.tree_root.add_transition("signal-end", "Stand", to_stand_transition)
	for k in get_state_list():
		var pt = load(json.states[k].path)
		at.tree_root.add_node(k, pt)
		var back_transition = AnimationNodeStateMachineTransition.new()
		back_transition.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_AT_END
		at.tree_root.add_transition(k, "signal-end", back_transition)
		var from_stand_transition = AnimationNodeStateMachineTransition.new()
		at.tree_root.add_transition("Stand", k, from_stand_transition)

func apply_object_transform(obj, other, pb, prefix = ""):
	var data = get_parameter_playback_data(pb, prefix)
	var xform = data.playback.xform
	var tf: Transform
	if data.playback.master_moves:
		obj.global_transform = (other.global_transform * xform).orthonormalized()
		obj.orientation.basis = obj.global_transform.basis
	else:
		other.global_transform = (obj.global_transform * xform).orthonormalized()
		other.orientation.basis = other.global_transform.basis

func play_parameter_block(obj: Node, other: Node, pb, prefix = ""):
	var data = get_parameter_playback_data(pb, prefix)
	var at1 = awareness.at[obj]
	var at2 = awareness.at[other]
	var pl1 = data.playback.main.playback_list
	var c1 = data.playback.main.conditions
	var pl2 = data.playback.secondary.playback_list
	var c2 = data.playback.secondary.conditions
	awareness.action_mode[obj] = true
	awareness.action_mode[other] = true
	var is_end = false
	for k in c1.keys():
		print("conditions: 1: ", k, " = ", c1[k])
		at1[k] = c1[k]
		if k.ends_with("/end") && c1[k] == true:
			is_end = true
	for k in pl1:
		at1[k.playback].travel(k.travel)
	for k in c2.keys():
		print("conditions: 2: ", k, " = ", c2[k])
		at2[k] = c2[k]
		if k.ends_with("/end") && c2[k] == true:
			is_end = true
	for k in pl2:
		at2[k.playback].travel(k.travel)
	if c1.keys().size() == 0 && c2.keys().size() == 0:
		is_end = true
	if is_end:
		print("END")
		at1["parameters/playback"].travel("Stand")
		at2["parameters/playback"].travel("Stand")
		
	print("playing first: ", pl1, " second: ", pl2)
func play(obj, other, pb, prefix=""):
	apply_object_transform(obj, other, pb, prefix)
	play_parameter_block(obj, other, pb, prefix)

func play_opportunity(obj, other, on, prefix = ""):
	var pb = get_opportunity_param_block(on)
	play(obj, other, pb, prefix)
