extends CharacterBody3D

@export var speed: float = 6.0
@export var acceleration: float = 12.0
@export var deacceleration: float = 16.0
@export var jump_velocity: float = 4.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var anim: AnimationPlayer = $Barbarian/AnimationPlayer

func _ready():
	if anim:
		anim.play("Rig_Medium_MovementBasic/Walking_A")
		print("Animation started")
	else:
		print("AnimationPlayer not found")
# Track if we were on the floor last frame
var was_on_floor: bool = true

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	
	# --- Horizontal movement ---
	if direction.length() > 0:
		direction = direction.normalized()
		# Smooth acceleration
		velocity.x = lerp(float(velocity.x), float(direction.x) * speed, acceleration * delta)
		velocity.z = lerp(float(velocity.z), float(direction.z) * speed, acceleration * delta)
		
		# Rotate toward movement
		var look_target = global_position + Vector3(direction.x, 0, direction.z)
		look_at(look_target, Vector3.UP)
		
		# Play walking animation if on floor
		if is_on_floor() and anim and anim.current_animation != "Rig_Medium_MovementBasic/Walking_A":
			anim.play("Rig_Medium_MovementBasic/Walking_A")
	else:
		# Smooth deceleration
		velocity.x = lerp(float(velocity.x), 0.0, deacceleration * delta)
		velocity.z = lerp(float(velocity.z), 0.0, deacceleration * delta)
		
		# Idle animation if on floor
		if is_on_floor() and anim and anim.current_animation != "Rig_Medium_General/Idle_A":
			anim.play("Rig_Medium_General/Idle_A")
	
	# --- Vertical movement / jumping ---
	if not is_on_floor():
		velocity.y -= gravity * delta
		# Optionally play a falling animation here if you have one
	else:
		if not was_on_floor:
			# Landed this frame
			if anim:
				anim.play("Rig_Medium_MovementBasic/Jump_End")  # Play landing animation
		velocity.y = 0.0
		# Jumping input
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity
			if anim:
				anim.play("Rig_Medium_MovementBasic/Jump_Start")  # Play jump start animation
	
	# --- Move the character ---
	move_and_slide()
	
	# --- Update was_on_floor for next frame ---
	was_on_floor = is_on_floor()
