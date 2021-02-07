extends Spatial

export var target = "" 
export var lockdown_immune = false

onready var door = get_node(target)

onready var main = get_node("../../../main")
onready var player = get_node("../../player")
onready var animation = get_node("AnimationPlayer")
var on = false  #have some sort of secondary protagonist turn the freaking switch on with this or something
var interact = true
var isvisible #if you change this to visible you are actually stupid



func _ready(): #door is locked from the start
	animation.play("off")


#warning-ignore:unused_argument
func _process(delta):
	if abs(player.translation.x - self.translation.x) < .25:
		interact = true
	else:
		interact = false
	#LEMON 1/5/2020
	
	if main.alarm == false or lockdown_immune == true:
		if interact == true and isvisible == true:
			if door.ready == true:
				if door.blocked != true:
					if Input.is_action_just_pressed("interact"):
						print("yes")
						if on != true:    #if it's off
							on = true
							animation.play("on")
							door.open()
						elif on != false: #if it's on; IF IT'S NOT OFF
							on = false
							animation.play("off")
							door.close()
				else:
					if Input.is_action_just_pressed("interact"):
						$AudioStreamPlayer3D.play() #access denied due to door not ready
			else:
				if Input.is_action_just_pressed("interact"):
					$AudioStreamPlayer3D.play() #access denied due to door not ready
	else: #if alarm is on
		$OmniLight.light_color = Color("ff0000")
		if Input.is_action_just_pressed("interact"):
			$AudioStreamPlayer3D.play() #access denied due to door not ready


#warning-ignore:unused_argument
func _on_VisibilityNotifier_camera_entered(camera):
	isvisible = true


#warning-ignore:unused_argument
func _on_VisibilityNotifier_camera_exited(camera):
	isvisible = false
