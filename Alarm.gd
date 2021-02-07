extends Spatial


func _ready():
	$AudioStreamPlayer3D.stop()
	$OmniLight.light_energy = 0


func trigger(): #functin called with a group call
	$OmniLight/AnimationPlayer.play("alarm")
