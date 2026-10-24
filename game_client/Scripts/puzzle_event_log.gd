class_name PuzzleEventLog extends Control

## Task 06: Windows Event Log Timeline Investigation
## Target: 19:02:10 (WINWORD.EXE opened Report_Final.docx)

signal timestamp_selected(timestamp: String)
signal puzzle_completed(is_success: bool)

const TARGET_TIMESTAMP: String = "19:02:10"
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_THAI_MEDIUM: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Medium.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

var is_completed: bool = false
var start_time: float = 0.0

@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var log_container: VBoxContainer = $VBox/Scroll/LogContainer

const EVENT_LOGS: Array[Dictionary] = [
	{ "time": "18:31:04", "source": "explorer.exe", "desc": "Process started (User session initialized)", "id": 4688 },
	{ "time": "18:34:19", "source": "CloudSync.exe", "desc": "Cloud background sync service active", "id": 7036 },
	{ "time": "18:47:53", "source": "SearchIndexer.exe", "desc": "System file catalog indexing finished", "id": 1008 },
	{ "time": "18:58:07", "source": "CloudSync.exe", "desc": "New file appeared: Report_Final.docx in shared folder", "id": 4663 },
	{ "time": "19:02:10", "source": "WINWORD.EXE", "desc": "Opened document: Report_Final.docx from group folder", "id": 4688 },
	{ "time": "19:03:16", "source": "WINWORD.EXE", "desc": "User executed Macro content via Enable Content", "id": 8001 },
	{ "time": "19:05:19", "source": "WINWORD.EXE", "desc": "File dropped: Office_Update_Helper.dat in AppData/Temp", "id": 4663 },
	{ "time": "19:05:32", "source": "Registry", "desc": "Persistence added: HKCU/Software/Microsoft/Windows/CurrentVersion/Run", "id": 4657 },
	{ "time": "21:21:50", "source": "Office_Update_Helper.exe", "desc": "Malware payload process spawned", "id": 4688 },
	{ "time": "21:22:39", "source": "Ransomware Engine", "desc": "File encrypted & renamed: Report_Final.docx.locked", "id": 5145 },
	{ "time": "21:22:47", "source": "Ransomware Engine", "desc": "File encrypted & renamed: Research_Data.xlsx.locked", "id": 5145 },
	{ "time": "21:22:55", "source": "Ransomware Engine", "desc": "File encrypted & renamed: Presentation.pptx.locked", "id": 5145 },
	{ "time": "21:23:08", "source": "Ransomware Engine", "desc": "Ransom note dropped: HOW_TO_RECOVER_FILES.txt", "id": 4663 },
	{ "time": "21:23:54", "source": "Network", "desc": "Interface state changed: Wi-Fi adapter disabled", "id": 1000 }
]

func _ready() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	_setup_scrollbar()
	_populate_logs()

# Style a slim, faint, minimalist scrollbar without heavy dark track
func _setup_scrollbar() -> void:
	var scroll: ScrollContainer = get_node_or_null("VBox/Scroll")
	if not scroll:
		return
	var v_bar: VScrollBar = scroll.get_v_scroll_bar()
	if not v_bar:
		return
	
	v_bar.custom_minimum_size.x = 3.0
	
	# Transparent track: removes the wide opaque black background track
	var empty_track := StyleBoxEmpty.new()
	v_bar.add_theme_stylebox_override("scroll", empty_track)
	v_bar.add_theme_stylebox_override("scroll_focus", empty_track)
	
	# Faint, thin translucent grabber (subtle pixel-art aesthetic)
	var grabber_normal := StyleBoxFlat.new()
	grabber_normal.bg_color = Color(0.7, 0.8, 0.95, 0.22)
	grabber_normal.corner_radius_top_left = 2
	grabber_normal.corner_radius_top_right = 2
	grabber_normal.corner_radius_bottom_right = 2
	grabber_normal.corner_radius_bottom_left = 2
	grabber_normal.content_margin_left = 1.0
	grabber_normal.content_margin_right = 1.0
	v_bar.add_theme_stylebox_override("grabber", grabber_normal)
	
	var grabber_hover := StyleBoxFlat.new()
	grabber_hover.bg_color = Color(0.85, 0.95, 1.0, 0.45)
	grabber_hover.corner_radius_top_left = 2
	grabber_hover.corner_radius_top_right = 2
	grabber_hover.corner_radius_bottom_right = 2
	grabber_hover.corner_radius_bottom_left = 2
	grabber_hover.content_margin_left = 1.0
	grabber_hover.content_margin_right = 1.0
	v_bar.add_theme_stylebox_override("grabber_highlight", grabber_hover)
	v_bar.add_theme_stylebox_override("grabber_pressed", grabber_hover)

func _populate_logs() -> void:
	if not log_container:
		return
	for child in log_container.get_children():
		child.queue_free()
	
	for entry in EVENT_LOGS:
		var btn := Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.custom_minimum_size.y = 15.0
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.clip_text = true
		btn.add_theme_font_override("font", FONT_MONO)
		btn.add_theme_font_size_override("font_size", 5)
		btn.text = " [%s] %-14s | ID %4d: %s" % [entry["time"], entry["source"], entry["id"], entry["desc"]]
		
		var normal_style := StyleBoxFlat.new()
		normal_style.bg_color = Color(0.08, 0.12, 0.18, 0.8)
		normal_style.content_margin_left = 4.0
		normal_style.content_margin_right = 4.0
		normal_style.content_margin_top = 2.0
		normal_style.content_margin_bottom = 2.0
		btn.add_theme_stylebox_override("normal", normal_style)
		
		var hover_style := StyleBoxFlat.new()
		hover_style.bg_color = Color(0.18, 0.28, 0.42, 0.9)
		hover_style.content_margin_left = 4.0
		hover_style.content_margin_right = 4.0
		hover_style.content_margin_top = 2.0
		hover_style.content_margin_bottom = 2.0
		btn.add_theme_stylebox_override("hover", hover_style)
		
		btn.pressed.connect(_on_log_entry_clicked.bind(entry["time"], btn))
		log_container.add_child(btn)

func _on_log_entry_clicked(timestamp: String, row_btn: Button) -> void:
	if is_completed:
		return
	
	if timestamp == TARGET_TIMESTAMP:
		is_completed = true
		row_btn.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45, 1.0))
		row_btn.text = "✔ " + row_btn.text
		if feedback_label:
			feedback_label.text = "✔ ถูกต้อง! เวลา 19:02:10 คือตอนที่เปิดไฟล์ Report_Final.docx ครั้งแรก (จุดเริ่มต้นภัยคุกคาม)"
			feedback_label.add_theme_color_override("font_color", Color(0.35, 0.95, 0.5, 1.0))
		
		# Send Telemetry Contract Task_06
		var duration: float = (Time.get_ticks_msec() / 1000.0) - start_time
		var tm: Node = get_tree().root.get_node_or_null("TelemetryManager")
		if tm and tm.has_method("track_event"):
			tm.track_event("Scene_04", "Task_06", "submit", maxf(1.0, duration), true, 1, false, {
				"selected_timestamp": TARGET_TIMESTAMP
			})
		
		timestamp_selected.emit(TARGET_TIMESTAMP)
		puzzle_completed.emit(true)
	else:
		if feedback_label:
			feedback_label.text = "❌ เหตุการณ์นี้ยังไม่ใช่จุดเริ่มต้นของภัยคุกคาม ลองตรวจดูเวลาช่วงที่เปิดไฟล์ Word ครั้งแรก"
			feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
