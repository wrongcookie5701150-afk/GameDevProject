class_name DownloadedFolderApp extends Control

signal file_opened(file_name: String)
signal minimize_requested
signal close_requested

const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

var hide_button: Button
var exit_button: Button
var maximize_button: Button
var report_file_panel: Control
var title_label: Label

var _is_maximized: bool = false
var _pre_maximize_pos: Vector2 = Vector2(90, 45)
var _pre_maximize_size: Vector2 = Vector2(300, 180)

func _ready() -> void:
	var win := get_node_or_null("ColorRect") as Control
	var head := get_node_or_null("ColorRect/VBoxContainer/ColorRect") as Control
	var global_settings = get_node_or_null("/root/GlobalSettings")
	if win and head and global_settings and global_settings.has_method("make_window_draggable"):
		global_settings.make_window_draggable(win, head)

	_resolve_nodes()
	_apply_modern_styling()
	_setup_buttons()
	_setup_file_items()

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

	var item_panels: Array[Control] = []
	if report_file_panel: item_panels.append(report_file_panel)
	var pp_p = find_child("PPPresentation", true, false) as Control
	if pp_p: item_panels.append(pp_p)
	var png_p = find_child("PNGNetworkDiagram", true, false) as Control
	if png_p: item_panels.append(png_p)
	var alert_p = find_child("AlertFile", true, false) as Control
	if alert_p: item_panels.append(alert_p)

	for p in item_panels:
		var card_sb := StyleBoxFlat.new()
		card_sb.bg_color = Color(0.88, 0.91, 0.95, 0.8)
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
		card_sb.border_color = Color(0.5, 0.7, 0.9, 0.6)
		card_sb.content_margin_left = 4.0
		card_sb.content_margin_right = 4.0
		card_sb.content_margin_top = 3.0
		card_sb.content_margin_bottom = 3.0
		p.add_theme_stylebox_override("panel", card_sb)

		for lbl in p.find_children("*", "Label", true, false):
			(lbl as Label).add_theme_font_size_override("font_size", 6)
		for tex in p.find_children("*", "TextureRect", true, false):
			(tex as TextureRect).custom_minimum_size = Vector2(11, 11)

func _resolve_nodes() -> void:
	hide_button = find_child("Hide", true, false) as Button
	if not hide_button:
		hide_button = get_node_or_null("ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Hide") as Button
	
	exit_button = find_child("Exit", true, false) as Button
	if not exit_button:
		exit_button = get_node_or_null("ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Exit") as Button
	
	report_file_panel = find_child("MSWordReport", true, false) as Control
	if not report_file_panel:
		report_file_panel = find_child("PanelContainer", true, false) as Control
	
	title_label = find_child("Label", true, false) as Label

func _setup_buttons() -> void:
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

func _setup_file_items() -> void:
	# 1. Report.docx file
	if report_file_panel:
		report_file_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		report_file_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_set_mouse_filter_recursive(report_file_panel, Control.MOUSE_FILTER_IGNORE)
		report_file_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		if not report_file_panel.gui_input.is_connected(_on_report_gui_input):
			report_file_panel.gui_input.connect(_on_report_gui_input)
		
		# Visual hover effect
		report_file_panel.mouse_entered.connect(func() -> void:
			var hover_box: StyleBoxFlat = StyleBoxFlat.new()
			hover_box.bg_color = Color(0.85, 0.90, 0.98, 1.0)
			hover_box.set_border_width_all(1)
			hover_box.border_color = Color(0.35, 0.65, 0.95, 1.0)
			hover_box.corner_radius_top_left = 7
			hover_box.corner_radius_top_right = 7
			hover_box.corner_radius_bottom_right = 7
			hover_box.corner_radius_bottom_left = 7
			hover_box.shadow_size = 6
			hover_box.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
			hover_box.shadow_offset = Vector2(0, 3)
			report_file_panel.add_theme_stylebox_override("panel", hover_box)
		)
		report_file_panel.mouse_exited.connect(func() -> void:
			report_file_panel.remove_theme_stylebox_override("panel")
		)
	
	# 2. Presentation.ppxt
	var pp_panel: Control = find_child("PPPresentation", true, false) as Control
	if pp_panel:
		pp_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		pp_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_set_mouse_filter_recursive(pp_panel, Control.MOUSE_FILTER_IGNORE)
		pp_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		pp_panel.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				file_opened.emit("Presentation.ppxt")
		)
	
	# 3. Network Diagram.png
	var png_panel: Control = find_child("PNGNetworkDiagram", true, false) as Control
	if png_panel:
		png_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		png_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_set_mouse_filter_recursive(png_panel, Control.MOUSE_FILTER_IGNORE)
		png_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		png_panel.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				file_opened.emit("Network Diagram.png")
		)
	
	# 4. Alert / ReadMe file
	var alert_panel: Control = find_child("AlertFile", true, false) as Control
	if alert_panel:
		alert_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		alert_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_set_mouse_filter_recursive(alert_panel, Control.MOUSE_FILTER_IGNORE)
		alert_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		alert_panel.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				file_opened.emit("ReadMe_to_recovery.txt")
		)

func _set_mouse_filter_recursive(node: Node, filter_mode: Control.MouseFilter) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = filter_mode
			_set_mouse_filter_recursive(child, filter_mode)

func _on_report_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("[DownloadedFolder] Report file clicked, opening Report.docx...")
		file_opened.emit("Report.docx")

func _on_hide_pressed() -> void:
	print("[DownloadedFolder] Hide (Minimize) button pressed")
	hide()
	minimize_requested.emit()

func _on_exit_pressed() -> void:
	print("[DownloadedFolder] Exit (Close) button pressed")
	hide()
	close_requested.emit()
