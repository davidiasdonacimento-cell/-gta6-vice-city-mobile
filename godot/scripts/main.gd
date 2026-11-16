extends Node3D

const PLAYER_SCRIPT := preload("res://scripts/player_controller.gd")
const PLAYER_VISUAL_SCRIPT := preload("res://scripts/player_visual.gd")
const CITY_BUILDER_SCRIPT := preload("res://scripts/city_builder.gd")
const CAR_SCRIPT := preload("res://scripts/car_controller.gd")
const HUD_SCRIPT := preload("res://scripts/mobile_hud.gd")

func _ready() -> void:
	_setup_environment()
	_build_city()
	_setup_player()
	_setup_camera()
	_setup_car()
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
	env.ambient_light_energy = 0.72
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world == null:
		world = WorldEnvironment.new()
		world.name = "WorldEnvironment"
		add_child(world)
	world.environment = env

func _build_city() -> void:
	var city := CITY_BUILDER_SCRIPT.new()
	city.name = "ViceCityCoastalDistrict"
	add_child(city)

func _setup_player() -> void:
	var player := get_node("Player") as CharacterBody3D
	player.set_script(PLAYER_SCRIPT)

	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.36
	capsule.height = 1.88
	collider.shape = capsule
	collider.position.y = 0.94
	player.add_child(collider)

	var visual := Node3D.new()
	visual.name = "Visual"
	visual.set_script(PLAYER_VISUAL_SCRIPT)
	player.add_child(visual)

func _setup_camera() -> void:
	var camera_pivot := Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0.0, 1.55, 0.0)
	get_node("Player").add_child(camera_pivot)

	var spring := SpringArm3D.new()
	spring.spring_length = 6.2
	spring.margin = 0.18
	camera_pivot.add_child(spring)

	var camera := Camera3D.new()
	camera.current = true
	camera.fov = 72.0
	camera.near = 0.08
	spring.add_child(camera)

func _setup_car() -> void:
	var car := CAR_SCRIPT.new() as VehicleBody3D
	car.name = "Car"
	car.position = Vector3(12.0, 0.15, 20.0)
	add_child(car)

func _setup_hud() -> void:
	var hud := CanvasLayer.new()
	hud.set_script(HUD_SCRIPT)
	add_child(hud)
