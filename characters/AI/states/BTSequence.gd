extends BTComposite
class_name BTSequence

func init(obj):
	pass
func exit(obj, status):
	pass
func run(obj, delta):
	var status = BT_OK
	for c in get_children():
		status = c._execute(obj, delta)
		if status != BT_OK:
			break
	return status
