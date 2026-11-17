extends Node
class_name ViceCityWorldClock

@export var real_seconds_per_game_hour: float = 30.0
var time_of_day := 9.0
var sun: DirectionalLight3D
var world_environment: WorldEnvironment
var sky_material: ProceduralSkyMaterial

func _ready() -> void:
	sun = get_parent().get_node_or_null("Sun") as DirectionalLight3D
	world_environment = get_parent().get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment != null and world_environment.environment != null:
		var sky := world_environment.environment.sky
		if sky != null:
			sky_material = sky.sky_material as ProceduralSkyMaterial
	_update_lighting()

func _process(delta: float) -> void:
	time_of_day = fposmod(time_of_day + delta / maxf(1.0, real_seconds_per_game_hour), 24.0)
	_update_lighting()

func _update_lighting() -> void:
	var sun_height := sin((time_of_day / 24.0) * TAU - PI * 0.5)
	var daylight := clampf((sun_height + 0.12) / 0.92, 0.04, 1.0)
	var sunset := clampf(1.0 - absf(time_of_day - 18.0) / 2.6, 0.0, 1.0)
	if time_of_day < 6.0:
		sunset = clampf(1.0 - absf(time_of_day - 6.0) / 2.0, 0.0, 1.0)

	if sun != null:
		sun.rotation_degrees.x = -sun_height * 72.0 - 12.0
		sun.rotation_degrees.y = -28.0
		sun.light_energy = lerpf(0.08, 1.25, daylight)
		sun.light_color = Color("#ffd0a1").lerp(Color("#fff0d4"), daylight)
		sun.shadow_enabled = daylight > 0.18

	if world_environment != null and world_environment.environment != null:
		world_environment.environment.ambient_light_energy = lerpf(0.18, 0.82, daylight)
		world_environment.environment.tonemap_exposure = lerpf(0.78, 1.0, daylight)

	if sky_material != null:
		var night_top := Color("#07182e")
		var day_top := Color("#17627a")
		var sunset_top := Color("#8a5473")
		var night_horizon := Color("#263b57")
		var day_horizon := Color("#f2a77d")
		var sunset_horizon := Color("#ef8d70")
		sky_material.sky_top_color = night_top.lerp(day_top, daylight).lerp(sunset_top, sunset * 0.68)
		sky_material.sky_horizon_color = night_horizon.lerp(day_horizon, daylight).lerp(sunset_horizon, sunset * 0.55)

func get_clock_text() -> String:
	var hour := int(floor(time_of_day))
	var minute := int(floor((time_of_day - float(hour)) * 60.0))
	return "%02d:%02d" % [hour, minute]
