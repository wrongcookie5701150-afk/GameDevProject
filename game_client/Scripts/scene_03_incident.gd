class_name Scene03Incident extends Control

## Scene 3: Incident Cutscene (21:21 - 21:25)
## Panel 1: Timelapse (19:02 -> 21:21 -> 21:22) & Notification popups
## Panel 2: Group folder display with clean files (21:22 - 21:23)
## Panel 3: Files encrypted to .locked & screen glitch (21:23)
## Panel 4: Ransomware note popup in Notepad (21:24)
## Panel 5: March Discord message & transition to Scene 4 (21:25)

signal scene_3_started
signal scene_3_completed

const SCENE_04_INVESTIGATION_PATH: String = "res://Scenes/investigation_screen.tscn"

@onready var desktop: Control = $Desktop

func _ready() -> void:
	scene_3_started.emit()
	if desktop:
		if desktop.has_signal("scene_3_cutscene_completed"):
			desktop.scene_3_cutscene_completed.connect(_on_incident_cutscene_completed)
		if desktop.has_method("start_incident_cutscene_direct"):
			desktop.call_deferred("start_incident_cutscene_direct")

func _on_incident_cutscene_completed() -> void:
	scene_3_completed.emit()
	if has_node("/root/SceneRouter"):
		SceneRouter.goto_scene_4_investigation()
	elif ResourceLoader.exists(SCENE_04_INVESTIGATION_PATH):
		get_tree().change_scene_to_file(SCENE_04_INVESTIGATION_PATH)

func _unhandled_input(event: InputEvent) -> void:
	# Developer quick-skip for debugging
	if OS.is_debug_build() and event is InputEventKey and event.pressed and event.keycode == KEY_F10:
		_on_incident_cutscene_completed()
