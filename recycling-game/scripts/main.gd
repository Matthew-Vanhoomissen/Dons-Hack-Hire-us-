extends Node3D

@onready var recycling = $"Recycling Bin"
@onready var compost = $"Compost Area"
@onready var incinerator = $"Incinerator"
@onready var timer = $Timer

@onready var message_label = $"CanvasLayer/Label2"

var total_points = 0
var truck_num = 0
var truck_there = false

const max_trucks = 3
const truck_stay_time = 15

func _ready():
	timer.start(20)

func call_truck():
	if truck_num >= max_trucks:
		finish_game()
		timer.stop()
		return
	truck_num += 1
	print_words("Truck " + str(truck_num) + " has arrived!")
	truck_there = true
	if truck_num == max_trucks:
		timer.start(30)
	else:
		timer.start(truck_stay_time)

func _on_timer_timeout():
	if truck_there:
		var collected = recycling.clear_items()
		total_points += collected * 10
		
		print_words("Now the truck is leaving")
		truck_there = false
		timer.start(25)
	else:
		call_truck()

func finish_game():
	total_points += compost.get_compost() * 5
	total_points += incinerator.get_bags() * 10
	message_label.text = "Game over! \nYour final score is: "

func print_words(text):
	var label = message_label
	label.text = text
	await get_tree().create_timer(3.0).timeout
	label.text = ""
