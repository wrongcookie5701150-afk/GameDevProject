class_name PuzzleDriveHistory extends Control

## Task 07: Drive History Typosquatting Investigation
## Target: mesasohot.sukj@universcity.example (domain: universcity.example)

signal typosquatting_detected(email: String, domain: String)
signal puzzle_completed(is_success: bool)

const TARGET_EMAIL: String = "mesasohot.sukj@universcity.example"
const TARGET_DOMAIN: String = "universcity.example"
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_THAI_MEDIUM: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

var is_completed: bool = false
var start_time: float = 0.0

@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var history_container: VBoxContainer = $VBox/Scroll/HistoryContainer

const DRIVE_ENTRIES: Array[Dictionary] = [
	{
		"time": "18:54",
		"file": "Network_Diagram.png",
		"email": "mesa.sukj@university.example",
		"owner": "Mesa Sukjai (เจ้าของไฟล์)",
		"status": "ปกติ (ไฟล์โครงสร้างเน็ตเวิร์กวิชา CS)"
	},
	{
		"time": "18:56",
		"file": "Research_Data.xlsx",
		"email": "mesa.sukj@university.example",
		"owner": "Mesa Sukjai (เจ้าของไฟล์)",
		"status": "ปกติ (ตารางข้อมูลผลวิจัยกลุ่ม)"
	},
	{
		"time": "18:57",
		"file": "Presentation.pptx",
		"email": "mesa.sukj@university.example",
		"owner": "Mesa Sukjai (เจ้าของไฟล์)",
		"status": "ปกติ (สไลด์นำเสนอวิชาความมั่นคงไซเบอร์)"
	},
	{
		"time": "18:58",
		"file": "Report_Final.docx",
		"email": "mesasohot.sukj@universcity.example",
		"owner": "External Collaborator (ผู้แชร์จากภายนอก)",
		"status": "⚠️ มีการตรวจพบ Macro ฝังอยู่ภายในเอกสาร"
	}
]

func _ready() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	_populate_history()

func _populate_history() -> void:
	if not history_container:
		return
	for child in history_container.get_children():
		child.queue_free()
	
	for entry in DRIVE_ENTRIES:
		var btn := Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.custom_minimum_size.y = 24.0
		btn.add_theme_font_override("font", FONT_THAI_MEDIUM)
		btn.add_theme_font_size_override("font_size", 6)
		btn.text = " [%s] %s\n แชร์โดย: %s | %s" % [entry["time"], entry["file"], entry["email"], entry["status"]]
		
		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = Color(0.08, 0.12, 0.18, 0.8)
		normal_style.content_margin_left = 6.0
		normal_style.content_margin_right = 6.0
		normal_style.content_margin_top = 3.0
		normal_style.content_margin_bottom = 3.0
		btn.add_theme_stylebox_override("normal", normal_style)
		
		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(0.18, 0.28, 0.42, 0.9)
		hover_style.content_margin_left = 6.0
		hover_style.content_margin_right = 6.0
		hover_style.content_margin_top = 3.0
		hover_style.content_margin_bottom = 3.0
		btn.add_theme_stylebox_override("hover", hover_style)
		
		btn.pressed.connect(_on_drive_entry_clicked.bind(entry["email"], btn))
		history_container.add_child(btn)

func _on_drive_entry_clicked(email: String, row_btn: Button) -> void:
	if is_completed:
		return
	
	if email == TARGET_EMAIL:
		is_completed = true
		row_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))
		row_btn.text = "⚠️ " + row_btn.text
		if feedback_label:
			feedback_label.text = "✔ ถูกต้อง! พบโดเมนปลอม 'universcity.example' (มีตัว c เกินมา) หลอกเป็น 'university'!"
			feedback_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.5, 1.0))
		
		# Send Telemetry Contract Task_07
		var duration: float = (Time.get_ticks_msec() / 1000.0) - start_time
		var tm: Node = get_tree().root.get_node_or_null("TelemetryManager")
		if tm and tm.has_method("track_event"):
			tm.track_event("Scene_04", "Task_07", "submit", maxf(1.0, duration), true, 1, false, {
				"selected_email": TARGET_EMAIL,
				"domain_checked": TARGET_DOMAIN
			})
		
		typosquatting_detected.emit(TARGET_EMAIL, TARGET_DOMAIN)
		puzzle_completed.emit(true)
	else:
		if feedback_label:
			feedback_label.text = "❌ บัญชีนี้คือ mesa.sukj@university.example ซึ่งเป็นโดเมนของมหาวิทยาลัยตามปกติ"
			feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
