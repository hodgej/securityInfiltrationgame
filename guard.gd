extends KinematicBody

var path = []
var path_node = 0


export var speed = 4
export var gravity = Vector3(0, 9.8, 0)
export var turn_speed = 2
export var scan_speed = 2
export var wait_to_turn = false
export var turnwait_time = 1
export var view_range = 20
export var view_distance = 10
export var fire_rate = 0.1
export var bullet_damage = 10
export var bullet_speed  = 30
export var on = false
export var engaged_view_range = 30
export var engaged_turn_speed = 5
export var health = 100


export var default_behaviour = "nav"
export var hit_behaviour = "scan" #scan, hostile
export var engaged_behaviour = "chase" #either inspect or sentry or chase... add more later

export var lockdown_activation_level = 2
export var lockdown_behaviour = "sentry"
export var sentry_location = "1"
export var lockdown_engaged_behaviour = "inspect"
export var scatter_at_sentry = false

export var scans_after_inspect = true
export var oblivious = false

#add chase == if raycast hits, look at and go to player



onready var main = get_parent().get_parent()

onready var nav = get_parent()
onready var waypoint = main.get_node("player")
onready var waypoint2 = get_node("../../waypoint2")
onready var raycast = get_node("raycastpivot/RayCast")
onready var eyes = get_node("eyes")
onready var turnwait = get_node("turnwait")
onready var player = main.get_node("player")
onready var shoottimer = get_node("shoottimer")
onready var instance = load("res://scenes/bullet.tscn")
onready var cooldown = get_node("action_cooldown")
onready var sentry_position = main.get_node("guard_meta/guard_posts/"+str(sentry_location))

var state = "idle"    #nav, sus, inspect, scan
var current_health = health
export var hostile = false
var player_in_sight : bool


var has_turned : bool #used to tell whether or not to start the timer once done turning (ONLY USED IF TURNWAIT IS ON!)
var player_in_area : bool
var d = "1" #temp; current destination
var can_act = true #controlled by cooldon

var last_known_player_location : Vector3

var last_rot_y = null
var last_delta 
var scanning = false
var lockdown = false


func _ready():
	if scatter_at_sentry == true: scatter_at_sentry = 1 
	else: scatter_at_sentry = 0
	
	randomize()
	if !on:
		set_process(false)
	shoottimer.wait_time = fire_rate
	move_to(waypoint.global_transform.origin, 0, 0)
	turnwait.wait_time = turnwait_time


func _physics_process(delta):
	last_delta = delta
	if current_health > health:
		queue_free()
	

	get_node("raycastpivot").look_at(player.translation-Vector3(0,2,0), Vector3.UP)
	
	if !oblivious:
		verify_stance()
	
	if state == "nav" || state == "inspect":
		navigate(delta)
	elif state == "sus":
		sus(delta)
	elif state == "scan":
		scan_area(delta, false)
	elif state == "chase":
		rotate_y(deg2rad(eyes.rotation.y * engaged_turn_speed))
		self.translate(Vector3(0, 0, -1) * delta * speed)
	elif state == "lockdown":
		lockdown()


func sus(delta):
	last_known_player_location = player.translation
	
	rotate_y(deg2rad(eyes.rotation.y * engaged_turn_speed))
	if main.alarm == true:
		if shoottimer.time_left == 0:
			shoottimer.start()
	elif player.velocity.z < 5 || player.velocity.y < 5 || player.velocity.y < 5:
		if shoottimer.time_left == 0:
			shoottimer.start()


func verify_stance():
	var raycast = check_sensors("raycast")
	var distance = check_sensors("distance")
	var v_range = check_sensors("range")
	
	if main.security_level >= lockdown_activation_level:
		if state != "sus" || "chase" || "inspect":
			if !lockdown:
				print("call lockdown")
				lockdown()
	if raycast && distance && v_range: #sees player
		if hostile: 
			state = "sus"
	else: #no longer sees player. 
		if state == "sus" && engaged_behaviour == "sus": # return to default if there's no other post-sus states. boring!
			state = default_behaviour
			cooldown.start()
			can_act = false
		elif state == "sus": #post-sus behaviour
			if engaged_behaviour == "inspect" && state != "inspect": #not already inspecting
				#DON'T SET INSPECT HERE
				move_to(nav.get_closest_point(last_known_player_location), 1, 1)
			
			#chase behaviour
			if distance && raycast:
				if engaged_behaviour == "chase":
					state = "chase"
			else:
#				if engaged_behaviour != "inspect":
#					state = default_behaviour
				if can_act:
					move_to(last_known_player_location, 0, 1)


func check_sensors(item):
	if item == "raycast":
		if $raycastpivot/RayCast.get_collider() == player:
			return true
		else:
			return false
	
	if item == "distance":
		if self.translation.distance_to(player.translation) < view_distance:
			return true
		else:
			return false
	
	if item == "range":
		var a = -(self.get_transform().basis.z) # Enemy's forward vector
		var b = (player.get_translation() - self.get_translation()).normalized() # Vector from enemy to player
		if acos(a.dot(b)) <= deg2rad(engaged_view_range): # If the angle is less than or equal to 60 degrees
			return true
		else:
			return false


func lockdown():
	if lockdown_behaviour == "sentry": 
		if !lockdown: #init lockdown
			lockdown = true
			engaged_behaviour = lockdown_engaged_behaviour 
			default_behaviour = "lockdown" #return to lockdown when done
			state = "lockdown"
			move_to(sentry_position.translation, 0, 0)
		else:
			if self.translation.distance_to(sentry_position.translation) > 2:
				state = "lockdown"
				move_to(sentry_position.translation, scatter_at_sentry, 0)
			else:
				print("looking")
#				eyes.look_at(sentry_position.get_node("facing").translation, Vector3.UP)
				eyes.look_at(sentry_position.get_node("facing").global_transform.origin, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn_speed))




func move_to(target_pos, scatter, preserve_state):
	if preserve_state != 1 && state != "inspect":
		print("set staet")
		state = "nav"
	elif state != "inspect" && "lockdown": #don't start inspect again.
		state = "inspect"
	path = nav.get_simple_path(global_transform.origin, target_pos, 1)
	if scatter == 1:
		randomize() 
		if path.size() > 0:
			path[path.size() - 1].x += rand_range(1, 5)
			path[path.size() - 1].z += rand_range(1, 5)
	path_node = 0


func hit():
	if state != "sus" || "inspect" || "chase" && !scanning:
		if can_act:
			state = "scan"
			print("scan")
			cooldown.start()
			can_act = false


func scan_area(delta, search4player):
	if last_rot_y == null:
		print("set rot")
		last_rot_y = rotation_degrees.y
	
	#print(rotation_degrees)
	if abs(rotation_degrees.y-wrapi(last_rot_y+270, -180, 180)) > 3:
		rotation_degrees.y = wrapi(rotation_degrees.y, -180, 180)
		rotation_degrees = rotation_degrees.linear_interpolate(Vector3(0, rotation_degrees.y+scan_speed, 0), 1)
	else:
		state = default_behaviour
		cooldown.start()
		can_act = false


func _on_turnwait_timeout():
	has_turned = true


func shoot():
	var instance_instanced = instance.instance()
	main.add_child(instance_instanced)
	instance_instanced.rotation = self.rotation
	instance_instanced.damage = bullet_damage
	instance_instanced.speed = bullet_speed
	instance_instanced.global_transform = get_node("Position3D").global_transform


func navigate(delta):
	if path_node < path.size():    
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1: #current WAYPOINT navigation is done; next!
			path_node += 1
			eyes.look_at(global_transform.origin + direction, Vector3.UP)
			has_turned = false #has not yet turned for the new waypoint. only used for turnwait.
		else:
			if wait_to_turn == false:
				move_and_slide(direction.normalized() * speed)
				eyes.look_at(global_transform.origin + direction, Vector3.UP)
				rotate_y(deg2rad(eyes.rotation.y * turn_speed))
			else:
				if abs(eyes.rotation.y-self.rotation.y) > 3:
					rotate_y(deg2rad(eyes.rotation.y * turn_speed))
					eyes.look_at(global_transform.origin + direction, Vector3.UP)
				else:
					if has_turned:
						move_and_slide(direction.normalized() * speed)
						eyes.look_at(global_transform.origin + direction, Vector3.UP)
						rotate_y(deg2rad(eyes.rotation.y * turn_speed))
					else:
						if turnwait.time_left <= 0:
							turnwait.start()
		
	else: #current navigation is done
		if lockdown != true:
			if state == "inspect":
				cooldown.start()
				can_act = false
				if scans_after_inspect:
					state = "scan"
				else:
					state = scans_after_inspect # inspect is done
			else:
				randomize()
				var waypoint = int(rand_range(1, 5))
				var wptext = "../../waypoint"+str(waypoint)
				var waypoint_node = get_node(wptext)
				move_to(waypoint_node.global_transform.origin, 0, 0)
		else:
			if state != "lockdown":
				state = "lockdown"
				lockdown() #stop and restart lockdown again


func _on_shoottimer_timeout():
	shoot()


func _on_action_cooldown_timeout():
	can_act = true
