# res://scenes/world_scenes/BaseWorldScene.gd
class_name BaseWorldScene
extends Node2D

signal tutorial_completed

@export var player_node: BasePlayer
var note_board_ui: Control

func _ready() -> void:
	setup_scene()

func setup_scene() -> void:
	if not player_node:
		player_node = find_child("Player", true, false) as BasePlayer

	if player_node and not player_node.interaction_requested.is_connected(_on_player_interacted):
		player_node.interaction_requested.connect(_on_player_interacted)

	_setup_inventory_ui()

func open_note_board() -> void:
	if not note_board_ui:
		var nb_controls: Array[Node] = find_children("NoteBoard", "Control", true, false)
		if not nb_controls.is_empty():
			note_board_ui = nb_controls[0] as Control
	if not note_board_ui:
		var nb_scene = load("res://scenes/initial/note_board.tscn")
		if nb_scene:
			note_board_ui = nb_scene.instantiate() as Control
			var canvas = find_child("CanvasLayer", true, false)
			if canvas:
				canvas.add_child(note_board_ui)
			else:
				var new_canvas: CanvasLayer = CanvasLayer.new()
				new_canvas.name = "NoteBoardCanvas"
				add_child(new_canvas)
				new_canvas.add_child(note_board_ui)
	if note_board_ui:
		if note_board_ui.has_signal("closed") and not note_board_ui.closed.is_connected(_on_note_board_closed):
			note_board_ui.closed.connect(_on_note_board_closed)
		var inv = get_node_or_null("/root/InventoryManager")
		if inv:
			inv.hide_inventory()
		if note_board_ui.has_method("open_board"):
			note_board_ui.open_board()
		else:
			note_board_ui.show()

func _on_note_board_closed() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv:
		inv.show_inventory()

func _setup_inventory_ui() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("show_inventory"):
		inv.show_inventory()
	if find_child("InventoryBar", true, false):
		return
	var inv_scene: PackedScene = load("res://ui/overlays/inventory_bar.tscn")
	if not inv_scene:
		return
	var inv_ui: Control = inv_scene.instantiate() as Control
	if not inv_ui:
		return
	inv_ui.name = "InventoryBar"
	var canvas = find_child("CanvasLayer", true, false)
	if canvas:
		canvas.add_child(inv_ui)
	else:
		var new_canvas: CanvasLayer = CanvasLayer.new()
		new_canvas.name = "InventoryCanvas"
		add_child(new_canvas)
		new_canvas.add_child(inv_ui)

func trigger_event(event_id: StringName) -> void:
	if event_id == &"tutorial_finish":
		tutorial_completed.emit()

func _on_player_interacted(_player: BasePlayer) -> void:
	# Override ฟังก์ชั่นนี้ในฉากย่อยเพื่อเช็กการโต้ตอบ
	pass
