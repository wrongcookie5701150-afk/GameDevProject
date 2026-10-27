class_name MSWordApp extends Control

signal macro_enabled
signal typing_completed
signal save_pressed
signal minimize_requested
signal close_requested

@onready var macro_banner: PanelContainer = $ColorRect/VBoxContainer/MacroBanner
@onready var enable_button: Button = $ColorRect/VBoxContainer/MacroBanner/HBox/EnableButton
@onready var status_label: Label = $ColorRect/VBoxContainer/MacroBanner/HBox/StatusLabel
@onready var typing_puzzle: TypingGamePuzzle = $ColorRect/VBoxContainer/MarginContainer/TypingPuzzle
@onready var report_editor: TextEdit = $ColorRect/VBoxContainer/MarginContainer/TypingPuzzle/TextEdit
@onready var hide_button: Button = $ColorRect/VBoxContainer/ColorRect/MarginContainer/HBoxContainer2/HBoxContainer/Hide
@onready var exit_button: Button = $ColorRect/VBoxContainer/ColorRect/MarginContainer/HBoxContainer2/HBoxContainer/Exit
@onready var save_button: Button = find_child("SaveButton", true, false) as Button

var _is_macro_enabled: bool = false

func _ready() -> void:
	if not hide_button:
		hide_button = find_child("Hide", true, false) as Button
	if not exit_button:
		exit_button = find_child("Exit", true, false) as Button
	if not enable_button:
		enable_button = find_child("EnableButton", true, false) as Button
	if not save_button:
		save_button = find_child("SaveButton", true, false) as Button
		if not save_button:
			save_button = find_child("Button", true, false) as Button
		
	if enable_button:
		enable_button.pressed.connect(_on_enable_content_pressed)
		enable_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if typing_puzzle and typing_puzzle.has_signal("scene_completion_requested"):
		typing_puzzle.scene_completion_requested.connect(_on_typing_completed)
	if hide_button:
		hide_button.pressed.connect(_on_hide_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	if save_button:
		save_button.pressed.connect(_on_save_pressed)
		save_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if typing_puzzle and report_editor:
		typing_puzzle.configure_input(report_editor)
		typing_puzzle.hide()
	
	if macro_banner:
		macro_banner.show()

func open_document() -> void:
	show()
	if not _is_macro_enabled:
		if macro_banner:
			macro_banner.show()
		if typing_puzzle:
			typing_puzzle.hide()
	else:
		if macro_banner:
			macro_banner.hide()
		if typing_puzzle:
			typing_puzzle.show()

func _on_enable_content_pressed() -> void:
	_is_macro_enabled = true
	if macro_banner:
		macro_banner.hide()
	if status_label:
		status_label.text = "Macros enabled. Document is being processed..."
	
	# Trigger typing puzzle
	if typing_puzzle:
		typing_puzzle.show()
		if typing_puzzle.has_method("start_puzzle"):
			typing_puzzle.start_puzzle()
	
	macro_enabled.emit()

func _on_typing_completed() -> void:
	if typing_puzzle:
		typing_puzzle.hide()
	if status_label:
		status_label.text = "Document processed successfully!"
	typing_completed.emit()

func _on_save_pressed() -> void:
	save_pressed.emit()

func highlight_save_button() -> void:
	if save_button:
		save_button.add_theme_color_override("font_color", Color(0.1, 0.7, 0.2, 1.0))
		save_button.tooltip_text = "Click to save Report_Final.docx"

func _on_hide_pressed() -> void:
	hide()
	minimize_requested.emit()

func _on_exit_pressed() -> void:
	hide()
	close_requested.emit()

func is_macro_enabled() -> bool:
	return _is_macro_enabled
