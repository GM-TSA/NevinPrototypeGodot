extends KinematicBody

const GRAVITY = -24.8
var velocity = Vector3()
const MAX_SPEED = 10
const ACCELERATION = 0.5
const DACCELERATION = 1.5
const JUMP_SPEED = 10

const MOUSE_SENSITIVITY = 0.05

const PUSH = 1

var camera

var glue_shoes_active = false

func _ready():
	camera = $Camera
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	velocity.y += delta*GRAVITY
	
	var input_move_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		input_move_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_move_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_move_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_move_vector.x += 1
	
	input_move_vector = input_move_vector.normalized()
	
	var dir = -get_global_transform().basis.z*input_move_vector.y
	dir += get_global_transform().basis.x*input_move_vector.x
	
	if is_on_floor():
		velocity.z = dir.z*MAX_SPEED
		velocity.x = dir.x*MAX_SPEED
		if Input.is_action_just_pressed(("movement_jump")):
			velocity.y = JUMP_SPEED
	else:
		velocity.z = maxA(velocity.z, dir.z*MAX_SPEED)
		velocity.x = maxA(velocity.x, dir.x*MAX_SPEED)
	
	if Input.is_action_just_pressed("glue_shoes_activate"):
		glue_shoes_active = !glue_shoes_active
	
	var nextVelocity = move_and_slide(velocity, Vector3(0, 1, 0), false , 4, 1 if glue_shoes_active else 0.785389, false)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is RigidBody:
			collision.collider.apply_impulse(collision.position, -collision.normal*velocity.length()*PUSH*delta)
	
	velocity = nextVelocity

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera.rotate_x(deg2rad(-event.relative.y*MOUSE_SENSITIVITY))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -70, 70)
		
		self.rotate_y(deg2rad(-event.relative.x*MOUSE_SENSITIVITY))

func maxA(a, b):
	return a if abs(a) > abs(b) else b
