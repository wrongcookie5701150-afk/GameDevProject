# res://scenes/common/player/BasePlayer.gd
class_name BasePlayer
extends CharacterBody2D

signal interaction_requested(player: BasePlayer)
signal interacted_with(target: Node)

@export var move_speed: float = 125.0
@export var movement_enabled: bool = true
@export var interaction_area_path: NodePath = ^"InteractionArea"

@onready var _interaction_area: Area2D = get_node_or_null(interaction_area_path) as Area2D

func _physics_process(_delta: float) -> void:
	if not movement_enabled:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * move_speed
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()

func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not enabled:
		velocity = Vector2.ZERO

func interact() -> void:
	if not movement_enabled:
		return

	interaction_requested.emit(self)
	if not is_instance_valid(_interaction_area):
		return

	# Check for overlapping interactable objects (Area2D from InteractObject)
	for target: Area2D in _interaction_area.get_overlapping_areas():
		var owner = target.get_parent()
		if owner and owner.has_method("interact"):
			owner.interact()
			interacted_with.emit(owner)

	# Also check for overlapping bodies (fallback)
	for target: Node2D in _interaction_area.get_overlapping_bodies():
		if target.has_method("interact"):
			target.interact()
			interacted_with.emit(target)
