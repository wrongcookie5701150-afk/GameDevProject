extends BaseWorldScene

const SCENE_03_PATH: String = "res://scenes/scene_03_incident/Scene_03_Incident.tscn"

var phone_panel: Control
var message_status_label: Label
var task_objective: Label
var inspect_hint: Button
var object_detail: Label
var playground: Node2D
var room_map: Node2D

var _messages_read: bool = false
var _nearby_object: InteractObject

func _ready() -> void:
	super._ready()
	
	# Resolve all nodes with null checks
	playground = get_node_or_null("Playground")
	room_map = get_node_or_null("Playground/Room")
	if not room_map:
		room_map = get_node_or_null("Playground/Map")
	player_node = get_node_or_null("Playground/Player")
	if not player_node:
		player_node = find_child("Player", true, false) as BasePlayer
	
	phone_panel = get_node_or_null("CanvasLayer/PhonePanel")
	message_status_label = get_node_or_null("CanvasLayer/PhonePanel/Content/MessageStatusLabel")
	task_objective = get_node_or_null("CanvasLayer/TaskObjective")
	inspect_hint = get_node_or_null("CanvasLayer/InspectHint")
	
	if player_node:
		object_detail = player_node.get_node_or_null("ObjectDatail")
	if not object_detail:
		object_detail = get_node_or_null("Playground/Player/ObjectDatail")
	if not object_detail:
		object_detail = find_child("ObjectDatail", true, false) as Label
	
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if phone_panel:
		phone_panel.hide()
		if phone_panel.has_signal("messages_read"):
			phone_panel.messages_read.connect(_on_phone_messages_read)
		if phone_panel.has_signal("closed"):
			phone_panel.closed.connect(_on_phone_closed)
	if task_objective:
		task_objective.text = "     ภารกิจ: กด [P] เพื่อเช็คแชทเมษา\n           - จากนั้นไปที่คอมพิวเตอร์ [Spacebar]"
		task_objective.show()
	if inspect_hint:
		inspect_hint.hide()
		inspect_hint.focus_mode = Control.FOCUS_NONE
		if not inspect_hint.pressed.is_connected(_on_inspect_hint_pressed):
			inspect_hint.pressed.connect(_on_inspect_hint_pressed)
	if object_detail:
		object_detail.set_anchors_preset(Control.PRESET_TOP_LEFT)
		object_detail.position = Vector2(-70.0, -49.0)
		object_detail.size = Vector2(150.0, 20.0)
		object_detail.hide()
	
	# Connect UI buttons
	var phone_toggle_btn = get_node_or_null("CanvasLayer/PhoneToggleButton") as Button
	if phone_toggle_btn:
		phone_toggle_btn.focus_mode = Control.FOCUS_NONE
		if not phone_toggle_btn.pressed.is_connected(_toggle_phone):
			phone_toggle_btn.pressed.connect(_toggle_phone)
	
	var read_msg_btn = get_node_or_null("CanvasLayer/PhonePanel/Content/ReadMessagesButton") as Button
	if read_msg_btn and not read_msg_btn.pressed.is_connected(_on_read_messages_pressed):
		read_msg_btn.pressed.connect(_on_read_messages_pressed)
	
	# Find and connect all interact objects reliably
	_connect_all_interact_objects()

func _connect_all_interact_objects() -> void:
	var objects = find_children("*", "InteractObject", true, false)
	for node in objects:
		var child = node as InteractObject
		if not child:
			continue
		if child.object_id == "object" and child.name == "Desktop":
			child.object_id = "computer"
			child.prompt_message = "Press Space to use the computer"
		# Hide and disable EV-DRIVE during tutorial scene so it cannot be picked up or block movement
		if child.object_id.to_lower() == "ev_drive" or child.name.to_lower() == "evdrive":
			child.gives_item = false
			child.hide()
			child.collision_layer = 0
			if child.interaction_area:
				child.interaction_area.collision_layer = 0
				child.interaction_area.monitoring = false
				child.interaction_area.monitorable = false
			continue
		if not child.player_approached.is_connected(_on_interactable_approached):
			child.player_approached.connect(_on_interactable_approached)
		if not child.player_left.is_connected(_on_interactable_left):
			child.player_left.connect(_on_interactable_left)
		if not child.interaction_requested.is_connected(_on_interactable_requested):
			child.interaction_requested.connect(_on_interactable_requested)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		if phone_panel and phone_panel.visible:
			_toggle_phone()
			get_viewport().set_input_as_handled()
			return
		if note_board_ui and note_board_ui.visible:
			if note_board_ui.has_method("close_board"):
				note_board_ui.close_board()
			else:
				note_board_ui.hide()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			var focused: Control = get_viewport().gui_get_focus_owner()
			if focused is LineEdit or focused is TextEdit:
				return
			_toggle_phone()
			get_viewport().set_input_as_handled()
			return

var _last_interact_frame: int = -1
var _last_interact_obj: InteractObject = null

func _on_player_interacted(_player: BasePlayer) -> void:
	if _nearby_object:
		_on_interactable_requested(_nearby_object)

func _on_inspect_hint_pressed() -> void:
	if _nearby_object:
		_on_interactable_requested(_nearby_object)

func _on_interactable_approached(interact_object: InteractObject, _player: Node2D) -> void:
	_nearby_object = interact_object
	var object_name = interact_object.name if interact_object.name else "Unknown Object"
	
	if inspect_hint:
		inspect_hint.show()
	
	if object_detail:
		match interact_object.object_id:
			"computer", "desktop":
				object_detail.text = "Computer: กด [Spacebar] เพื่อเปิดคอมทำงานกลุ่ม"
			"notebook", "taodam":
				object_detail.text = "TaoDam: โน้ตบุ๊กเครื่องสำรอง (ยังไม่ได้ใช้ตอนนี้)"
			"note_board":
				object_detail.text = "NoteBoard: กระดานบันทึกเบาะแส"
			"lamp":
				object_detail.text = "Lamp: โคมไฟอ่านหนังสือของเมย์"
			"bookshelf":
				object_detail.text = "Bookshelf: ชั้นหนังสือเรียนวิชา Cybersecurity"
			"bed":
				object_detail.text = "Bed: เตียงนอนของเมย์ ต้องรีบปั่นงานก่อนนอน!"
			"speaker":
				object_detail.text = "Speaker: ลำโพงตั้งโต๊ะ"
			_:
				object_detail.text = object_name
		object_detail.show()

func _on_interactable_left(interact_object: InteractObject, _player: Node2D) -> void:
	if _nearby_object == interact_object:
		_nearby_object = null
		if inspect_hint:
			inspect_hint.hide()
		if object_detail:
			object_detail.hide()

func _on_interactable_requested(interact_object: InteractObject) -> void:
	if not interact_object:
		return
	var cur_frame: int = Engine.get_process_frames()
	if cur_frame == _last_interact_frame and _last_interact_obj == interact_object:
		return
	_last_interact_frame = cur_frame
	_last_interact_obj = interact_object
	match interact_object.object_id:
		"computer", "desktop":
			if not _messages_read:
				if task_objective:
					task_objective.text = "     ภารกิจ: กด [P] เพื่อเปิดมือถืออ่านแชทเมษาก่อน!"
				if object_detail:
					object_detail.text = "เมย์: ลองกด [P] เปิดมือถือดูข้อความที่เมษาส่งมาก่อนดีกว่า"
					object_detail.show()
				return
			_enter_pc_scene()
		"note_board":
			open_note_board()
		"notebook", "taodam":
			if object_detail:
				object_detail.text = "TaoDam: ตอนนี้ไปใช้เครื่อง PC หลักพิมพ์รายงานก่อนดีกว่า"
				object_detail.show()
		_:
			if object_detail:
				object_detail.show()

func _toggle_phone() -> void:
	if not phone_panel:
		return
	if phone_panel.has_method("toggle_phone"):
		phone_panel.toggle_phone()
	else:
		phone_panel.visible = not phone_panel.visible
	if phone_panel.visible and not _messages_read:
		_mark_messages_read()

func _on_phone_messages_read(contact: String) -> void:
	if contact == "mesa":
		_mark_messages_read()

func _on_phone_closed() -> void:
	if not _messages_read:
		_mark_messages_read()
	if player_node:
		player_node.set_movement_enabled(true)

func _on_read_messages_pressed() -> void:
	_mark_messages_read()
	if phone_panel:
		if phone_panel.has_method("close_phone"):
			phone_panel.close_phone()
		else:
			phone_panel.hide()

func _mark_messages_read() -> void:
	if _messages_read:
		return
	_messages_read = true
	if message_status_label:
		message_status_label.text = "Messages read"
	if task_objective:
		task_objective.text = "     ภารกิจ: เดินไปที่คอมพิวเตอร์ (PC)\n           - กด [Spacebar] เพื่อดาวน์โหลดและพิมพ์รายงาน"
	TelemetryManager.track_event(
		"Scene_02",
		"T01",
		"messages_read",
		0.0,
		true,
		1,
		false,
		{"message_count": 4}
	)

func _enter_pc_scene() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_03_PATH)
	if result != OK:
		push_error("Unable to load Scene 3: %s (error %d)" % [SCENE_03_PATH, result])

func _toggle_pause_menu() -> void:
	if has_node("/root/FloatMenu"):
		FloatMenu.toggle_pause()
