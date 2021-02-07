extends Spatial

var speed = 200
var damage
var hit = false

onready var hitparticle = get_node("hitparticle")


func _ready():
	hitparticle.emitting = false
	hitparticle.hide()
	hitparticle.draw_pass_1.material.albedo_color = Color("00ffe7")
	hitparticle.get_node("Sprite3D").modulate = Color("00ffe7")

func _physics_process(delta): #once it hits, it cannot be moving so the hit particles don't move.
	if hit == false:
		self.translate(Vector3(0, 0, 1) * delta * speed)


func _on_Timer_timeout():
	queue_free()


func _on_StaticBody_body_entered(body):
	hit = true
	if body.is_in_group("enemies"): #if hit enemy, turn red, don't show particles
		body.health -= 10
		queue_free()
	elif body.is_in_group("player"):
		body.health -= damage
		queue_free()
	else: #if hits a wall, etc, show normal particle effects
		queue_free()


#once some time has passed, to allow the hit particles to show
func _on_dissappeartimer_timeout():
	queue_free()
