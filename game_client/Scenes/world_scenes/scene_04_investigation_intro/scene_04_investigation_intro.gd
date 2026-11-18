extends BaseWorldScene

const SCENE_05_PATH: String = "res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn"

@onready var player: BasePlayer = $Playground/Player
@onready var status_label: Label = find_child("TaskObjective", true, false) as Label
@onready var phone_toggle_button: Button = find_child("PhoneToggleButton", true, false) as Button
@onready var inspect_hint: Button = find_child("InspectHint", true, false) as Button
@onready var phone_panel: Control = find_child("PhonePanel", true, false) as Control
@onready var playground: Node = $Playground
@onready var ev_drive_panel: Panel = find_child("EVDrivePanel", true, false) as Panel
@onready var ev_drive_label: Label = get_node_or_null("CanvasLayer/EVDrivePanel/Content/Label") as Label

var tao_dam_object: InteractObject
var bookshelf_object: InteractObject
var ev_drive_object: InteractObject
var computer_object: InteractObject
var object_detail: Label
var _nearby_object: InteractObject

var _chat_with_march_completed: bool = false
var _taodam_ready_on_desk: bool = false
var _bookshelf_inspected: bool = false
var _ev_drive_collected: bool = false
var _forensic_image_created: bool = false
var _last_interact_frame: int = -1
var _last_interact_obj: InteractObject = null
var _ev_panel_opened_frame: int = -1

func _ready() -> void:
	super._ready()
	player_node = player
	
	if player:
		object_detail = player.get_node_or_null("ObjectDatail")
	if not object_detail:
		object_detail = find_child("ObjectDatail", true, false) as Label
	if object_detail:
		object_detail.set_anchors_preset(Control.PRESET_TOP_LEFT)
		object_detail.position = Vector2(-70.0, -49.0)
		object_detail.size = Vector2(160.0, 20.0)
		object_detail.hide()

	if ev_drive_panel:
		ev_drive_panel.hide()
	if inspect_hint:
		inspect_hint.hide()
		inspect_hint.focus_mode = Control.FOCUS_NONE
		inspect_hint.pressed.connect(func() -> void:
			if _nearby_object:
				_on_interactable_requested(_nearby_object)
		)
	
	if status_label:
		status_label.text = "     ภารกิจ: กด [C] เพื่อเปิดมือถือ\n           - คุยขอคำปรึกษาจากพี่มาร์ช (March)"
	
	if phone_panel:
		phone_panel.hide()
		if phone_panel.has_method("switch_to_contact"):
			phone_panel.current_contact = "march"
		if phone_panel.has_signal("march_chat_completed"):
			phone_panel.march_chat_completed.connect(_on_march_chat_completed)
		if phone_panel.has_signal("closed"):
			phone_panel.closed.connect(_on_phone_closed)
	
	if phone_toggle_button:
		phone_toggle_button.focus_mode = Control.FOCUS_NONE
		phone_toggle_button.pressed.connect(_toggle_phone)
	
	var ev_close_btn: Button = get_node_or_null("CanvasLayer/EVDrivePanel/Content/CloseButton") as Button
	if ev_close_btn:
		ev_close_btn.pressed.connect(_on_ev_panel_close_pressed)
	
	_connect_all_interact_objects()
	
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and "investigation_phase" in inv and inv.investigation_phase == 2:
		# ผู้เล่นสืบสวนบนเต่าดำเสร็จแล้ว กลับมาห้องนอนเพื่อแปะโน้ตและไปเครื่อง PC
		_chat_with_march_completed = true
		_bookshelf_inspected = true
		_ev_drive_collected = true
		_forensic_image_created = true
		_taodam_ready_on_desk = true
		if ev_drive_object:
			ev_drive_object.hide()
			ev_drive_object.collision_layer = 0
			if ev_drive_object.interaction_area:
				ev_drive_object.interaction_area.collision_layer = 0
		if tao_dam_object:
			tao_dam_object.show()
			tao_dam_object.collision_layer = 1
			if tao_dam_object.interaction_area:
				tao_dam_object.interaction_area.collision_layer = 2
				tao_dam_object.interaction_area.monitoring = true
				tao_dam_object.interaction_area.monitorable = true
		if phone_panel:
			if phone_panel.has_method("set_task_completed"):
				phone_panel.set_task_completed("isolate_network", true)
				phone_panel.set_task_completed("prepare_taodam", true)
				phone_panel.set_task_completed("make_image", true)
				phone_panel.set_task_completed("open_taodam", true)
			if phone_panel.has_method("add_task"):
				phone_panel.add_task("pin_notes", "นำโน้ตความรู้ทั้ง 3 แผ่นไปแปะที่ NoteBoard [Spacebar]", false)
				phone_panel.add_task("recover_pc", "เดินไปที่เครื่อง PC ของเมย์ [Spacebar] เพื่อกู้คืนข้อมูล", false)
		_refresh_objective_text()
	elif inv and inv.has_method("has_item") and inv.has_item("ev_drive"):
		_ev_drive_collected = true
		_bookshelf_inspected = true
		_taodam_ready_on_desk = true
		if ev_drive_object:
			ev_drive_object.hide()
			ev_drive_object.collision_layer = 0
			if ev_drive_object.interaction_area:
				ev_drive_object.interaction_area.collision_layer = 0
		if tao_dam_object:
			tao_dam_object.show()
			tao_dam_object.collision_layer = 1
			if tao_dam_object.interaction_area:
				tao_dam_object.interaction_area.collision_layer = 2
				tao_dam_object.interaction_area.monitoring = true
				tao_dam_object.interaction_area.monitorable = true
	else:
		if ev_drive_object:
			ev_drive_object.show()
		# Hide tao_dam_object until bookshelf is inspected
		if tao_dam_object:
			tao_dam_object.hide()
			tao_dam_object.collision_layer = 0
			if tao_dam_object.interaction_area:
				tao_dam_object.interaction_area.collision_layer = 0
				tao_dam_object.interaction_area.monitoring = false
				tao_dam_object.interaction_area.monitorable = false

	if player:
		player.set_movement_enabled(true)

func _connect_all_interact_objects() -> void:
	var objects = find_children("*", "InteractObject", true, false)
	for node in objects:
		var child: InteractObject = node as InteractObject
		if not child:
			continue
		if child.object_id == "object" and child.name == "Desktop":
			child.object_id = "computer"
			child.prompt_message = "- กด [Spacebar] ใช้คอมพิวเตอร์"
		var oid: String = child.object_id.to_lower()
		if oid == "taodam" or oid == "notebook":
			tao_dam_object = child
		elif oid == "bookshelf":
			bookshelf_object = child
		elif oid == "ev_drive" or child.name.to_lower() == "evdrive":
			child.object_id = "ev_drive"
			child.gives_item = false
			ev_drive_object = child
		elif oid == "computer" or oid == "desktop":
			computer_object = child
		
		if not child.interaction_requested.is_connected(_on_interactable_requested):
			child.interaction_requested.connect(_on_interactable_requested)
		if not child.player_approached.is_connected(_on_interactable_approached):
			child.player_approached.connect(_on_interactable_approached)
		if not child.player_left.is_connected(_on_interactable_left):
			child.player_left.connect(_on_interactable_left)

func _unhandled_input(event: InputEvent) -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return

	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		if _close_active_overlay():
			get_viewport().set_input_as_handled()
			return

	if ev_drive_panel and ev_drive_panel.visible and Engine.get_process_frames() != _ev_panel_opened_frame:
		if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
			_on_ev_panel_close_pressed()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("Chat"):
		_toggle_phone("chat")
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("Task"):
		_toggle_phone("task")
		get_viewport().set_input_as_handled()
		return

func _close_active_overlay() -> bool:
	if note_board_ui and note_board_ui.visible:
		if note_board_ui.has_method("close_board"):
			note_board_ui.close_board()
		else:
			note_board_ui.hide()
		return true
	if phone_panel and phone_panel.visible:
		_toggle_phone()
		return true
	if ev_drive_panel and ev_drive_panel.visible:
		ev_drive_panel.hide()
		if player:
			player.set_movement_enabled(true)
		return true
	return false

func _toggle_phone(target_mode: String = "") -> void:
	if not phone_panel:
		return
	if not phone_panel.visible:
		if phone_panel.has_method("open_phone"):
			phone_panel.open_phone(target_mode)
			phone_panel.switch_to_contact("march")
		else:
			phone_panel.show()
		
		if (target_mode == "" or target_mode == "chat") and not _chat_with_march_completed:
			if player:
				player.set_movement_enabled(false)
			if phone_panel.has_method("start_march_chat"):
				phone_panel.start_march_chat()
	else:
		if target_mode != "" and phone_panel.has_method("toggle_phone"):
			phone_panel.toggle_phone(target_mode)
		else:
			if phone_panel.has_method("close_phone"):
				phone_panel.close_phone()
			else:
				phone_panel.hide()

func _on_march_chat_completed() -> void:
	_chat_with_march_completed = true
	if is_instance_valid(player):
		player.set_movement_enabled(true)
	_refresh_objective_text()

func _on_phone_closed() -> void:
	if not _chat_with_march_completed:
		_on_march_chat_completed()
	if is_instance_valid(player):
		player.set_movement_enabled(true)

func _on_player_interacted(_p: BasePlayer) -> void:
	if _nearby_object:
		_on_interactable_requested(_nearby_object)

func _on_interactable_approached(object: InteractObject, _p: Node2D) -> void:
	_nearby_object = object
	if inspect_hint:
		if object and not object.prompt_message.is_empty():
			inspect_hint.text = object.prompt_message
		else:
			inspect_hint.text = "- กด [Spacebar] เพื่อสำรวจ"
		inspect_hint.show()
	
	if object_detail and object:
		var inv_chk = get_node_or_null("/root/InventoryManager")
		match object.object_id.to_lower():
			"taodam", "notebook":
				if inv_chk and "investigation_phase" in inv_chk and inv_chk.investigation_phase >= 2:
					object_detail.text = "TaoDam: สืบสวนครบทุกขั้นตอนแล้ว (ไปที่กระดาน NoteBoard และ PC)"
				elif not _forensic_image_created:
					object_detail.text = "TaoDam: วางพร้อมแล้ว! ไปทำ Image ใส่แฟลชไดรฟ์ที่ PC ก่อน"
				else:
					object_detail.text = "TaoDam: กด [Spacebar] เพื่อเปิดเครื่องเต่าดำ"
			"bookshelf":
				if not _bookshelf_inspected:
					object_detail.text = "Bookshelf: กด [Spacebar] เพื่อค้นหาเต่าดำและ Flashdrive"
				else:
					object_detail.text = "Bookshelf: หยิบเต่าดำและ Flashdrive (EV-DRIVE) มาแล้ว"
			"ev_drive":
				if not _ev_drive_collected:
					object_detail.text = "Flashdrive (EV-DRIVE): กด [Spacebar] เพื่อหยิบแฟลชไดรฟ์"
				else:
					object_detail.text = "Bookshelf: เก็บแฟลชไดรฟ์ EV-DRIVE มาแล้ว"
			"computer", "desktop":
				if inv_chk and "investigation_phase" in inv_chk and inv_chk.investigation_phase == 2:
					object_detail.text = "PC ของเมย์: กด [Spacebar] เพื่อเริ่มขั้นตอนกู้คืนข้อมูล (Scene 7)"
				elif not _bookshelf_inspected or not _ev_drive_collected:
					object_detail.text = "PC ของเมย์: ไปหยิบเต่าดำและแฟลชไดรฟ์จากชั้นหนังสือมาก่อน"
				elif not _forensic_image_created:
					object_detail.text = "PC ของเมย์: กด [Spacebar] เพื่อทำ Forensic Image ลงแฟลชไดรฟ์"
				else:
					object_detail.text = "PC ของเมย์: ทำ Forensic Image เสร็จแล้ว ไปที่เต่าดำได้เลย"
			"note_board":
				if inv_chk and "investigation_phase" in inv_chk and inv_chk.investigation_phase == 2:
					object_detail.text = "NoteBoard: กด [Spacebar] เพื่อแปะโน้ตทั้ง 3 แผ่นและทบทวนความรู้"
				else:
					object_detail.text = "NoteBoard: กระดานสรุปเบาะแส & องค์ความรู้"
			_:
				object_detail.text = object.name
		object_detail.show()

func _on_interactable_left(object: InteractObject, _p: Node2D) -> void:
	if _nearby_object == object:
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
	var obj_id: String = interact_object.object_id.to_lower()
	if obj_id == "object" and (interact_object.name.to_lower() == "evdrive" or interact_object.name.to_lower() == "ev_drive"):
		obj_id = "ev_drive"
	elif obj_id == "object" and interact_object.name.to_lower() == "desktop":
		obj_id = "computer"

	if obj_id == "note_board":
		var inv_mgr = get_node_or_null("/root/InventoryManager")
		if inv_mgr and inv_mgr.has_method("pin_all_inventory_notes_to_board"):
			inv_mgr.pin_all_inventory_notes_to_board()
		if phone_panel and phone_panel.has_method("set_task_completed"):
			phone_panel.set_task_completed("pin_first_note", true)
			phone_panel.set_task_completed("pin_notes", true)
		open_note_board()
		_refresh_objective_text()
		return

	if not _chat_with_march_completed:
		if status_label:
			status_label.text = "     ภารกิจ: กด [C] เพื่อคุยกับพี่มาร์ชในมือถือก่อน!"
		if object_detail:
			object_detail.text = "เมย์: ต้องกด [C] ปรึกษาพี่มาร์ชในมือถือก่อนว่าควรทำยังไง!"
			object_detail.show()
		return

	match obj_id:
		"taodam", "notebook":
			var inv_mgr = get_node_or_null("/root/InventoryManager")
			if inv_mgr and "investigation_phase" in inv_mgr and inv_mgr.investigation_phase >= 2:
				if object_detail:
					object_detail.text = "เมย์: สืบสวนบนเต่าดำครบทุกขั้นตอนแล้ว! นำโน้ตไปแปะที่บอร์ดแล้วไปกู้คืนที่ PC"
					object_detail.show()
				return

			if not _forensic_image_created:
				if object_detail:
					object_detail.text = "เมย์: ต้องเอา Flashdrive ไปเสียบเครื่อง PC เพื่อทำ Forensic Image ก่อน!"
					object_detail.show()
			else:
				_enter_taodam_isolation_scene()

		"bookshelf", "ev_drive":
			if not _bookshelf_inspected or not _ev_drive_collected:
				_inspect_bookshelf()
			else:
				if object_detail:
					object_detail.text = "เมย์: เก็บเต่าดำและ Flashdrive (EV-DRIVE) ออกมาเรียบร้อยแล้ว"
					object_detail.show()

		"computer", "desktop":
			var inv_mgr = get_node_or_null("/root/InventoryManager")
			if inv_mgr and "investigation_phase" in inv_mgr and inv_mgr.investigation_phase == 2:
				var has_unpinned: bool = false
				for slot in inv_mgr.slots:
					if not slot.is_empty() and String(slot.get("id", "")).begins_with("note_"):
						has_unpinned = true
						break
				if has_unpinned:
					if object_detail:
						object_detail.text = "เมย์: นำโน้ตความรู้ในกระเป๋าไปแปะที่กระดาน NoteBoard ก่อนดีกว่า!"
						object_detail.show()
					return
				
				# ปลดล็อกโน้ตครบแล้ว -> กู้คืน PC ใน Scene 7
				if phone_panel and phone_panel.has_method("set_task_completed"):
					phone_panel.set_task_completed("recover_pc", true)
				inv_mgr.investigation_phase = 3
				var result: Error = get_tree().change_scene_to_file("res://scenes/scene_07_recovery/Scene_07_Recovery.tscn")
				if result != OK:
					push_error("Unable to load Scene 7 recovery: %s (error %d)" % ["res://scenes/scene_07_recovery/Scene_07_Recovery.tscn", result])
				return

			if not _bookshelf_inspected or not _ev_drive_collected:
				if object_detail:
					object_detail.text = "เมย์: ต้องไปหยิบเต่าดำและ Flashdrive จากชั้นหนังสือมาก่อน!"
					object_detail.show()
				_refresh_objective_text()
			elif not _forensic_image_created:
				_create_forensic_image_on_pc()
			else:
				if object_detail:
					object_detail.text = "เมย์: คัดลอก Forensic Image ลง Flashdrive แล้ว ไปเปิดเต่าดำได้เลย!"
					object_detail.show()

func _inspect_bookshelf() -> void:
	_bookshelf_inspected = true
	_taodam_ready_on_desk = true
	if tao_dam_object:
		tao_dam_object.show()
		tao_dam_object.collision_layer = 1
		if tao_dam_object.interaction_area:
			tao_dam_object.interaction_area.collision_layer = 2
			tao_dam_object.interaction_area.monitoring = true
			tao_dam_object.interaction_area.monitorable = true
	
	_collect_ev_drive()
	
	if phone_panel and phone_panel.has_method("set_task_completed"):
		phone_panel.set_task_completed("prepare_taodam", true)
		phone_panel.add_task("make_image", "นำ Flashdrive ไปทำ Forensic Image ที่เครื่อง PC", true)
	
	if object_detail:
		object_detail.text = "เมย์: พบโน้ตบุ๊ก 'เต่าดำ' และ Flashdrive ที่ชั้นหนังสือ! นำเต่าดำมาวางบนโต๊ะแล้ว"
		object_detail.show()
	_refresh_objective_text()

func _collect_ev_drive() -> void:
	_ev_drive_collected = true
	if ev_drive_object:
		ev_drive_object.hide()
		ev_drive_object.collision_layer = 0
		if ev_drive_object.interaction_area:
			ev_drive_object.interaction_area.collision_layer = 0
	if inspect_hint:
		inspect_hint.hide()
	
	var inv_manager = get_node_or_null("/root/InventoryManager")
	if inv_manager and inv_manager.has_method("add_item"):
		inv_manager.add_item("ev_drive", "EV-DRIVE", load("res://assets/Icon32x32/disk.png"), "EV-DRIVE (E:) - แฟลชไดรฟ์สำหรับเก็บ Forensic Image")
	
	_refresh_objective_text()

func _create_forensic_image_on_pc() -> void:
	_forensic_image_created = true
	_taodam_ready_on_desk = true
	_ev_panel_opened_frame = Engine.get_process_frames()
	if player:
		player.set_movement_enabled(false)
	
	# แจกโน้ตองค์ความรู้ #1 (Forensic Image & Chain of Custody)
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("award_knowledge_note"):
		inv.award_knowledge_note("note_forensic_prep", self)

	if phone_panel and phone_panel.has_method("set_task_completed"):
		phone_panel.set_task_completed("make_image", true)
		phone_panel.add_task("pin_first_note", "นำโน้ตแผ่นแรกไปแปะที่ NoteBoard [Spacebar]", true)
		phone_panel.add_task("open_taodam", "ไปที่โน้ตบุ๊ก 'เต่าดำ' เพื่อตรวจสอบการ Isolate", false)
	
	if ev_drive_label:
		ev_drive_label.text = "สร้าง Forensic Image ลงแฟลชไดรฟ์ EV-DRIVE (E:) สำเร็จ!\nคัดลอก Report_Final.docx, Windows_Event_Log.txt, Drive_Activity.log\nและ Evidence_Manifest.txt (จดบันทึกโน้ตความรู้ #1 ลงกระเป๋าแล้ว)"
	if ev_drive_panel:
		ev_drive_panel.show()
	_refresh_objective_text()

func _on_ev_panel_close_pressed() -> void:
	if ev_drive_panel:
		ev_drive_panel.hide()
	if player:
		player.set_movement_enabled(true)
	_refresh_objective_text()

func _refresh_objective_text() -> void:
	if not status_label:
		return
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and "investigation_phase" in inv and inv.investigation_phase == 2:
		var has_notes: bool = false
		for slot in inv.slots:
			if not slot.is_empty() and String(slot.get("id", "")).begins_with("note_"):
				has_notes = true
				break
		if has_notes:
			status_label.text = "     ภารกิจ: นำโน้ตความรู้ทั้ง 3 แผ่นในกระเป๋าไปแปะที่ NoteBoard [Spacebar]\n           - จากนั้นไปที่เครื่อง PC ของเมย์ เพื่อทำการกู้คืนข้อมูล"
		else:
			status_label.text = "     ภารกิจ: เดินไปที่เครื่อง PC ของเมย์ [Spacebar]\n           - เพื่อทำการกู้คืนข้อมูลและจัดทำรายงาน (Scene 7)"
		return

	if not _chat_with_march_completed:
		status_label.text = "     ภารกิจ: กด [C] เพื่อเปิดมือถือ\n           - คุยขอคำปรึกษาจากพี่มาร์ช (March)"
	elif not _bookshelf_inspected or not _ev_drive_collected:
		status_label.text = "     ภารกิจ: เดินไปที่ชั้นหนังสือ (Bookshelf)\n           - กด [Spacebar] หาเต่าดำและ Flashdrive"
	elif not _forensic_image_created:
		status_label.text = "     ภารกิจ: นำ Flashdrive ไปที่เครื่อง PC ของเมย์\n           - กด [Spacebar] เพื่อทำ Forensic Image"
	else:
		var has_forensic_note: bool = false
		if inv and "slots" in inv:
			for slot in inv.slots:
				if not slot.is_empty() and slot.get("id", "") == "note_forensic_prep":
					has_forensic_note = true
					break
		if has_forensic_note:
			status_label.text = "     ภารกิจ: เดินไปที่กระดาน NoteBoard [Spacebar]\n           - แปะโน้ตแผ่นแรกเพื่อทบทวน จากนั้นไปเปิดเครื่อง 'เต่าดำ'"
		else:
			status_label.text = "     ภารกิจ: ไปที่โน้ตบุ๊ก 'เต่าดำ' บนโต๊ะ\n           - กด [Spacebar] เพื่อตรวจเช็คการ Isolate"

func _enter_taodam_isolation_scene() -> void:
	if phone_panel and phone_panel.has_method("set_task_completed"):
		phone_panel.set_task_completed("open_taodam", true)
	
	# นำ EV-DRIVE ออกจากกระเป๋า (เสียบคาไว้ที่เต่าดำแล้ว คืนช่องว่าง 3 ช่องให้พร้อมรับโน้ตใน Scene 6)
	var inv = get_node_or_null("/root/InventoryManager")
	if inv:
		if inv.has_method("remove_item"):
			inv.remove_item("ev_drive")
		inv.investigation_phase = 1

	var result: Error = get_tree().change_scene_to_file(SCENE_05_PATH)
	if result != OK:
		push_error("Unable to load Scene 5: %s (error %d)" % [SCENE_05_PATH, result])

