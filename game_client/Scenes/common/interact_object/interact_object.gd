class_name InteractObject
extends StaticBody2D

signal interaction_requested(object: InteractObject)
signal player_approached(object: InteractObject, player: Node2D)
signal player_left(object: InteractObject, player: Node2D)

@export var object_id: String = "object"
@export var prompt_message: String = "Press Space to inspect"
@export var debug_mode: bool = false

@onready var interaction_area: Area2D = $InteractionArea

var _is_player_nearby: bool = false

func _ready() -> void:
	# Connect both body and area detection for maximum compatibility
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)
	_update_placeholder_color()

	if debug_mode:
		print("[InteractObject] %s initialized at position %s" % [object_id, position])

func interact() -> void:
	if debug_mode:
		print("[InteractObject] %s interacted with!" % object_id)
	interaction_requested.emit(self)

func _on_body_entered(body: Node2D) -> void:
	if body is BasePlayer or body is CharacterBody2D:
		if not _is_player_nearby:
			_is_player_nearby = true
			if debug_mode:
				print("[InteractObject] Player approached %s (body detection)" % object_id)
			player_approached.emit(self, body)

func _on_body_exited(body: Node2D) -> void:
	if body is BasePlayer or body is CharacterBody2D:
		if _is_player_nearby:
			_is_player_nearby = false
			if debug_mode:
				print("[InteractObject] Player left %s (body detection)" % object_id)
			player_left.emit(self, body)

func _on_area_entered(area: Area2D) -> void:
	# Check if this area belongs to a player (Player's InteractionArea)
	var owner_node = area.get_parent()
	if owner_node and (owner_node is BasePlayer or owner_node is CharacterBody2D):
		if not _is_player_nearby:
			_is_player_nearby = true
			if debug_mode:
				print("[InteractObject] Player approached %s (area detection)" % object_id)
			player_approached.emit(self, owner_node)

func _on_area_exited(area: Area2D) -> void:
	# Check if this area belongs to a player
	var owner_node = area.get_parent()
	if owner_node and (owner_node is BasePlayer or owner_node is CharacterBody2D):
		if _is_player_nearby:
			_is_player_nearby = false
			if debug_mode:
				print("[InteractObject] Player left %s (area detection)" % object_id)
			player_left.emit(self, owner_node)

func _update_placeholder_color() -> void:
	var colors: Dictionary = {
		"computer": Color(0.35, 0.75, 0.95),
		"bookshelf": Color(0.75, 0.55, 0.3),
		"notebook": Color(0.9, 0.85, 0.45),
		"lamp": Color(0.95, 0.8, 0.35)
	}
	if has_node("Sprite2D"):
		$Sprite2D.modulate = colors.get(object_id, Color.WHITE)
