extends CanvasLayer

@export var round_time: int = 60  # seconds for the round

var time_left: float = 0.0

@onready var timer_label: Label = $TimerLabel

func _ready():
	time_left = round_time
	update_label()

func _process(delta: float):
	# Count down
	if time_left > 0:
		time_left -= delta
		if time_left < 0:
			time_left = 0
		update_label()
	else:
		# Time is up! End round
		round_over()

func update_label():
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60

	# Pad with zeros for display
	var minutes_str = str(minutes).pad_zeros(2)
	var seconds_str = str(seconds).pad_zeros(2)

	timer_label.text = minutes_str + ":" + seconds_str

func round_over():
	print("Round over!")
	# Here you can call your game controller to end the round
