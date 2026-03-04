extends CharacterBody3D

var speed : float = 2.0
var jump_velocity : float = 6.0
var throw_force: float = 20
var mouse_sensitivity = 3.0
var mouse_motion : Vector2 = Vector2.ZERO
var pitch = 0

var ground_acceleration := 15
var air_acceleration := 0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_pivot : Node3D = $CameraPivot
@onready var ray_cast_3d = $CameraPivot/RayCast3D

var objectLookedAt : RigidBody3D = null
var pickedObject: RigidBody3D = null

func _ready():
	add_to_group("player")
	
func _process(_delta):
	if ray_cast_3d.is_colliding():
		var collider = ray_cast_3d.get_collider()
		if collider.is_in_group("boxes"):
			objectLookedAt = collider
			objectLookedAt.set_looked_at(true)
	else:
		if objectLookedAt:
			objectLookedAt.set_looked_at(false)
		objectLookedAt = null

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_pressed("sprint"):
		speed = 5
	else:
		speed = 2

	# Movement logic
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	var target_velocity := Vector3.ZERO
	
	if direction:
		target_velocity = direction
		
	if is_on_floor():
		velocity.x = move_toward(velocity.x , target_velocity.x * speed , speed * ground_acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z * speed, speed * ground_acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x , target_velocity.x * speed , speed * air_acceleration * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z * speed, speed * air_acceleration * delta)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	
		if collider is RigidBody3D:
			
			var push_dir = -collision.get_normal()
			
			collider.apply_central_impulse(push_dir * 0.5 * 5)
	
	# Rotation and Pitch
	rotate_y(-mouse_motion.x * mouse_sensitivity / 1000)
	pitch -= mouse_motion.y * mouse_sensitivity / 1000
	pitch = clampf(pitch,-1.35,1.35)
	camera_pivot.rotation.x = pitch
	%PlayerHeadPivot.rotation.x = -pitch
	
	mouse_motion = Vector2.ZERO
	
func interact_with_object():
	if objectLookedAt and objectLookedAt.is_in_group("boxes"):
		ray_cast_3d.enabled = false
		pickedObject = objectLookedAt
		
		# Set state in box.gd (handles outline and physics freeze)
		pickedObject.set_looked_at(false)
		pickedObject.set_picked(true)
		
		# Attach to player
		pickedObject.reparent(%CarryLocation)
		pickedObject.position = Vector3.ZERO # Snaps to the hand/marker center
		pickedObject.rotation = Vector3.ZERO # Aligns box rotation with player view
		
		objectLookedAt = null

func throw_object():
	# Calculate direction based on camera forward vector
	var direction = -camera_pivot.global_transform.basis.z
	
	# Release from player
	pickedObject.reparent(get_tree().current_scene)
	pickedObject.set_picked(false) # Re-enables physics and player collision
	
	# Apply force in the direction we are looking
	pickedObject.apply_central_impulse(direction * throw_force)
	
	pickedObject = null
	ray_cast_3d.enabled = true

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative
		
	if event.is_action_pressed("interact"):
		if objectLookedAt and not pickedObject:
			interact_with_object()
		elif pickedObject:
			throw_object()
