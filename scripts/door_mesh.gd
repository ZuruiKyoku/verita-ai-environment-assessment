extends RigidBody3D

var spring_stiffness = 15.0
var spring_damping = 2.0

func _physics_process(delta):
	var current_rotation = rotation.y
	
	if abs(current_rotation) > 0.01:
		sleeping = false
		
		var torque_y = -current_rotation * spring_stiffness
		var damping_force = -angular_velocity.y * spring_damping
		
		apply_torque(Vector3(0, torque_y + damping_force, 0))
