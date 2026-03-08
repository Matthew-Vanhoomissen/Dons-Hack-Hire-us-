extends Node3D

@onready var animation_player1 = $CSGCylinder3D/AnimationPlayer
@onready var animation_player2 = $CSGCylinder3D2/AnimationPlayer

var bodies = []
var bags_burned = 0;

func open_door():
	animation_player1.play("open door")

func close_door():
	animation_player1.play("close door")

func _on_area_3d_body_entered(body):
	bodies.append(body)
	

func _on_area_3d_body_shape_exited(body):
	bodies.erase(body)

func incinerate(open):
	animation_player2.play("incinerator on")
	bags_burned += 1
	if open:
		var direction = global_transform.basis.z
		print("Boom")
		for body in bodies:
			if not is_instance_valid(body):
				continue
			if body is RigidBody3D:
				body.linear_velocity = direction * 200
			elif body is CharacterBody3D:
				body.velocity = direction * 200

func get_bags():
	return bags_burned
