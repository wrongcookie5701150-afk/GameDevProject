class_name GGDiskApp extends Control

signal folder_downloaded
signal minimize_requested
signal close_requested

@onready var hide_button: Button = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Hide
@onready var exit_button: Button = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Exit
@onready var download_button: Button = $ColorRect/VBoxContainer/Utility/IconBar/Download
@onready var report_item: PanelContainer = $ColorRect/VBoxContainer/MarginContainer/GridContainer/PanelContainer
@onready var title_label: Label = $ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/Label

var _is_downloaded: bool = false

func _ready() -> void:
	if hide_button:
		hide_button.pressed.connect(_on_hide_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	if download_button:
		download_button.pressed.connect(_on_download_pressed)
		download_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		download_button.tooltip_text = "ดาวน์โหลดโฟลเดอร์งานกลุ่ม (Download Folder)"
	
	# Clicking on the report panel or download icon also triggers download
	if report_item:
		report_item.mouse_filter = Control.MOUSE_FILTER_STOP
		report_item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		report_item.gui_input.connect(_on_report_item_gui_input)

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
