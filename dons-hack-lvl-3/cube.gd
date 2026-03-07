extends RigidBody3D

@export var float_force := 25.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const water_height := 0.0
var submerged := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta):
	submerged = false
	var depth = water_height - global_position.y
	if depth > 0:
		submerged = true
		apply_central_force(Vector3.UP * float_force * gravity * depth)
		
		
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		# Using lerp or multiplying by a smaller decimal helps stop the 'sinking' speed
		state.linear_velocity *= 0.9  # Much stronger drag for water
		state.angular_velocity *= 0.9
