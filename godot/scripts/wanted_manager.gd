extends Node3D
class_name ViceCityWantedManager

const HEAT_LIMITS := [0.0, 12.0, 28.0, 48.0, 72.0, 100.0]
const MAX_HEAT := 120.0

var player: CharacterBody3D
var vehicle: Node3D
var wanted_level := 0
var heat := 0.0
var police_units: Array[Node3D] = []
var status_text := "Cidade tranquila"

func _ready() -> void:
	player = get_parent().get_node_or_null("Player") as CharacterBody3D
	vehicle = get_parent().get_node_or_null("Car")
	_update_wanted_level()

func _process(delta: float) -> void:
	if player == null or vehicle == null:
		return
	var driving := bool(vehicle.get("is_driving"))
	var speed := (vehicle as VehicleBody3D).linear_velocity.length() if driving else player.velocity.length()
	if driving and speed > 25.0:
		heat = minf(MAX_HEAT, heat + (speed - 23.0) * 0.42 * delta)
	else:
		heat = maxf(0.0, heat - (2.2 if wanted_level > 0 else 5.0) * delta)
	_update_wanted_level()
	_update_police(delta)

func _update_wanted_level() -> void:
	var next_level := 0
	for index in range(1, HEAT_LIMITS.size()):
		if heat >= float(HEAT_LIMITS[index]):
			next_level = index
	wanted_level = next_level
	status_text = "Cidade tranquila" if wanted_level == 0 else "Polícia em perseguição"
	_sync_police_count()

func _sync_police_count() -> void:
	var desired := 0 if wanted_level == 0 else mini(3, ceili(float(wanted_level) / 2.0))
	while police_units.size() < desired:
		var unit := _create_police_unit()
		police_units.append(unit)
		add_child(unit)
	while police_units.size() > desired:
		var unit: Node3D = police_units.pop_back()
		unit.queue_free()

func _create_police_unit() -> Node3D:
	var unit := Node3D.new()
	unit.name = "PolicePatrolUnit"
	unit.set_meta("patrol_speed", 11.0)
	unit.set_meta("phase", randf() * TAU)

	var body := MeshInstance3D.new()
	body.name = "PatrolSedanBody"
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.67
	body_mesh.height = 3.8
	body.mesh = body_mesh
	body.rotation.x = PI * 0.5
	body.position.y = 0.62
	body.material_override = _mat(Color("#e8e8e0"), 0.42, 0.18)
	unit.add_child(body)

	var cabin := MeshInstance3D.new()
	var cabin_mesh := CapsuleMesh.new()
	cabin_mesh.radius = 0.48
	cabin_mesh.height = 2.0
	cabin.mesh = cabin_mesh
	cabin.rotation.x = PI * 0.5
	cabin.position = Vector3(0.0, 1.12, 0.0)
	cabin.material_override = _mat(Color("#183c50"), 0.18, 0.2)
	unit.add_child(cabin)

	var stripe := MeshInstance3D.new()
	var stripe_mesh := CylinderMesh.new()
	stripe_mesh.top_radius = 0.69
	stripe_mesh.bottom_radius = 0.69
	stripe_mesh.height = 0.12
	stripe_mesh.radial_segments = 24
	stripe.mesh = stripe_mesh
	stripe.rotation.x = PI * 0.5
	stripe.position.y = 0.72
	stripe.material_override = _mat(Color("#1c4162"), 0.45, 0.15)
	unit.add_child(stripe)

	for side in [-1.0, 1.0]:
		var beacon := MeshInstance3D.new()
		var beacon_mesh := SphereMesh.new()
		beacon_mesh.radius = 0.16
		beacon_mesh.height = 0.22
		beacon.mesh = beacon_mesh
		beacon.position = Vector3(side * 0.25, 1.62, 0.0)
		beacon.material_override = _mat(Color("#2688ff") if side < 0.0 else Color("#ff3d4f"), 0.22, 0.1)
		unit.add_child(beacon)

	return unit

func _mat(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	material.emission_enabled = true if color.r > 0.8 and color.b < 0.4 else false
	if material.emission_enabled:
		material.emission = color
		material.emission_energy_multiplier = 0.45
	return material

func _update_police(delta: float) -> void:
	if wanted_level == 0 or player == null:
		return
	var target: Node3D = vehicle if bool(vehicle.get("is_driving")) else player
	for index in range(police_units.size()):
		var unit := police_units[index]
		if unit == null:
			continue
		var phase := float(unit.get_meta("phase")) + delta * (8.0 + wanted_level)
		unit.set_meta("phase", phase)
		var orbit := Vector3(cos(float(index) * 2.1 + phase * 0.08), 0.0, sin(float(index) * 2.1 + phase * 0.08))
		var desired_position := target.global_position + orbit * (22.0 + float(index) * 8.0)
		desired_position.y = 0.15
		var patrol_speed := 10.0 + float(wanted_level) * 2.4
		unit.global_position = unit.global_position.move_toward(desired_position, patrol_speed * delta)
		var look_target := target.global_position
		look_target.y = unit.global_position.y
		if unit.global_position.distance_to(look_target) > 0.5:
			unit.look_at(look_target, Vector3.UP)
		var pulse := 0.5 + 0.5 * sin(phase * 2.0)
		for beacon in unit.get_children():
			if beacon is MeshInstance3D and beacon.mesh is SphereMesh:
				beacon.scale = Vector3.ONE * (0.82 + pulse * 0.28)

func add_heat(amount: float) -> void:
	heat = clampf(heat + maxf(0.0, amount), 0.0, MAX_HEAT)
	_update_wanted_level()

func get_wanted_level() -> int:
	return wanted_level

func get_stars_text() -> String:
	if wanted_level == 0:
		return "PROCURADO  —"
	return "PROCURADO  " + "★".repeat(wanted_level) + "☆".repeat(5 - wanted_level)

func get_status_text() -> String:
	return status_text
