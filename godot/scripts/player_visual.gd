extends Node3D
class_name ViceCityPlayerVisual

var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var torso: MeshInstance3D
var animation_time := 0.0
var blend := 0.0

func _ready() -> void:
	_build_character()

func _material(color: Color, roughness: float = 0.82) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	return result

func _capsule(parent: Node3D, radius: float, height: float, material: Material, position: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var shape := CapsuleMesh.new()
	shape.radius = radius
	shape.height = height
	instance.mesh = shape
	instance.material_override = material
	instance.position = position
	parent.add_child(instance)
	return instance

func _sphere(parent: Node3D, radius: float, material: Material, position: Vector3, scale_value: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2.0
	instance.mesh = shape
	instance.material_override = material
	instance.position = position
	instance.scale = scale_value
	parent.add_child(instance)
	return instance

func _build_character() -> void:
	var skin := _material(Color("#b97957"))
	var jacket := _material(Color("#1b4960"))
	var jacket_light := _material(Color("#2e7890"))
	var trousers := _material(Color("#263748"))
	var shoes := _material(Color("#151d25"))
	var hair := _material(Color("#171b20"))
	var eyes := _material(Color("#171b20"), 0.35)

	torso = _capsule(self, 0.29, 0.94, jacket, Vector3(0.0, 1.12, 0.0))
	_sphere(self, 0.10, jacket_light, Vector3(0.0, 1.28, -0.255), Vector3(1.0, 0.38, 0.30))
	_capsule(self, 0.085, 0.22, skin, Vector3(0.0, 1.68, 0.0))
	_sphere(self, 0.205, skin, Vector3(0.0, 1.83, 0.0), Vector3(0.93, 1.05, 0.91))
	_sphere(self, 0.19, hair, Vector3(0.0, 1.96, 0.015), Vector3(1.0, 0.55, 1.0))
	_sphere(self, 0.027, eyes, Vector3(-0.075, 1.84, -0.183))
	_sphere(self, 0.027, eyes, Vector3(0.075, 1.84, -0.183))
	_sphere(self, 0.026, skin, Vector3(0.0, 1.78, -0.205), Vector3(0.75, 0.8, 0.65))

	var belt := MeshInstance3D.new()
	var belt_mesh := CylinderMesh.new()
	belt_mesh.top_radius = 0.255
	belt_mesh.bottom_radius = 0.255
	belt_mesh.height = 0.085
	belt_mesh.radial_segments = 20
	belt.mesh = belt_mesh
	belt.material_override = shoes
	belt.position.y = 0.79
	add_child(belt)

	left_arm = Node3D.new()
	left_arm.position = Vector3(-0.34, 1.43, 0.0)
	add_child(left_arm)
	_capsule(left_arm, 0.105, 0.73, jacket, Vector3(0.0, -0.30, 0.0))
	_sphere(left_arm, 0.095, skin, Vector3(0.0, -0.68, -0.015))

	right_arm = Node3D.new()
	right_arm.position = Vector3(0.34, 1.43, 0.0)
	add_child(right_arm)
	_capsule(right_arm, 0.105, 0.73, jacket, Vector3(0.0, -0.30, 0.0))
	_sphere(right_arm, 0.095, skin, Vector3(0.0, -0.68, -0.015))

	left_leg = Node3D.new()
	left_leg.position = Vector3(-0.155, 0.77, 0.0)
	add_child(left_leg)
	_capsule(left_leg, 0.135, 0.80, trousers, Vector3(0.0, -0.32, 0.0))
	_sphere(left_leg, 0.14, shoes, Vector3(0.0, -0.70, -0.085), Vector3(1.0, 0.72, 1.45))

	right_leg = Node3D.new()
	right_leg.position = Vector3(0.155, 0.77, 0.0)
	add_child(right_leg)
	_capsule(right_leg, 0.135, 0.80, trousers, Vector3(0.0, -0.32, 0.0))
	_sphere(right_leg, 0.14, shoes, Vector3(0.0, -0.70, -0.085), Vector3(1.0, 0.72, 1.45))

func _process(delta: float) -> void:
	var actor := get_parent() as CharacterBody3D
	if actor == null:
		return
	var horizontal_speed := Vector2(actor.velocity.x, actor.velocity.z).length()
	var target_blend := clampf(horizontal_speed / 3.2, 0.0, 1.0)
	blend = move_toward(blend, target_blend, delta * 7.0)
	animation_time += delta * lerpf(3.2, 9.0, clampf(horizontal_speed / 8.0, 0.0, 1.0))
	var swing := sin(animation_time) * 0.72 * blend
	left_leg.rotation.x = swing
	right_leg.rotation.x = -swing
	left_arm.rotation.x = -swing * 0.68
	right_arm.rotation.x = swing * 0.68
	torso.position.y = 1.12 + sin(animation_time * 2.0) * 0.025 * blend
