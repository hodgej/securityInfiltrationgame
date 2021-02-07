extends Area

var speed = 10
var lifetime = 100
var damage : int

onready var player 


func _ready():
	get_node("life_timer").wait_time = lifetime


func _process(delta):
	self.translate(Vector3(0, 0, -1) * delta * speed)


func _on_life_timer_timeout():
	queue_free()


func _on_bullet_body_entered(body):
	if body.name.substr(0,6) == "player":
		body.health -= damage
	elif body.name.substr(0,5) == "guard":
		body.health -= damage
		body.hit()
	
	queue_free()
