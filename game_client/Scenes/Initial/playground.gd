class_name Playground
extends Node2D

@onready var room: Node2D = get_node_or_null("Room")
@onready var map: Node2D = get_node_or_null("Room") if get_node_or_null("Room") else get_node_or_null("Map")
@onready var player: BasePlayer = get_node_or_null("Player") as BasePlayer
@onready var inventory_bar: Control = get_node_or_null("Textbox/InventoryBar")

# Quick accessor properties for standard room interact objects
var desktop_object: InteractObject:
	get: return get_interact_object("computer")

var taodam_object: InteractObject:
	get: return get_interact_object("taodam")

var bookshelf_object: InteractObject:
	get: return get_interact_object("bookshelf")

var ev_drive_object: InteractObject:
	get: return get_interact_object("ev_drive")

var bed_object: InteractObject:
	get: return get_interact_object("bed")

var speaker_object: InteractObject:
	get: return get_interact_object("speaker")

var lamp_object: InteractObject:
	get: return get_interact_object("lamp")

var noteboard_object: InteractObject:
	get: return get_interact_object("note_board")

func get_interact_object(id_or_name: String) -> InteractObject:
	# Check inside Room/InteractObject or Map/InteractObject
	var container: Node = get_node_or_null("Room/InteractObject")
	if not container:
		container = get_node_or_null("Map/InteractObject")
	if container:
		# 1. Direct child by node name
		var direct: Node = container.get_node_or_null(id_or_name)
		if direct is InteractObject:
			return direct
		
		# 2. Match by object_id or name (case-insensitive)
		for child: Node in container.get_children():
			if child is InteractObject:
				if child.object_id.to_lower() == id_or_name.to_lower() or child.name.to_lower() == id_or_name.to_lower():
					return child
				# Aliases
				if (id_or_name.to_lower() == "taodam" and child.name.to_lower() == "notebook") or \
				   (id_or_name.to_lower() == "computer" and child.name.to_lower() == "desktop") or \
				   (id_or_name.to_lower() == "ev_drive" and child.name.to_lower() == "evdrive") or \
				   (id_or_name.to_lower() == "flashdrive" and (child.name.to_lower() == "evdrive" or child.object_id.to_lower() == "ev_drive")):
					return child

	# 3. Fallback search anywhere in Playground
	for node: Node in find_children("*", "InteractObject", true, false):
		var obj: InteractObject = node as InteractObject
		if obj:
			var obj_id_low := obj.object_id.to_lower()
			var name_low := obj.name.to_lower()
			var target_low := id_or_name.to_lower()
			if obj_id_low == target_low or name_low == target_low:
				return obj
			if target_low in ["ev_drive", "flashdrive", "evdrive"] and (obj_id_low in ["ev_drive", "flashdrive"] or name_low in ["evdrive", "ev_drive"]):
				return obj
	return null

func get_all_interact_objects() -> Array[InteractObject]:
	var list: Array[InteractObject] = []
	for node: Node in find_children("*", "InteractObject", true, false):
		var obj: InteractObject = node as InteractObject
		if obj:
			list.append(obj)
	return list

func show_inventory() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("show_inventory"):
		inv.show_inventory()
	elif inventory_bar:
		inventory_bar.show()

func hide_inventory() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("hide_inventory"):
		inv.hide_inventory()
	elif inventory_bar:
		inventory_bar.hide()
