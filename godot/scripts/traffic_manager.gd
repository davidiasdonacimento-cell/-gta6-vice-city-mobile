extends Node3D
class_name ViceCityTrafficManager

const TRAFFIC_CAR_SCRIPT := preload("res://scripts/traffic_car.gd")
const CITY_LIMIT := 260.0
const ROAD_STEP := 80.0

func _ready() -> void:
	_spawn_traffic()

func _spawn_traffic() -> void:
	var lanes := [-4.0, 4.0]
	var road_indices := [-2, -1, 0, 1, 2]
	for index in range(12):
		var car := TRAFFIC_CAR_SCRIPT.new() as CharacterBody3D
		car.name = "TrafficCar_%02d" % index
		var horizontal := index % 2 == 0
		var road := road_indices[(index * 3 + 1) % road_indices.size()]
		var lane := lanes[floori(float(index) / 2.0) % 2]
		var direction := 1.0 if floori(float(index) / 4.0) % 2 == 0 else -1.0
		if horizontal:
			car.travel_axis = Vector3.RIGHT
			car.travel_sign = direction
			car.position = Vector3(-CITY_LIMIT + float(index) * 38.0, 0.0, float(road) * ROAD_STEP + lane)
			car.rotation.y = -PI * 0.5 if direction > 0.0 else PI * 0.5
		else:
			car.travel_axis = Vector3.FORWARD
			car.travel_sign = direction
			car.position = Vector3(float(road) * ROAD_STEP + lane, 0.0, -CITY_LIMIT + float(index) * 38.0)
			car.rotation.y = 0.0 if direction > 0.0 else PI
		car.travel_speed = 8.5 + float(index % 4) * 1.15
		car.world_limit = CITY_LIMIT
		add_child(car)
