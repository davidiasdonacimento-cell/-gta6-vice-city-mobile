extends Node3D
class_name ViceCityDistrictBuilder

const CITY_SPAN := 560.0
const ROAD_WIDTH := 18.0
const ROAD_STEP := 80.0

var rng := RandomNumberGenerator.new()
var asphalt: StandardMaterial3D
var sidewalk: StandardMaterial3D
var lane_paint: StandardMaterial3D
var glass_material: StandardMaterial3D
var palm_material: StandardMaterial3D
var trunk_material: StandardMaterial3D
var lamp_material: StandardMaterial3D
var imported_tree_models: Array[Node] = []
var imported_bush_model: Node

func _ready() -> void:
	rng.seed = 24681357
	_create_materials()
	build_city()

func _create_materials() -> void:
	asphalt = _mat(Color("#283b46"), 0.96)
	sidewalk = _mat(Color("#c6b9a3"), 0.92)
	lane_paint = _mat(Color("#e8d7a9"), 0.72)
	glass_material = _mat(Color("#244f60"), 0.24, 0.24)
	palm_material = _mat(Color("#367957"), 0.92)
	trunk_material = _mat(Color("#866044"), 0.98)
	lamp_material = _mat(Color("#f7d89a"), 0.32, 0.1)
	lamp_material.emission_enabled = true
	lamp_material.emission = Color("#f6c875")
	lamp_material.emission_energy_multiplier = 0.7

func _mat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material

func build_city() -> void:
	_build_island_and_ocean()
	_build_roads()
	_build_city_blocks()
	_build_waterfront()
	_build_street_furniture()
	_build_palms()
	_build_asset_parks()

func _build_island_and_ocean() -> void:
	var island := MeshInstance3D.new()
	island.name = "CoastalLand"
	var land_mesh := PlaneMesh.new()
	land_mesh.size = Vector2(CITY_SPAN + 80.0, CITY_SPAN + 80.0)
	island.mesh = land_mesh
	island.position.y = -0.55
	island.material_override = _mat(Color("#927f67"), 1.0)
	add_child(island)

	var ocean := MeshInstance3D.new()
	ocean.name = "Ocean"
	var water_mesh := PlaneMesh.new()
	water_mesh.size = Vector2(2600.0, 2600.0)
	ocean.mesh = water_mesh
	ocean.position.y = -0.72
	var water := _mat(Color("#08728a"), 0.2, 0.22)
	ocean.material_override = water
	add_child(ocean)

	var ground_body := StaticBody3D.new()
	ground_body.name = "GroundCollision"
	var ground_shape := CollisionShape3D.new()
	var ground_box := BoxShape3D.new()
	ground_box.size = Vector3(CITY_SPAN + 80.0, 0.5, CITY_SPAN + 80.0)
	ground_shape.shape = ground_box
	ground_shape.position.y = -0.52
	ground_body.add_child(ground_shape)
	add_child(ground_body)

func _build_roads() -> void:
	for road_index in range(-3, 4):
		var coordinate := float(road_index) * ROAD_STEP
		_add_plane("Road_EW_%s" % road_index, Vector2(CITY_SPAN, ROAD_WIDTH), Vector3(0, -0.27, coordinate), asphalt)
		_add_plane("Road_NS_%s" % road_index, Vector2(ROAD_WIDTH, CITY_SPAN), Vector3(coordinate, -0.265, 0), asphalt)

		for side in [-1.0, 1.0]:
			var verge := side * (ROAD_WIDTH * 0.5 + 2.2)
			_add_plane("Sidewalk_EW", Vector2(CITY_SPAN, 4.4), Vector3(0, -0.20, coordinate + verge), sidewalk)
			_add_plane("Sidewalk_NS", Vector2(4.4, CITY_SPAN), Vector3(coordinate + verge, -0.20, 0), sidewalk)

		for dash_index in range(0, 10):
			var dash_x := -CITY_SPAN * 0.5 + 12.0 + float(dash_index) * 56.0
			_add_plane("LaneDash_EW", Vector2(10.0, 0.20), Vector3(dash_x, -0.245, coordinate), lane_paint)
			var dash_z := -CITY_SPAN * 0.5 + 12.0 + float(dash_index) * 56.0
			_add_plane("LaneDash_NS", Vector2(0.20, 10.0), Vector3(coordinate, -0.24, dash_z), lane_paint)

	_add_plane("MainBoulevard_Median", Vector2(CITY_SPAN, 1.2), Vector3(0, -0.235, 0), _mat(Color("#d4be88"), 0.8))
	_add_plane("CentralBoulevard_Median", Vector2(1.2, CITY_SPAN), Vector3(0, -0.235, 0), _mat(Color("#d4be88"), 0.8))

func _add_plane(node_name: String, dimensions: Vector2, location: Vector3, material: Material) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := PlaneMesh.new()
	mesh.size = dimensions
	instance.mesh = mesh
	instance.position = location
	instance.material_override = material
	add_child(instance)

func _build_city_blocks() -> void:
	var facades: Array[Color] = [
		Color("#d7a27e"),
		Color("#e7c99b"),
		Color("#c7b4a0"),
		Color("#e0b8a4"),
		Color("#a9c5bd"),
		Color("#e1d2b7"),
		Color("#c49a82")
	]
	for block_x in range(6):
		for block_z in range(6):
			var center_x := -200.0 + float(block_x) * ROAD_STEP
			var center_z := -200.0 + float(block_z) * ROAD_STEP
			if (block_x + block_z) % 6 == 0:
				continue
			var count := 2 if block_x in [2, 3] and block_z in [2, 3] else 1
			for slot in range(count):
				var offset_x := -13.5 if slot == 0 and count == 2 else (13.5 if count == 2 else 0.0)
				var offset_z := rng.randf_range(-8.0, 8.0)
				var radius := rng.randf_range(7.5, 11.5)
				var height := rng.randf_range(20.0, 60.0)
				if block_x in [2, 3] and block_z in [2, 3]:
					height += rng.randf_range(8.0, 24.0)
				var facade: Color = facades[rng.randi_range(0, facades.size() - 1)]
				_create_tower(Vector3(center_x + offset_x, 0.0, center_z + offset_z), radius, height, facade, rng.randi_range(0, 3))

func _create_tower(location: Vector3, radius: float, height: float, facade_color: Color, style: int) -> void:
	var tower := StaticBody3D.new()
	tower.name = "ArtDecoTower"
	tower.position = Vector3(location.x, height * 0.5 - 0.27, location.z)
	add_child(tower)

	var collision := CollisionShape3D.new()
	var collision_shape := CylinderShape3D.new()
	collision_shape.radius = radius * 1.18
	collision_shape.height = height
	collision.shape = collision_shape
	tower.add_child(collision)

	var facade := _mat(facade_color, 0.82)
	var trim := _mat(facade_color.lightened(0.16), 0.66)
	var dark_glass := _mat(Color("#17495b"), 0.2, 0.28)

	_add_cylinder(tower, radius * 1.15, radius * 1.10, 3.6, facade, -height * 0.5 + 1.8, 40)
	_add_cylinder(tower, radius, radius * (0.84 if style == 1 else 0.94), height - 6.0, facade, 0.5, 40)
	_add_cylinder(tower, radius * 0.82, radius * 0.76, height * 0.62, dark_glass, 0.9, 40)

	var floors := clampi(int(height / 10.0), 3, 6)
	for floor_index in range(floors):
		var y := -height * 0.27 + float(floor_index) * (height * 0.54 / maxf(1.0, float(floors - 1)))
		_add_cylinder(tower, radius * 0.94, radius * 0.94, 0.18, trim, y, 40)

	for fin_index in range(6):
		var angle := TAU * float(fin_index) / 6.0
		var fin := MeshInstance3D.new()
		var fin_mesh := CylinderMesh.new()
		fin_mesh.top_radius = 0.16
		fin_mesh.bottom_radius = 0.22
		fin_mesh.height = height * 0.72
		fin_mesh.radial_segments = 8
		fin.mesh = fin_mesh
		fin.material_override = trim
		fin.position = Vector3(cos(angle) * radius * 0.96, 0.4, sin(angle) * radius * 0.96)
		tower.add_child(fin)

	_add_cylinder(tower, radius * 0.78, radius * 0.70, 4.2, trim, height * 0.5 - 2.1, 40)
	if style == 2:
		_add_cylinder(tower, radius * 0.55, radius * 0.42, 7.0, facade, height * 0.5 + 2.7, 32)
		_add_cylinder(tower, radius * 0.25, radius * 0.18, 5.0, trim, height * 0.5 + 8.7, 24)
	else:
		_add_cylinder(tower, radius * 0.50, radius * 0.44, 3.0, facade, height * 0.5 + 1.5, 32)

	_add_shop_sign(tower, radius, height, facade_color)

func _add_cylinder(parent: Node3D, bottom_radius: float, top_radius: float, cylinder_height: float, material: Material, y: float, segments: int = 32) -> void:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.bottom_radius = bottom_radius
	mesh.top_radius = top_radius
	mesh.height = cylinder_height
	mesh.radial_segments = segments
	instance.mesh = mesh
	instance.material_override = material
	instance.position.y = y
	parent.add_child(instance)

func _add_shop_sign(parent: Node3D, radius: float, height: float, facade_color: Color) -> void:
	var sign := Label3D.new()
	sign.text = ["OCEAN HOTEL", "SUNSET PLAZA", "VICE CITY", "PALM CLUB", "BAY RESIDENCE"][rng.randi_range(0, 4)]
	sign.position = Vector3(0, -height * 0.5 + 4.6, radius * 1.12)
	sign.pixel_size = 0.006
	sign.font_size = 34
	sign.modulate = Color("#ffe7bd")
	sign.outline_size = 5
	sign.outline_modulate = Color("#183947")
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(sign)

func _build_waterfront() -> void:
	var promenade := _mat(Color("#d9c8a6"), 0.8)
	_add_plane("OceanPromenade", Vector2(620.0, 14.0), Vector3(0, -0.16, 282.0), promenade)
	_add_plane("BeachSand", Vector2(620.0, 30.0), Vector3(0, -0.25, 305.0), _mat(Color("#d8bd8b"), 1.0))
	_add_plane("MarinaPier", Vector2(96.0, 5.0), Vector3(160.0, 0.0, 326.0), _mat(Color("#9c7957"), 0.9))
	for pier_x in [-270.0, -180.0, -90.0, 0.0, 90.0, 180.0, 270.0]:
		_add_plane("WaterfrontPaving", Vector2(2.4, 11.0), Vector3(pier_x, -0.08, 282.0), promenade)

func _build_palms() -> void:
	var locations: Array[Vector3] = []
	for road_index in [-2, 0, 2]:
		var coordinate := float(road_index) * ROAD_STEP
		for step in range(0, 5):
			var along := -160.0 + float(step) * 80.0
			locations.append(Vector3(along, 0.0, coordinate + 14.5))
			if road_index == 0:
				locations.append(Vector3(coordinate + 14.5, 0.0, along))
	for beach_index in range(0, 10):
		locations.append(Vector3(-225.0 + float(beach_index) * 50.0, 0.0, 276.0))
	_create_palm_multimeshes(locations)

func _create_palm_multimeshes(locations: Array[Vector3]) -> void:
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.11
	trunk_mesh.bottom_radius = 0.25
	trunk_mesh.height = 5.4
	trunk_mesh.radial_segments = 9
	var trunk_batch := MultiMesh.new()
	trunk_batch.transform_format = MultiMesh.TRANSFORM_3D
	trunk_batch.mesh = trunk_mesh
	trunk_batch.instance_count = locations.size()
	for index in range(locations.size()):
		var location: Vector3 = locations[index]
		trunk_batch.set_instance_transform(index, Transform3D(Basis.IDENTITY, Vector3(location.x, 2.43, location.z)))
	var trunks := MultiMeshInstance3D.new()
	trunks.name = "PalmTrunks_Batched"
	trunks.multimesh = trunk_batch
	trunks.material_override = trunk_material
	add_child(trunks)

	var leaf_mesh := SphereMesh.new()
	leaf_mesh.radius = 1.0
	leaf_mesh.height = 2.0
	var leaf_batch := MultiMesh.new()
	leaf_batch.transform_format = MultiMesh.TRANSFORM_3D
	leaf_batch.mesh = leaf_mesh
	leaf_batch.instance_count = locations.size() * 7
	var leaf_index := 0
	for location in locations:
		for frond_index in range(7):
			var angle := TAU * float(frond_index) / 7.0
			var scale_basis := Basis(Vector3.UP, -angle).scaled(Vector3(0.25, 0.10, 1.65))
			var leaf_position := Vector3(location.x + cos(angle) * 0.78, 4.78, location.z + sin(angle) * 0.78)
			leaf_batch.set_instance_transform(leaf_index, Transform3D(scale_basis, leaf_position))
			leaf_index += 1
	var leaves := MultiMeshInstance3D.new()
	leaves.name = "PalmFronds_Batched"
	leaves.multimesh = leaf_batch
	leaves.material_override = palm_material
	add_child(leaves)

func _load_embedded_glb(encoded_path: String) -> Node:
	if not FileAccess.file_exists(encoded_path):
		push_warning("Missing optional vegetation asset: " + encoded_path)
		return null
	var encoded := FileAccess.get_file_as_string(encoded_path).strip_edges()
	encoded = encoded.replace("\n", "").replace("\r", "").replace(" ", "")
	if encoded.is_empty():
		push_warning("Empty vegetation asset: " + encoded_path)
		return null
	var bytes := Marshalls.base64_to_raw(encoded)
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var error := document.append_from_buffer(bytes, "", state)
	if error != OK:
		push_warning("Could not import vegetation GLB %s: %s" % [encoded_path, error_string(error)])
		return null
	return document.generate_scene(state)

func _build_asset_parks() -> void:
	var asset_paths := [
		"res://assets/vegetation/tree1.glb.b64",
		"res://assets/vegetation/tree2.glb.b64",
		"res://assets/vegetation/tree3.glb.b64"
	]
	for path in asset_paths:
		var source := _load_embedded_glb(path)
		if source != null:
			imported_tree_models.append(source)
	imported_bush_model = _load_embedded_glb("res://assets/vegetation/bush.glb.b64")

	var park_centers: Array[Vector2] = [
		Vector2(40.0, 40.0),
		Vector2(-200.0, -200.0),
		Vector2(-120.0, 200.0),
		Vector2(-40.0, 120.0),
		Vector2(120.0, -40.0),
		Vector2(200.0, -120.0)
	]
	var lawn_material := _mat(Color("#47724f"), 1.0)
	var path_material := _mat(Color("#d2c3a2"), 0.92)
	for park_index in range(park_centers.size()):
		var center: Vector2 = park_centers[park_index]
		_add_plane("ParkLawn_%02d" % park_index, Vector2(43.0, 43.0), Vector3(center.x, -0.255, center.y), lawn_material)
		_add_plane("ParkWalk_%02d" % park_index, Vector2(3.0, 38.0), Vector3(center.x, -0.245, center.y), path_material)
		_add_plane("ParkWalkCross_%02d" % park_index, Vector2(38.0, 3.0), Vector3(center.x, -0.244, center.y), path_material)
		if imported_tree_models.is_empty():
			continue
		for tree_index in range(6):
			var angle := TAU * float(tree_index) / 6.0 + float(park_index) * 0.37
			var radial := Vector2(cos(angle), sin(angle)) * 14.5
			var source_index := (tree_index + park_index) % imported_tree_models.size()
			var tree := imported_tree_models[source_index].duplicate()
			var tree_root := Node3D.new()
			tree_root.name = "QuaterniusCC0Tree"
			tree_root.position = Vector3(center.x + radial.x, 0.0, center.y + radial.y)
			tree_root.rotation.y = rng.randf_range(0.0, TAU)
			var tree_scale := rng.randf_range(0.92, 1.18)
			tree_root.scale = Vector3.ONE * tree_scale
			tree_root.add_child(tree)
			add_child(tree_root)
		if imported_bush_model != null:
			for bush_index in range(4):
				var bush := Node3D.new()
				bush.name = "QuaterniusCC0Bush"
				var offset_x := -15.0 if bush_index % 2 == 0 else 15.0
				var offset_z := -15.0 if bush_index < 2 else 15.0
				bush.position = Vector3(center.x + offset_x, 0.0, center.y + offset_z)
				bush.scale = Vector3.ONE * 1.25
				bush.add_child(imported_bush_model.duplicate())
				add_child(bush)
		_create_park_bench(Vector3(center.x - 7.0, -0.27, center.y))
		_create_park_bench(Vector3(center.x + 7.0, -0.27, center.y))

func _create_park_bench(location: Vector3) -> void:
	var bench := Node3D.new()
	bench.name = "ParkBench"
	bench.position = location
	add_child(bench)
	var wood := _mat(Color("#8d6245"), 0.86)
	var metal := _mat(Color("#344b55"), 0.58, 0.45)
	var seat := MeshInstance3D.new()
	var seat_mesh := BoxMesh.new()
	seat_mesh.size = Vector3(2.8, 0.16, 0.72)
	seat.mesh = seat_mesh
	seat.material_override = wood
	seat.position.y = 0.52
	bench.add_child(seat)
	var back := MeshInstance3D.new()
	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(2.8, 0.82, 0.14)
	back.mesh = back_mesh
	back.material_override = wood
	back.position = Vector3(0.0, 0.95, 0.30)
	bench.add_child(back)
	for side in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var leg_mesh := BoxMesh.new()
		leg_mesh.size = Vector3(0.14, 0.48, 0.14)
		leg.mesh = leg_mesh
		leg.material_override = metal
		leg.position = Vector3(side * 1.12, 0.25, 0.0)
		bench.add_child(leg)

func _build_street_furniture() -> void:
	for road_index in range(-3, 4):
		var coordinate := float(road_index) * ROAD_STEP
		for side in [-1.0, 1.0]:
			var lamp := Node3D.new()
			lamp.name = "BoulevardLamp"
			lamp.position = Vector3(coordinate + side * 13.5, -0.27, -190.0 + float(road_index + 3) * 5.0)
			add_child(lamp)
			var pole := MeshInstance3D.new()
			var pole_mesh := CylinderMesh.new()
			pole_mesh.top_radius = 0.07
			pole_mesh.bottom_radius = 0.12
			pole_mesh.height = 5.2
			pole_mesh.radial_segments = 8
			pole.mesh = pole_mesh
			pole.material_override = _mat(Color("#344852"), 0.55, 0.65)
			pole.position.y = 2.6
			lamp.add_child(pole)
			var head := MeshInstance3D.new()
			var head_mesh := SphereMesh.new()
			head_mesh.radius = 0.24
			head_mesh.height = 0.32
			head.mesh = head_mesh
			head.material_override = lamp_material
			head.position = Vector3(0.0, 5.15, 0.0)
			lamp.add_child(head)
