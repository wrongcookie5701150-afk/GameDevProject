# res://Scripts/Core/BaseWorldScene.gd
class_name BaseWorldScene
extends Node2D

signal tutorial_completed

@export var player_node: BasePlayer

func _ready() -> void:
	setup_scene()

func setup_scene() -> void:
	if not player_node:
		player_node = find_child("Player", true, false) as BasePlayer

	if player_node:
		player_node.interaction_requested.connect(_on_player_interacted)

func trigger_event(event_id: String) -> void:
	if event_id == "tutorial_finish":
		tutorial_completed.emit()

func _on_player_interacted(_player: BasePlayer) -> void:
	# Override ฟังก์ชั่นนี้ในฉากย่อยเพื่อเช็กการโต้ตอบ
	pass
