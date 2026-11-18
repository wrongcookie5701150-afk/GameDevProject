extends Control

const SCENE_07_RECOVERY_PATH: String = "res://scenes/scene_07_recovery/Scene_07_Recovery.tscn"
const SCENE_04_BEDROOM_PATH: String = "res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn"

const INVESTIGATION_TASKS: Array[String] = [
	"1. ตรวจสอบ MD5 Hash ของ Report_Final.docx (T08)",
	"2. ตรวจสอบ Windows Event Log หาเวลาเกิดเหตุ (T06)",
	"3. ตรวจสอบ Drive Activity Log หาโดเมนปลอม (T07)",
	"4. ตรวจสอบ Macro ใน Report_Final.docx (T09)",
	"5. ถอดรหัสเพย์โหลด Helper & Mode (T10-11)",
	"6. วางแผนตัดวงจร Persistence 7 ขั้นตอน (T12)"
]

@onready var notebook_screen: Control = $CanvasLayer/NotebookScreen
@onready var phone_panel: PhonePanelTaoDam = get_node_or_null("CanvasLayer/PhonePanel") as PhonePanelTaoDam
@onready var terminal_app: TerminalApp = get_node_or_null("CanvasLayer/Terminal") as TerminalApp
@onready var checklist: BasePuzzleUI = get_node_or_null("CanvasLayer/Checklist_UI") as BasePuzzleUI

# Puzzles
@onready var hash_puzzle: BaseDecoderPuzzle = $CanvasLayer/Puzzle_Hash_Verify
@onready var event_log_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Event_Log
@onready var drive_history_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Drive_History
@onready var macro_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_File_Structure
@onready var decoder_puzzle: DecoderPuzzle = $CanvasLayer/Puzzle_Decoder
@onready var persistence_puzzle: BaseSequencePuzzle = $CanvasLayer/Puzzle_Persistence_Order

# Completion
@onready var completion_panel: Control = $CanvasLayer/CompletionPanel
@onready var recovery_button: Button = $CanvasLayer/CompletionPanel/VBox/RecoveryButton

# Toolbar Nodes (Hidden in realistic desktop exploration)
@onready var toolbar: PanelContainer = get_node_or_null("CanvasLayer/ForensicToolbar") as PanelContainer
@onready var hash_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/Tools/HashButton") as Button
@onready var event_log_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/Tools/EventLogButton") as Button
@onready var drive_history_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/Tools/DriveHistoryButton") as Button
@onready var macro_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/Tools/MacroButton") as Button
@onready var decoder_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/Tools/DecoderButton") as Button
@onready var persistence_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/Tools/PersistenceButton") as Button

@onready var status_label: Label = get_node_or_null("CanvasLayer/ForensicToolbar/Content/BottomRow/StatusLabel") as Label
@onready var cmd_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/BottomRow/CmdButton") as Button
@onready var inspector_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/BottomRow/InspectorButton") as Button
@onready var phone_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/BottomRow/PhoneButton") as Button
@onready var close_puzzle_btn: Button = get_node_or_null("CanvasLayer/ForensicToolbar/Content/BottomRow/ClosePuzzleButton") as Button

var inspector_app: Control = null
var decoder_app: Control = null
var ev_folder_app: Control = null
var inspector_icon: Button = null
var decoder_icon: Button = null
var ev_file_icon: Button = null
var _cmd_desktop_icon: Button = null

var _hash_verified: bool = false
var _event_log_verified: bool = false
var _drive_history_verified: bool = false
var _macro_inspected: bool = false
var _decoding_complete: bool = false
var _persistence_stopped: bool = false

var _phone_taskbar_btn: Button = null

var _idle_seconds: float = 0.0
var _idle_tier1_sent: bool = false
var _idle_tier2_sent: bool = false
var _active_emphasis_tween: Tween = null
var _emphasized_node: Control = null

func _ready() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv and inv.has_method("hide_inventory"):
		inv.hide_inventory()

	_hide_puzzles()
	if completion_panel:
		completion_panel.hide()
	if notebook_screen:
		notebook_screen.show()

	# Free internal TaskObjective inside locked notebook_screen.tscn
	var old_task: Control = notebook_screen.get_node_or_null("TaskObjective") as Control
	if old_task:
		old_task.queue_free()

	# 1. Hide ForensicToolbar so player investigates authentically via Desktop apps
	if toolbar:
		toolbar.hide()

	# Setup Checklist_UI
	if checklist and checklist.has_method("setup_custom_checklist"):
		checklist.setup_custom_checklist("เป้าหมาย: ตรวจวิเคราะห์หลักฐานภาพสะท้อน (EV-01 Investigation)", INVESTIGATION_TASKS)
		_update_checklist_progress()

	# Connect PhonePanelTaoDam
	if phone_panel:
		phone_panel.show()
		phone_panel.move_to_front()
		if phone_panel.has_signal("evidence_requested") and not phone_panel.evidence_requested.is_connected(_on_phone_evidence_requested):
			phone_panel.evidence_requested.connect(_on_phone_evidence_requested)

	_setup_toolbar_buttons()
	_setup_isolated_notebook_state()
	_hide_unnecessary_personal_apps()
	_connect_app_icons()
	_setup_taskbar_phone_button()
	_setup_in_app_evidence_buttons()

	# Connect puzzle completion signals
	hash_puzzle.puzzle_resolved.connect(_on_hash_verified)
	event_log_puzzle.puzzle_resolved.connect(_on_event_log_verified)
	drive_history_puzzle.puzzle_resolved.connect(_on_drive_history_verified)
	macro_puzzle.puzzle_resolved.connect(_on_macro_inspected)
	decoder_puzzle.all_decoding_complete.connect(_on_decoding_complete)
	persistence_puzzle.puzzle_resolved.connect(_on_persistence_stopped)

	if recovery_button:
		recovery_button.pressed.connect(_on_recovery_pressed)

	_refresh_tool_availability()
	_refresh_phone_ui()

	# Open EV-01 Explorer immediately on left side
	_on_ev_file_icon_pressed()

func _update_checklist_progress() -> void:
	if not checklist or not checklist.has_method("set_task_index_completed"):
		return
	checklist.set_task_index_completed(0, _hash_verified)
	checklist.set_task_index_completed(1, _event_log_verified)
	checklist.set_task_index_completed(2, _drive_history_verified)
	checklist.set_task_index_completed(3, _macro_inspected)
	checklist.set_task_index_completed(4, _decoding_complete)
	checklist.set_task_index_completed(5, _persistence_stopped)

func _process(delta: float) -> void:
	if completion_panel and completion_panel.visible:
		return
	if _persistence_stopped:
		return

	_idle_seconds += delta
	if _idle_seconds >= 35.0 and not _idle_tier2_sent:
		_idle_tier2_sent = true
		_trigger_idle_tier2_emphasis()
	elif _idle_seconds >= 20.0 and not _idle_tier1_sent:
		_idle_tier1_sent = true
		_trigger_idle_tier1_hint()

func _reset_idle_timer() -> void:
	_idle_seconds = 0.0
	_idle_tier1_sent = false
	_idle_tier2_sent = false
	_clear_target_emphasis()

func _trigger_idle_tier1_hint() -> void:
	if not phone_panel:
		return
	var step: int = _get_current_step()
	var hint: String = ""
	match step:
		1:
			hint = "น้องเมย์ ติดตรงไหนมั้ย? ลองเปิด Evidence_Manifest.txt ดูค่า MD5 แล้วเปิด CMD พิมพ์ 'certutil -hashfile Report_Final.docx MD5' ดูนะน้อง!"
		2:
			hint = "ขั้นที่ 2 ให้เปิดไฟล์ Windows_Event_Log.txt ในโฟลเดอร์ Logs ของไดรฟ์ E: (หรือเปิดผ่าน Inspector) ดูเวลาที่เกิดเหตุก่อน 19:00 นะ!"
		3:
			hint = "ขั้นที่ 3 เปิด Drive_Activity.log ดูว่าใครแชร์ไฟล์มา สังเกตชื่อโดเมนอีเมลดีๆ ว่ามีตัวสะกดผิดมั้ย!"
		4:
			hint = "ขั้นที่ 4 ตรวจโครงสร้างไฟล์ Report_Final.docx ใน Inspector ดูว่ามี word/vbaProject.bin ซ่อนอยู่มั้ย!"
		5:
			hint = "ขั้นที่ 5 เปิดแอป Decoder บน Desktop แล้วเอาโค้ด Base64 / Hex จากไฟล์ macro ไปถอดรหัสหาชื่อ Helper และโหมดทำลาย!"
		6:
			hint = "ขั้นสุดท้าย วางแผนตัดวงจร Persistence 7 ขั้นตอน เริ่มจากบูตเข้า Safe Mode ก่อนเลยน้อง!"
	if not hint.is_empty():
		if phone_panel.has_method("send_march_hint"):
			phone_panel.send_march_hint(hint)
		if _phone_taskbar_btn:
			_phone_taskbar_btn.text = "📱 March (มีคำใบ้ใหม่!)"

func _trigger_idle_tier2_emphasis() -> void:
	var step: int = _get_current_step()
	var hint: String = ""
	var target_control: Control = null
	
	match step:
		1:
			hint = "พี่ทำไฮไลท์กระพริบที่ไอคอน CMD บนหน้าจอให้แล้วนะน้อง! กดเปิด CMD หรือกดส่งผลตรวจค่า Hash ได้เลย"
			target_control = _cmd_desktop_icon if _cmd_desktop_icon else hash_btn
		2:
			hint = "พี่ไฮไลท์กระพริบที่แอป Inspector ให้แล้วน้อง รีบเปิดเข้าไปตรวจดูเวลาใน Event Log เลย!"
			target_control = inspector_icon if inspector_icon else event_log_btn
		3:
			hint = "พี่ไฮไลท์กระพริบที่แอป Inspector ให้แล้ว เข้าไปตรวจดูบันทึกโดเมนปลอมใน Drive Log ด่วนเลย!"
			target_control = inspector_icon if inspector_icon else drive_history_btn
		4:
			hint = "ลองเปิด Inspector ตรวจดูโฟลเดอร์ word ใน Report_Final.docx ด่วนเลยน้อง! (พี่ไฮไลท์ให้แล้ว)"
			target_control = inspector_icon if inspector_icon else macro_btn
		5:
			hint = "พี่ทำไฮไลท์ที่ไอคอนแอป Decoder บนหน้าจอให้แล้วนะ กดเปิดเข้าไปถอดรหัสได้เลย!"
			target_control = decoder_icon if decoder_icon else decoder_btn
		6:
			hint = "พี่ไฮไลท์ปุ่มวางแผนตัดวงจรให้แล้ว จัดเรียง 7 ขั้นตอนให้ถูกต้องเลย!"
			target_control = persistence_btn if (persistence_btn and persistence_btn.visible) else ev_file_icon
			
	if not hint.is_empty() and phone_panel and phone_panel.has_method("send_march_hint"):
		phone_panel.send_march_hint(hint)
		if _phone_taskbar_btn:
			_phone_taskbar_btn.text = "📱 March (ชี้เป้า!)"
			
	if target_control:
		_emphasize_target_control(target_control)

func _emphasize_target_control(target_node: Control) -> void:
	if not target_node:
		return
	_clear_target_emphasis()
	_emphasized_node = target_node
	_active_emphasis_tween = create_tween().set_loops()
	_active_emphasis_tween.tween_property(target_node, "modulate", Color(1.8, 1.8, 0.4, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_active_emphasis_tween.tween_property(target_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _clear_target_emphasis() -> void:
	if _active_emphasis_tween and _active_emphasis_tween.is_valid():
		_active_emphasis_tween.kill()
	_active_emphasis_tween = null
	if _emphasized_node and is_instance_valid(_emphasized_node):
		_emphasized_node.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_emphasized_node = null

func _on_phone_evidence_requested(task_id: String) -> void:
	_reset_idle_timer()
	match task_id:
		"t08_hash":
			_on_hash_pressed()
		"t06_event_log":
			_on_event_log_pressed()
		"t07_drive_log":
			_on_drive_history_pressed()
		"t09_macro":
			_on_macro_pressed()
		"t10_decoder":
			_on_decoder_pressed()
		"t12_persistence":
			_on_persistence_pressed()

func _hide_unnecessary_personal_apps() -> void:
	if not notebook_screen:
		return
	# Hide Discord, GGdisk, MSword on Desktop
	var discord_icon := notebook_screen.find_child("Discord", true, false) as Button
	if discord_icon:
		discord_icon.hide()
	var ggdisk_icon := notebook_screen.find_child("GGdisk", true, false) as Button
	if ggdisk_icon:
		ggdisk_icon.hide()
	var msword_icon := notebook_screen.find_child("MSword", true, false) as Button
	if msword_icon:
		msword_icon.hide()

	# Hide Discord, GGdisk, MSword in Start Menu
	var menu_discord := notebook_screen.find_child("MenuDiscord", true, false) as Button
	if menu_discord:
		menu_discord.hide()
	var menu_ggdisk := notebook_screen.find_child("MenuGGDisk", true, false) as Button
	if menu_ggdisk:
		menu_ggdisk.hide()
	var menu_word := notebook_screen.find_child("MenuWord", true, false) as Button
	if menu_word:
		menu_word.hide()

func _setup_taskbar_phone_button() -> void:
	if not notebook_screen:
		return
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")

	var taskbar_box: Container = notebook_screen.find_child("TaskbarTabsContainer", true, false) as Container
	if not taskbar_box:
		taskbar_box = notebook_screen.find_child("SystemTray", true, false) as Container
	if not taskbar_box:
		taskbar_box = notebook_screen.find_child("HBox", true, false) as Container

	if taskbar_box and not taskbar_box.has_node("PhoneTaskbarBtn"):
		_phone_taskbar_btn = Button.new()
		_phone_taskbar_btn.name = "PhoneTaskbarBtn"
		_phone_taskbar_btn.text = "📱 แชทพี่มาร์ช [P]"
		_phone_taskbar_btn.custom_minimum_size = Vector2(85, 16)
		_phone_taskbar_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if thai_font:
			_phone_taskbar_btn.add_theme_font_override("font", thai_font)
		_phone_taskbar_btn.add_theme_font_size_override("font_size", 7)

		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.22, 0.35, 0.95)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.35, 0.75, 1.0, 0.9)
		sb.corner_radius_top_left = 4
		sb.corner_radius_top_right = 4
		sb.corner_radius_bottom_right = 4
		sb.corner_radius_bottom_left = 4
		sb.content_margin_left = 6.0
		sb.content_margin_right = 6.0
		sb.content_margin_top = 2.0
		sb.content_margin_bottom = 2.0
		_phone_taskbar_btn.add_theme_stylebox_override("normal", sb)

		var sb_h := sb.duplicate() as StyleBoxFlat
		sb_h.bg_color = Color(0.18, 0.35, 0.55, 1.0)
		_phone_taskbar_btn.add_theme_stylebox_override("hover", sb_h)

		_phone_taskbar_btn.pressed.connect(func() -> void:
			_toggle_phone()
		)
		taskbar_box.add_child(_phone_taskbar_btn)

func _setup_toolbar_buttons() -> void:
	if hash_btn and not hash_btn.pressed.is_connected(_on_hash_pressed):
		hash_btn.pressed.connect(_on_hash_pressed)
	if event_log_btn and not event_log_btn.pressed.is_connected(_on_event_log_pressed):
		event_log_btn.pressed.connect(_on_event_log_pressed)
	if drive_history_btn and not drive_history_btn.pressed.is_connected(_on_drive_history_pressed):
		drive_history_btn.pressed.connect(_on_drive_history_pressed)
	if macro_btn and not macro_btn.pressed.is_connected(_on_macro_pressed):
		macro_btn.pressed.connect(_on_macro_pressed)
	if decoder_btn and not decoder_btn.pressed.is_connected(_on_decoder_pressed):
		decoder_btn.pressed.connect(_on_decoder_pressed)
	if persistence_btn and not persistence_btn.pressed.is_connected(_on_persistence_pressed):
		persistence_btn.pressed.connect(_on_persistence_pressed)

	if cmd_btn and not cmd_btn.pressed.is_connected(_on_cmd_pressed):
		cmd_btn.pressed.connect(_on_cmd_pressed)
	if inspector_btn and not inspector_btn.pressed.is_connected(_on_inspector_pressed):
		inspector_btn.pressed.connect(_on_inspector_pressed)
	if phone_btn and not phone_btn.pressed.is_connected(func() -> void: _toggle_phone("")):
		phone_btn.pressed.connect(func() -> void: _toggle_phone(""))
	if close_puzzle_btn and not close_puzzle_btn.pressed.is_connected(_hide_puzzles):
		close_puzzle_btn.pressed.connect(_hide_puzzles)

func _refresh_tool_availability() -> void:
	if hash_btn:
		hash_btn.text = "✓ 1.Hash(T08)" if _hash_verified else "1.Hash(T08)"
		_apply_toolbar_btn_style(hash_btn, _hash_verified)
	if event_log_btn:
		event_log_btn.text = "✓ 2.EventLog(T06)" if _event_log_verified else "2.EventLog(T06)"
		_apply_toolbar_btn_style(event_log_btn, _event_log_verified)
	if drive_history_btn:
		drive_history_btn.text = "✓ 3.DriveLog(T07)" if _drive_history_verified else "3.DriveLog(T07)"
		_apply_toolbar_btn_style(drive_history_btn, _drive_history_verified)
	if macro_btn:
		macro_btn.text = "✓ 4.Macro(T09)" if _macro_inspected else "4.Macro(T09)"
		_apply_toolbar_btn_style(macro_btn, _macro_inspected)
	if decoder_btn:
		decoder_btn.text = "✓ 5.Decode(T10-11)" if _decoding_complete else "5.Decode(T10-11)"
		_apply_toolbar_btn_style(decoder_btn, _decoding_complete)
	if persistence_btn:
		persistence_btn.text = "✓ 6.StopTask(T12)" if _persistence_stopped else "6.StopTask(T12)"
		_apply_toolbar_btn_style(persistence_btn, _persistence_stopped)

	var done_count: int = _get_completed_steps_count()
	if status_label:
		if done_count == 6:
			status_label.text = "🎉 [6/6] สืบสวนหลักฐานครบทุกขั้นตอนแล้ว! นำโน้ตทั้ง 3 แผ่นกลับไปแปะที่บอร์ดห้องนอน"
			status_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6, 1.0))
		else:
			status_label.text = "⚡ สืบสวนหลักฐาน (%d/6): เปิด EV-01 หรือ CMD / Inspector / Decoder ได้อย่างอิสระ [กด P ถามพี่มาร์ช]" % done_count
			status_label.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0, 1.0))

func _get_completed_steps_count() -> int:
	var count: int = 0
	for v: bool in [_hash_verified, _event_log_verified, _drive_history_verified, _macro_inspected, _decoding_complete, _persistence_stopped]:
		if v: count += 1
	return count

func _get_current_step() -> int:
	if not _hash_verified: return 1
	if not _event_log_verified: return 2
	if not _drive_history_verified: return 3
	if not _macro_inspected: return 4
	if not _decoding_complete: return 5
	if not _persistence_stopped: return 6
	return 7

func _apply_toolbar_btn_style(btn: Button, is_done: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_right = 3
	sb.corner_radius_bottom_left = 3
	sb.content_margin_left = 4.0
	sb.content_margin_right = 4.0
	sb.content_margin_top = 2.0
	sb.content_margin_bottom = 2.0
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1

	if is_done:
		sb.bg_color = Color(0.08, 0.28, 0.16, 0.95)
		sb.border_color = Color(0.3, 0.9, 0.5, 0.9)
		btn.add_theme_color_override("font_color", Color(0.7, 1.0, 0.8, 1.0))
	else:
		sb.bg_color = Color(0.1, 0.15, 0.24, 0.9)
		sb.border_color = Color(0.3, 0.55, 0.8, 0.8)
		btn.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 1.0))

	btn.add_theme_stylebox_override("normal", sb)

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
		ssid_lbl.text = "เครือข่าย: ไม่ได้เชื่อมต่อ (Disconnected)"
	var wifi_toggle_btn: Button = notebook_screen.find_child("WifiToggleBtn", true, false) as Button
	if wifi_toggle_btn:
		wifi_toggle_btn.text = "สัญญาณ Wi-Fi: ปิดใช้งาน (Disabled)"
	var wifi_sync_lbl: Label = notebook_screen.find_child("WifiCloudSyncLabel", true, false) as Label
	if wifi_sync_lbl:
		wifi_sync_lbl.text = "CloudSync: ปิดการทำงาน (Offline)"

func _unhandled_input(event: InputEvent) -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	var is_typing: bool = focused and (focused is LineEdit or focused is TextEdit)
	if is_typing:
		return

	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		if phone_panel and phone_panel.visible:
			phone_panel.close_phone()
			get_viewport().set_input_as_handled()
			return
		_hide_puzzles()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("Chat") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_P or event.keycode == KEY_C)):
		_toggle_phone("chat")
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("Task") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_T):
		_toggle_phone("task")
		get_viewport().set_input_as_handled()
		return

func _toggle_phone(target_mode: String = "") -> void:
	if not phone_panel:
		return
	if phone_panel.visible:
		phone_panel.close_phone()
	else:
		phone_panel.open_phone(target_mode if not target_mode.is_empty() else "chat")
		phone_panel.move_to_front()

	if _phone_taskbar_btn:
		_phone_taskbar_btn.text = "📱 แชทพี่มาร์ช [P]"

func _launch_puzzle(puzzle: BasePuzzleUI) -> void:
	_reset_idle_timer()
	_hide_puzzles()
	puzzle.show()
	puzzle.start_puzzle()
	puzzle.move_to_front()

func _on_hash_pressed() -> void:
	_launch_puzzle(hash_puzzle)

func _on_event_log_pressed() -> void:
	_launch_puzzle(event_log_puzzle)

func _on_drive_history_pressed() -> void:
	_launch_puzzle(drive_history_puzzle)

func _on_macro_pressed() -> void:
	_launch_puzzle(macro_puzzle)

func _on_decoder_pressed() -> void:
	_launch_puzzle(decoder_puzzle)

func _on_persistence_pressed() -> void:
	_launch_puzzle(persistence_puzzle)

func _launch_current_step_puzzle() -> void:
	var step: int = _get_current_step()
	match step:
		1: _on_hash_pressed()
		2: _on_event_log_pressed()
		3: _on_drive_history_pressed()
		4: _on_macro_pressed()
		5: _on_decoder_pressed()
		6: _on_persistence_pressed()
		_:
			if completion_panel:
				completion_panel.show()
				completion_panel.move_to_front()

func _on_hash_verified() -> void:
	_hash_verified = true
	_hide_puzzles()
	_reset_idle_timer()
	if phone_panel and phone_panel.has_method("on_hash_verified"):
		phone_panel.on_hash_verified()
	_update_checklist_progress()
	_notify_phone_message()
	_refresh_tool_availability()
	_refresh_phone_ui()
	_check_knowledge_notes_and_completion()

func _on_event_log_verified() -> void:
	_event_log_verified = true
	_hide_puzzles()
	_reset_idle_timer()
	if phone_panel and phone_panel.has_method("on_event_log_verified"):
		phone_panel.on_event_log_verified()
	_update_checklist_progress()
	_notify_phone_message()
	_refresh_tool_availability()
	_refresh_phone_ui()
	_check_knowledge_notes_and_completion()

func _on_drive_history_verified() -> void:
	_drive_history_verified = true
	_hide_puzzles()
	_reset_idle_timer()
	if phone_panel and phone_panel.has_method("on_drive_history_verified"):
		phone_panel.on_drive_history_verified()
	_update_checklist_progress()
	_notify_phone_message()
	_refresh_tool_availability()
	_refresh_phone_ui()
	_check_knowledge_notes_and_completion()

func _on_macro_inspected() -> void:
	_macro_inspected = true
	_hide_puzzles()
	_reset_idle_timer()
	if phone_panel and phone_panel.has_method("on_macro_inspected"):
		phone_panel.on_macro_inspected()
	_update_checklist_progress()
	_notify_phone_message()
	_refresh_tool_availability()
	_refresh_phone_ui()
	_check_knowledge_notes_and_completion()

func _on_decoding_complete() -> void:
	_decoding_complete = true
	_hide_puzzles()
	_reset_idle_timer()
	if phone_panel and phone_panel.has_method("on_decoding_complete"):
		phone_panel.on_decoding_complete()
	_update_checklist_progress()
	_notify_phone_message()
	_refresh_tool_availability()
	_refresh_phone_ui()
	_check_knowledge_notes_and_completion()

func _on_persistence_stopped() -> void:
	_persistence_stopped = true
	_hide_puzzles()
	_reset_idle_timer()
	if phone_panel and phone_panel.has_method("on_persistence_stopped"):
		phone_panel.on_persistence_stopped()
	_update_checklist_progress()
	_notify_phone_message()
	_refresh_tool_availability()
	_refresh_phone_ui()
	_check_knowledge_notes_and_completion()

func _notify_phone_message() -> void:
	if _phone_taskbar_btn:
		_phone_taskbar_btn.text = "📱 แชทพี่มาร์ช [P] (!)"

func _check_knowledge_notes_and_completion() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	# Note 2: Isolation & Logs (เมื่อ Hash + EventLog + DriveLog สำเร็จครบ)
	if _hash_verified and _event_log_verified and _drive_history_verified:
		if inv and inv.has_method("award_knowledge_note"):
			var already_has: bool = (inv.has_method("has_knowledge_note") and inv.has_knowledge_note("note_isolation_logs")) \
				or (inv.has_method("has_item") and inv.has_item("note_isolation_logs")) \
				or ("pinned_notes" in inv and inv.pinned_notes.has("note_isolation_logs"))
			if not already_has:
				inv.award_knowledge_note("note_isolation_logs", self)

	# Note 3: Macro & Payload (เมื่อ Macro + Decode สำเร็จครบ)
	if _macro_inspected and _decoding_complete:
		if inv and inv.has_method("award_knowledge_note"):
			var already_has: bool = (inv.has_method("has_knowledge_note") and inv.has_knowledge_note("note_malware_payload")) \
				or (inv.has_method("has_item") and inv.has_item("note_malware_payload")) \
				or ("pinned_notes" in inv and inv.pinned_notes.has("note_malware_payload"))
			if not already_has:
				inv.award_knowledge_note("note_malware_payload", self)

	# Note 4: Persistence Stop (เมื่อตัดวงจร Persistence สำเร็จ)
	if _persistence_stopped:
		if inv and inv.has_method("award_knowledge_note"):
			var already_has: bool = (inv.has_method("has_knowledge_note") and inv.has_knowledge_note("note_persistence_stop")) \
				or (inv.has_method("has_item") and inv.has_item("note_persistence_stop")) \
				or ("pinned_notes" in inv and inv.pinned_notes.has("note_persistence_stop"))
			if not already_has:
				inv.award_knowledge_note("note_persistence_stop", self)

	# เมื่อทำครบทั้ง 6 ภารกิจ
	if _hash_verified and _event_log_verified and _drive_history_verified and _macro_inspected and _decoding_complete and _persistence_stopped:
		if recovery_button:
			recovery_button.text = "ลุกจากเต่าดำกลับห้องนอน (นำโน้ตทั้ง 3 แผ่นไปแปะที่บอร์ดก่อนกู้คืน PC)"
		if completion_panel:
			completion_panel.show()
			completion_panel.move_to_front()

func _on_recovery_pressed() -> void:
	var inv = get_node_or_null("/root/InventoryManager")
	if inv:
		inv.investigation_phase = 2
	var result: Error = get_tree().change_scene_to_file(SCENE_04_BEDROOM_PATH)
	if result != OK:
		push_error("Unable to load Scene 4 bedroom: %s" % result)

func _hide_puzzles() -> void:
	if hash_puzzle: hash_puzzle.hide()
	if event_log_puzzle: event_log_puzzle.hide()
	if drive_history_puzzle: drive_history_puzzle.hide()
	if macro_puzzle: macro_puzzle.hide()
	if decoder_puzzle: decoder_puzzle.hide()
	if persistence_puzzle: persistence_puzzle.hide()
	if notebook_screen:
		var start_popup := notebook_screen.find_child("StartMenuPopup", true, false) as Control
		if start_popup: start_popup.hide()
		var wifi_popup := notebook_screen.find_child("WifiPopup", true, false) as Control
		if wifi_popup: wifi_popup.hide()

func _on_cmd_pressed() -> void:
	_reset_idle_timer()
	if not terminal_app:
		return
	if terminal_app.visible:
		terminal_app.hide()
	else:
		_center_app_window(terminal_app)
		terminal_app.show()
		terminal_app.move_to_front()
		if terminal_app.has_method("open_terminal"):
			terminal_app.open_terminal()

func _on_terminal_hash_verified(file_name: String, hash_val: String) -> void:
	_reset_idle_timer()
	if hash_puzzle and hash_puzzle.has_method("_on_hash_from_cmd"):
		hash_puzzle._on_hash_from_cmd(file_name, hash_val)

func _on_inspector_pressed() -> void:
	_reset_idle_timer()
	if not inspector_app:
		return
	if inspector_app.visible:
		inspector_app.hide()
	else:
		_center_app_window(inspector_app)
		inspector_app.show()
		inspector_app.move_to_front()

func _on_decoder_app_icon_pressed() -> void:
	_reset_idle_timer()
	if not decoder_app:
		return
	if decoder_app.visible:
		decoder_app.hide()
	else:
		_center_app_window(decoder_app)
		decoder_app.show()
		decoder_app.move_to_front()
		if _macro_inspected and decoder_puzzle and "input_edit" in decoder_app and decoder_app.input_edit:
			if decoder_app.input_edit.text.strip_edges().is_empty():
				if decoder_puzzle.decode_stage == 0:
					decoder_app.input_edit.text = DecoderPuzzle.HELPER_BASE64
				else:
					decoder_app.input_edit.text = DecoderPuzzle.MODE_HEX

func _on_ev_file_icon_pressed() -> void:
	_reset_idle_timer()
	if not ev_folder_app:
		return
	if ev_folder_app.visible:
		ev_folder_app.hide()
	else:
		_center_app_window(ev_folder_app)
		ev_folder_app.show()
		ev_folder_app.move_to_front()

func _on_ev_file_inspect_requested(file_id: String) -> void:
	if inspector_app:
		_center_app_window(inspector_app)
		inspector_app.show()
		inspector_app.move_to_front()
		if inspector_app.has_method("select_file"):
			inspector_app.select_file(file_id)

func _on_puzzle_shortcut_requested(task_key: String) -> void:
	match task_key:
		"T08": _on_hash_pressed()
		"T06": _on_event_log_pressed()
		"T07": _on_drive_history_pressed()
		"T09": _on_macro_pressed()
		"T10", "T11": _on_decoder_pressed()
		"T12": _on_persistence_pressed()

func _center_app_window(app_node: Control) -> void:
	if not app_node:
		return
	app_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app_node.set_anchors_preset(Control.PRESET_TOP_LEFT)
	app_node.position = Vector2(44, 8)
	app_node.size = Vector2(236, 232)
	app_node.custom_minimum_size = Vector2(236, 232)
	var box = app_node.get_node_or_null("ColorRect") as Control
	if not box:
		box = app_node.get_node_or_null("WindowPanel") as Control
	if box:
		box.mouse_filter = Control.MOUSE_FILTER_STOP
		box.set_anchors_preset(Control.PRESET_TOP_LEFT)
		box.position = Vector2.ZERO
		box.size = Vector2(236, 232)
		box.custom_minimum_size = Vector2(236, 232)

func _connect_app_icons() -> void:
	if not notebook_screen:
		return
	inspector_app = notebook_screen.find_child("InspectorApp", true, false) as Control
	decoder_app = notebook_screen.find_child("DecoderApp", true, false) as Control
	ev_folder_app = notebook_screen.find_child("EvFolder", true, false) as Control

	if inspector_app:
		_center_app_window(inspector_app)
		inspector_app.hide()
		if inspector_app.has_signal("puzzle_shortcut_requested") and not inspector_app.puzzle_shortcut_requested.is_connected(_on_puzzle_shortcut_requested):
			inspector_app.puzzle_shortcut_requested.connect(_on_puzzle_shortcut_requested)

	if decoder_app:
		_center_app_window(decoder_app)
		decoder_app.hide()

	if ev_folder_app:
		_center_app_window(ev_folder_app)
		ev_folder_app.hide()
		if ev_folder_app.has_signal("file_inspect_requested") and not ev_folder_app.file_inspect_requested.is_connected(_on_ev_file_inspect_requested):
			ev_folder_app.file_inspect_requested.connect(_on_ev_file_inspect_requested)
		if ev_folder_app.has_signal("puzzle_shortcut_requested") and not ev_folder_app.puzzle_shortcut_requested.is_connected(_on_puzzle_shortcut_requested):
			ev_folder_app.puzzle_shortcut_requested.connect(_on_puzzle_shortcut_requested)

	# Setup TerminalApp (directly referenced from CanvasLayer in .tscn)
	if terminal_app:
		_center_app_window(terminal_app)
		terminal_app.hide()
		if terminal_app.has_signal("hash_verified_via_cmd") and not terminal_app.hash_verified_via_cmd.is_connected(_on_terminal_hash_verified):
			terminal_app.hash_verified_via_cmd.connect(_on_terminal_hash_verified)

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

	# Add Desktop CMD Icon button dynamically into Desktop icon column
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
	var icon_vbox = notebook_screen.get_node_or_null("MarginContainer/VBoxContainer")
	if icon_vbox and not icon_vbox.has_node("CmdDesktopIcon"):
		var cmd_icon := Button.new()
		cmd_icon.name = "CmdDesktopIcon"
		cmd_icon.text = "CMD"
		cmd_icon.icon = preload("res://assets/Icon32x32/script_text.png")
		cmd_icon.custom_minimum_size = Vector2(32, 32)
		cmd_icon.expand_icon = true
		cmd_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if thai_font:
			cmd_icon.add_theme_font_override("font", thai_font)
		cmd_icon.add_theme_font_size_override("font_size", 6)
		cmd_icon.pressed.connect(_on_cmd_pressed)
		icon_vbox.add_child(cmd_icon)
		_cmd_desktop_icon = cmd_icon

	# Add Desktop Phone Button dynamically into Desktop icon column
	if icon_vbox and not icon_vbox.has_node("PhoneButton"):
		var phone_desktop_icon := Button.new()
		phone_desktop_icon.name = "PhoneButton"
		phone_desktop_icon.text = "Phone"
		phone_desktop_icon.icon = preload("res://assets/Icon32x32/dialogue_page.png")
		phone_desktop_icon.custom_minimum_size = Vector2(32, 32)
		phone_desktop_icon.expand_icon = true
		phone_desktop_icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if thai_font:
			phone_desktop_icon.add_theme_font_override("font", thai_font)
		phone_desktop_icon.add_theme_font_size_override("font_size", 6)
		phone_desktop_icon.pressed.connect(func() -> void:
			if phone_panel:
				if not phone_panel.visible:
					phone_panel.open_phone("chat")
				phone_panel.move_to_front()
		)
		icon_vbox.add_child(phone_desktop_icon)

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

	var start_leave_btn := notebook_screen.find_child("StartMenuLeaveBtn", true, false) as Button
	if start_leave_btn:
		start_leave_btn.pressed.connect(func() -> void:
			if start_popup:
				start_popup.hide()
			if phone_panel:
				phone_panel.send_march_hint("ยังสืบสวนไม่ครบทั้ง 6 ขั้นตอนเลยน้อง อย่าเพิ่งออกจากเครื่องเต่าดำนะ!")
				phone_panel.open_phone("chat")
				phone_panel.move_to_front()
		)

func _setup_in_app_evidence_buttons() -> void:
	var thai_font: FontFile = load("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")

	# 1. In CMD (Terminal): Add Submit Hash Evidence Button
	if terminal_app:
		var quick_hbox: HBoxContainer = terminal_app.find_child("QuickCommandsHBox", true, false) as HBoxContainer
		if quick_hbox and not quick_hbox.has_node("CmdHashEvidenceBtn"):
			var hash_submit_btn := Button.new()
			hash_submit_btn.name = "CmdHashEvidenceBtn"
			hash_submit_btn.text = "📝 บันทึกค่า Hash (T08)"
			hash_submit_btn.custom_minimum_size = Vector2(0, 16)
			hash_submit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if thai_font:
				hash_submit_btn.add_theme_font_override("font", thai_font)
			hash_submit_btn.add_theme_font_size_override("font_size", 6)
			_apply_evidence_btn_style(hash_submit_btn)
			hash_submit_btn.pressed.connect(_on_hash_pressed)
			quick_hbox.add_child(hash_submit_btn)

	# 2. In Inspector: Add Evidence Submission Shortcut Buttons at bottom of ColorRect
	if inspector_app:
		var insp_box: Control = inspector_app.get_node_or_null("ColorRect") as Control
		if not insp_box:
			insp_box = inspector_app.find_child("ColorRect", true, false) as Control
		if insp_box and not insp_box.has_node("InspectorEvidenceBar"):
			var bar := HBoxContainer.new()
			bar.name = "InspectorEvidenceBar"
			bar.anchor_left = 0.0
			bar.anchor_right = 1.0
			bar.anchor_top = 1.0
			bar.anchor_bottom = 1.0
			bar.offset_left = 4.0
			bar.offset_right = -4.0
			bar.offset_top = -24.0
			bar.offset_bottom = -4.0
			bar.alignment = BoxContainer.ALIGNMENT_CENTER
			bar.add_theme_constant_override("separation", 3)

			var btn_ev := Button.new()
			btn_ev.text = "📝 บันทึก Event Log (T06)"
			_style_sub_evidence_btn(btn_ev, thai_font, _on_event_log_pressed)
			bar.add_child(btn_ev)

			var btn_dr := Button.new()
			btn_dr.text = "📝 บันทึก Drive Log (T07)"
			_style_sub_evidence_btn(btn_dr, thai_font, _on_drive_history_pressed)
			bar.add_child(btn_dr)

			var btn_mc := Button.new()
			btn_mc.text = "📝 บันทึก Macro (T09)"
			_style_sub_evidence_btn(btn_mc, thai_font, _on_macro_pressed)
			bar.add_child(btn_mc)

			insp_box.add_child(bar)

	# 3. In Decoder: Add Submit Decode Evidence Button at bottom of ColorRect
	if decoder_app:
		var dec_box: Control = decoder_app.get_node_or_null("ColorRect") as Control
		if not dec_box:
			dec_box = decoder_app.find_child("ColorRect", true, false) as Control
		if dec_box and not dec_box.has_node("DecoderEvidenceBar"):
			var bar := HBoxContainer.new()
			bar.name = "DecoderEvidenceBar"
			bar.anchor_left = 0.0
			bar.anchor_right = 1.0
			bar.anchor_top = 1.0
			bar.anchor_bottom = 1.0
			bar.offset_left = 4.0
			bar.offset_right = -4.0
			bar.offset_top = -24.0
			bar.offset_bottom = -4.0
			bar.alignment = BoxContainer.ALIGNMENT_CENTER

			var decode_submit_btn := Button.new()
			decode_submit_btn.name = "DecoderEvidenceBtn"
			decode_submit_btn.text = "📝 บันทึกผลถอดรหัสเพย์โหลด (T10-11)"
			decode_submit_btn.custom_minimum_size = Vector2(0, 16)
			decode_submit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if thai_font:
				decode_submit_btn.add_theme_font_override("font", thai_font)
			decode_submit_btn.add_theme_font_size_override("font_size", 6)
			_apply_evidence_btn_style(decode_submit_btn)
			decode_submit_btn.pressed.connect(_on_decoder_pressed)
			bar.add_child(decode_submit_btn)

			dec_box.add_child(bar)

	# 4. In EV-01 Explorer: Add Persistence Evidence Button
	if ev_folder_app:
		var details_hbox: HBoxContainer = ev_folder_app.find_child("DetailsBar", true, false) as HBoxContainer
		if not details_hbox:
			details_hbox = ev_folder_app.find_child("HBox", true, false) as HBoxContainer
		if details_hbox and not details_hbox.has_node("EvPersistenceEvidenceBtn"):
			var persist_btn := Button.new()
			persist_btn.name = "EvPersistenceEvidenceBtn"
			persist_btn.text = "📝 วางแผนตัดวงจร Persistence (T12)"
			persist_btn.custom_minimum_size = Vector2(0, 16)
			persist_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			if thai_font:
				persist_btn.add_theme_font_override("font", thai_font)
			persist_btn.add_theme_font_size_override("font_size", 6)
			_apply_evidence_btn_style(persist_btn)
			persist_btn.pressed.connect(_on_persistence_pressed)
			details_hbox.add_child(persist_btn)

func _style_sub_evidence_btn(btn: Button, font: FontFile, callback: Callable) -> void:
	btn.custom_minimum_size = Vector2(0, 14)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if font:
		btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 5)
	_apply_evidence_btn_style(btn)
	btn.pressed.connect(callback)

func _apply_evidence_btn_style(btn: Button) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.14, 0.32, 0.25, 0.95)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.35, 0.85, 0.6, 0.95)
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_right = 3
	sb.corner_radius_bottom_left = 3
	sb.content_margin_left = 5.0
	sb.content_margin_right = 5.0
	sb.content_margin_top = 2.0
	sb.content_margin_bottom = 2.0
	btn.add_theme_stylebox_override("normal", sb)

	var sb_h := sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = Color(0.2, 0.45, 0.35, 1.0)
	btn.add_theme_stylebox_override("hover", sb_h)

func _refresh_phone_ui() -> void:
	if phone_panel and phone_panel.has_method("update_evidence_ui"):
		phone_panel.update_evidence_ui()

func _show_march_chat_line(march_msg: String) -> void:
	if phone_panel and phone_panel.has_method("send_march_hint"):
		phone_panel.send_march_hint(march_msg)
