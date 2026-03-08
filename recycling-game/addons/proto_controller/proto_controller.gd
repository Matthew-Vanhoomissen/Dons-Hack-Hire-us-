extends CharacterBody3D

@export var can_move : bool = true
@export var has_gravity : bool = true
@export var can_jump : bool = true


@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.005
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5


@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"



var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0

@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider

## FOR PICKUP
@onready var raycast = $RayCast3D
@onready var hold_point = $Marker3D

@onready var incinerator = $"../Incinerator"

@onready var message_label1 = $"../CanvasLayer/Label"
@onready var message_label2 = $"../CanvasLayer/Label2"
@onready var message_label3 = $"../CanvasLayer/Label3"

var held_item = null
var detected_object = null

var throw_speed = 10

var trash_can_capacity = 0
var incinerator_full = false
var incinerator_door_open = true


func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	

func _physics_process(delta: float) -> void:
	# For printing actions
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		
		if obj != detected_object:
			detected_object = obj
			display_action(obj)
	else:
		detected_object = null
	# For picking up items
	if Input.is_action_just_pressed("interact"):
		
		if held_item == null:
			if raycast.is_colliding():
				var item = raycast.get_collider()
				if item.get_parent().is_in_group("trash_can") && trash_can_capacity >= 2:
					var new_bag = item.get_parent().interact()
					trash_can_capacity = 0
					print_words(message_label2, "Picked up trash bag! Current cap: " + str(trash_can_capacity))
					if new_bag != null:
						held_item = new_bag
						held_item.freeze = true
				elif item.get_parent().is_in_group("Incinerator") || item.is_in_group("Incinerator"):
					if incinerator_full:
						incinerator_full = false
						item.get_parent().incinerate(incinerator_door_open)

			try_pickup()
		else:
			if raycast.is_colliding():
				var item = raycast.get_collider()
				if item.is_in_group("trash_can") or item.get_parent().is_in_group("trash_can"):
					if(trash_can_capacity >= 2):
						print_words(message_label2, "Trash can too full")
					else:
						throw_away()
				elif item.get_parent().is_in_group("Incinerator"):
					put_in()
				else:
					drop_object()
					pass
			else:
				drop_object()

	if Input.is_action_just_pressed("throw"):
		if held_item != null:
			throw_object()
		else:
			if raycast.is_colliding():
				var obj = raycast.get_collider()
				if obj && obj is Node:
					if obj.is_in_group("Incinerator") || (obj.get_parent() && obj.get_parent().is_in_group("Incinerator")):
						toggle_door()
				
	if held_item != null:
		held_item.global_position = hold_point.global_position

	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity


	move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()

func try_pickup():
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		
		if obj is RigidBody3D:
			print_words(message_label1, "Press e to drop")
			print_words(message_label3, "Press f to throw")
			held_item = obj
			obj.freeze = true

func drop_object():
	held_item.freeze = false
	held_item = null

func throw_object():
	held_item.freeze = false
	var throw_direction = -$Marker3D.global_transform.basis.z
	throw_direction.y += .3
	throw_direction = throw_direction.normalized()
	held_item.linear_velocity = throw_direction * throw_speed
	
	held_item = null

func throw_away():
	if(held_item.is_in_group("trash") || held_item.get_parent().is_in_group("trash")):
		trash_can_capacity += 1 
		print_words(message_label2, "Trash thrown away. Current cap " + str(trash_can_capacity))
		held_item.queue_free()
		held_item = null

func put_in():
	if !incinerator_full:
		if incinerator_door_open:
			held_item.queue_free()
			held_item = null
			incinerator_full = true
			print_words(message_label2, "Deposited trash bag")
		else:
			print_words(message_label2, "Incinerator door closed! Open the door")
	else:
		print_words(message_label2, "Incinerator full")

func toggle_door():
	if incinerator_door_open:
		incinerator.close_door()
		incinerator_door_open = false
	else:
		incinerator.open_door()
		incinerator_door_open = true

func display_action(obj):
	if held_item == null:
		if obj is RigidBody3D || obj.get_parent() is RigidBody3D:
			print_words(message_label1, "Press e to pick up")
		elif obj.get_parent().is_in_group("trash_can") && trash_can_capacity >= 2:
			print_words(message_label1, "Press e to remove bag")
		elif (obj.get_parent().is_in_group("Incinerator") || obj.is_in_group("Incinerator")):
			if incinerator_full:
				print_words(message_label1, "Press e to use incerator")
			if incinerator_door_open:
				print_words(message_label3, "Press f to close door")
			else:
				print_words(message_label3, "Press f to open door")

func print_words(label, text):
	
	label.text = text
	await get_tree().create_timer(3.0).timeout
	label.text = ""

## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
