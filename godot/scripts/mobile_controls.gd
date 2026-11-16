extends Control
class_name MobileControls

signal look_delta(delta_pixels: Vector2)

@export var joystick_radius: float = 76.0
@export var knob_radius: float = 29.0
@export var look_sensitivity: float = 1.0

var _move := Vector2.ZERO
var _left_touch := -1
var _right_touch := -1
var _left_origin := Vector2.ZERO
var _left_knob := Vector2.ZERO
var _right_last := Vector2.ZERO

func _ready() -> void:
    set_process_input(true)
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func get_move_vector() -> Vector2:
    return _move

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x < size.x * 0.48 and _left_touch == -1:
                _left_touch = event.index
                _left_origin = event.position
                _left_knob = event.position
                _move = Vector2.ZERO
                queue_redraw()
            elif event.position.x >= size.x * 0.48 and _right_touch == -1:
                _right_touch = event.index
                _right_last = event.position
        else:
            if event.index == _left_touch:
                _left_touch = -1
                _move = Vector2.ZERO
                queue_redraw()
            if event.index == _right_touch:
                _right_touch = -1

    elif event is InputEventScreenDrag:
        if event.index == _left_touch:
            var offset: Vector2 = event.position - _left_origin
            if offset.length() > joystick_radius:
                offset = offset.normalized() * joystick_radius
            _left_knob = _left_origin + offset
            _move = Vector2(offset.x / joystick_radius, offset.y / joystick_radius)
            queue_redraw()
        elif event.index == _right_touch:
            var delta_pixels: Vector2 = event.position - _right_last
            _right_last = event.position
            look_delta.emit(delta_pixels * look_sensitivity)

func _draw() -> void:
    if _left_touch != -1:
        draw_circle(_left_origin, joystick_radius, Color(0.08, 0.13, 0.2, 0.42))
        draw_arc(_left_origin, joystick_radius, 0.0, TAU, 64, Color(0.55, 0.78, 1.0, 0.8), 3.0)
        draw_circle(_left_knob, knob_radius, Color(0.22, 0.68, 1.0, 0.88))
        draw_arc(_left_knob, knob_radius, 0.0, TAU, 48, Color(0.85, 0.95, 1.0, 0.95), 2.0)
