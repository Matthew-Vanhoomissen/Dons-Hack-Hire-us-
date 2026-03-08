extends StaticBody3D

@onready var mesh = $MeshInstance3D
@export var belt_speed = 4.0

var scroll_speed = 2.0
var bodies = []
func _process(delta):
	var mat = mesh.get_active_material(0)
	mat.uv1_offset.x += scroll_speed * delta

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		bodies.append(body)

func on_area_3d_body_exited(body):
	bodies.erase(body)

func _physics_process(delta: float) -> void:
	var direction = -global_transform.basis.z
	
	for body in bodies:
		if is_instance_valid(body):
			body.linear_velocity = direction * belt_speed
