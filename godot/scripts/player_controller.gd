extends CharacterBody3D

@export var walk_speed := 5.2
@export var run_speed := 8.4
@export var acceleration := 18.0
@export var gravity := 20.0
var mobile_direction := Vector2.ZERO
var camera_pivot: Node3D

func _ready() -> void:
	camera_pivot = get_node_or_null("CameraPivot")

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if mobile_direction.length() > 0.08:
		input = mobile_direction
	var basis := camera_pivot.global_basis if camera_pivot else global_basis
	var forward := -basis.z
	var right := basis.x
	var direction := (right * input.x + forward * -input.y)
	direction.y = 0
	direction = direction.normalized()
	var target_speed := run_speed if Input.is_action_pressed("run") else walk_speed
	velocity.x = move_toward(velocity.x, direction.x * target_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * target_speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
	if direction.length() > 0.05:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 10.0)
	move_and_slide()
