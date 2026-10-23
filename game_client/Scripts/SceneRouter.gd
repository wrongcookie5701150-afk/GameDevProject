extends Node

## Autoload: SceneRouter
## Centralized scene transition controller ensuring loose coupling between game scenes.

signal scene_transition_started(target_scene_path: String)
signal scene_transition_completed(new_scene_path: String)

const SCENE_MAIN_MENU: String = "res://Scenes/ui/MainMenu.tscn"
const SCENE_01_INTRO: String = "res://Scenes/Scene_01_Intro.tscn"
const SCENE_02_TUTORIAL: String = "res://Scenes/Scene_02_Tutorial.tscn"
const SCENE_02_DESKTOP: String = "res://Scenes/Initial/desktop_screen.tscn"
const SCENE_03_INCIDENT: String = "res://Scenes/Scene_03_Incident.tscn"
const SCENE_04_INVESTIGATION: String = "res://Scenes/investigation_screen.tscn"

func goto_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("SceneRouter: Target scene not found: %s" % path)
		return
	scene_transition_started.emit(path)
	var err := get_tree().change_scene_to_file(path)
	if err == OK:
		scene_transition_completed.emit(path)
	else:
		push_error("SceneRouter: Failed to load scene %s with code %d" % [path, err])

func goto_main_menu() -> void:
	goto_scene(SCENE_MAIN_MENU)

func goto_scene_1_intro() -> void:
	if has_node("/root/GameState"):
		GameState.reset_to_initial_state()
		GameState.scene_phase = "SCENE_01_INTRO"
		GameState.is_scene_4 = false
	goto_scene(SCENE_01_INTRO)

func goto_scene_2_tutorial() -> void:
	if has_node("/root/GameState"):
		GameState.scene_phase = "SCENE_2_TUTORIAL"
		GameState.is_scene_4 = false
	goto_scene(SCENE_02_TUTORIAL)

func goto_scene_2_desktop() -> void:
	if has_node("/root/GameState"):
		GameState.scene_phase = "SCENE_2_DESKTOP"
	goto_scene(SCENE_02_DESKTOP)

func goto_scene_3_incident() -> void:
	if has_node("/root/GameState"):
		GameState.scene_phase = "SCENE_3_INCIDENT"
	goto_scene(SCENE_03_INCIDENT)

func goto_scene_4_investigation() -> void:
	if has_node("/root/GameState"):
		GameState.scene_phase = "SCENE_4_INVESTIGATION"
		GameState.is_scene_4 = true
		GameState.clock = "21:25"
	goto_scene(SCENE_04_INVESTIGATION)

func goto_scene_4_bedroom() -> void:
	if has_node("/root/GameState"):
		GameState.scene_phase = "SCENE_4_INVESTIGATION_INTRO"
		GameState.is_scene_4 = true
		GameState.clock = "21:25"
	goto_scene(SCENE_02_TUTORIAL)
