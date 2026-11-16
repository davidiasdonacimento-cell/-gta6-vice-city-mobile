extends CanvasLayer

var player: CharacterBody3D
var stick_origin := Vector2.ZERO
var stick_pointer := -1
var stick_vector := Vector2.ZERO
var camera_drag_id := -1
var last_camera_point := Vector2.ZERO
var camera_pivot: Node3D
var joystick_button: Button

const JOYSTICK_RADIUS := 58.0
const CAMERA_SAFE_BOTTOM := 230.0

func _ready() -> void:
	player = get_parent().get_node("Player") as CharacterBody3D
	camera_pivot = player.get_node("CameraPivot")
	_build_controls()

func _build_controls() -> void:
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layer)

	joystick_button = _make_button("", Vector2(34, -180), Vector2(150, 150), layer)
	joystick_button.name = "TouchJoystick"
	joystick_button.modulate = Color(0.65, 0.95, 0.96, 0.45)
	joystick_button.focus_mode = Control.FOCUS_NONE
	joystick_button.gui_input.connect(_on_joystick_input)

	var run_button := _make_button("CORRER", Vector2(-142, -170), Vector2(108, 54), layer)
	run_button.name = "RunButton"
	run_button.focus_mode = Control.FOCUS_NONE
	run_button.add_theme_color_override("font_color", Color.WHITE)
	run_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	run_button.button_down.connect(func(): Input.action_press("run"))
	run_button.button_up.connect(func(): Input.action_release("run"))

	var hint := Label.new()
	hint.text = "Arraste o lado direito para girar a câmera"
	hint.position = Vector2(18, 18)
	hint.add_theme_font_size_override("font_size", 16)
	layer.add_child(hint)

func _make_button(label_text: String, offset: Vector2, button_size: Vector2, parent: Control) -> Button:
	var button := Button.new()
	button.text = label_text
	button.size = button_size
	button.anchor_left = 0.0 if offset.x >= 0.0 else 1.0
	button.anchor_right = button.anchor_left
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.position = offset
	button.add_theme_font_size_override("font_size", 14)
	parent.add_child(button)
	return button

func _on_joystick_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			stick_pointer = event.index
			stick_origin = event.position
			stick_vector = Vector2.ZERO
		else:
			if event.index == stick_pointer:
				stick_pointer = -1
				stick_vector = Vector2.ZERO
				player.mobile_direction = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == stick_pointer:
		var offset: Vector2 = event.position - stick_origin
		stick_vector = (offset / JOYSTICK_RADIUS).limit_length(1.0)
		if stick_vector.length() < 0.12:
			stick_vector = Vector2.ZERO
	player.mobile_direction = stick_vector

func _input(event: InputEvent) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		if event.pressed:
			var on_camera_area := event.position.x > viewport_size.x * 0.48 and event.position.y < viewport_size.y - CAMERA_SAFE_BOTTOM
			if on_camera_area and camera_drag_id == -1:
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
	if player:
		player.mobile_direction = Vector2.ZERO
