extends CanvasLayer

class TouchJoystick:
	extends Control
	signal vector_changed(value: Vector2)

	var touch_id := -1
	var value := Vector2.ZERO
	const CENTER := Vector2(80.0, 80.0)
	const RADIUS := 62.0
	const KNOB_RADIUS := 27.0

	func _ready() -> void:
		custom_minimum_size = Vector2(160.0, 160.0)
		size = custom_minimum_size
		mouse_filter = Control.MOUSE_FILTER_STOP
		queue_redraw()

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventScreenTouch:
			if event.pressed and touch_id == -1:
				touch_id = event.index
				_update_value(event.position)
				accept_event()
			elif not event.pressed and event.index == touch_id:
				touch_id = -1
				value = Vector2.ZERO
				vector_changed.emit(value)
				queue_redraw()
				accept_event()
		elif event is InputEventScreenDrag and event.index == touch_id:
			_update_value(event.position)
			accept_event()

	func _update_value(point: Vector2) -> void:
		var offset: Vector2 = point - CENTER
		value = (offset / RADIUS).limit_length(1.0)
		if value.length() < 0.12:
			value = Vector2.ZERO
		vector_changed.emit(value)
		queue_redraw()

	func _draw() -> void:
		draw_circle(CENTER, RADIUS + 7.0, Color(0.025, 0.06, 0.1, 0.34))
		draw_circle(CENTER, RADIUS, Color(0.12, 0.22, 0.31, 0.42))
		draw_arc(CENTER, RADIUS, 0.0, TAU, 64, Color(0.55, 0.82, 1.0, 0.72), 3.0, true)
		var knob_center: Vector2 = CENTER + value * 43.0
		draw_circle(knob_center, KNOB_RADIUS, Color(0.12, 0.58, 0.88, 0.88))
		draw_arc(knob_center, KNOB_RADIUS, 0.0, TAU, 48, Color(0.88, 0.96, 1.0, 0.95), 2.0, true)

var player: CharacterBody3D
var car: Node3D
var camera_pivot: Node3D
var camera_drag_id := -1
var last_camera_point := Vector2.ZERO
var vehicle_button: Button
var run_button: Button
var brake_button: Button

const CAMERA_SAFE_BOTTOM := 230.0
const VEHICLE_INTERACTION_DISTANCE := 8.5

func _ready() -> void:
	player = get_parent().get_node("Player") as CharacterBody3D
	car = get_parent().get_node_or_null("Car")
	camera_pivot = player.get_node("CameraPivot")
	_build_controls()

func _build_controls() -> void:
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layer)

	var joystick := TouchJoystick.new()
	joystick.name = "TouchJoystick"
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.position = Vector2(28.0, -178.0)
	joystick.vector_changed.connect(_on_move_changed)
	layer.add_child(joystick)

	run_button = Button.new()
	run_button.name = "RunButton"
	run_button.text = "CORRER"
	run_button.size = Vector2(108.0, 54.0)
	run_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	run_button.position = Vector2(-136.0, -170.0)
	run_button.focus_mode = Control.FOCUS_NONE
	run_button.add_theme_font_size_override("font_size", 14)
	run_button.add_theme_color_override("font_color", Color.WHITE)
	run_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	run_button.button_down.connect(func(): Input.action_press("run"))
	run_button.button_up.connect(func(): Input.action_release("run"))
	layer.add_child(run_button)

	vehicle_button = Button.new()
	vehicle_button.name = "VehicleButton"
	vehicle_button.text = "ENTRAR"
	vehicle_button.size = Vector2(116.0, 52.0)
	vehicle_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	vehicle_button.position = Vector2(-140.0, -236.0)
	vehicle_button.focus_mode = Control.FOCUS_NONE
	vehicle_button.add_theme_font_size_override("font_size", 14)
	vehicle_button.add_theme_color_override("font_color", Color.WHITE)
	vehicle_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	vehicle_button.pressed.connect(_toggle_vehicle)
	layer.add_child(vehicle_button)

	brake_button = Button.new()
	brake_button.name = "BrakeButton"
	brake_button.text = "FREIO"
	brake_button.size = Vector2(116.0, 52.0)
	brake_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	brake_button.position = Vector2(-140.0, -170.0)
	brake_button.focus_mode = Control.FOCUS_NONE
	brake_button.add_theme_font_size_override("font_size", 14)
	brake_button.add_theme_color_override("font_color", Color.WHITE)
	brake_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	brake_button.button_down.connect(_set_mobile_brake.bind(true))
	brake_button.button_up.connect(_set_mobile_brake.bind(false))
	layer.add_child(brake_button)

	var hint := Label.new()
	hint.text = "Joystick: mover • lado direito: câmera"
	hint.position = Vector2(18.0, 18.0)
	hint.add_theme_font_size_override("font_size", 16)
	layer.add_child(hint)

func _process(_delta: float) -> void:
	if car == null or player == null:
		return
	var driving := bool(car.get("is_driving"))
	var near_car := player.global_position.distance_to(car.global_position) <= VEHICLE_INTERACTION_DISTANCE
	vehicle_button.visible = driving or near_car
	vehicle_button.text = "SAIR" if driving else "ENTRAR"
	run_button.visible = not driving
	brake_button.visible = driving

func _on_move_changed(value: Vector2) -> void:
	if car != null and bool(car.get("is_driving")):
		car.set("mobile_input", value)
		player.mobile_direction = Vector2.ZERO
	else:
		if car != null:
			car.set("mobile_input", Vector2.ZERO)
		player.mobile_direction = value

func _set_mobile_brake(pressed: bool) -> void:
	if car != null and bool(car.get("is_driving")):
		car.set("mobile_brake", pressed)

func _toggle_vehicle() -> void:
	if car == null or player == null:
		return
	if bool(car.get("is_driving")):
		car.call("exit_vehicle")
	elif player.global_position.distance_to(car.global_position) <= VEHICLE_INTERACTION_DISTANCE:
		car.call("enter_vehicle", player)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_toggle_vehicle()

	var viewport_size := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		if event.pressed:
			var camera_area := event.position.x > viewport_size.x * 0.48 and event.position.y < viewport_size.y - CAMERA_SAFE_BOTTOM
			if camera_area and camera_drag_id == -1:
				camera_drag_id = event.index
				last_camera_point = event.position
		elif event.index == camera_drag_id:
			camera_drag_id = -1
	elif event is InputEventScreenDrag and event.index == camera_drag_id:
		var delta_pixels: Vector2 = event.position - last_camera_point
		camera_pivot.rotation.y -= delta_pixels.x * 0.006
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - delta_pixels.y * 0.004, -0.45, 0.5)
		last_camera_point = event.position

func _exit_tree() -> void:
	Input.action_release("run")
	if car != null and bool(car.get("is_driving")):
		car.call("exit_vehicle")
	if player:
		player.mobile_direction = Vector2.ZERO
