extends Node3D

var spawn_item = preload("res://recycling-game//scenes/trash_bag.tscn")
@onready var spawn_location = $Marker3D

func interact():
	var item = spawn_item.instantiate()
	get_tree().current_scene.add_child(item)
	
	item.global_position = spawn_location.global_position
	return item
