# res://Scripts/Core/BasePlayer.gd
class_name BasePlayer
extends CharacterBody2D

signal interaction_requested(player: BasePlayer)

@export var movement_enabled: bool = true

func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO

func interact() -> void:
	if movement_enabled:
		interaction_requested.emit(self)
