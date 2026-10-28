class_name InteractObject
extends StaticBody2D

signal interaction_requested(object: InteractObject)
signal player_approached(object: InteractObject, player: Node2D)
signal player_left(object: InteractObject, player: Node2D)

@export var object_id: String = "object"
@export var prompt_message: String = "Press Space to inspect"
@export var debug_mode: bool = false

@export_group("Item Pickup")
@export var gives_item: bool = false
@export var item_id: String = ""
@export var item_name: String = ""
@export var item_icon: Texture2D
@export var item_description: String = ""
@export var hide_on_pickup: bool = false

@onready var interaction_area: Area2D = $InteractionArea

var _is_player_nearby: bool = false
var _nearby_players: Dictionary = {}

func _ready() -> void:
	# Connect both body and area detection for maximum compatibility
	interaction_area.set_collision_mask_value(1, true)
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

	if gives_item and not item_id.is_empty():
		var inv = get_node_or_null("/root/InventoryManager")
		if inv:
			var slot: int = inv.add_item(item_id, item_name, item_icon, item_description)
			if slot != -1 and hide_on_pickup:
				hide()
				collision_layer = 0
				if interaction_area:
					interaction_area.collision_layer = 0

	interaction_requested.emit(self)

func _on_body_entered(body: Node2D) -> void:
	if body is BasePlayer or body is CharacterBody2D:
		_update_player_presence(body, "body", true)

func _on_body_exited(body: Node2D) -> void:
	if body is BasePlayer or body is CharacterBody2D:
		_update_player_presence(body, "body", false)

func _on_area_entered(area: Area2D) -> void:
	# Check if this area belongs to a player (Player's InteractionArea)
	var owner_node = area.get_parent()
	if owner_node and (owner_node is BasePlayer or owner_node is CharacterBody2D):
		_update_player_presence(owner_node, "area", true)

func _on_area_exited(area: Area2D) -> void:
	# Check if this area belongs to a player
	var owner_node = area.get_parent()
	if owner_node and (owner_node is BasePlayer or owner_node is CharacterBody2D):
		_update_player_presence(owner_node, "area", false)

func _update_player_presence(player: Node2D, detector: String, is_present: bool) -> void:
	var player_id: int = player.get_instance_id()
	var detectors: Dictionary = _nearby_players.get(player_id, {"body": false, "area": false})
	var was_any_player_nearby: bool = not _nearby_players.is_empty()
	detectors[detector] = is_present
	var is_nearby: bool = bool(detectors.get("body", false)) or bool(detectors.get("area", false))
	if is_nearby:
		_nearby_players[player_id] = detectors
	else:
		_nearby_players.erase(player_id)
	_is_player_nearby = not _nearby_players.is_empty()
	if not was_any_player_nearby and _is_player_nearby:
		if debug_mode:
			print("[InteractObject] Player approached %s" % object_id)
		player_approached.emit(self, player)
	elif was_any_player_nearby and not _is_player_nearby:
		if debug_mode:
			print("[InteractObject] Player left %s" % object_id)
		player_left.emit(self, player)

func _update_placeholder_color() -> void:
	var colors: Dictionary = {
		"computer": Color(0.35, 0.75, 0.95),
		"bookshelf": Color(0.75, 0.55, 0.3),
		"notebook": Color(0.9, 0.85, 0.45),
		"lamp": Color(0.95, 0.8, 0.35)
	}
	if has_node("Sprite2D"):
		$Sprite2D.modulate = colors.get(object_id, Color.WHITE)
