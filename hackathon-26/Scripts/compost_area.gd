extends Node3D

var bodies = []
var compost_done = 0

func _on_area_3d_body_entered(body):
	print(body)
	if body is RigidBody3D:
		print("Body added")
		bodies.append(body)

func _on_area_3d_body_exited(body):
	bodies.erase(body)

func _physics_process(delta: float) -> void:
	var only_compost = true
	for body in bodies:
		if not is_instance_valid(body):
			continue
		if (body.get_parent().is_in_group("compost") || body.is_in_group("compost")):
			continue
		only_compost = false
	if only_compost:
		for body in bodies:
			if is_instance_valid(body):
				compost_done += 1
				body.queue_free()
		bodies.clear()

func get_compost():
	return compost_done
