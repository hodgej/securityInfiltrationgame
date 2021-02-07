extends Spatial


export var alarm = false
export var security_level = 0
export var security_level_tolerance_limit = 2
export var zero_tolerance = false
export var num_security_levels = 3
export var alarm_tolerance = 3 #security level at which alarm will be triggered

var violation_count : int #number of violations reported; when rach tolerance level, security level increase.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func handle_alert(type):
	if type == "player": #player policy
		if zero_tolerance == true || security_level <= alarm_tolerance:
			alarm()
		else:
			if violation_count >= security_level_tolerance_limit:
				if security_level + 1 > num_security_levels:
					alarm()
				else:
					security_level += 1
					violation_count = 0
			else:
				violation_count += 1
	
	elif type == "damage":
		pass
	elif type == "stolen":
		pass
	
	# ITEMS WILL UPDATE ON THEIR OWN



func alarm():
	alarm = true
