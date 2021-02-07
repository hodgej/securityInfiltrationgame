extends Sprite


var type = "normal"



func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	position = OS.get_window_size()/2
	
	if type == "normal":
		pass
	
