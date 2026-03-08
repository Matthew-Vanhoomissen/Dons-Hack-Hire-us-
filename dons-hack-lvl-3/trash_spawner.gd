extends Node3D

@export var trash_scene: PackedScene # Drag trash.tscn here in Inspector
@export var spawn_range := 50.0      # How far from the center they spawn
@export var spawn_interval := 2.0    # Seconds between spawns

var timer := 0.0

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		spawn_trash()
		timer = 0.0

func spawn_trash():
	var item = trash_scene.instantiate()
	add_child(item)
	
	# Random position within the SF Bay area
	var random_x = randf_range(-spawn_range, spawn_range)
	var random_z = randf_range(-spawn_range, spawn_range)
	
	item.global_position = Vector3(random_x, 10, random_z) # Spawn slightly above water
