class_name DownloadedFolderApp extends Control

signal file_opened(file_name: String)
signal minimize_requested
signal close_requested

var hide_button: Button
var exit_button: Button
var report_file_panel: Control
var title_label: Label

func _ready() -> void:
	_resolve_nodes()
	_setup_buttons()
	_setup_file_items()

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
	if hide_button:
		hide_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hide_button.custom_minimum_size = Vector2(10, 8)
		if not hide_button.pressed.is_connected(_on_hide_pressed):
			hide_button.pressed.connect(_on_hide_pressed)
	
	if exit_button:
		exit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		exit_button.custom_minimum_size = Vector2(10, 8)
		if not exit_button.pressed.is_connected(_on_exit_pressed):
			exit_button.pressed.connect(_on_exit_pressed)

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
			hover_box.set_corner_radius_all(2)
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
