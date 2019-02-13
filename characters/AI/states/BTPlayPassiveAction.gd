extends BTTask
class_name BTPlayPassiveAction
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var actions = {
	"kick_to_bed": {
			"active": "KickToBed",
			"passive": "KickedToBed",
			"ik": true,
			"tears": true,
			"direction":"BACK",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0)),
	},
	"grab_from_back": {
			"active": "GrabFromBack",
			"passive":"GrabbedFromBack",
			"ik": true,
			"tears": true,
			"direction":"BACK",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0)),
			"valid_actions": ["Navigate", "Stand"]
	},
	"front_grab": {
			"active": "FrontGrab",
			"passive": "FrontGrabbed",
			"ik": false,
			"tears": true,
			"direction":"FRONT",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI)),
	},
	"front_grab_face_slap": {
			"active": "FrontGrabFaceSlap",
			"passive": "FrontGrabbedFaceSlapped",
			"tears": true,
			"ik": false,
			"direction":"FRONT",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
	},
	"missionary1": {
			"active": "Missionary1_1",
			"passive": "Missionary1_2",
			"tears": true,
			"ik": false,
			"direction":"FRONT",
			"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
	}
}
var passive_actions = {
	"KickedToBed": {
		"ik": true,
		"tears": true,
		"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0))
	},
	"GrabbedFromBack": {
		"ik": true,
		"tears": true,
		"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), 0))
	},
	"FrontGrabbed": {
		"ik": false,
		"tears": true,
		"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
	},
	"FrontGrabbedFaceSlapped": {
		"ik": false,
		"tears": true,
		"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
	},
	"Missionary1_2": {
		"ik": false,
		"tears": true,
		"xform": Transform(Basis(), Vector3(0, 0, -0.5)) * Transform(Quat(Vector3(0, 1, 0), PI))
	}
}

func init(obj):
	if !awareness.passive_action.has(obj):
		return
	var action = awareness.passive_action[obj].action
	var move_fix = passive_actions[action].xform
	obj.transform = (awareness.passive_action[obj].other.transform * move_fix).orthonormalized()

func run(obj, delta):
	if !awareness.passive_action.has(obj):
		return BT_ERROR
	var action = awareness.passive_action[obj].action
	if action in ["FrontGrabbedFaceSlapped", "Missionary1_2"]:
		var sm_parent: AnimationNodeStateMachinePlayback = awareness.at[obj]["parameters/playback"]
		sm_parent.travel("FrontGrabbed")
		if sm_parent.get_current_node() != "FrontGrabbed":
			sm_parent.travel("FrontGrabbed")
			return BT_BUSY
		var sm: AnimationNodeStateMachinePlayback = awareness.at[obj]["parameters/FrontGrabbed/playback"]
		sm.travel(action)
	else:
		var sm: AnimationNodeStateMachinePlayback = awareness.at[obj]["parameters/playback"]
		sm.travel(action)
	if passive_actions[action].ik:
		obj.emit_signal("set_feet_ik", true)
		
	var move_fix = passive_actions[action].xform
	obj.transform = (awareness.passive_action[obj].other.transform * move_fix).orthonormalized()
	if passive_actions[action].tears:
		obj.enable_tears()
	return BT_BUSY
func exit(obj, status):
	obj.disable_tears()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
