extends CharacterBody3D
class_name ViceCityTrafficCar

var travel_axis := Vector3.RIGHT
var travel_sign := 1.0
var travel_speed := 10.0
var lane_coordinate := 0.0
var world_limit := 270.0
var impact_cooldown := 0.0

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.85, 0.8, 4.0)
	collision.shape = shape
	collision.position.y = 0.55
	add_child(collision)
	_build_visual()
	var impact := Area3D.new()
	impact.collision_layer = 0
	impact.collision_mask = 1
	var impact_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.4, 1.8, 4.8)
	impact_shape.shape = box
	impact_shape.position.y = 0.65
	impact.add_child(impact_shape)
	impact.body_entered.connect(_on_impact)
	add_child(impact)

func _build_visual() -> void:
	var palette: Array[Color] = [Color("#d9b66c"), Color("#4c8790"), Color("#b85c4e"), Color("#d8d5ca"), Color("#607d67")]
	var paint := StandardMaterial3D.new()
	paint.albedo_color = palette[randi() % palette.size()]
	paint.roughness = 0.34
	paint.metallic = 0.28
	var body := MeshInstance3D.new()
	var hull := CapsuleMesh.new()
	hull.radius = 0.68
	hull.height = 3.8
	body.mesh = hull
	body.rotation.x = PI * 0.5
	body.position.y = 0.62
	body.material_override = paint
	add_child(body)
	var cabin := MeshInstance3D.new()
	var glass := CapsuleMesh.new()
	glass.radius = 0.48
	glass.height = 1.95
	cabin.mesh = glass
	cabin.rotation.x = PI * 0.5
	cabin.position.y = 1.12
	var glass_material := StandardMaterial3D.new()
	glass_material.albedo_color = Color("#1b4656")
	glass_material.metallic = 0.18
	glass_material.roughness = 0.16
	cabin.material_override = glass_material
	add_child(cabin)
	for side in [-1.0, 1.0]:
		for front in [-1.0, 1.0]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := SphereMesh.new()
			wheel_mesh.radius = 0.34
			wheel_mesh.height = 0.68
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(side * 0.77, 0.36, front * 1.25)
			wheel.material_override = _mat(Color("#11191e"))
			add_child(wheel)

func _mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	return material

func _physics_process(_delta: float) -> void:
	velocity = travel_axis * travel_speed * travel_sign
	move_and_slide()
	if travel_axis.x != 0.0:
		if global_position.x > world_limit:
			global_position.x = -world_limit
		elif global_position.x < -world_limit:
			global_position.x = world_limit
	else:
		if global_position.z > world_limit:
			global_position.z = -world_limit
		elif global_position.z < -world_limit:
			global_position.z = world_limit

func _on_impact(body: Node3D) -> void:
	if impact_cooldown > 0.0:
		return
	if body.name != "Player" and body.name != "Car":
		return
	impact_cooldown = 2.0
	var wanted := get_tree().current_scene.get_node_or_null("WantedManager")
	if wanted != null:
		wanted.call("add_heat", 14.0)

func _process(delta: float) -> void:
	impact_cooldown = maxf(0.0, impact_cooldown - delta)
