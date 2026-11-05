class_name DiscordApp extends Control

signal minimize_requested
signal close_requested

@onready var hide_button: Button = find_child("Hide", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button

func _ready() -> void:
	if hide_button:
		hide_button.pressed.connect(_on_hide_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)

func _on_hide_pressed() -> void:
	hide()
	minimize_requested.emit()

func _on_exit_pressed() -> void:
	hide()
	close_requested.emit()
