class_name PhonePanelTaoDam
extends PhonePanelController

signal march_chat_completed
signal evidence_requested(task_id: String)

var march_chat_done: bool = false
var is_march_typing: bool = false
var _chat_queue: Array[Dictionary] = []
var _is_streaming_queue: bool = false
var _evidence_buttons: Dictionary = {}
var _chat_evidence_btn: Button = null

const TASK_T08_ID: String = "t08_hash"
const TASK_T08_TEXT: String = "เปิด CMD ตรวจสอบ MD5 Hash ของ Report_Final.docx (T08)"

const TASK_T06_ID: String = "t06_event_log"
const TASK_T06_TEXT: String = "ตรวจ Windows_Event_Log.txt หาเวลาเกิดเหตุ (T06)"

const TASK_T07_ID: String = "t07_drive_log"
const TASK_T07_TEXT: String = "ตรวจ Drive_Activity.log หาโดเมนปลอม Typosquatting (T07)"

const TASK_T09_ID: String = "t09_macro"
const TASK_T09_TEXT: String = "ตรวจโครงสร้าง Macro ใน Report_Final.docx (T09)"

const TASK_T10_ID: String = "t10_decoder"
const TASK_T10_TEXT: String = "ใช้แอป Decoder ถอดรหัสเพย์โหลด Helper & Mode (T10-11)"

const TASK_T12_ID: String = "t12_persistence"
const TASK_T12_TEXT: String = "วางแผนตัดวงจร Persistence 7 ขั้นตอนใน Safe Mode (T12)"

const INITIAL_CHAT_LINES: Array[Dictionary] = [
	{
		"sender": "March",
		"text": "น้องเมย์ เปิดเต่าดำติดแล้วใช่มั้ย? อิมเมจ EV-01 อยู่ในไดรฟ์ E: นะ"
	},
	{
		"sender": "May",
		"text": "เปิดติดแล้วค่ะพี่มาร์ช! ไดรฟ์ E: ขึ้นครบเลย ต้องเริ่มตรวจจากตรงไหนก่อนคะ?"
	},
	{
		"sender": "March",
		"text": "ขั้นแรกเลยนะ ให้เปิดโฟลเดอร์ Incident_Notes ดูไฟล์ Evidence_Manifest.txt แล้วเปิด CMD พิมพ์ certutil -hashfile Report_Final.docx MD5 ตรวจว่าค่า Hash ตรงกับ Manifest มั้ย",
		"is_task": true,
		"task_id": TASK_T08_ID,
		"task_text": TASK_T08_TEXT
	},
	{
		"sender": "May",
		"text": "รับทราบค่ะ หนูจะรีบเปิด CMD คำนวณค่า MD5 เทียบกับ Manifest เดี๋ยวนี้!"
	}
]

func _ready() -> void:
	current_contact = "march"
	march_history = ""
	super._ready()
	switch_to_contact("march")
	_setup_evidence_submission_ui()
	update_evidence_ui()
	start_initial_chat()

func _setup_evidence_submission_ui() -> void:
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	
	# 1. In ChatContent/Content: Add quick active evidence button right above HBoxContainer (the send bar)
	if chat_content:
		var send_hbox: Control = chat_content.find_child("HBoxContainer", true, false) as Control
		if send_hbox and not chat_content.has_node("ActiveEvidenceBtn"):
			_chat_evidence_btn = Button.new()
			_chat_evidence_btn.name = "ActiveEvidenceBtn"
			_chat_evidence_btn.text = "📝 ส่งผลตรวจ: ขั้นที่ 1 (MD5 Hash)"
			_chat_evidence_btn.custom_minimum_size = Vector2(0, 16)
			_chat_evidence_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if thai_font:
				_chat_evidence_btn.add_theme_font_override("font", thai_font)
			_chat_evidence_btn.add_theme_font_size_override("font_size", 6)
			_apply_evidence_button_style(_chat_evidence_btn)
			_chat_evidence_btn.pressed.connect(func() -> void:
				var target_id := _get_current_active_task_id()
				if not target_id.is_empty():
					evidence_requested.emit(target_id)
			)
			chat_content.add_child(_chat_evidence_btn)
			chat_content.move_child(_chat_evidence_btn, send_hbox.get_index())
			
	# 2. In TaskContent: Add shortcuts grid for all 6 tasks
	if task_content and not task_content.has_node("EvidenceGrid"):
		var grid := GridContainer.new()
		grid.name = "EvidenceGrid"
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 2)
		grid.add_theme_constant_override("v_separation", 2)
		
		var tasks_info: Array[Dictionary] = [
			{"id": TASK_T08_ID, "label": "1.Hash(T08)"},
			{"id": TASK_T06_ID, "label": "2.Event(T06)"},
			{"id": TASK_T07_ID, "label": "3.Drive(T07)"},
			{"id": TASK_T09_ID, "label": "4.Macro(T09)"},
			{"id": TASK_T10_ID, "label": "5.Decode(T10)"},
			{"id": TASK_T12_ID, "label": "6.Stop(T12)"}
		]
		
		for t: Dictionary in tasks_info:
			var btn := Button.new()
			btn.text = t["label"]
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.custom_minimum_size = Vector2(0, 14)
			btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var mono_font: FontFile = load("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")
			if mono_font:
				btn.add_theme_font_override("font", mono_font)
			btn.add_theme_font_size_override("font_size", 5)
			_apply_evidence_button_style(btn)
			var tid: String = t["id"]
			btn.pressed.connect(func() -> void:
				evidence_requested.emit(tid)
			)
			grid.add_child(btn)
			_evidence_buttons[tid] = btn
			
		var hint_lbl: Control = task_content.find_child("TaskHintLabel", true, false) as Control
		task_content.add_child(grid)
		if hint_lbl:
			task_content.move_child(grid, hint_lbl.get_index())

func _apply_evidence_button_style(btn: Button) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.22, 0.35, 0.95)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.3, 0.7, 1.0, 0.9)
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_right = 3
	sb.corner_radius_bottom_left = 3
	sb.content_margin_left = 4.0
	sb.content_margin_right = 4.0
	sb.content_margin_top = 2.0
	sb.content_margin_bottom = 2.0
	btn.add_theme_stylebox_override("normal", sb)

	var sb_h := sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = Color(0.18, 0.32, 0.5, 1.0)
	btn.add_theme_stylebox_override("hover", sb_h)

func _get_current_active_task_id() -> String:
	if not _is_task_done(TASK_T08_ID):
		return TASK_T08_ID
	if not _is_task_done(TASK_T06_ID):
		return TASK_T06_ID
	if not _is_task_done(TASK_T07_ID):
		return TASK_T07_ID
	if not _is_task_done(TASK_T09_ID):
		return TASK_T09_ID
	if not _is_task_done(TASK_T10_ID):
		return TASK_T10_ID
	if not _is_task_done(TASK_T12_ID):
		return TASK_T12_ID
	return ""

func update_evidence_ui() -> void:
	var active_id: String = _get_current_active_task_id()
	if _chat_evidence_btn:
		match active_id:
			TASK_T08_ID:
				_chat_evidence_btn.text = "📝 ส่งผลตรวจ: 1.MD5 Hash (T08)"
				_chat_evidence_btn.visible = true
			TASK_T06_ID:
				_chat_evidence_btn.text = "📝 ส่งผลตรวจ: 2.Event Log (T06)"
				_chat_evidence_btn.visible = true
			TASK_T07_ID:
				_chat_evidence_btn.text = "📝 ส่งผลตรวจ: 3.Drive Log (T07)"
				_chat_evidence_btn.visible = true
			TASK_T09_ID:
				_chat_evidence_btn.text = "📝 ส่งผลตรวจ: 4.Macro Doc (T09)"
				_chat_evidence_btn.visible = true
			TASK_T10_ID:
				_chat_evidence_btn.text = "📝 ส่งผลตรวจ: 5.Decoder (T10-11)"
				_chat_evidence_btn.visible = true
			TASK_T12_ID:
				_chat_evidence_btn.text = "📝 ส่งผลตรวจ: 6.Stop Persistence (T12)"
				_chat_evidence_btn.visible = true
			_:
				_chat_evidence_btn.text = "✅ สืบสวนครบ 6 ขั้นตอนแล้ว"
				_chat_evidence_btn.visible = true

	for tid: String in _evidence_buttons:
		var btn: Button = _evidence_buttons[tid]
		if is_instance_valid(btn):
			var done: bool = _is_task_done(tid)
			var base_label: String = btn.text.replace("✓ ", "")
			btn.text = ("✓ " if done else "") + base_label
			if done:
				btn.modulate = Color(0.6, 1.0, 0.75, 1.0)
			else:
				btn.modulate = Color(1.0, 1.0, 1.0, 1.0)

func send_march_hint(hint_text: String) -> void:
	play_task_chime()
	var line_str: String = "March: %s\n\n" % hint_text
	march_history += line_str
	if current_contact == "march" and messages_label:
		messages_label.text = march_history
	_scroll_to_bottom()

func _unhandled_input(event: InputEvent) -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return

	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		if visible:
			close_phone()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("Chat") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_P or event.keycode == KEY_C)):
		toggle_phone("chat")
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("Task") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T):
		toggle_phone("task")
		get_viewport().set_input_as_handled()
		return

func start_initial_chat() -> void:
	if march_chat_done or is_march_typing:
		return
	queue_march_dialogue(INITIAL_CHAT_LINES)

func queue_march_dialogue(lines: Array[Dictionary]) -> void:
	for line: Dictionary in lines:
		_chat_queue.append(line)
	if not _is_streaming_queue:
		_process_chat_queue()

func _process_chat_queue() -> void:
	if _chat_queue.is_empty():
		_is_streaming_queue = false
		is_march_typing = false
		if chat_name_btn:
			chat_name_btn.text = "March (พี่มาร์ช)"
		return

	_is_streaming_queue = true
	is_march_typing = true
	var item: Dictionary = _chat_queue.pop_front()
	var sender: String = str(item.get("sender", "March"))
	var text: String = str(item.get("text", ""))
	var is_task: bool = bool(item.get("is_task", false))
	var task_id: String = str(item.get("task_id", ""))
	var task_text: String = str(item.get("task_text", ""))

	if chat_name_btn:
		chat_name_btn.text = "%s (กำลังพิมพ์...)" % sender

	# Typing delay
	await get_tree().create_timer(0.6).timeout
	if not is_instance_valid(self):
		return

	var line_str: String = "%s: %s\n\n" % [sender, text]
	march_history += line_str
	if current_contact == "march" and messages_label:
		messages_label.text = march_history
	_scroll_to_bottom()

	if is_task:
		play_task_chime()
		add_task(task_id, task_text, false)

	if chat_name_btn:
		chat_name_btn.text = "March (พี่มาร์ช)"

	# Brief pause between messages
	await get_tree().create_timer(0.3).timeout
	if not is_instance_valid(self):
		return

	_process_chat_queue()

func on_hash_verified() -> void:
	set_task_completed(TASK_T08_ID, true)
	update_evidence_ui()
	queue_march_dialogue([
		{
			"sender": "March",
			"text": "ยอดเยี่ยมมากน้อง! ค่า MD5 ของ Report_Final.docx ตรงกับ Manifest เป๊ะ แสดงว่าหลักฐานสมบูรณ์ ไม่มีการถูกแก้ไข!"
		},
		{
			"sender": "March",
			"text": "ขั้นต่อไป ให้เข้าไปดูในโฟลเดอร์ Logs เปิดไฟล์ Windows_Event_Log.txt ดูเวลาที่เครื่องเริ่มรันไฟล์ Word เพื่อหา Timeline เกิดเหตุนะน้อง",
			"is_task": true,
			"task_id": TASK_T06_ID,
			"task_text": TASK_T06_TEXT
		}
	])

func on_event_log_verified() -> void:
	set_task_completed(TASK_T06_ID, true)
	update_evidence_ui()
	queue_march_dialogue([
		{
			"sender": "March",
			"text": "ชัดเจนเลย! เวลา 19:02:10 คือตอนที่เปิดไฟล์รายงาน (ก่อนเกิดเหตุคือ 18:55)"
		},
		{
			"sender": "March",
			"text": "ต่อไปให้เปิด Drive_Activity.log ดูว่าใครแชร์ไฟล์นี้มา สังเกตตัวสะกดโดเมนอีเมลดีๆ นะ!",
			"is_task": true,
			"task_id": TASK_T07_ID,
			"task_text": TASK_T07_TEXT
		}
	])

func on_drive_history_verified() -> void:
	set_task_completed(TASK_T07_ID, true)
	update_evidence_ui()
	queue_march_dialogue([
		{
			"sender": "March",
			"text": "จับโป๊ะได้แล้ว! @universcity.example เป็นโดเมนปลอม (Typosquatting) แน่ๆ!"
		},
		{
			"sender": "March",
			"text": "ทีนี้ลองตรวจโครงสร้างไฟล์ Report_Final.docx ใน Inspector ดูว่ามีโฟลเดอร์ Macro ซ่อนอยู่ตรงไหน",
			"is_task": true,
			"task_id": TASK_T09_ID,
			"task_text": TASK_T09_TEXT
		}
	])

func on_macro_inspected() -> void:
	set_task_completed(TASK_T09_ID, true)
	update_evidence_ui()
	queue_march_dialogue([
		{
			"sender": "March",
			"text": "เจอ word/vbaProject.bin กับโค้ดใน vba_extracted_macro.vba แล้ว!"
		},
		{
			"sender": "March",
			"text": "ในนั้นมีโค้ด Base64 กับ Hex ซ่อนอยู่ ให้เปิดแอป Decoder บน Desktop ไปถอดรหัสหาชื่อ Helper กับโหมดทำลายเลย!",
			"is_task": true,
			"task_id": TASK_T10_ID,
			"task_text": TASK_T10_TEXT
		}
	])

func on_decoding_complete() -> void:
	set_task_completed(TASK_T10_ID, true)
	update_evidence_ui()
	queue_march_dialogue([
		{
			"sender": "March",
			"text": "มัลแวร์คือ Office_Update_Helper โหมด FILE_WIPE สินะ ตัวร้ายที่สั่งลบไฟล์และฝังตัว!"
		},
		{
			"sender": "March",
			"text": "ก่อนจะกู้ไฟล์ ต้องวางแผนตัดวงจร Persistence ทั้ง 7 ขั้นตอนใน Safe Mode ให้สนิทก่อน!",
			"is_task": true,
			"task_id": TASK_T12_ID,
			"task_text": TASK_T12_TEXT
		}
	])

func on_persistence_stopped() -> void:
	set_task_completed(TASK_T12_ID, true)
	update_evidence_ui()
	queue_march_dialogue([
		{
			"sender": "March",
			"text": "สุดยอดมากน้องเมย์! ตัดวงจรมัลแวร์ได้สำเร็จ 100% แล้ว!"
		},
		{
			"sender": "March",
			"text": "ตอนนี้เราได้โน้ตความรู้ครบ 3 แผ่นแล้ว ลุกจากเต่าดำกลับไปห้องนอน แปะโน้ตลงบอร์ด แล้วเริ่มกู้คืน PC ได้เลย!"
		}
	])

func _march_auto_reply() -> void:
	await get_tree().create_timer(0.8).timeout
	if not is_instance_valid(self):
		return

	var advice: String = ""
	if not _is_task_done(TASK_T08_ID):
		advice = "ตรวจค่า MD5 ใน CMD ด้วยคำสั่ง certutil -hashfile Report_Final.docx MD5 แล้วเทียบกับ Manifest ใน Incident_Notes นะน้อง!"
	elif not _is_task_done(TASK_T06_ID):
		advice = "ลองเปิด Windows_Event_Log.txt ใน Inspector ดูช่วงเวลา 19:02:10 นะน้อง!"
	elif not _is_task_done(TASK_T07_ID):
		advice = "ดู Drive_Activity.log เช็คตัวสะกดอีเมลคนส่ง @universcity.example ดูนะ!"
	elif not _is_task_done(TASK_T09_ID):
		advice = "ตรวจไฟล์ Report_Final.docx ใน Inspector ดูว่ามี word/vbaProject.bin มั้ย!"
	elif not _is_task_done(TASK_T10_ID):
		advice = "เอาโค้ด Base64 และ Hex ใน vba_extracted_macro.vba ไปถอดในแอป Decoder บน Desktop เลย!"
	elif not _is_task_done(TASK_T12_ID):
		advice = "วางแผนตัดวงจร 7 ขั้นตอน เริ่มจาก Safe Mode -> ปิด Task -> กักกัน Helper -> ลบ Persistence -> ยืนยันหยุด -> ปิด CloudSync -> แล้วกู้ไฟล์!"
	else:
		advice = "ได้โน้ตความรู้ครบ 3 แผ่นแล้ว ลุกกลับห้องนอนไปแปะ NoteBoard ได้เลยน้อง!"

	march_history += "March: %s\n\n" % advice
	if current_contact == "march" and messages_label:
		messages_label.text = march_history
		_scroll_to_bottom()

func _is_task_done(task_id: String) -> bool:
	for t: Dictionary in current_tasks:
		if t.get("id", "") == task_id:
			return bool(t.get("completed", false))
	return false
