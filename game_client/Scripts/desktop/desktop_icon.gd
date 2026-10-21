@tool
class_name DesktopIcon extends VBoxContainer

## DesktopIcon - Clickable & Double-clickable Desktop icon
## Emits app activation request matching Story Content app IDs.

signal icon_activated(app_id: String)
signal icon_selected(app_id: String)

@export var app_id: String = ""
@export var app_name: String = "App":
	set(value):
		app_name = value
		_update_ui()

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_update_ui()

@onready var icon_rect: TextureRect = get_node_or_null("%IconRect")
@onready var name_label: Label = get_node_or_null("%NameLabel")

var _last_click_time: float = 0.0
const DOUBLE_CLICK_TIME: float = 0.40
var _is_selected: bool = false

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_update_ui()

func _update_ui() -> void:
	if not name_label:
		name_label = get_node_or_null("%NameLabel")
	if not icon_rect:
		icon_rect = get_node_or_null("%IconRect")
	
	if name_label and not app_name.is_empty():
		name_label.text = app_name
	if icon_rect and icon_texture:
		icon_rect.texture = icon_texture

func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var now: float = Time.get_ticks_msec() / 1000.0
		set_selected(true)
		if now - _last_click_time <= DOUBLE_CLICK_TIME and (now - _last_click_time) > 0.0:
			icon_activated.emit(app_id)
			_last_click_time = 0.0
		else:
			icon_selected.emit(app_id)
			_last_click_time = now

func set_selected(selected: bool) -> void:
	_is_selected = selected
	if name_label:
		if selected:
			name_label.modulate = Color(0.65, 0.88, 1.0)
		else:
			name_label.modulate = Color.WHITE
	queue_redraw()

func _draw() -> void:
	if _is_selected:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color(0.2, 0.5, 0.9, 0.35), true)
		draw_rect(r, Color(0.4, 0.8, 1.0, 0.9), false, 1.0)
