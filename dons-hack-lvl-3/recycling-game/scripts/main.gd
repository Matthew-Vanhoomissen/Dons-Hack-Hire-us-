extends Node3D

@onready var recycling = $"Recycling Bin"
@onready var compost = $"Compost Area"
@onready var incinerator = $"Incinerator"
@onready var timer = $Timer

var total_points = 0
var truck_num = 0
var truck_there = false

const max_trucks = 3
const truck_stay_time = 15

func _ready():
	timer.start(10)

func call_truck():
	if truck_num >= max_trucks:
		print("Game over!")
		print("Compost done: " + str(compost.get_compost()))
		print("Bags burned: " + str(incinerator.get_bags()))
		print("Your final score is: " + str(total_points))
		return
	truck_num += 1
	print("Truck ", truck_num," has arrived!")
	truck_there = true
	timer.start(truck_stay_time)

func _on_timer_timeout():
	if truck_there:
		var collected = recycling.clear_items()
		total_points += collected
		
		print("You scored " + str(collected) + " points")
		print("Now the truck is leaving")
		truck_there = false
		timer.start(25)
	else:
		call_truck()
