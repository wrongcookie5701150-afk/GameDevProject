class_name DesktopWindow extends Control

## DesktopWindow - Base window component for in-game simulated OS
## Manages dragging, window focus (move_to_front), minimize, and close.

signal window_closed()
signal window_minimized()
signal window_focused()

@export var window_title: String = "Application"
@export var window_icon: Texture2D

@onready var title_label: Label = get_node_or_null("%TitleLabel")
@onready var icon_rect: TextureRect = get_node_or_null("%IconRect")
@onready var title_bar: Control = get_node_or_null("%TitleBar")
@onready var close_btn: Button = get_node_or_null("%CloseBtn")
@onready var minimize_btn: Button = get_node_or_null("%MinimizeBtn")
@onready var content_area: MarginContainer = get_node_or_null("%ContentArea")

func get_content_container() -> Control:
	if not content_area:
		content_area = get_node_or_null("%ContentArea")
	if not content_area:
		content_area = find_child("ContentArea", true, false) as MarginContainer
	return content_area

var _is_dragging: bool = false
var _drag_start_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if title_bar:
		title_bar.custom_minimum_size.y = 18.0
	if title_label:
		title_label.text = window_title
	if icon_rect:
		icon_rect.custom_minimum_size = Vector2(16, 16)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if window_icon:
			icon_rect.texture = window_icon
	if close_btn:
		close_btn.custom_minimum_size = Vector2(16, 16)
		if not close_btn.pressed.is_connected(close_window):
			close_btn.pressed.connect(close_window)
	if minimize_btn:
		minimize_btn.custom_minimum_size = Vector2(16, 16)
		if not minimize_btn.pressed.is_connected(minimize_window):
			minimize_btn.pressed.connect(minimize_window)
	if title_bar and not title_bar.gui_input.is_connected(_on_title_bar_gui_input):
		title_bar.gui_input.connect(_on_title_bar_gui_input)
	
	gui_input.connect(_on_window_gui_input)

func _on_window_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		focus_window()

func _on_title_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_drag_start_pos = event.position
				focus_window()
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		position += event.position - _drag_start_pos
		# Keep window within 480x270 viewport boundaries
		var vp_size: Vector2 = get_viewport_rect().size
		if vp_size.x > 0 and vp_size.y > 0:
			position.x = clampf(position.x, 0.0, max(0.0, vp_size.x - size.x))
			position.y = clampf(position.y, 0.0, max(0.0, vp_size.y - size.y - 20.0))

func focus_window() -> void:
	move_to_front()
	window_focused.emit()

func open_window() -> void:
	show()
	focus_window()

func close_window() -> void:
	hide()
	window_closed.emit()

func minimize_window() -> void:
	hide()
	window_minimized.emit()
