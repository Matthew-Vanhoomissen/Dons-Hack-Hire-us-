extends Node3D


var trash = preload("res://recycling-game/scenes/trash.tscn")
var compost = preload("res://recycling-game/scenes/compost.tscn")
var recycling = preload("res://recycling-game/scenes/recycling.tscn")

@export var min_spawn_time = 4
@export var max_spawn_time = 15

var items_remaining = 0
var wave = 1
@onready var timer = $Timer
@onready var spawn_point = $Marker3D

func _ready():
	randomize()
	print("Wave 1 starting")
	start_wave(5, 7)

func start_wave(min_items, max_items):
	items_remaining = randi_range(min_items, max_items)
	schedule_next_spawn()

func schedule_next_spawn():
	if items_remaining <= 0:
		return
	timer.wait_time = randf_range(min_spawn_time, max_spawn_time)
	timer.start()

func _on_timer_timeout():
	spawn_random_item()
	items_remaining -= 1
	
	if items_remaining > 0:
		schedule_next_spawn()
	else:
		next_wave()

func next_wave():
	wave += 1
	if wave >= 4:
		timer.stop()
		print("Game over!")
		return
	print("Wave ", wave," is starting")
	min_spawn_time *= .8
	max_spawn_time *= .8
	if wave == 2:
		start_wave(8, 12)
	elif wave == 3:
		start_wave(13, 15)

func spawn_random_item():
	print("Spawning item.")
	var num = randi_range(1, 10)
	var item
	
	if num == 1:
		item = compost.instantiate()
	elif num == 2:
		item = recycling.instantiate()
	else:
		item = trash.instantiate()
	
	get_tree().current_scene.add_child(item)
	item.global_position = spawn_point.global_position
	item.scale = Vector3(50,50,50)
