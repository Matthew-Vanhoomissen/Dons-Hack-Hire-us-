extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	if anim:
		anim.play("Armature|ArmatureAction")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
