extends Control

signal macro_enabled
signal typing_completed

var macro_banner: PanelContainer
var enable_button: Button
var status_label: Label
var typing_puzzle: Control
var hide_button: Button
var exit_button: Button

var _is_macro_enabled: bool = false

func _ready() -> void:
	macro_banner = get_node_or_null("MacroBanner")
	enable_button = get_node_or_null("MacroBanner/EnableButton")
	status_label = get_node_or_null("MacroBanner/StatusLabel")
	typing_puzzle = get_node_or_null("TypingPuzzle")
	hide_button = get_node_or_null("ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Hide")
	exit_button = get_node_or_null("ColorRect/VBoxContainer/ColorRect/space/HBoxContainer2/HBoxContainer/Exit")
	
	if enable_button:
		enable_button.pressed.connect(_on_enable_content_pressed)
	if typing_puzzle and typing_puzzle.has_signal("scene_completion_requested"):
		typing_puzzle.scene_completion_requested.connect(_on_typing_completed)
	if hide_button:
		hide_button.pressed.connect(_on_hide_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)

func open_document() -> void:
	if not _is_macro_enabled:
		_on_enable_content_pressed()

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

func _on_hide_pressed() -> void:
	hide()

func _on_exit_pressed() -> void:
	hide()

func is_macro_enabled() -> bool:
	return _is_macro_enabled
