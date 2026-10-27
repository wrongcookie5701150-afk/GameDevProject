class_name DownloadedFolderApp extends Control

signal file_opened(file_name: String)
signal minimize_requested
signal close_requested

@onready var hide_button: Button = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Hide
@onready var exit_button: Button = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Exit
@onready var report_file_panel: PanelContainer = $ColorRect/VBoxContainer/MarginContainer/FilesList/PanelContainer
@onready var title_label: Label = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/Label

func _ready() -> void:
	if hide_button:
		hide_button.pressed.connect(_on_hide_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	
	if report_file_panel:
		report_file_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		report_file_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		report_file_panel.gui_input.connect(_on_report_gui_input)
		_set_mouse_filter_recursive(report_file_panel, Control.MOUSE_FILTER_PASS)
		report_file_panel.mouse_filter = Control.MOUSE_FILTER_STOP

func _set_mouse_filter_recursive(node: Node, filter_mode: Control.MouseFilter) -> void:
	for child in node.get_children():
		if child is Control:
			child.mouse_filter = filter_mode
			_set_mouse_filter_recursive(child, filter_mode)

func _on_report_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		file_opened.emit("report.docx")

func _on_hide_pressed() -> void:
	hide()
	minimize_requested.emit()

func _on_exit_pressed() -> void:
	hide()
	close_requested.emit()
