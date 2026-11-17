extends CanvasLayer
class_name ViceCityMainMenu

var root_control: Control
var menu_panel: PanelContainer
var controls_label: Label
var play_button: Button
var controls_button: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_build_menu()
	_animate_intro()

func _build_menu() -> void:
	root_control = Control.new()
	root_control.name = "MainMenuRoot"
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root_control)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.012, 0.035, 0.06, 0.88)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(center)

	menu_panel = PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(460.0, 520.0)
	center.add_child(menu_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#102c3a")
	panel_style.border_color = Color("#2a91b0")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(22)
	panel_style.content_margin_left = 34.0
	panel_style.content_margin_right = 34.0
	panel_style.content_margin_top = 30.0
	panel_style.content_margin_bottom = 30.0
	menu_panel.add_theme_stylebox_override("panel", panel_style)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	menu_panel.add_child(layout)

	var eyebrow := Label.new()
	eyebrow.text = "MUNDO ABERTO • EXPERIÊNCIA MOBILE"
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", Color("#7fd9e8"))
	layout.add_child(eyebrow)

	var title := Label.new()
	title.text = "VICE CITY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#fff0d2"))
	title.add_theme_color_override("font_outline_color", Color("#123b4b"))
	title.add_theme_constant_override("outline_size", 8)
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "COSTA • CIDADE • LIBERDADE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#e7a77f"))
	layout.add_child(subtitle)

	var separator := HSeparator.new()
	layout.add_child(separator)

	play_button = _create_menu_button("JOGAR", Color("#147c9e"))
	play_button.pressed.connect(_start_game)
	layout.add_child(play_button)

	controls_button = _create_menu_button("CONTROLES", Color("#254d61"))
	controls_button.pressed.connect(_toggle_controls)
	layout.add_child(controls_button)

	controls_label = Label.new()
	controls_label.text = "CELULAR: joystick esquerdo para andar ou dirigir. Arraste o lado direito para girar a câmera. Use ENTRAR para dirigir, FREIO para parar e LOJA / GARAGEM para melhorar o carro."
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.add_theme_font_size_override("font_size", 14)
	controls_label.add_theme_color_override("font_color", Color("#d4e4e6"))
	controls_label.visible = false
	layout.add_child(controls_label)

	var footer := Label.new()
	footer.text = "PROJETO INDEPENDENTE • BUILD EM DESENVOLVIMENTO"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 11)
	footer.add_theme_color_override("font_color", Color("#89a6ae"))
	layout.add_child(footer)

func _create_menu_button(caption: String, color: Color) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0.0, 54.0)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(12)
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = color.lightened(0.16)
	button.add_theme_stylebox_override("hover", hover)
	return button

func _animate_intro() -> void:
	menu_panel.modulate.a = 0.0
	menu_panel.scale = Vector2(0.94, 0.94)
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(menu_panel, "modulate:a", 1.0, 0.55)
	tween.tween_property(menu_panel, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _toggle_controls() -> void:
	controls_label.visible = not controls_label.visible
	controls_button.text = "OCULTAR CONTROLES" if controls_label.visible else "CONTROLES"

func _start_game() -> void:
	get_tree().paused = false
	root_control.queue_free()
	queue_free()

func _exit_tree() -> void:
	if get_tree() != null:
		get_tree().paused = false
