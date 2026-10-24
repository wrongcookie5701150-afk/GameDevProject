class_name Scene04Investigation extends Control

## Scene 4: เข้าสู่วิถีไซเบอร์ (Investigation Intro & Triage)
## Step 1: Discord consultation & Disconnect Wi-Fi (Triage)
## Step 2: Phone call & Tao Dam Checklist (Task 5: เช็คสภาพเต่าดำ)
## Step 3: Windows Event Log Timeline 19:02:10 (Task 6 / Puzzle_Event_Log)
## Step 4: Drive History Typosquatting (Task 7 / Puzzle_Drive_History)
## Step 5: Transition to Scene 5 (Forensic Lab)

signal scene_4_started
signal triage_wifi_disconnected
signal tao_dam_checked
signal event_log_completed(timestamp: String)
signal drive_history_completed(email: String, domain: String)
signal scene_4_completed

const SCENE_05_FORENSIC_PATH: String = "res://Scenes/Scene_05_Forensic.tscn"
const PUZZLE_EVENT_LOG_SCENE: PackedScene = preload("res://Scenes/Puzzle_Event_Log.tscn")
const PUZZLE_DRIVE_HISTORY_SCENE: PackedScene = preload("res://Scenes/Puzzle_Drive_History.tscn")
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_THAI_MEDIUM: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf")

@onready var desktop: Control = $Desktop

# Modals & Dialogues
var checklist_modal: PanelContainer
var chk_wifi: CheckBox
var chk_lan: CheckBox
var chk_account: CheckBox
var chk_files: CheckBox
var chk_confirm_btn: Button

var investigation_window: DesktopWindow
var completion_modal: PanelContainer
var is_wifi_cut: bool = false
var is_tao_dam_ready: bool = false
var is_event_log_done: bool = false
var is_drive_history_done: bool = false

func _ready() -> void:
	scene_4_started.emit()
	if desktop:
		if desktop.has_method("setup_scene_4_investigation_mode"):
			desktop.call_deferred("setup_scene_4_investigation_mode")
		if desktop.has_signal("wifi_toggled"):
			desktop.wifi_toggled.connect(_on_desktop_wifi_toggled)
	
	_setup_checklist_modal()
	_setup_investigation_window()
	_setup_completion_modal()
	
	# Start Step 1 prompt
	_prompt_step_1_triage()

# Step 1: Triage - Disconnect Wi-Fi
func _prompt_step_1_triage() -> void:
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_callback(func() -> void:
		_show_toast("พี่มาร์ช (Discord)", "น้องงงง คอมโดนไวรัสเรียกค่าไถ่แล้ว รีบตัดเน็ตคอมพิวเตอร์ก่อนเลย!", 3.5)
		_set_task_text("• Scene 4: เข้าสู่วิถีไซเบอร์", "- [ ] ตัดการเชื่อมต่อ Wi-Fi ที่ Taskbar ทันที (Triage)")
	)

func _on_desktop_wifi_toggled(is_connected: bool) -> void:
	if not is_connected and not is_wifi_cut:
		is_wifi_cut = true
		triage_wifi_disconnected.emit()
		_show_toast("เมย์", "ตัดเน็ตเรียบร้อยแล้ว ไวรัสไม่น่าจะส่งข้อมูลออกไปได้แล้วนะ", 2.5)
		_set_task_text("• Scene 4: เข้าสู่วิถีไซเบอร์", "- [x] ตัดการเชื่อมต่อ Wi-Fi สำเร็จ")
		
		# Advance to Step 2: Tao Dam checklist
		var tw := create_tween()
		tw.tween_interval(1.8)
		tw.tween_callback(_start_step_2_tao_dam)

# Step 2: Tao Dam Isolated Environment Checklist (Task 5)
func _start_step_2_tao_dam() -> void:
	_show_toast("มาร์ช (โทรศัพท์)", "ยังมีโน้ตบุ๊กเต่าดำอยู่ใช่มั้ย มาเช็คสภาพเครื่องก่อนใช้งาน", 3.0)
	_set_task_text("• Task 5: เช็คสภาพเต่าดำ", "- [ ] ตรวจสอบความพร้อมเครื่องเต่าดำ (Isolated Environment)")
	
	var tw := create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(func() -> void:
		if checklist_modal:
			checklist_modal.visible = true
	)

func _setup_checklist_modal() -> void:
	checklist_modal = PanelContainer.new()
	checklist_modal.name = "TaoDamChecklistModal"
	checklist_modal.custom_minimum_size = Vector2(280, 160)
	checklist_modal.size = Vector2(280, 160)
	checklist_modal.position = Vector2(100, 45)
	checklist_modal.z_index = 50
	checklist_modal.visible = false
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.6, 0.9, 0.9)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	checklist_modal.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	checklist_modal.add_child(vbox)
	
	var title := Label.new()
	title.text = "🐢 Task 5: เช็คสภาพเครื่องเต่าดำ (Isolated Environment)"
	title.add_theme_font_override("font", FONT_THAI_BOLD)
	title.add_theme_font_size_override("font_size", 7)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4, 1.0))
	vbox.add_child(title)
	
	var desc := Label.new()
	desc.text = "ตรวจสอบสภาพเครื่องวิเคราะห์หลักฐาน ต้องแยกตัวจากเครือข่ายอย่างสมบูรณ์:"
	desc.add_theme_font_override("font", FONT_THAI_MEDIUM)
	desc.add_theme_font_size_override("font_size", 6)
	desc.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95, 0.9))
	vbox.add_child(desc)
	
	chk_wifi = CheckBox.new()
	chk_wifi.text = "1. Wi-Fi ปิดอยู่ (ไม่มีสัญญาณเชื่อมต่อไร้สาย)"
	chk_wifi.add_theme_font_override("font", FONT_THAI_MEDIUM)
	chk_wifi.add_theme_font_size_override("font_size", 6)
	chk_wifi.toggled.connect(_on_checklist_toggled)
	vbox.add_child(chk_wifi)
	
	chk_lan = CheckBox.new()
	chk_lan.text = "2. ไม่เสียบสาย LAN เข้าเครื่อง"
	chk_lan.add_theme_font_override("font", FONT_THAI_MEDIUM)
	chk_lan.add_theme_font_size_override("font_size", 6)
	chk_lan.toggled.connect(_on_checklist_toggled)
	vbox.add_child(chk_lan)
	
	chk_account = CheckBox.new()
	chk_account.text = "3. ไม่มีเชื่อมต่อบัญชีหรืออีเมลส่วนตัว"
	chk_account.add_theme_font_override("font", FONT_THAI_MEDIUM)
	chk_account.add_theme_font_size_override("font_size", 6)
	chk_account.toggled.connect(_on_checklist_toggled)
	vbox.add_child(chk_account)
	
	chk_files = CheckBox.new()
	chk_files.text = "4. ไม่มีไฟล์งานสำคัญค้างอยู่ในเครื่อง"
	chk_files.add_theme_font_override("font", FONT_THAI_MEDIUM)
	chk_files.add_theme_font_size_override("font_size", 6)
	chk_files.toggled.connect(_on_checklist_toggled)
	vbox.add_child(chk_files)
	
	chk_confirm_btn = Button.new()
	chk_confirm_btn.text = "ยืนยันความพร้อมเต่าดำ (Isolated Environment)"
	chk_confirm_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	chk_confirm_btn.add_theme_font_size_override("font_size", 6)
	chk_confirm_btn.disabled = true
	chk_confirm_btn.pressed.connect(_on_tao_dam_confirmed)
	vbox.add_child(chk_confirm_btn)
	
	add_child(checklist_modal)

func _on_checklist_toggled(_toggled: bool) -> void:
	if chk_wifi and chk_lan and chk_account and chk_files and chk_confirm_btn:
		chk_confirm_btn.disabled = not (chk_wifi.button_pressed and chk_lan.button_pressed and chk_account.button_pressed and chk_files.button_pressed)

func _on_tao_dam_confirmed() -> void:
	is_tao_dam_ready = true
	if checklist_modal:
		checklist_modal.visible = false
	
	tao_dam_checked.emit()
	_show_toast("เมย์", "เต่าดำพร้อมใช้งานแบบ Isolated Environment แล้ว!", 2.5)
	_set_task_text("• Task 6: ขีดเส้นแบ่งเวลา", "- [ ] ตรวจสอบ Event Log และระบุเวลาจุดเริ่มต้น (19:02:10)")
	
	# Advance to Step 3: Event Log
	var tw := create_tween()
	tw.tween_interval(1.5)
	tw.tween_callback(_start_step_3_event_log)

# Step 3: Windows Event Log Timeline 19:02:10 (Task 6 / Puzzle_Event_Log)
func _start_step_3_event_log() -> void:
	_show_toast("มาร์ช", "มีเหตุการณ์บันทึกไว้เยอะมาก พอจำได้มั้ยว่าทำอะไรก่อนไฟล์จะล็อกไป", 3.0)
	if investigation_window:
		investigation_window.window_title = "Event Viewer - Windows Logs (Task 6)"
		var content := investigation_window.get_content_container()
		for child in content.get_children():
			child.queue_free()
		
		var puzzle := PUZZLE_EVENT_LOG_SCENE.instantiate()
		puzzle.connect("timestamp_selected", _on_event_log_selected)
		content.add_child(puzzle)
		
		investigation_window.visible = true
		investigation_window.move_to_front()

func _on_event_log_selected(timestamp: String) -> void:
	if timestamp == "19:02:10" and not is_event_log_done:
		is_event_log_done = true
		event_log_completed.emit(timestamp)
		_show_toast("เมย์", "เริ่มต้นจากไฟล์ Report_Final.docx ตอน 19:02:10 เมษาแกล้งฉันหรือเปล่านะ", 3.2)
		_set_task_text("• Task 7: คนร้ายนั้นก็คือ..", "- [ ] ตรวจสอบประวัติ Google Drive หาผู้ส่งที่น่าสงสัย")
		
		# Advance to Step 4: Drive History
		var tw := create_tween()
		tw.tween_interval(2.0)
		tw.tween_callback(_start_step_4_drive_history)

# Step 4: Drive History Typosquatting (Task 7 / Puzzle_Drive_History)
func _start_step_4_drive_history() -> void:
	_show_toast("มาร์ช", "ลองเช็คที่มาของไฟล์บน Google Drive กันก่อนว่าใครส่งมา", 3.0)
	if investigation_window:
		investigation_window.window_title = "Google Drive - ประวัติกิจกรรมงานกลุ่ม (Task 7)"
		var content := investigation_window.get_content_container()
		for child in content.get_children():
			child.queue_free()
		
		var puzzle := PUZZLE_DRIVE_HISTORY_SCENE.instantiate()
		puzzle.connect("typosquatting_detected", _on_typosquatting_detected)
		content.add_child(puzzle)
		
		investigation_window.visible = true
		investigation_window.move_to_front()

func _on_typosquatting_detected(email: String, domain: String) -> void:
	if not is_drive_history_done:
		is_drive_history_done = true
		drive_history_completed.emit(email, domain)
		_show_toast("เมย์", "เธอไม่ได้ส่งไฟล์นี้มาหรอเนี่ย! โดน mesasohot หลอกซะแล้ว", 3.2)
		_set_task_text("• Scene 4: สรุปผลการสืบสวน", "- [x] ระบุผู้ส่ง Phishing สำเร็จ (mesasohot.sukj@universcity.example)")
		
		# Advance to Step 5: Scene completion
		var tw := create_tween()
		tw.tween_interval(2.5)
		tw.tween_callback(_complete_scene_4)

func _complete_scene_4() -> void:
	_show_toast("มาร์ช", "เอาล่ะ ได้เวลาวิเคราะห์หลักฐานแล้ว ยังมี EV Drive มั้ย เดี๋ยวเราไปต่อที่แล็บเต่าดำ", 3.5)
	if completion_modal:
		completion_modal.visible = true
	scene_4_completed.emit()

func _setup_investigation_window() -> void:
	var win_scene: PackedScene = preload("res://Scenes/desktop/DesktopWindow.tscn")
	investigation_window = win_scene.instantiate() as DesktopWindow
	investigation_window.name = "InvestigationWindow"
	investigation_window.custom_minimum_size = Vector2(300, 185)
	investigation_window.size = Vector2(300, 185)
	investigation_window.position = Vector2(90, 30)
	investigation_window.z_index = 42
	investigation_window.visible = false
	add_child(investigation_window)

func _setup_completion_modal() -> void:
	completion_modal = PanelContainer.new()
	completion_modal.name = "Scene4CompletionModal"
	completion_modal.custom_minimum_size = Vector2(260, 100)
	completion_modal.size = Vector2(260, 100)
	completion_modal.position = Vector2(110, 80)
	completion_modal.z_index = 55
	completion_modal.visible = false
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.1, 0.16, 0.98)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.85, 0.45, 0.95)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	completion_modal.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	completion_modal.add_child(vbox)
	
	var title := Label.new()
	title.text = "🎉 จบการสืบสวนเบื้องต้น (Scene 4 Completed)"
	title.add_theme_font_override("font", FONT_THAI_BOLD)
	title.add_theme_font_size_override("font_size", 7)
	title.add_theme_color_override("font_color", Color(0.4, 0.95, 0.5, 1.0))
	vbox.add_child(title)
	
	var desc := Label.new()
	desc.text = "ระบุเวลาจุดเริ่มต้น (19:02:10) และตรวจพบ Phishing Typosquatting เรียบร้อยแล้ว\nพร้อมเข้าสู่การวิเคราะห์ Forensics ใน Scene 5!"
	desc.add_theme_font_override("font", FONT_THAI_MEDIUM)
	desc.add_theme_font_size_override("font_size", 6)
	desc.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
	vbox.add_child(desc)
	
	var next_btn := Button.new()
	next_btn.text = "เข้าสู่ Scene 5: วิเคราะห์หลักฐาน (Forensic Lab)"
	next_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	next_btn.add_theme_font_size_override("font_size", 6)
	next_btn.pressed.connect(_on_next_scene_pressed)
	vbox.add_child(next_btn)
	
	add_child(completion_modal)

func _on_next_scene_pressed() -> void:
	if ResourceLoader.exists(SCENE_05_FORENSIC_PATH):
		get_tree().change_scene_to_file(SCENE_05_FORENSIC_PATH)

func _show_toast(speaker: String, text: String, duration: float = 3.0) -> void:
	if desktop and desktop.has_method("_show_dialogue_toast"):
		desktop._show_dialogue_toast(speaker, text, duration)

func _set_task_text(header: String, item1: String) -> void:
	if desktop:
		var h_label: Label = desktop.get("objective_header_label") as Label
		var i_label: Label = desktop.get("objective_item1_label") as Label
		if h_label: h_label.text = header
		if i_label: i_label.text = item1

func _unhandled_input(event: InputEvent) -> void:
	# Developer quick-skip for debugging
	if OS.is_debug_build() and event is InputEventKey and event.pressed and event.keycode == KEY_F10:
		_complete_scene_4()
