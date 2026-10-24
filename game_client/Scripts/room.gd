class_name BedroomRoomMap extends Node2D

## Room map handler
## If room.tscn is executed directly as standalone scene (e.g. F6 in editor),
## it automatically redirects to Scene_02_Tutorial.tscn for the full bedroom scene.

const BEDROOM_SCENE_PATH: String = "res://Scenes/Scene_02_Tutorial.tscn"

func _ready() -> void:
	if get_tree() and get_tree().current_scene == self:
		if has_node("/root/SceneRouter"):
			SceneRouter.goto_scene_2_tutorial()
		elif ResourceLoader.exists(BEDROOM_SCENE_PATH):
			get_tree().change_scene_to_file(BEDROOM_SCENE_PATH)
