extends Control

## FloatMenu Controller: ควบคุมเมนู Pause และเปิด SettingsModal ผ่าน Code

@onready var resume_button: Button = %Resume
@onready var settings_button: Button = %Settings
@onready var main_menu_button: Button = %MainManu
@onready var quit_button: Button = %QuitGame

const SETTINGS_MODAL_SCENE: PackedScene = preload("res://ui/menus/SettingsModal.tscn")
const MAIN_MENU_SCENE_PATH: String = "res://ui/menus/MainMenu.tscn"

var settings_modal_instance: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_connect_signals()

func _connect_signals() -> void:
	if resume_button and not resume_button.pressed.is_connected(_on_resume_pressed):
		resume_button.pressed.connect(_on_resume_pressed)
	if settings_button and not settings_button.pressed.is_connected(_on_settings_pressed):
		settings_button.pressed.connect(_on_settings_pressed)
	if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_pressed):
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	if quit_button and not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if settings_modal_instance and is_instance_valid(settings_modal_instance) and settings_modal_instance.visible:
				return
			
			_toggle_pause()
			get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	var new_pause_state: bool = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	
	if new_pause_state and resume_button:
		resume_button.grab_focus()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()

func _on_settings_pressed() -> void:
	if not settings_modal_instance or not is_instance_valid(settings_modal_instance):
		settings_modal_instance = SETTINGS_MODAL_SCENE.instantiate() as Control
		settings_modal_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		
		get_parent().add_child(settings_modal_instance)
		
		if settings_modal_instance.has_signal("closed"):
			settings_modal_instance.closed.connect(_on_settings_closed)

	if settings_modal_instance.has_method("open"):
		settings_modal_instance.open()
	else:
		settings_modal_instance.show()

func _on_settings_closed() -> void:
	if settings_button:
		settings_button.grab_focus()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	if ResourceLoader.exists(MAIN_MENU_SCENE_PATH):
		get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
	else:
		push_error("Main Menu scene not found at path: " + MAIN_MENU_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
