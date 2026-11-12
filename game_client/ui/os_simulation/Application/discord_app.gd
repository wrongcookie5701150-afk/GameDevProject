class_name DiscordApp extends Control

signal minimize_requested
signal close_requested

@onready var hide_button: Button = find_child("Hide", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button

func _ready() -> void:
	var win := get_node_or_null("ColorRect") as Control
	var head := get_node_or_null("ColorRect/VBoxContainer/ColorRect") as Control
	var global_settings = get_node_or_null("/root/GlobalSettings")
	if win and head and global_settings and global_settings.has_method("make_window_draggable"):
		global_settings.make_window_draggable(win, head)

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
