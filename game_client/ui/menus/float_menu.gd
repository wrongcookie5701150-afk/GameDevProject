extends CanvasLayer

## FloatMenu Controller: Global Pause Menu & Settings Modal Launcher

@onready var resume_button: Button = (get_node_or_null("%Resume") if get_node_or_null("%Resume") else get_node_or_null("%ResumeButton")) as Button
@onready var settings_button: Button = (get_node_or_null("%Settings") if get_node_or_null("%Settings") else get_node_or_null("%SettingsButton")) as Button
@onready var main_menu_button: Button = (get_node_or_null("%MainMenu") if get_node_or_null("%MainMenu") else get_node_or_null("%MainManu")) as Button
@onready var quit_button: Button = (get_node_or_null("%QuitGame") if get_node_or_null("%QuitGame") else get_node_or_null("%QuitGameButton")) as Button
@onready var menu_root: Control = $MenuRoot
@onready var settings_modal: Control = get_node_or_null("SettingsModal")

const MAIN_MENU_SCENE_PATH: String = "res://ui/menus/MainMenu.tscn"

var can_pause: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	hide_menu()
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

	if settings_modal and settings_modal.has_signal("closed") and not settings_modal.closed.is_connected(_on_settings_closed):
		settings_modal.closed.connect(_on_settings_closed)

func _unhandled_input(event: InputEvent) -> void:
	if not can_pause:
		return

	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path == MAIN_MENU_SCENE_PATH:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if settings_modal and is_instance_valid(settings_modal) and settings_modal.visible:
				return

			toggle_pause()
			get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if visible and menu_root and menu_root.visible:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	if not can_pause:
		return

	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path == MAIN_MENU_SCENE_PATH:
		return

	get_tree().paused = true
	visible = true
	if menu_root:
		menu_root.visible = true
	if resume_button:
		resume_button.call_deferred("grab_focus")

func resume_game() -> void:
	get_tree().paused = false
	hide_menu()

func hide_menu() -> void:
	visible = false
	if menu_root:
		menu_root.visible = false
	if settings_modal and is_instance_valid(settings_modal):
		settings_modal.visible = false

func _on_resume_pressed() -> void:
	resume_game()

func _on_settings_pressed() -> void:
	if settings_modal and is_instance_valid(settings_modal):
		if settings_modal.has_method("open"):
			settings_modal.open()
		else:
			settings_modal.show()

func _on_settings_closed() -> void:
	if settings_button and visible:
		settings_button.call_deferred("grab_focus")

func _on_main_menu_pressed() -> void:
	resume_game()
	if ResourceLoader.exists(MAIN_MENU_SCENE_PATH):
		get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
	else:
		push_error("Main Menu scene not found at path: " + MAIN_MENU_SCENE_PATH)

func _on_quit_pressed() -> void:
	get_tree().quit()
