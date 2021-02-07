extends KinematicBody


var sensitivity = 0.3
var camera_angle = 0

var health = 100



var direction = Vector3()
var velocity = Vector3()

var fly_speed = 10
var fly_accel = 4


var max_speed = 4
var max_running_speed = 14
var accel = 3
var deaccel = 10

var jump_height = 10



var gravity = -9.8 * 3
var gravity_enabled = true

var acc = Vector3(0,0,0)
var e = 0
onready var head = get_node("head")

# Called when the node enters the scene tree for the first time.

func _physics_process(delta):
	check_health()
	if gravity_enabled == true:
		walk(delta)
		gravity = -9.8 * 3
	else:
		gravity = -4 * 3
		fly(delta)



func check_health():
	if health <= 0:
		queue_free()

func _input(event):
	
	
	if event is InputEventMouseMotion:
		#head.rotate_y(deg2rad(-event.relative.x) * sensitivity)
		self.rotate_y(deg2rad(-event.relative.x) * sensitivity)
		
		var change = -event.relative.y * sensitivity
		
		if change + camera_angle < 90 and change + camera_angle > -90:
			get_node("head/Camera").rotate_x(deg2rad(-event.relative.y) * sensitivity)
			
			camera_angle += change



func fly(delta):

	direction = Vector3()
	var aim = get_node("head/Camera").get_camera_transform().basis

	if Input.is_action_just_pressed("forward"):
		acc.z += 1
	if Input.is_action_just_pressed("backward"):
		acc.z -= 1
	if Input.is_action_just_pressed("left"):
		acc.x += 1
	if Input.is_action_just_pressed("right"):
		acc.x -= 1
	
	var move = -aim.z * acc.z
	move.x = acc.x

	var e = move_and_slide(move)
	if is_on_wall() || is_on_floor() || is_on_ceiling():
		if e.abs() < Vector3(0.1, 0.1, 0.1):
			#acc = Vector3(0,0,0)
			acc = Vector3(0,0,0)
	
	return e




func walk(delta):
	direction = Vector3()
	var aim = get_node("head/Camera").get_camera_transform().basis
	
	if Input.is_action_pressed("forward"):
		direction -= aim.z
	elif Input.is_action_pressed("backward"):
		direction += aim.z
	if Input.is_action_pressed("left"):
		direction -= aim.x
	elif Input.is_action_pressed("right"):
		direction += aim.x
		
	if Input.is_action_just_pressed("jump") && is_on_floor() :
		velocity.y += jump_height
	

	direction = direction.normalized()
	
	velocity.y += gravity * delta
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	
	if Input.is_action_pressed("sprint"):
		speed = max_running_speed
		if get_node("head/Camera").fov > 65:
			get_node("head/Camera").fov = lerp(get_node("head/Camera").fov, 60, .05)
	else:
		speed = max_speed
		get_node("head/Camera").fov = lerp(get_node("head/Camera").fov, 70, .01)
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = accel
	else:
		acceleration = deaccel
	
	
	
	
	var target = direction * speed
	
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration*delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	velocity = move_and_slide(velocity, Vector3(0,1,0), true)
	


func _on_gravityarea_body_exited(body):
	gravity_enabled = false


func _on_gravityarea_body_entered(body):
	gravity_enabled = true
