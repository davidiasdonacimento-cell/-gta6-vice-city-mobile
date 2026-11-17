extends Node3D
class_name ViceCityPedestrianManager

const PEDESTRIAN_COUNT := 14
const WALK_SPEED := 1.15
var pedestrians: Array[Node3D] = []
var routes: Array[PackedVector3Array] = []
var route_indices: Array[int] = []

func _ready() -> void:
	_build_routes()
	_spawn_pedestrians()

func _build_routes() -> void:
	for route_index in range(11):
		var road := float(route_index - 5) * 80.0
		var route := PackedVector3Array([
			Vector3(-545.0, 0.0, road + 14.0),
			Vector3(545.0, 0.0, road + 14.0),
			Vector3(545.0, 0.0, road - 14.0),
			Vector3(-545.0, 0.0, road - 14.0)
		])
		routes.append(route)

func _spawn_pedestrians() -> void:
	var palette: Array[Color] = [Color("#e5a36f"), Color("#4d8f91"), Color("#b86c6b"), Color("#d6c9a5"), Color("#667a9a"), Color("#c9a2d1")]
	for index in range(PEDESTRIAN_COUNT):
		var person := Node3D.new()
		person.name = "Pedestrian_%02d" % index
		var route_index := index % routes.size()
		var point_index := (index * 2) % routes[route_index].size()
		person.position = routes[route_index][point_index]
		person.set_meta("route_index", route_index)
		person.set_meta("point_index", point_index)
		person.set_meta("walk_speed", WALK_SPEED + float(index % 4) * 0.12)
		_build_person_visual(person, palette[index % palette.size()])
		add_child(person)
		pedestrians.append(person)

func _build_person_visual(person: Node3D, shirt_color: Color) -> void:
	var shirt := StandardMaterial3D.new()
	shirt.albedo_color = shirt_color
	shirt.roughness = 0.88
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.27
	torso_mesh.height = 0.92
	torso.mesh = torso_mesh
	torso.position.y = 1.05
	torso.material_override = shirt
	person.add_child(torso)
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color("#c78f6d")
	skin.roughness = 0.92
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.22
	head_mesh.height = 0.42
	head.mesh = head_mesh
	head.position.y = 1.72
	head.material_override = skin
	person.add_child(head)
	var legs_material := StandardMaterial3D.new()
	legs_material.albedo_color = Color("#263a4a")
	var legs := MeshInstance3D.new()
	var legs_mesh := CapsuleMesh.new()
	legs_mesh.radius = 0.12
	legs_mesh.height = 0.76
	legs.mesh = legs_mesh
	legs.position = Vector3(0.0, 0.42, 0.0)
	legs.material_override = legs_material
	person.add_child(legs)

func _process(delta: float) -> void:
	for person in pedestrians:
		if person == null:
			continue
		var route_index := int(person.get_meta("route_index"))
		var point_index := int(person.get_meta("point_index"))
		var route: PackedVector3Array = routes[route_index]
		var target := route[point_index]
		var speed := float(person.get_meta("walk_speed"))
		person.position = person.position.move_toward(target, speed * delta)
		var direction := target - person.position
		if direction.length() > 0.1:
			person.look_at(person.position + direction, Vector3.UP)
		if person.position.distance_to(target) < 0.8:
			point_index = (point_index + 1) % route.size()
			person.set_meta("point_index", point_index)
