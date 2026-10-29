extends Control

const SCENE_07_RECOVERY_PATH: String = "res://scenes/scene_07_recovery/Scene_07_Recovery.tscn"

@onready var notebook_screen: Control = $CanvasLayer/NotebookScreen
@onready var forensic_toolbar: PanelContainer = $CanvasLayer/ForensicToolbar
@onready var status_label: Label = $CanvasLayer/ForensicToolbar/Content/BottomRow/StatusLabel
@onready var close_puzzle_button: Button = $CanvasLayer/ForensicToolbar/Content/BottomRow/ClosePuzzleButton
@onready var inspector_button: Button = $CanvasLayer/ForensicToolbar/Content/BottomRow/InspectorButton

@onready var hash_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/HashButton
@onready var event_log_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/EventLogButton
@onready var drive_history_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/DriveHistoryButton
@onready var macro_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/MacroButton
@onready var decoder_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/DecoderButton
@onready var persistence_button: Button = $CanvasLayer/ForensicToolbar/Content/Tools/PersistenceButton

@onready var hash_puzzle: BaseDecoderPuzzle = $CanvasLayer/Puzzle_Hash_Verify
@onready var event_log_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Event_Log
@onready var drive_history_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Drive_History
@onready var macro_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_File_Structure
@onready var decoder_puzzle: DecoderPuzzle = $CanvasLayer/Puzzle_Decoder
@onready var persistence_puzzle: BaseSequencePuzzle = $CanvasLayer/Puzzle_Persistence_Order

@onready var completion_panel: Control = $CanvasLayer/CompletionPanel
@onready var recovery_button: Button = $CanvasLayer/CompletionPanel/VBox/RecoveryButton

var inspector_app: Control = null
var decoder_app: Control = null
var ev_folder_app: Control = null
var inspector_icon: Button = null
var decoder_icon: Button = null
var ev_file_icon: Button = null

var _hash_verified: bool = false
var _event_log_verified: bool = false
var _drive_history_verified: bool = false
var _macro_inspected: bool = false
var _decoding_complete: bool = false

func _ready() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("hide_inventory"):
		inv.hide_inventory()

	_hide_puzzles()
	completion_panel.hide()
	notebook_screen.show()
	forensic_toolbar.show()

	hash_button.pressed.connect(_on_hash_pressed)
	event_log_button.pressed.connect(_on_event_log_pressed)
	drive_history_button.pressed.connect(_on_drive_history_pressed)
	macro_button.pressed.connect(_on_macro_pressed)
	decoder_button.pressed.connect(_on_decoder_pressed)
	persistence_button.pressed.connect(_on_persistence_pressed)
	inspector_button.pressed.connect(_on_inspector_pressed)
	close_puzzle_button.pressed.connect(_hide_puzzles)
	recovery_button.pressed.connect(_on_recovery_pressed)

	hash_puzzle.puzzle_resolved.connect(_on_hash_verified)
	event_log_puzzle.puzzle_resolved.connect(_on_event_log_verified)
	drive_history_puzzle.puzzle_resolved.connect(_on_drive_history_verified)
	macro_puzzle.puzzle_resolved.connect(_on_macro_inspected)
	decoder_puzzle.all_decoding_complete.connect(_on_decoding_complete)
	persistence_puzzle.puzzle_resolved.connect(_on_persistence_stopped)

	_setup_isolated_notebook_state()
	_connect_app_icons()
	_refresh_tool_availability()

	# Start directly with Step 1: MD5 Hash Verification
	_on_hash_pressed()

func _setup_isolated_notebook_state() -> void:
	if not notebook_screen:
		return
	var nb_task_obj: Control = notebook_screen.get_node_or_null("TaskObjective") as Control
	if nb_task_obj:
		nb_task_obj.hide()
	var window_container: Control = notebook_screen.get_node_or_null("WindowContainer") as Control
	if window_container:
		window_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		window_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		window_container.position = Vector2.ZERO
		window_container.size = Vector2(480, 204)
	var wifi_tray_btn: Button = notebook_screen.find_child("WifiTrayButton", true, false) as Button
	if wifi_tray_btn:
		wifi_tray_btn.icon = preload("res://assets/Icon32x32/world_disable.png")
		wifi_tray_btn.text = "No Net"
	var wifi_status_lbl: Label = notebook_screen.find_child("WifiStatusLabel", true, false) as Label
	if wifi_status_lbl:
		wifi_status_lbl.text = "สถานะ: ตัดการเชื่อมต่อแล้ว (Disconnected)"
		wifi_status_lbl.add_theme_color_override("font_color", Color(0.95, 0.35, 0.35, 1.0))
	var ssid_lbl: Label = notebook_screen.find_child("SSIDLabel", true, false) as Label
	if ssid_lbl:
		ssid_lbl.text = "สาย LAN: ไม่ได้เชื่อมต่อ (Unplugged)"
	var wifi_toggle_btn: Button = notebook_screen.find_child("WifiToggleBtn", true, false) as Button
	if wifi_toggle_btn:
		wifi_toggle_btn.text = "สัญญาณ Wi-Fi: ปิดใช้งาน (Disabled)"
	var wifi_sync_lbl: Label = notebook_screen.find_child("WifiCloudSyncLabel", true, false) as Label
	if wifi_sync_lbl:
		wifi_sync_lbl.text = "CloudSync: ปิดการทำงาน (Offline)"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused and (focused is LineEdit or focused is TextEdit):
			return
		_hide_puzzles()
		get_viewport().set_input_as_handled()

func _on_hash_pressed() -> void:
	_launch_puzzle("Step 1/6 (T08): เทียบค่า MD5 ของไฟล์หลักฐานกับ Evidence_Manifest.txt", hash_puzzle)

func _on_event_log_pressed() -> void:
	if not _hash_verified:
		status_label.text = "⚠️ กรุณาตรวจสอบความถูกต้องของ Hash (1.Hash T08) ก่อน!"
		return
	_launch_puzzle("Step 2/6 (T06): ตรวจ Windows_Event_Log.txt หาเวลาที่เปิด Report_Final.docx", event_log_puzzle)

func _on_drive_history_pressed() -> void:
	if not _event_log_verified:
		status_label.text = "⚠️ กรุณาตรวจ Event Log (2.EventLog T06) เพื่อระบุเวลาเกิดเหตุก่อน!"
		return
	_launch_puzzle("Step 3/6 (T07): ตรวจ Drive_Activity.log หาอีเมลผู้ส่งที่ปลอมแปลงโดเมน", drive_history_puzzle)

func _on_macro_pressed() -> void:
	if not _drive_history_verified:
		status_label.text = "⚠️ กรุณาตรวจ Drive_Activity.log (3.DriveLog T07) ก่อน!"
		return
	_launch_puzzle("Step 4/6 (T09): ใช้ olevba ตรวจโครงสร้างไฟล์ Report_Final.docx หา Macro", macro_puzzle)

func _on_decoder_pressed() -> void:
	if not _macro_inspected:
		status_label.text = "⚠️ กรุณาตรวจโครงสร้าง Macro (4.Macro T09) ก่อน!"
		return
	_launch_puzzle("Step 5/6 (T10-T11): ถอดรหัสชื่อไฟล์ Helper และโหมดการทำงาน (สามารถเปิดแอป Decoder ช่วยได้)", decoder_puzzle)

func _on_persistence_pressed() -> void:
	if not _decoding_complete:
		status_label.text = "⚠️ กรุณาถอดรหัสข้อมูลมัลแวร์ (5.Decode T10-T11) ให้ครบก่อน!"
		return
	_launch_puzzle("Step 6/6 (T12): เรียงลำดับการหยุด Persistence และ Scheduled Task ทั้ง 7 ขั้นตอน", persistence_puzzle)

func _launch_puzzle(msg: String, puzzle: BasePuzzleUI) -> void:
	_hide_puzzles()
	puzzle.show()
	puzzle.start_puzzle()
	status_label.text = msg

func _on_hash_verified() -> void:
	_hash_verified = true
	_hide_puzzles()
	status_label.text = "✅ [1/6] ยืนยัน MD5 ตรงกับ Manifest! ต่อไปกด [2.EventLog(T06)] เพื่อตรวจเวลาเกิดเหตุ"
	_refresh_tool_availability()
	_on_event_log_pressed()

func _on_event_log_verified() -> void:
	_event_log_verified = true
	_hide_puzzles()
	status_label.text = "✅ [2/6] พบเวลาเกิดเหตุ 19:02:10! ต่อไปกด [3.DriveLog(T07)] เพื่อตรวจหาผู้ส่งปลอม"
	_refresh_tool_availability()
	_on_drive_history_pressed()

func _on_drive_history_verified() -> void:
	_drive_history_verified = true
	_hide_puzzles()
	status_label.text = "✅ [3/6] พบผู้ส่งปลอม (@universcity.example)! ต่อไปกด [4.Macro(T09)] ตรวจโครงสร้างเอกสาร"
	_refresh_tool_availability()
	_on_macro_pressed()

func _on_macro_inspected() -> void:
	_macro_inspected = true
	_hide_puzzles()
	status_label.text = "✅ [4/6] พบโค้ดฝังตัวใน vbaProject.bin! ต่อไปกด [5.Decode(T10-11)] เพื่อถอดรหัส Payload"
	_refresh_tool_availability()
	_on_decoder_pressed()

func _on_decoding_complete() -> void:
	_decoding_complete = true
	_hide_puzzles()
	status_label.text = "✅ [5/6] ยืนยันมัลแวร์ Office_Update_Helper (FILE_WIPE)! ต่อไปกด [6.StopTask(T12)]"
	_refresh_tool_availability()
	_on_persistence_pressed()

func _on_persistence_stopped() -> void:
	_hide_puzzles()
	completion_panel.show()
	status_label.text = "✅ [6/6] สืบสวนและวางแผนหยุด Persistence สำเร็จ! พร้อมกลับไปกู้คืนข้อมูลที่ PC ของเมย์"

func _on_recovery_pressed() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_07_RECOVERY_PATH)
	if result != OK:
		push_error("Unable to load Scene 7 recovery: %s" % result)

func _refresh_tool_availability() -> void:
	event_log_button.disabled = not _hash_verified
	drive_history_button.disabled = not _event_log_verified
	macro_button.disabled = not _drive_history_verified
	decoder_button.disabled = not _macro_inspected
	persistence_button.disabled = not _decoding_complete

func _hide_puzzles() -> void:
	hash_puzzle.hide()
	event_log_puzzle.hide()
	drive_history_puzzle.hide()
	macro_puzzle.hide()
	decoder_puzzle.hide()
	persistence_puzzle.hide()
	if inspector_app:
		inspector_app.hide()
	if decoder_app:
		decoder_app.hide()
	if ev_folder_app:
		ev_folder_app.hide()
	if notebook_screen:
		var start_popup := notebook_screen.find_child("StartMenuPopup", true, false) as Control
		if start_popup:
			start_popup.hide()
		var wifi_popup := notebook_screen.find_child("WifiPopup", true, false) as Control
		if wifi_popup:
			wifi_popup.hide()

func _on_inspector_pressed() -> void:
	if not inspector_app:
		return
	if inspector_app.visible:
		inspector_app.hide()
	else:
		_hide_puzzles()
		inspector_app.show()
		status_label.text = "Inspector: ตรวจสอบเนื้อหาไฟล์และ Log ใน EV-DRIVE (E:)"

func _on_decoder_app_icon_pressed() -> void:
	if not decoder_app:
		return
	if decoder_app.visible:
		decoder_app.hide()
	else:
		_hide_puzzles()
		decoder_app.show()
		if _macro_inspected and decoder_puzzle and "input_edit" in decoder_app and decoder_app.input_edit:
			if decoder_app.input_edit.text.strip_edges().is_empty():
				if decoder_puzzle.decode_stage == 0:
					decoder_app.input_edit.text = DecoderPuzzle.HELPER_BASE64
				else:
					decoder_app.input_edit.text = DecoderPuzzle.MODE_HEX
		status_label.text = "Decoder App: เครื่องมือช่วยถอดรหัส Base64 / Hex และคำนวณ MD5"

func _on_ev_file_icon_pressed() -> void:
	if not ev_folder_app:
		return
	if ev_folder_app.visible:
		ev_folder_app.hide()
	else:
		_hide_puzzles()
		ev_folder_app.show()
		status_label.text = "EV-DRIVE (E:): เปิดดูไฟล์หลักฐานและ Log ที่อิมเมจมาจากเครื่องเมย์"

func _on_ev_file_inspect_requested(file_id: String) -> void:
	if ev_folder_app:
		ev_folder_app.hide()
	if inspector_app:
		_hide_puzzles()
		inspector_app.show()
		if inspector_app.has_method("select_file"):
			inspector_app.select_file(file_id)
		status_label.text = "Inspector: กำลังตรวจไฟล์ %s" % file_id

func _center_app_window(app_node: Control) -> void:
	if not app_node:
		return
	app_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	app_node.offset_left = 0.0
	app_node.offset_top = 0.0
	app_node.offset_right = 0.0
	app_node.offset_bottom = 0.0

func _connect_app_icons() -> void:
	if not notebook_screen:
		return
	inspector_app = notebook_screen.find_child("InspectorApp", true, false) as Control
	decoder_app = notebook_screen.find_child("DecoderApp", true, false) as Control
	ev_folder_app = notebook_screen.find_child("EvFolder", true, false) as Control

	if inspector_app:
		_center_app_window(inspector_app)
		inspector_app.hide()
	if decoder_app:
		_center_app_window(decoder_app)
		decoder_app.hide()
	if ev_folder_app:
		_center_app_window(ev_folder_app)
		ev_folder_app.hide()
		if ev_folder_app.has_signal("file_inspect_requested") and not ev_folder_app.file_inspect_requested.is_connected(_on_ev_file_inspect_requested):
			ev_folder_app.file_inspect_requested.connect(_on_ev_file_inspect_requested)

	inspector_icon = notebook_screen.find_child("InspectorIcon", true, false) as Button
	if inspector_icon and not inspector_icon.pressed.is_connected(_on_inspector_pressed):
		inspector_icon.pressed.connect(_on_inspector_pressed)

	decoder_icon = notebook_screen.find_child("DecoderIcon", true, false) as Button
	if decoder_icon and not decoder_icon.pressed.is_connected(_on_decoder_app_icon_pressed):
		decoder_icon.pressed.connect(_on_decoder_app_icon_pressed)

	ev_file_icon = notebook_screen.find_child("EvfileIcon", true, false) as Button
	if ev_file_icon:
		ev_file_icon.visible = true
		if not ev_file_icon.pressed.is_connected(_on_ev_file_icon_pressed):
			ev_file_icon.pressed.connect(_on_ev_file_icon_pressed)

	var start_btn := notebook_screen.find_child("StartButton", true, false) as Button
	var start_popup := notebook_screen.find_child("StartMenuPopup", true, false) as Control
	var wifi_tray_btn := notebook_screen.find_child("WifiTrayButton", true, false) as Button
	var wifi_popup := notebook_screen.find_child("WifiPopup", true, false) as Control
	var wifi_close_btn := notebook_screen.find_child("WifiCloseBtn", true, false) as Button
	if start_btn and start_popup:
		start_btn.pressed.connect(func() -> void:
			start_popup.visible = !start_popup.visible
			if wifi_popup:
				wifi_popup.hide()
		)
	if wifi_tray_btn and wifi_popup:
		wifi_tray_btn.pressed.connect(func() -> void:
			wifi_popup.visible = !wifi_popup.visible
			if start_popup:
				start_popup.hide()
		)
	if wifi_close_btn and wifi_popup:
		wifi_close_btn.pressed.connect(func() -> void:
			wifi_popup.hide()
		)
	var menu_files := notebook_screen.find_child("MenuFiles", true, false) as Button
	var menu_notepad := notebook_screen.find_child("MenuNotepad", true, false) as Button
	var menu_recycle := notebook_screen.find_child("MenuRecycleBin", true, false) as Button
	for btn: Button in [menu_files, menu_notepad, menu_recycle]:
		if btn and not btn.pressed.is_connected(_on_ev_file_icon_pressed):
			btn.pressed.connect(_on_ev_file_icon_pressed)
	var menu_word := notebook_screen.find_child("MenuWord", true, false) as Button
	if menu_word and not menu_word.pressed.is_connected(_on_inspector_pressed):
		menu_word.pressed.connect(_on_inspector_pressed)
	var menu_discord := notebook_screen.find_child("MenuDiscord", true, false) as Button
	var menu_ggdisk := notebook_screen.find_child("MenuGGDisk", true, false) as Button
	for btn: Button in [menu_discord, menu_ggdisk]:
		if btn and not btn.pressed.is_connected(_on_decoder_app_icon_pressed):
			btn.pressed.connect(_on_decoder_app_icon_pressed)
	var start_leave_btn := notebook_screen.find_child("StartMenuLeaveBtn", true, false) as Button
	if start_leave_btn:
		start_leave_btn.pressed.connect(func() -> void:
			if start_popup:
				start_popup.hide()
			status_label.text = "⚠️ กรุณาสืบสวนหลักฐานใน EV-DRIVE ให้ครบทั้ง 6 ขั้นตอนก่อนออกจากเครื่องเต่าดำ!"
		)
