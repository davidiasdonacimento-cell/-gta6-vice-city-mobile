extends CharacterBody3D

@export var walk_speed: float = 5.2
@export var run_speed: float = 8.4
@export var acceleration: float = 18.0
@export var gravity: float = 20.0

var mobile_direction := Vector2.ZERO
var camera_pivot: Node3D

func _ready() -> void:
	camera_pivot = get_node_or_null("CameraPivot")

func _physics_process(delta: float) -> void:
	if camera_pivot == null:
		camera_pivot = get_node_or_null("CameraPivot")

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if mobile_direction.length() > 0.08:
		input_vector = mobile_direction

	var reference_basis: Basis = camera_pivot.global_basis if camera_pivot else global_basis
	var forward := -reference_basis.z
	var right := reference_basis.x
	var direction := right * input_vector.x - forward * input_vector.y
	direction.y = 0.0
	direction = direction.normalized()

	var target_speed := run_speed if Input.is_action_pressed("run") else walk_speed
	var target_velocity := direction * target_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.05

	if direction.length() > 0.05:
		var target_yaw := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, minf(1.0, delta * 10.0))

	move_and_slide()
