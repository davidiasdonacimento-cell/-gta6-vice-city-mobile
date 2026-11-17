extends Node3D
class_name ViceCityMissionManager

var cash := 0
var current_index := 0
var status_text := ""
var marker_nodes: Array[Node3D] = []

var missions: Array[Dictionary] = [
	{
		"title": "Entrega na Marina",
		"detail": "Leve a encomenda até a orla",
		"position": Vector3(0.0, 0.0, 242.0),
		"reward": 350
	},
	{
		"title": "Pacote no Centro",
		"detail": "Atravesse a avenida até o centro",
		"position": Vector3(160.0, 0.0, 0.0),
		"reward": 500
	},
	{
		"title": "Entrega no Parque",
		"detail": "Finalize a rota no parque do bairro",
		"position": Vector3(-160.0, 0.0, 160.0),
		"reward": 650
	}
]

var _marker_material: StandardMaterial3D

func _ready() -> void:
	_marker_material = StandardMaterial3D.new()
	_marker_material.albedo_color = Color("#ffd166")
	_marker_material.emission_enabled = true
	_marker_material.emission = Color("#ffb52e")
	_marker_material.emission_energy_multiplier = 2.0
	_marker_material.roughness = 0.25
	for index in range(missions.size()):
		_create_marker(index)
	_update_status()

func _create_marker(index: int) -> void:
	var marker := Node3D.new()
	marker.name = "DeliveryMarker_%02d" % (index + 1)
	marker.position = missions[index]["position"]
	marker.visible = index == current_index
	add_child(marker)
	marker_nodes.append(marker)

	var ring := MeshInstance3D.new()
	ring.name = "MarkerRing"
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 2.55
	ring_mesh.outer_radius = 3.1
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 10
	ring.mesh = ring_mesh
	ring.material_override = _marker_material
	ring.position.y = 0.12
	marker.add_child(ring)

	var beacon := MeshInstance3D.new()
	beacon.name = "Beacon"
	var beacon_mesh := CylinderMesh.new()
	beacon_mesh.top_radius = 0.11
	beacon_mesh.bottom_radius = 0.36
	beacon_mesh.height = 2.8
	beacon_mesh.radial_segments = 16
	beacon.mesh = beacon_mesh
	beacon.material_override = _marker_material
	beacon.position.y = 1.45
	marker.add_child(beacon)

	var light := OmniLight3D.new()
	light.light_color = Color("#ffcc6b")
	light.light_energy = 0.8
	light.omni_range = 11.0
	light.position.y = 2.2
	marker.add_child(light)

	var area := Area3D.new()
	area.name = "DeliveryZone"
	area.collision_layer = 0
	area.collision_mask = 1
	var zone_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 9.0
	zone_shape.shape = sphere
	zone_shape.position.y = 1.4
	area.add_child(zone_shape)
	area.body_entered.connect(_on_delivery_zone_entered.bind(index))
	marker.add_child(area)

func _process(delta: float) -> void:
	if current_index >= marker_nodes.size():
		return
	var marker := marker_nodes[current_index]
	var ring := marker.get_node_or_null("MarkerRing") as MeshInstance3D
	if ring:
		ring.rotation.y += delta * 0.8
		var pulse := 1.0 + sin(float(Time.get_ticks_msec()) * 0.004) * 0.055
		ring.scale = Vector3.ONE * pulse

func _on_delivery_zone_entered(body: Node3D, mission_index: int) -> void:
	if mission_index != current_index:
		return
	var player := get_parent().get_node_or_null("Player")
	var car := get_parent().get_node_or_null("Car")
	if body != player and body != car:
		return
	_complete_current_mission()

func _complete_current_mission() -> void:
	if current_index >= missions.size():
		return
	var completed: Dictionary = missions[current_index]
	cash += int(completed["reward"])
	marker_nodes[current_index].visible = false
	current_index += 1
	_update_status()

	if current_index < missions.size():
		marker_nodes[current_index].visible = true

func _update_status() -> void:
	if current_index < missions.size():
		var mission: Dictionary = missions[current_index]
		status_text = "%s — %s" % [mission["title"], mission["detail"]]
	else:
		status_text = "Todas as entregas concluídas! Explore a cidade."

func has_active_mission() -> bool:
	return current_index < missions.size()

func get_current_target() -> Vector3:
	if current_index >= missions.size():
		return Vector3.ZERO
	return missions[current_index]["position"]

func get_cash() -> int:
	return cash

func get_mission_number() -> int:
	return mini(current_index + 1, missions.size())
