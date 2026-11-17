extends VehicleBody3D
class_name ViceCityCar

@export var engine_power: float = 1450.0
@export var reverse_power: float = 650.0
@export var brake_power: float = 34.0
@export var max_steering: float = 0.48

var is_driving := false
var mobile_input := Vector2.ZERO
var mobile_brake := false
var driver: CharacterBody3D

var _body_material: StandardMaterial3D
var _glass_material: StandardMaterial3D
var _rubber_material: StandardMaterial3D
var _rim_material: StandardMaterial3D
var _light_material: StandardMaterial3D

func _ready() -> void:
	mass = 1120.0
	linear_damp = 0.16
	angular_damp = 1.25
	center_of_mass = Vector3(0.0, -0.28, 0.0)
	_body_material = _mat(Color("#c95c43"), 0.32, 0.42)
	_glass_material = _mat(Color("#173b4a"), 0.16, 0.18)
	_rubber_material = _mat(Color("#121a20"), 0.96)
	_rim_material = _mat(Color("#b8c4c5"), 0.28, 0.78)
	_light_material = _mat(Color("#ffe3b5"), 0.3, 0.0)
	_build_collision()
	_build_car_body()
	_build_wheels()

func _mat(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

func _build_collision() -> void:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 0.68, 4.35)
	collision.shape = shape
	collision.position = Vector3(0.0, 0.22, 0.0)
	add_child(collision)

func _box(parent: Node3D, dimensions: Vector3, position: Vector3, material: Material, bevel: float = 0.0) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	instance.mesh = mesh
	instance.material_override = material
	instance.position = position
	parent.add_child(instance)

func _add_loft_hull(parent: Node3D, node_name: String, sections: Array, material: Material) -> void:
	var loops: Array[PackedVector3Array] = []
	for section in sections:
		var z := float(section["z"])
		var bottom := float(section["bottom"])
		var middle := float(section["middle"])
		var top := float(section["top"])
		var bottom_y := float(section["bottom_y"])
		var middle_y := float(section["middle_y"])
		var top_y := float(section["top_y"])
		loops.append(PackedVector3Array([
			Vector3(-bottom, bottom_y, z),
			Vector3(-middle, middle_y, z),
			Vector3(-top, top_y, z),
			Vector3(top, top_y, z),
			Vector3(middle, middle_y, z),
			Vector3(bottom, bottom_y, z)
		]))

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for section_index in range(loops.size() - 1):
		var current := loops[section_index]
		var next_section := loops[section_index + 1]
		for point_index in range(current.size()):
			var next_point := (point_index + 1) % current.size()
			var a := current[point_index]
			var b := current[next_point]
			var c := next_section[next_point]
			var d := next_section[point_index]
			surface.add_vertex(a)
			surface.add_vertex(c)
			surface.add_vertex(b)
			surface.add_vertex(a)
			surface.add_vertex(d)
			surface.add_vertex(c)

	for endpoint in [0, loops.size() - 1]:
		var section := loops[endpoint]
		var center_y := 0.0
		for point in section:
			center_y += point.y
		center_y /= float(section.size())
		var center := Vector3(0.0, center_y, section[0].z)
		for point_index in range(section.size()):
			var next_point := (point_index + 1) % section.size()
			if endpoint == 0:
				surface.add_vertex(center)
				surface.add_vertex(section[next_point])
				surface.add_vertex(section[point_index])
			else:
				surface.add_vertex(center)
				surface.add_vertex(section[point_index])
				surface.add_vertex(section[next_point])
	surface.generate_normals()

	var hull := MeshInstance3D.new()
	hull.name = node_name
	hull.mesh = surface.commit()
	hull.material_override = material
	parent.add_child(hull)

func _build_car_body() -> void:
	var body_sections := [
		{"z": -2.18, "bottom": 0.73, "middle": 0.82, "top": 0.74, "bottom_y": 0.12, "middle_y": 0.27, "top_y": 0.43},
		{"z": -1.48, "bottom": 0.91, "middle": 0.88, "top": 0.69, "bottom_y": 0.10, "middle_y": 0.39, "top_y": 0.62},
		{"z": -0.52, "bottom": 0.96, "middle": 0.88, "top": 0.67, "bottom_y": 0.10, "middle_y": 0.43, "top_y": 0.65},
		{"z": 0.78, "bottom": 0.94, "middle": 0.86, "top": 0.66, "bottom_y": 0.10, "middle_y": 0.40, "top_y": 0.60},
		{"z": 1.66, "bottom": 0.83, "middle": 0.79, "top": 0.68, "bottom_y": 0.12, "middle_y": 0.30, "top_y": 0.46},
		{"z": 2.16, "bottom": 0.72, "middle": 0.74, "top": 0.68, "bottom_y": 0.15, "middle_y": 0.22, "top_y": 0.32}
	]
	_add_loft_hull(self, "CurvedBody", body_sections, _body_material)

	var cabin_sections := [
		{"z": -1.18, "bottom": 0.69, "middle": 0.57, "top": 0.44, "bottom_y": 0.56, "middle_y": 0.84, "top_y": 1.13},
		{"z": -0.62, "bottom": 0.73, "middle": 0.67, "top": 0.57, "bottom_y": 0.58, "middle_y": 0.98, "top_y": 1.34},
		{"z": 0.48, "bottom": 0.71, "middle": 0.64, "top": 0.54, "bottom_y": 0.58, "middle_y": 0.97, "top_y": 1.33},
		{"z": 1.19, "bottom": 0.64, "middle": 0.55, "top": 0.43, "bottom_y": 0.53, "middle_y": 0.81, "top_y": 1.08}
	]
	_add_loft_hull(self, "PanoramicGlassCabin", cabin_sections, _glass_material)

	var roof_material := _mat(Color("#a94336"), 0.38, 0.28)
	var roof_sections := [
		{"z": -0.72, "bottom": 0.55, "middle": 0.56, "top": 0.55, "bottom_y": 1.25, "middle_y": 1.31, "top_y": 1.34},
		{"z": 0.56, "bottom": 0.53, "middle": 0.55, "top": 0.53, "bottom_y": 1.24, "middle_y": 1.31, "top_y": 1.34}
	]
	_add_loft_hull(self, "RoofPanel", roof_sections, roof_material)

	var headlight_material := _mat(Color("#f6dfaa"), 0.22, 0.0)
	headlight_material.emission_enabled = true
	headlight_material.emission = Color("#f6d78f")
	headlight_material.emission_energy_multiplier = 0.4
	for side in [-1.0, 1.0]:
		var headlight := MeshInstance3D.new()
		var headlight_mesh := SphereMesh.new()
		headlight_mesh.radius = 0.17
		headlight_mesh.height = 0.12
		headlight.mesh = headlight_mesh
		headlight.material_override = headlight_material
		headlight.position = Vector3(side * 0.65, 0.38, -2.13)
		add_child(headlight)

	var taillight_material := _mat(Color("#b72d31"), 0.36, 0.0)
	for side in [-1.0, 1.0]:
		var taillight := MeshInstance3D.new()
		var taillight_mesh := BoxMesh.new()
		taillight_mesh.size = Vector3(0.36, 0.13, 0.06)
		taillight.mesh = taillight_mesh
		taillight.material_override = taillight_material
		taillight.position = Vector3(side * 0.63, 0.39, 2.17)
		add_child(taillight)

	var bumper := _mat(Color("#343f46"), 0.54, 0.5)
	_box(self, Vector3(1.78, 0.13, 0.12), Vector3(0.0, 0.18, -2.20), bumper)
	_box(self, Vector3(1.78, 0.13, 0.12), Vector3(0.0, 0.18, 2.20), bumper)
	var grille := _mat(Color("#1b2b32"), 0.48, 0.38)
	_box(self, Vector3(0.72, 0.18, 0.035), Vector3(0.0, 0.31, -2.19), grille)

func _build_wheels() -> void:
	for front in [true, false]:
		for side in [-1.0, 1.0]:
			var wheel := VehicleWheel3D.new()
			wheel.name = ("Front" if front else "Rear") + ("Left" if side < 0.0 else "Right")
			wheel.position = Vector3(side * 0.94, 0.0, -1.42 if front else 1.42)
			wheel.wheel_radius = 0.42
			wheel.wheel_rest_length = 0.16
			wheel.suspension_travel = 0.18
			wheel.suspension_stiffness = 26.0
			wheel.damping_compression = 0.55
			wheel.damping_relaxation = 0.82
			wheel.wheel_friction_slip = 2.2
			wheel.wheel_roll_influence = 0.12
			wheel.use_as_steering = front
			wheel.use_as_traction = not front
			add_child(wheel)

			var tire := MeshInstance3D.new()
			var tire_mesh := CylinderMesh.new()
			tire_mesh.top_radius = 0.40
			tire_mesh.bottom_radius = 0.40
			tire_mesh.height = 0.22
			tire_mesh.radial_segments = 20
			tire.mesh = tire_mesh
			tire.material_override = _rubber_material
			tire.rotation_degrees.z = 90.0
			wheel.add_child(tire)

			var rim := MeshInstance3D.new()
			var rim_mesh := CylinderMesh.new()
			rim_mesh.top_radius = 0.22
			rim_mesh.bottom_radius = 0.22
			rim_mesh.height = 0.235
			rim_mesh.radial_segments = 16
			rim.mesh = rim_mesh
			rim.material_override = _rim_material
			rim.rotation_degrees.z = 90.0
			wheel.add_child(rim)

func enter_vehicle(actor: CharacterBody3D) -> void:
	if is_driving or actor == null:
		return
	driver = actor
	is_driving = true
	mobile_input = Vector2.ZERO
	mobile_brake = false
	driver.set("mobile_direction", Vector2.ZERO)
	driver.set_physics_process(false)
	var driver_collision := driver.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if driver_collision:
		driver_collision.set_deferred("disabled", true)
	var visual := driver.get_node_or_null("Visual")
	if visual:
		visual.visible = false

func exit_vehicle() -> void:
	if not is_driving or driver == null:
		return
	is_driving = false
	engine_force = 0.0
	brake = brake_power
	var exit_position := global_position + global_basis.x * 2.1 + Vector3(0.0, 0.25, 0.0)
	driver.global_position = exit_position
	driver.global_rotation.y = global_rotation.y
	driver.velocity = linear_velocity * 0.25
	driver.set_physics_process(true)
	var driver_collision := driver.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if driver_collision:
		driver_collision.set_deferred("disabled", false)
	var visual := driver.get_node_or_null("Visual")
	if visual:
		visual.visible = true
		visual.rotation = Vector3.ZERO
	driver.set("mobile_direction", Vector2.ZERO)
	driver = null
	mobile_input = Vector2.ZERO
	mobile_brake = false

func _physics_process(_delta: float) -> void:
	if not is_driving or driver == null:
		engine_force = 0.0
		brake = 22.0
		steering = move_toward(steering, 0.0, 0.06)
		return

	var throttle := -mobile_input.y
	var steer_input := mobile_input.x
	if absf(throttle) < 0.08:
		throttle = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	if absf(steer_input) < 0.08:
		steer_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if throttle >= 0.0:
		engine_force = throttle * engine_power
	else:
		engine_force = throttle * reverse_power
	brake = brake_power if mobile_brake or Input.is_action_pressed("vehicle_brake") else 0.0
	steering = move_toward(steering, steer_input * max_steering, 0.07)

	driver.global_position = global_position + Vector3(0.0, 0.82, 0.0)
	driver.global_rotation.y = global_rotation.y
