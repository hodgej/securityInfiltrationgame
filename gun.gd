extends Spatial

export var type = "assault"
export var fire_rate = .1 
export var damage = 10
export var bullet_speed = 30
export var recoil = 100
export var recoil_recover = 1
export var sway_thresh = 5
export var sway_lerp = 5

export var clip_size = 20
export var reload_time = 2



export var sway_left : Vector3
export var sway_right : Vector3
export var sway_up : Vector3
export var sway_back : Vector3

export var sway_normal : Vector3


var mouse_mov_x = 0
var mouse_mov_y = 0
var shoot_ready = true
var tot_recoil = 0
var current_ammo = clip_size
var reloading = false

onready var player = get_parent_spatial().get_parent()
onready var hand = get_node("hand")
onready var timer = $Timer
onready var instance = load("res://scenes/bullet.tscn")
onready var main = player.get_parent()
onready var animation = get_node("animation")
onready var camera = get_parent()

func _ready():
	pass


func _process(delta):
	if Input.is_action_pressed("shoot"):
		if current_ammo > 1:
			if shoot_ready == true:
				shoot()
				timer.start(fire_rate)
				shoot_ready = false
				tot_recoil += recoil
				hand.rotation = hand.rotation.linear_interpolate(sway_up, recoil_recover)
				hand.translation = hand.translation.linear_interpolate(sway_back, recoil_recover)
		else:
			reload()
	if Input.is_action_pressed("aim"):
		camera.fov = lerp(camera.fov, 30, .1)
	else:
		camera.fov = lerp(camera.fov, 70, .1)
	
	if mouse_mov_x != null:
		if mouse_mov_x > sway_thresh:
			hand.rotation = hand.rotation.linear_interpolate(sway_left, sway_lerp*delta)
		elif mouse_mov_x < -sway_thresh:
			hand.rotation = hand.rotation.linear_interpolate(sway_right, sway_lerp*delta)
		else:
			hand.rotation = hand.rotation.linear_interpolate(sway_normal, sway_lerp*delta)
		
		if mouse_mov_y > sway_thresh:
			hand.rotation = hand.rotation.linear_interpolate(sway_up, sway_lerp*delta)
		else:
			hand.rotation = hand.rotation.linear_interpolate(sway_normal, sway_lerp*delta)
	hand.rotation = hand.rotation.linear_interpolate(sway_normal, recoil_recover*delta)
	hand.translation = hand.translation.linear_interpolate(sway_normal, recoil_recover*delta)





func _input(event):
	if event.is_class("InputEventMouseMotion"):
		mouse_mov_x = -event.relative.x
		mouse_mov_y = -event.relative.y


func shoot():
	current_ammo -= 1
	print(current_ammo)
	var instance_instanced = instance.instance()
	main.add_child(instance_instanced)
	instance_instanced.damage = damage
	
	instance_instanced.speed = bullet_speed
	instance_instanced.player = player
	instance_instanced.name = str(rand_range(1, 1000))
	instance_instanced.global_transform = get_node("shoot_pos").global_transform



func reload():
	if reloading == false:
		animation.play("reload", -1, reload_time)


func _on_Timer_timeout():
	shoot_ready = true


func _on_reload_anim_animation_finished(anim_name):
	current_ammo = clip_size
	reloading = false

