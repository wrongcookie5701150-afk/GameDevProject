extends Control

## Main Menu controller: handles navigation, modal popups, and localization.

@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton

@onready var continue_modal: Control = %ContinueModal
@onready var settings_modal: Control = %SettingsModal

const INTRO_SCENE_PATH: String = "res://Scenes/Scene_01_Intro.tscn"

var current_language_idx: int = 0

func _ready() -> void:
	_connect_signals()
	if settings_modal and "current_language_idx" in settings_modal:
		_apply_language(settings_modal.current_language_idx)
	else:
		_apply_language(0)
	if start_button:
		start_button.call_deferred("grab_focus")

func _connect_signals() -> void:
	# Main menu buttons
	if start_button and not start_button.pressed.is_connected(_on_start_button_pressed):
		start_button.pressed.connect(_on_start_button_pressed)
	if continue_button and not continue_button.pressed.is_connected(_on_continue_button_pressed):
		continue_button.pressed.connect(_on_continue_button_pressed)
	if settings_button and not settings_button.pressed.is_connected(_on_settings_button_pressed):
		settings_button.pressed.connect(_on_settings_button_pressed)
	if exit_button and not exit_button.pressed.is_connected(_on_exit_button_pressed):
		exit_button.pressed.connect(_on_exit_button_pressed)

	# Modal callbacks
	if continue_modal and continue_modal.has_signal("closed") and not continue_modal.closed.is_connected(_on_continue_modal_closed):
		continue_modal.closed.connect(_on_continue_modal_closed)
	if settings_modal and settings_modal.has_signal("closed") and not settings_modal.closed.is_connected(_on_settings_modal_closed):
		settings_modal.closed.connect(_on_settings_modal_closed)
	if settings_modal and settings_modal.has_signal("language_changed") and not settings_modal.language_changed.is_connected(_on_language_changed):
		settings_modal.language_changed.connect(_on_language_changed)

func _on_start_button_pressed() -> void:
	# Reset game session state and launch Scene 1 Cutscene via SceneRouter
	if has_node("/root/SceneRouter"):
		SceneRouter.goto_scene_1_intro()
	elif ResourceLoader.exists(INTRO_SCENE_PATH):
		get_tree().change_scene_to_file(INTRO_SCENE_PATH)
	else:
		push_error("Scene not found: %s" % INTRO_SCENE_PATH)

func _on_continue_button_pressed() -> void:
	# Open save slot / continue modal
	if continue_modal:
		if continue_modal.has_method("open"):
			continue_modal.open()
		else:
			continue_modal.show()

func _on_settings_button_pressed() -> void:
	# Open settings modal
	if settings_modal:
		if settings_modal.has_method("open"):
			settings_modal.open()
		else:
			settings_modal.show()

func _on_exit_button_pressed() -> void:
	# Quit desktop app
	get_tree().quit()

func _on_continue_modal_closed() -> void:
	if continue_button:
		continue_button.grab_focus()

func _on_settings_modal_closed() -> void:
	if settings_button:
		settings_button.grab_focus()

func _on_language_changed(index: int) -> void:
	_apply_language(index)

func _apply_language(idx: int) -> void:
	current_language_idx = idx
	if idx == 0:
		if start_button: start_button.text = "New Game"
		if continue_button: continue_button.text = "Continue"
		if settings_button: settings_button.text = "Settings"
		if exit_button: exit_button.text = "Exit"
	else:
		if start_button: start_button.text = "เริ่มเกมใหม่"
		if continue_button: continue_button.text = "เล่นต่อ"
		if settings_button: settings_button.text = "ตั้งค่า"
		if exit_button: exit_button.text = "ออกจากเกม"

	if continue_modal and continue_modal.has_method("apply_language"):
		continue_modal.apply_language(idx)
	if settings_modal and settings_modal.has_method("apply_language") and settings_modal.current_language_idx != idx:
		settings_modal.apply_language(idx)
