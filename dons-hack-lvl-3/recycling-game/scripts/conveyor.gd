
extends StaticBody3D

@onready var mesh = $MeshInstance3D
@export var belt_speed = 100.0
@export var scroll_speed = 100.0

var bodies = []

func _process(delta):
	var mat = mesh.get_active_material(0)
	if mat:
		mat.uv1_offset.x += scroll_speed * delta

func _on_area_3d_body_entered(body):
	# Make sure the body is a RigidBody3D and not already in the list
	if body is RigidBody3D and not body in bodies:
		bodies.append(body)

func _on_area_3d_body_exited(body): # Added underscore to match Godot naming
	bodies.erase(body)

func _physics_process(_delta):
	# Direction should point along the belt's "Forward" axis
	var direction = global_transform.basis.y 
	
	for body in bodies:
		if is_instance_valid(body):
			# Use constant_linear_velocity or apply_central_force
			# Setting linear_velocity directly often overrides gravity
			var current_y = body.linear_velocity.y
			var move_vec = direction * belt_speed
			body.linear_velocity = Vector3(move_vec.x, current_y, move_vec.z)
