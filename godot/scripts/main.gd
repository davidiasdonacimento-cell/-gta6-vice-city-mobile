extends Node3D

const PLAYER_SCRIPT := preload("res://scripts/player_controller.gd")
const HUD_SCRIPT := preload("res://scripts/mobile_hud.gd")

func _ready() -> void:
	_setup_environment()
	_build_test_island()
	_setup_player()
	_setup_camera()
	_setup_hud()

func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#17627a")
	sky_material.sky_horizon_color = Color("#f2a77d")
	sky_material.ground_bottom_color = Color("#172c32")
	sky_material.ground_horizon_color = Color("#c98e72")
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)

func _build_test_island() -> void:
	# Smooth terrain foundation; production city assets will replace this blockout.
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(1800, 1800)
	ground.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#426b55")
	material.roughness = 1.0
	ground.material_override = material
	ground.position.y = -0.12
	add_child(ground)

	var ocean := MeshInstance3D.new()
	var sea := PlaneMesh.new()
	sea.size = Vector2(10000, 10000)
	ocean.mesh = sea
	var water := StandardMaterial3D.new()
	water.albedo_color = Color("#12677c")
	water.roughness = 0.24
	water.metallic = 0.18
	ocean.material_override = water
	ocean.position.y = -0.35
	add_child(ocean)

func _setup_player() -> void:
	var player := get_node("Player") as CharacterBody3D
	player.set_script(PLAYER_SCRIPT)
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.42
	capsule.height = 1.85
	collider.shape = capsule
	collider.position.y = 0.93
	player.add_child(collider)
	var body := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.4
	capsule_mesh.height = 1.8
	body.mesh = capsule_mesh
	body.position.y = 0.92
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#d9a27f")
	body.material_override = mat
	player.add_child(body)

func _setup_camera() -> void:
	var camera_pivot := Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0, 2.1, 0)
	get_node("Player").add_child(camera_pivot)
	var spring := SpringArm3D.new()
	spring.spring_length = 6.5
	spring.margin = 0.2
	camera_pivot.add_child(spring)
	var camera := Camera3D.new()
	camera.current = true
	camera.fov = 72
	spring.add_child(camera)

func _setup_hud() -> void:
	var hud := CanvasLayer.new()
	hud.set_script(HUD_SCRIPT)
	add_child(hud)
