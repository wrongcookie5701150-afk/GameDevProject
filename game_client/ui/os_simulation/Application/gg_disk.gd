class_name GGDiskApp extends Control

signal folder_downloaded
signal minimize_requested
signal close_requested

const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

@onready var hide_button: Button = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Hide
@onready var exit_button: Button = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Exit
var maximize_button: Button = null

@onready var download_button: Button = $ColorRect/VBoxContainer/Utility/IconBar/Download
@onready var report_item: PanelContainer = $ColorRect/VBoxContainer/MarginContainer/GridContainer/PanelContainer
@onready var title_label: Label = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/Label

var _is_downloaded: bool = false
var _is_maximized: bool = false
var _pre_maximize_pos: Vector2 = Vector2(90, 45)
var _pre_maximize_size: Vector2 = Vector2(300, 180)

func _ready() -> void:
	var win := get_node_or_null("ColorRect") as Control
	var head := get_node_or_null("ColorRect/VBoxContainer/ColorRect") as Control
	var global_settings = get_node_or_null("/root/GlobalSettings")
	if win and head and global_settings and global_settings.has_method("make_window_draggable"):
		global_settings.make_window_draggable(win, head)

	_apply_modern_styling()

	_setup_window_buttons()
	if download_button:
		if not download_button.pressed.is_connected(_on_download_pressed):
			download_button.pressed.connect(_on_download_pressed)
		download_button.custom_minimum_size = Vector2(12, 10)
		download_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		download_button.tooltip_text = "ดาวน์โหลดโฟลเดอร์งานกลุ่ม (Download Folder)"
	
	# Clicking on the report panel or download icon also triggers download
	if report_item:
		_set_mouse_filter_recursive(report_item, Control.MOUSE_FILTER_IGNORE)
		report_item.mouse_filter = Control.MOUSE_FILTER_STOP
		report_item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if not report_item.gui_input.is_connected(_on_report_item_gui_input):
			report_item.gui_input.connect(_on_report_item_gui_input)

func _apply_modern_styling() -> void:
	var win := get_node_or_null("ColorRect") as Control
	if win:
		if win is ColorRect:
			(win as ColorRect).color = Color(0, 0, 0, 0)
		
		var bg_panel: Panel = win.get_node_or_null("WinBgPanel") as Panel
		if not bg_panel:
			bg_panel = Panel.new()
			bg_panel.name = "WinBgPanel"
			bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bg_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			win.add_child(bg_panel)
			win.move_child(bg_panel, 0)
		
		var win_sb := StyleBoxFlat.new()
		win_sb.bg_color = Color(0.95, 0.96, 0.98, 1.0)
		win_sb.corner_radius_top_left = 7
		win_sb.corner_radius_top_right = 7
		win_sb.corner_radius_bottom_left = 7
		win_sb.corner_radius_bottom_right = 7
		win_sb.shadow_size = 6
		win_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		win_sb.shadow_offset = Vector2(0, 3)
		win_sb.border_width_left = 1
		win_sb.border_width_top = 1
		win_sb.border_width_right = 1
		win_sb.border_width_bottom = 1
		win_sb.border_color = Color(0.2, 0.45, 0.75, 0.5)
		bg_panel.add_theme_stylebox_override("panel", win_sb)

	var head := get_node_or_null("ColorRect/VBoxContainer/ColorRect") as Control
	if head:
		var head_panel: Panel = head.get_node_or_null("HeadBgPanel") as Panel
		if not head_panel:
			head_panel = Panel.new()
			head_panel.name = "HeadBgPanel"
			head_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			head_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			head.add_child(head_panel)
			head.move_child(head_panel, 0)
		if head is ColorRect:
			(head as ColorRect).color = Color(0, 0, 0, 0)
		
		var head_sb := StyleBoxFlat.new()
		head_sb.bg_color = Color(0.06, 0.44, 0.77, 1.0)
		head_sb.corner_radius_top_left = 7
		head_sb.corner_radius_top_right = 7
		head_sb.corner_radius_bottom_left = 0
		head_sb.corner_radius_bottom_right = 0
		head_panel.add_theme_stylebox_override("panel", head_sb)

	if title_label:
		title_label.add_theme_font_size_override("font_size", 8)

	if report_item:
		var card_sb := StyleBoxFlat.new()
		card_sb.bg_color = Color(0.88, 0.91, 0.95, 1.0)
		card_sb.corner_radius_top_left = 7
		card_sb.corner_radius_top_right = 7
		card_sb.corner_radius_bottom_left = 7
		card_sb.corner_radius_bottom_right = 7
		card_sb.shadow_size = 6
		card_sb.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
		card_sb.shadow_offset = Vector2(0, 3)
		card_sb.border_width_left = 1
		card_sb.border_width_top = 1
		card_sb.border_width_right = 1
		card_sb.border_width_bottom = 1
		card_sb.border_color = Color(0.45, 0.65, 0.9, 0.7)
		card_sb.content_margin_left = 6.0
		card_sb.content_margin_right = 6.0
		card_sb.content_margin_top = 4.0
		card_sb.content_margin_bottom = 4.0
		report_item.add_theme_stylebox_override("panel", card_sb)

		for child in report_item.find_children("*", "Label", true, false):
			(child as Label).add_theme_font_size_override("font_size", 6)
		for tex in report_item.find_children("*", "TextureRect", true, false):
			(tex as TextureRect).custom_minimum_size = Vector2(11, 11)

	if download_button:
		download_button.add_theme_font_size_override("font_size", 6)
		download_button.add_theme_constant_override("icon_max_width", 11)

func _set_mouse_filter_recursive(node: Node, filter_mode: Control.MouseFilter) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = filter_mode
			_set_mouse_filter_recursive(child, filter_mode)

func _on_report_item_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_trigger_download()

func _on_download_pressed() -> void:
	_trigger_download()

func _trigger_download() -> void:
	if _is_downloaded:
		return
	_is_downloaded = true
	if download_button:
		download_button.disabled = true
	folder_downloaded.emit()

func _on_hide_pressed() -> void:
	hide()
	minimize_requested.emit()

func _on_exit_pressed() -> void:
	hide()
	close_requested.emit()

func _setup_window_buttons() -> void:
	var win := get_node_or_null("ColorRect") as Control
	var head := get_node_or_null("ColorRect/VBoxContainer/ColorRect") as Control

	if not hide_button:
		hide_button = find_child("Hide", true, false) as Button
	if not exit_button:
		exit_button = find_child("Exit", true, false) as Button

	var btn_container: HBoxContainer = null
	if hide_button and hide_button.get_parent() is HBoxContainer:
		btn_container = hide_button.get_parent() as HBoxContainer
	elif exit_button and exit_button.get_parent() is HBoxContainer:
		btn_container = exit_button.get_parent() as HBoxContainer

	if btn_container:
		btn_container.add_theme_constant_override("separation", 0)

	if not maximize_button:
		maximize_button = find_child("Maximize", true, false) as Button
		if not maximize_button:
			maximize_button = find_child("MaximizeButton", true, false) as Button
		if not maximize_button and btn_container:
			maximize_button = Button.new()
			maximize_button.name = "Maximize"
			btn_container.add_child(maximize_button)
			if hide_button:
				btn_container.move_child(maximize_button, hide_button.get_index() + 1)

	var btn_normal := StyleBoxEmpty.new()
	var btn_hover := StyleBoxFlat.new()
	btn_hover.bg_color = Color(1.0, 1.0, 1.0, 0.15)
	var btn_pressed := StyleBoxFlat.new()
	btn_pressed.bg_color = Color(1.0, 1.0, 1.0, 0.25)
	
	var close_hover := StyleBoxFlat.new()
	close_hover.bg_color = Color(0.91, 0.08, 0.14, 1.0)
	var close_pressed := StyleBoxFlat.new()
	close_pressed.bg_color = Color(0.75, 0.05, 0.1, 1.0)

	if hide_button:
		hide_button.icon = null
		hide_button.text = "─"
		hide_button.custom_minimum_size = Vector2(20, 16)
		hide_button.size = Vector2(20, 16)
		hide_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hide_button.add_theme_font_override("font", FONT_MONO)
		hide_button.add_theme_font_size_override("font_size", 7)
		hide_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		hide_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		hide_button.add_theme_stylebox_override("normal", btn_normal)
		hide_button.add_theme_stylebox_override("hover", btn_hover)
		hide_button.add_theme_stylebox_override("pressed", btn_pressed)
		if not hide_button.pressed.is_connected(_on_hide_pressed):
			hide_button.pressed.connect(_on_hide_pressed)

	if maximize_button:
		maximize_button.icon = null
		maximize_button.text = "❐" if _is_maximized else "□"
		maximize_button.custom_minimum_size = Vector2(20, 16)
		maximize_button.size = Vector2(20, 16)
		maximize_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		maximize_button.add_theme_font_override("font", FONT_MONO)
		maximize_button.add_theme_font_size_override("font_size", 7)
		maximize_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		maximize_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		maximize_button.add_theme_stylebox_override("normal", btn_normal)
		maximize_button.add_theme_stylebox_override("hover", btn_hover)
		maximize_button.add_theme_stylebox_override("pressed", btn_pressed)
		if not maximize_button.pressed.is_connected(_toggle_maximize):
			maximize_button.pressed.connect(_toggle_maximize)

	if exit_button:
		exit_button.icon = null
		exit_button.text = "✕"
		exit_button.custom_minimum_size = Vector2(22, 16)
		exit_button.size = Vector2(22, 16)
		exit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		exit_button.add_theme_font_override("font", FONT_MONO)
		exit_button.add_theme_font_size_override("font_size", 7)
		exit_button.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		exit_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
		exit_button.add_theme_stylebox_override("normal", btn_normal)
		exit_button.add_theme_stylebox_override("hover", close_hover)
		exit_button.add_theme_stylebox_override("pressed", close_pressed)
		if not exit_button.pressed.is_connected(_on_exit_pressed):
			exit_button.pressed.connect(_on_exit_pressed)

	if head and not head.gui_input.is_connected(_on_header_gui_input):
		head.gui_input.connect(_on_header_gui_input)

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.double_click:
			_toggle_maximize()

func _toggle_maximize() -> void:
	var win := get_node_or_null("ColorRect") as Control
	if not win:
		return
	
	_is_maximized = !_is_maximized
	if _is_maximized:
		_pre_maximize_pos = win.position
		_pre_maximize_size = win.size
		win.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		win.position = Vector2(2, 2)
		win.size = Vector2(476, 246)
		win.custom_minimum_size = Vector2(476, 246)
		if maximize_button:
			maximize_button.text = "❐"
	else:
		win.position = _pre_maximize_pos
		win.size = _pre_maximize_size
		win.custom_minimum_size = _pre_maximize_size
		if maximize_button:
			maximize_button.text = "□"
