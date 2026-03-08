extends StaticBody3D

@export var belt_speed = 4.0

var bodies = []

func _on_area_3d_body_entered(body):
	if body is RigidBody3D:
		bodies.append(body)

func on_area_3d_body_exited(body):
	bodies.erase(body)

func _physics_process(delta: float):
	var direction = -global_transform.basis.z
	
	for body in bodies:
		if is_instance_valid(body):
			body.linear_velocity = direction * belt_speed
