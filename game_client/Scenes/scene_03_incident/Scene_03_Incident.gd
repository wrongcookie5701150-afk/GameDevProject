extends DesktopScreenController

const SCENE_04_PATH: String = "res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn"

# Thai and Mono fonts for academic document & cutscene
const FONT_THAI_REG: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Regular.ttf")
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_THAI_SEMIBOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")

# 10x10 / 12x12 Pixel Icons for Academic Figures
const ICON_WARNING: Texture2D = preload("res://assets/Icon32x32/warning.png")
const ICON_DOC: Texture2D = preload("res://assets/Icon32x32/doc.png")
const ICON_SCRIPT: Texture2D = preload("res://assets/Icon32x32/script_code.png")
const ICON_COMPUTER: Texture2D = preload("res://assets/Icon32x32/computer.png")
const ICON_WIFI_OFF: Texture2D = preload("res://assets/Icon32x32/world_disable.png")
const ICON_WIFI_ON: Texture2D = preload("res://assets/Icon32x32/world_enable.png")
const ICON_MAGNIFIER: Texture2D = preload("res://assets/Icon32x32/magnifier.png")
const ICON_CLOCK: Texture2D = preload("res://assets/Icon32x32/clock.png")
const ICON_SHIELD: Texture2D = preload("res://assets/Icon32x32/shield.png")
const ICON_DELETE: Texture2D = preload("res://assets/Icon32x32/delete.png")
const ICON_DISK_SAVE: Texture2D = preload("res://assets/Icon32x32/disk_save.png")

# Cutscene Controls & Overlays
@onready var ransom_note: PanelContainer = %RansomNote
@onready var ransom_minimize_btn: Button = get_node_or_null("%MinimizeButton") as Button
@onready var ransom_close_btn: Button = get_node_or_null("%CloseButton") as Button
@onready var march_chat_panel: Panel = get_node_or_null("MarchChatPanel")
@onready var skip_button: Button = %SkipCutsceneButton
@onready var glitch_overlay: ColorRect = %GlitchOverlay

# Backward compatibility nodes
@onready var notification_panel: Panel = get_node_or_null("NotificationPanel")
@onready var notification_label: Label = get_node_or_null("NotificationPanel/NotificationLabel")

# Cutscene state
var _is_skipped: bool = false
var _is_cutscene_running: bool = false
var _is_waiting_for_save: bool = false
var _is_ransomware_triggered: bool = false
var _can_exit_pc: bool = false

var _passage_label: RichTextLabel

# Dynamic Cutscene UI Elements
var _cutscene_dim_overlay: ColorRect = null
var _loading_overlay: CenterContainer = null
var _cutscene_root: VBoxContainer = null
var _cutscene_scroll: ScrollContainer = null
var _cutscene_sections_container: VBoxContainer = null
var _cutscene_progress_bar: ProgressBar = null
var _cutscene_live_status_lbl: Label = null
var _cutscene_blink_tween: Tween = null
var _section_nodes: Array[Dictionary] = []

const FULL_REPORT_TEXT: String = """=== Cybersecurity Group Assignment: Incident Analysis & Recovery ===
Author: May (CS Year 2) | Group 8
Course: Network & Cyber Security Fundamentals
--------------------------------------------------------------

[1] Phishing Delivery & Email Provenance
- Attackers register typosquatting domains (e.g. subtle misspellings in sender emails or shared drives).
- Always verify sender domains character-by-character before trusting attachments.
- Macro-enabled documents (VBA AutoOpen / Document_Open) execute hidden helper binaries directly in AppData/Temp.

[2] Payload Obfuscation & Decoding Techniques
- Attackers obfuscate critical strings using Base64 and Hexadecimal encoding to bypass signature scanners.
- Base64 Decoding: Stripping padding and decoding strings exposes dropped helper tools (e.g. 'Office_Update_Helper.exe').
- Hexadecimal Decoding: Hex strings (e.g. 46 49 4C 45...) decode to ASCII commands such as 'FILE_WIPE'.
- Crucial Rule: Analysts must determine whether malware is reversible encryption or a destructive wiper before restoration!

[3] Windows Event Log Forensics & Timelines
- Windows Security and System Event Logs track process creation and network beacons with exact timestamps.
- Cross-referencing timestamps (e.g. initial execution at 19:02:10) isolates patient zero and affected files.

[4] Incident Containment & 3-2-1 Safe Backup Recovery
- First response: Immediately isolate infected devices from the network to halt automated CloudSync!
- Terminate persistence: Inspect Scheduled Tasks (schtasks) and Registry Run keys before recovery.
- Safe Restoration: Apply the 3-2-1 backup rule - restore clean versions prior to infection to an isolated destination.
--------------------------------------------------------------
[Report draft complete. All 4 group files ready for submission.]"""

const CUTSCENE_SECTIONS: Array[Dictionary] = [
	{
		"time": "19:30",
		"title": "1. กลไกการหลอกลวงทางวิศวกรรมสังคมและการฝังสคริปต์มาโครในเอกสาร",
		"text": "      จากการศึกษาพฤติกรรมการโจมตีทางไซเบอร์พบว่า ผู้โจมตีนิยมใช้เทคนิคจดชื่อโดเมนเลียนแบบหน่วยงานจริง หรือ [b][color=#0d5c9e]Domain Typosquatting[/color][/b] (เช่น เปลี่ยนรหัสจาก [b].ac.th[/b] เป็น [b][color=#b91c1c].ac.co[/color][/b]) ร่วมกับการเร่งรัดให้เปิดไฟล์แนบ เมื่อเหยื่อกดอนุญาต [b]Enable Content[/b] โมดูลมาโครแฝง ([b]word/vbaProject.bin[/b]) จะถอดรหัสสตริง [b]Base64[/b] และ [b]Hexadecimal[/b] เพื่อรันคำสั่งทำลายข้อมูลทันที",
		"notification": "⚙️ ระบบเบื้องหลัง (19:30 น.): สคริปต์จากปุ่ม Enable Macro กำลังทำงานเงียบๆ ในพื้นหลัง...",
		"fig_type": "fig1",
		"fig_badge": "[กำลังสร้างและแทรกแผนภาพประกอบ Figure 1...]"
	},
	{
		"time": "20:15",
		"title": "2. การจำกัดขอบเขตความเสียหาย (Containment) และผลกระทบต่อระบบซิงค์คลาวด์",
		"text": "      เมื่อพบว่าเครื่องคอมพิวเตอร์มีอาการผิดปกติหรือสงสัยว่าติดมัลแวร์ มาตรการแรกที่สำคัญที่สุดคือ [b][color=#0d5c9e]การตัดการเชื่อมต่อเครือข่ายและระงับบริการซิงค์ข้อมูลอัตโนมัติ (Network & Cloud Sync Isolation)[/color][/b] ทันที เพราะหากปล่อยให้เชื่อมต่ออินเทอร์เน็ตต่อไป ระบบ Cloud Auto-Sync จะอัปโหลดไฟล์ที่ถูกล็อก ([b].locked[/b]) ขึ้นไปเขียนทับสำเนาที่ปลอดภัยบนคลาวด์โดยอัตโนมัติ",
		"notification": "⚠️ System Alert (20:15 น.): แอบติดตั้ง 'Office_Update_Helper' ลงใน Scheduled Task สำเร็จ",
		"fig_type": "fig2",
		"fig_badge": "[กำลังสร้างและแทรกแผนภาพประกอบ Figure 2...]"
	},
	{
		"time": "21:00",
		"title": "3. มาตรฐานการตรวจพิสูจน์หลักฐานดิจิทัลบนเครื่องวิเคราะห์แยกส่วน (Digital Forensics)",
		"text": "      ผู้ตรวจสอบจะต้องไม่เปิดหรือซ่อมไฟล์บนเครื่องที่เกิดเหตุโดยตรง แต่ต้องคัดลอกออกมาเป็น [b][color=#0d5c9e]สำเนาหลักฐานแบบอ่านอย่างเดียว (Read-Only Forensic Image)[/color][/b] เพื่อนำไปตรวจสอบในเครื่องคอมพิวเตอร์แยกส่วนที่ตัดการเชื่อมต่อเครือข่าย (Air-Gapped Lab) ตามตารางเครื่องมือมาตรฐานดังนี้",
		"notification": "🔒 Background Process (21:00 น.): โปรเซสแปลกปลอมกำลังเข้าถึงโฟลเดอร์ 'งานกลุ่มล้านแปด'...",
		"fig_type": "table1",
		"fig_badge": "[กำลังสร้างและแทรกตารางสรุป Table 1...]"
	},
	{
		"time": "21:20",
		"title": "4. ขั้นตอนการถอนการฝังตัวถาวร (Persistence) และการกู้คืนตามหลักการ 3-2-1 Backup",
		"text": "      ก่อนทำการกู้คืนข้อมูล ผู้ดูแลระบบต้องเข้าสู่ [b][color=#0d5c9e]Safe Mode[/color][/b] เพื่อระงับการทำงานของมัลแวร์เบื้องหลัง และถอนรายการที่ฝังตัวอยู่ใน [b][color=#b91c1c]Scheduled Task[/color][/b] ออกให้หมดสิ้น จากนั้นจึงกู้คืนไฟล์จากจุดเวลาที่ปลอดภัยก่อนเกิดเหตุ ([b]Clean Snapshot[/b]) ตามหลักการสำรองข้อมูล [b][color=#065f46]3-2-1 Backup Rule[/color][/b] (มีข้อมูล 3 ชุด เก็บในสื่อ 2 ประเภท และแยกเก็บนอกสถานที่หรือคลาวด์ 1 ชุด)",
		"notification": "☁️ CloudSync (21:20 น.): เตรียมซิงค์ไฟล์ในโฟลเดอร์งานกลุ่มขึ้นคลาวด์อัตโนมัติทันทีที่กด Save",
		"fig_type": "fig3",
		"fig_badge": "[กำลังสร้างและแทรกแผนภาพประกอบ Figure 3...]"
	}
]

func _ready() -> void:
	super._ready()
	_init_incident_overlays()
	_connect_incident_signals()
	_show_toast("💡 ภารกิจ: เปิดแอป 'GG Disk' เพื่อดาวน์โหลดโฟลเดอร์ 'งานกลุ่ม' มาทำรายงาน")

func _init_incident_overlays() -> void:
	if notification_panel:
		notification_panel.hide()
	if march_chat_panel:
		march_chat_panel.hide()
	if ransom_note:
		ransom_note.hide()
	if glitch_overlay:
		glitch_overlay.hide()
	if skip_button:
		skip_button.hide()
	if clock_label:
		clock_label.text = "19:02"

func _connect_incident_signals() -> void:
	if skip_button and not skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.connect(_on_skip_pressed)
	if not ransom_close_btn and ransom_note:
		ransom_close_btn = ransom_note.find_child("CloseButton", true, false) as Button
	if not ransom_minimize_btn and ransom_note:
		ransom_minimize_btn = ransom_note.find_child("MinimizeButton", true, false) as Button
	
	if ransom_close_btn and not ransom_close_btn.pressed.is_connected(_on_ransom_dismissed):
		ransom_close_btn.pressed.connect(_on_ransom_dismissed)
	if ransom_minimize_btn and not ransom_minimize_btn.pressed.is_connected(_on_ransom_dismissed):
		ransom_minimize_btn.pressed.connect(_on_ransom_dismissed)
	
	if ms_word_window:
		if ms_word_window.has_signal("typing_completed") and not ms_word_window.typing_completed.is_connected(_on_typing_game_completed):
			ms_word_window.typing_completed.connect(_on_typing_game_completed)
		if ms_word_window.has_signal("macro_enabled") and not ms_word_window.macro_enabled.is_connected(_on_word_macro_enabled):
			ms_word_window.macro_enabled.connect(_on_word_macro_enabled)
		if ms_word_window.has_signal("save_pressed") and not ms_word_window.save_pressed.is_connected(_on_save_clicked):
			ms_word_window.save_pressed.connect(_on_save_clicked)
		else:
			var save_btn: Button = ms_word_window.find_child("SaveButton", true, false) as Button
			if not save_btn:
				save_btn = ms_word_window.find_child("Button", true, false) as Button
			if save_btn and not save_btn.pressed.is_connected(_on_save_clicked):
				save_btn.pressed.connect(_on_save_clicked)

func _on_folder_downloaded_from_disk() -> void:
	super._on_folder_downloaded_from_disk()
	if clock_label:
		clock_label.text = "19:02"

func _on_word_macro_enabled() -> void:
	if clock_label:
		clock_label.text = "19:03"
	TelemetryManager.track_event("Scene_02", "T03", "macro_enabled", 0.0, true)

func _on_typing_game_completed() -> void:
	# Transition smoothly into the improved cinematic report writing cutscene
	_play_report_writing_cutscene()

## Helper to safely target the MS Word Workspace MarginContainer (avoids AppHeader/MarginContainer)
func _get_workspace_margin() -> Control:
	if not ms_word_window:
		return null
	var margin: Control = ms_word_window.get_node_or_null("ColorRect/VBoxContainer/Workspace/MarginContainer") as Control
	if not margin:
		var workspace: Control = ms_word_window.find_child("Workspace", true, false) as Control
		if workspace:
			margin = workspace.get_node_or_null("MarginContainer") as Control
			if not margin:
				margin = workspace
	return margin

# ---------------------------------------------------------------------------
# Cutscene Step 1: Background Dimming & Transition Loading Card
# ---------------------------------------------------------------------------
func _play_report_writing_cutscene() -> void:
	if _is_cutscene_running:
		return
	_is_cutscene_running = true
	_is_skipped = false

	_prepare_word_for_cutscene()
	_apply_cutscene_dimming()

	await _show_transition_loading_card()
	if _is_skipped or not is_instance_valid(self) or not is_inside_tree():
		return

	_build_live_cutscene_ui()
	await _run_live_cutscene_sequence()

func _prepare_word_for_cutscene() -> void:
	if not ms_word_window:
		return
	ms_word_window.show()
	ms_word_window.move_to_front()
	_update_taskbar_tab(ms_word_window, "MS Word", true)
	_highlight_active_tab(ms_word_window)

	# Expand MS Word window to full safe canvas (444x232)
	if ms_word_window.has_method("prepare_blank_canvas"):
		ms_word_window.call("prepare_blank_canvas")

	# Hide macro banner if visible
	var macro_banner: Node = ms_word_window.find_child("MacroBanner", true, false)
	if macro_banner and macro_banner is CanvasItem:
		macro_banner.hide()

	# Hide RibbonTabs and ToolBar during live typing cutscene
	var ribbon_tabs: Control = ms_word_window.find_child("RibbonTabs", true, false) as Control
	if ribbon_tabs:
		ribbon_tabs.hide()
	var toolbar: Control = ms_word_window.find_child("ToolBar", true, false) as Control
	if toolbar:
		toolbar.hide()

	# Hide the old VScrollBar of ms_word_window to prevent duplicate scrollbars
	var old_vsb: Control = ms_word_window.find_child("VScrollBar", true, false) as Control
	if old_vsb:
		old_vsb.hide()

	# Hide previous interactive pre-test puzzle & raw passage editor
	var typing_puzzle: Node = ms_word_window.find_child("TypingPuzzle", true, false)
	if typing_puzzle:
		if "is_resolved" in typing_puzzle:
			typing_puzzle.is_resolved = true
		if typing_puzzle is CanvasItem:
			typing_puzzle.hide()

	_passage_label = ms_word_window.find_child("PassageLabel", true, false) as RichTextLabel
	if not _passage_label and typing_puzzle:
		_passage_label = typing_puzzle.find_child("PassageLabel", true, false) as RichTextLabel
	if _passage_label:
		_passage_label.hide()

	var editor_input: TextEdit = ms_word_window.find_child("TextEdit", true, false) as TextEdit
	if editor_input:
		editor_input.text = ""
		editor_input.editable = false
		editor_input.release_focus()
		editor_input.hide()

	# Hide Workspace MarginContainer temporarily while transition loading card is active
	var ws_margin: Control = _get_workspace_margin()
	if ws_margin:
		ws_margin.hide()

	if ms_word_window.has_method("scroll_to_top"):
		ms_word_window.call("scroll_to_top")

func _apply_cutscene_dimming() -> void:
	if _cutscene_dim_overlay and is_instance_valid(_cutscene_dim_overlay):
		_cutscene_dim_overlay.queue_free()
		_cutscene_dim_overlay = null

	# Add dimming overlay directly to self covering full screen (480x270)
	_cutscene_dim_overlay = ColorRect.new()
	_cutscene_dim_overlay.name = "CutsceneDimOverlay"
	_cutscene_dim_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cutscene_dim_overlay.custom_minimum_size = Vector2(480, 270)
	_cutscene_dim_overlay.size = Vector2(480, 270)
	_cutscene_dim_overlay.color = Color(0.01, 0.02, 0.06, 0.0)
	_cutscene_dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cutscene_dim_overlay.z_as_relative = false
	_cutscene_dim_overlay.z_index = 20
	add_child(_cutscene_dim_overlay)

	# Ensure ms_word_window is at z_index 25 and skip_button at 28
	if ms_word_window:
		ms_word_window.z_as_relative = false
		ms_word_window.z_index = 25

	if skip_button:
		skip_button.z_as_relative = false
		skip_button.z_index = 28
		skip_button.show()
		skip_button.move_to_front()

	var dim_tw := create_tween()
	dim_tw.tween_property(_cutscene_dim_overlay, "color:a", 0.72, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _restore_cutscene_dimming(duration: float = 0.35) -> void:
	if _cutscene_dim_overlay and is_instance_valid(_cutscene_dim_overlay):
		var target_overlay: ColorRect = _cutscene_dim_overlay
		_cutscene_dim_overlay = null
		var tw := create_tween()
		tw.tween_property(target_overlay, "color:a", 0.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.finished.connect(func() -> void:
			if is_instance_valid(target_overlay):
				target_overlay.queue_free()
		)
	if ms_word_window and is_instance_valid(ms_word_window):
		ms_word_window.z_as_relative = true
		ms_word_window.z_index = 0

func _show_transition_loading_card() -> void:
	if not ms_word_window:
		return

	# Add loading overlay directly to ColorRect (the main window frame of MS Word)
	var word_color_rect: Control = ms_word_window.get_node_or_null("ColorRect") as Control
	if not word_color_rect:
		word_color_rect = ms_word_window

	_loading_overlay = CenterContainer.new()
	_loading_overlay.name = "CutsceneLoadingOverlay"
	_loading_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_loading_overlay.mouse_filter = Control.MOUSE_FILTER_PASS
	_loading_overlay.z_as_relative = false
	_loading_overlay.z_index = 30
	word_color_rect.add_child(_loading_overlay)

	var card := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.96)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.24, 0.52, 0.88, 0.95)
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_right = 4
	sb.corner_radius_bottom_left = 4
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 10.0
	sb.content_margin_bottom = 10.0
	sb.shadow_color = Color(0, 0, 0, 0.45)
	sb.shadow_size = 6
	card.add_theme_stylebox_override("panel", sb)
	_loading_overlay.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	card.add_child(vb)

	var title_lbl := Label.new()
	title_lbl.text = "⏳ กำลังบันทึกผลแบบประเมิน และเปิดไฟล์ร่างรายงานวิชาการ..."
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	title_lbl.add_theme_font_size_override("font_size", 7)
	title_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "(Sec101_Report_Final.docx)"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_override("font", FONT_THAI_REG)
	sub_lbl.add_theme_font_size_override("font_size", 6)
	sub_lbl.add_theme_color_override("font_color", Color(0.55, 0.78, 1.0, 0.95))
	vb.add_child(sub_lbl)

	var pb := ProgressBar.new()
	pb.custom_minimum_size = Vector2(240, 8)
	pb.min_value = 0.0
	pb.max_value = 100.0
	pb.value = 0.0
	pb.show_percentage = true
	pb.add_theme_font_override("font", FONT_THAI_REG)
	pb.add_theme_font_size_override("font_size", 5)

	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = Color(0.12, 0.16, 0.22, 1.0)
	pb_bg.corner_radius_top_left = 2
	pb_bg.corner_radius_top_right = 2
	pb_bg.corner_radius_bottom_right = 2
	pb_bg.corner_radius_bottom_left = 2
	var pb_fg := StyleBoxFlat.new()
	pb_fg.bg_color = Color(0.18, 0.58, 0.92, 1.0)
	pb_fg.corner_radius_top_left = 2
	pb_fg.corner_radius_top_right = 2
	pb_fg.corner_radius_bottom_right = 2
	pb_fg.corner_radius_bottom_left = 2
	pb.add_theme_stylebox_override("background", pb_bg)
	pb.add_theme_stylebox_override("fill", pb_fg)
	vb.add_child(pb)

	var detail_lbl := Label.new()
	detail_lbl.text = "กำลังเตรียมโครงสร้างเอกสารและแทรกข้อมูลวิเคราะห์ภัยคุกคาม..."
	detail_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_lbl.add_theme_font_override("font", FONT_THAI_REG)
	detail_lbl.add_theme_font_size_override("font_size", 5)
	detail_lbl.add_theme_color_override("font_color", Color(0.65, 0.72, 0.82, 0.85))
	vb.add_child(detail_lbl)

	# ~1.2s total transition loading
	var tw := create_tween()
	tw.tween_property(pb, "value", 100.0, 1.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	while tw.is_running() and not _is_skipped and is_instance_valid(self) and is_inside_tree():
		await get_tree().create_timer(0.05).timeout

	if _is_skipped or not is_instance_valid(self) or not is_inside_tree():
		if is_instance_valid(_loading_overlay):
			_loading_overlay.queue_free()
			_loading_overlay = null
		return

	await get_tree().create_timer(0.08).timeout

	if is_instance_valid(_loading_overlay):
		var target_load: CenterContainer = _loading_overlay
		_loading_overlay = null
		var fade_tw := create_tween()
		fade_tw.tween_property(target_load, "modulate:a", 0.0, 0.15)
		fade_tw.finished.connect(func() -> void:
			if is_instance_valid(target_load):
				target_load.queue_free()
		)
		await get_tree().create_timer(0.16).timeout

# ---------------------------------------------------------------------------
# Cutscene Step 2: Live Status Bar & Dynamic Paper Building
# ---------------------------------------------------------------------------
func _build_live_cutscene_ui() -> void:
	var workspace_margin: Control = _get_workspace_margin()
	if not workspace_margin:
		return

	workspace_margin.show()

	if _cutscene_root and is_instance_valid(_cutscene_root):
		_cutscene_root.queue_free()
		_cutscene_root = null

	# Ensure duplicate VScrollBar is hidden
	var old_vsb: Control = ms_word_window.find_child("VScrollBar", true, false) as Control
	if old_vsb:
		old_vsb.hide()

	# Ensure RibbonTabs and ToolBar remain hidden while typing live
	var ribbon_tabs: Control = ms_word_window.find_child("RibbonTabs", true, false) as Control
	if ribbon_tabs:
		ribbon_tabs.hide()
	var toolbar: Control = ms_word_window.find_child("ToolBar", true, false) as Control
	if toolbar:
		toolbar.hide()

	_cutscene_root = VBoxContainer.new()
	_cutscene_root.name = "CutsceneReportRoot"
	_cutscene_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cutscene_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cutscene_root.custom_minimum_size = Vector2(0, 175)
	_cutscene_root.add_theme_constant_override("separation", 2)
	workspace_margin.add_child(_cutscene_root)

	# --- Live Status Bar ---
	var status_panel := PanelContainer.new()
	status_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sp_style := StyleBoxFlat.new()
	sp_style.bg_color = Color(0.1, 0.15, 0.24, 0.96)
	sp_style.border_width_bottom = 1
	sp_style.border_color = Color(0.24, 0.48, 0.78, 0.85)
	sp_style.corner_radius_top_left = 2
	sp_style.corner_radius_top_right = 2
	sp_style.content_margin_left = 6.0
	sp_style.content_margin_right = 6.0
	sp_style.content_margin_top = 2.0
	sp_style.content_margin_bottom = 2.0
	status_panel.add_theme_stylebox_override("panel", sp_style)
	_cutscene_root.add_child(status_panel)

	var sb_hb := HBoxContainer.new()
	sb_hb.add_theme_constant_override("separation", 6)
	status_panel.add_child(sb_hb)

	_cutscene_live_status_lbl = Label.new()
	_cutscene_live_status_lbl.text = "🟢 กำลังพิมพ์เรียบเรียงรายงานส่งอาจารย์ (19:30 น. -> 21:20 น.)"
	_cutscene_live_status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cutscene_live_status_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	_cutscene_live_status_lbl.add_theme_font_size_override("font_size", 6)
	_cutscene_live_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 1.0))
	_cutscene_live_status_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sb_hb.add_child(_cutscene_live_status_lbl)

	# Blinking glow tween for live typing indicator
	_cutscene_blink_tween = create_tween().set_loops()
	_cutscene_blink_tween.tween_property(_cutscene_live_status_lbl, "modulate:a", 0.45, 0.55).set_trans(Tween.TRANS_SINE)
	_cutscene_blink_tween.tween_property(_cutscene_live_status_lbl, "modulate:a", 1.0, 0.55).set_trans(Tween.TRANS_SINE)

	_cutscene_progress_bar = ProgressBar.new()
	_cutscene_progress_bar.custom_minimum_size = Vector2(90, 9)
	_cutscene_progress_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_cutscene_progress_bar.min_value = 0.0
	_cutscene_progress_bar.max_value = 100.0
	_cutscene_progress_bar.value = 0.0
	_cutscene_progress_bar.show_percentage = true
	_cutscene_progress_bar.add_theme_font_override("font", FONT_THAI_REG)
	_cutscene_progress_bar.add_theme_font_size_override("font_size", 5)

	var cpb_bg := StyleBoxFlat.new()
	cpb_bg.bg_color = Color(0.14, 0.18, 0.25, 1.0)
	cpb_bg.corner_radius_top_left = 1
	cpb_bg.corner_radius_top_right = 1
	cpb_bg.corner_radius_bottom_right = 1
	cpb_bg.corner_radius_bottom_left = 1
	var cpb_fg := StyleBoxFlat.new()
	cpb_fg.bg_color = Color(0.12, 0.62, 0.85, 1.0)
	cpb_fg.corner_radius_top_left = 1
	cpb_fg.corner_radius_top_right = 1
	cpb_fg.corner_radius_bottom_right = 1
	cpb_fg.corner_radius_bottom_left = 1
	_cutscene_progress_bar.add_theme_stylebox_override("background", cpb_bg)
	_cutscene_progress_bar.add_theme_stylebox_override("fill", cpb_fg)
	sb_hb.add_child(_cutscene_progress_bar)

	# --- Scroll Container for Document Paper ---
	_cutscene_scroll = ScrollContainer.new()
	_cutscene_scroll.name = "CutscenePaperScroll"
	_cutscene_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cutscene_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_cutscene_scroll.custom_minimum_size = Vector2(0, 150)
	_cutscene_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_cutscene_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_cutscene_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	_cutscene_root.add_child(_cutscene_scroll)

	# พื้นหลังโต๊ะทำงาน MS Word สีเทาอมฟ้าอ่อน (ขนาบข้างละ ~35px)
	var desk_panel := PanelContainer.new()
	desk_panel.name = "DeskBackground"
	desk_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desk_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var desk_style := StyleBoxFlat.new()
	desk_style.bg_color = Color(0.86, 0.89, 0.93, 1.0)
	desk_style.content_margin_left = 6.0
	desk_style.content_margin_right = 6.0
	desk_style.content_margin_top = 6.0
	desk_style.content_margin_bottom = 10.0
	desk_panel.add_theme_stylebox_override("panel", desk_style)
	_cutscene_scroll.add_child(desk_panel)

	# แผ่นกระดาษรายงานวิชาการ A4 สีขาว กว้าง 348px กึ่งกลางโต๊ะทำงาน พร้อมเงาตกกระทบ
	var paper_panel := PanelContainer.new()
	paper_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	paper_panel.custom_minimum_size = Vector2(348, 0)
	var paper_style := StyleBoxFlat.new()
	paper_style.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	paper_style.border_width_left = 1
	paper_style.border_width_top = 1
	paper_style.border_width_right = 1
	paper_style.border_width_bottom = 2
	paper_style.border_color = Color(0.72, 0.76, 0.82, 1.0)
	paper_style.corner_radius_top_left = 5
	paper_style.corner_radius_top_right = 5
	paper_style.corner_radius_bottom_left = 5
	paper_style.corner_radius_bottom_right = 5
	paper_style.shadow_size = 6
	paper_style.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
	paper_style.content_margin_left = 8.0
	paper_style.content_margin_right = 8.0
	paper_style.content_margin_top = 6.0
	paper_style.content_margin_bottom = 8.0
	paper_panel.add_theme_stylebox_override("panel", paper_style)
	desk_panel.add_child(paper_panel)

	var doc_vbox := VBoxContainer.new()
	doc_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	doc_vbox.add_theme_constant_override("separation", 6)
	paper_panel.add_child(doc_vbox)

	# Document Header
	var header_vbox := VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 2)
	doc_vbox.add_child(header_vbox)

	var run_hbox := HBoxContainer.new()
	header_vbox.add_child(run_hbox)

	var run_l := Label.new()
	run_l.text = "รายวิชา 2110xxx ความมั่นคงปลอดภัยไซเบอร์เบื้องต้น (ภาคการศึกษาต้น)"
	run_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run_l.add_theme_font_override("font", FONT_THAI_REG)
	run_l.add_theme_font_size_override("font_size", 5)
	run_l.add_theme_color_override("font_color", Color(0.42, 0.47, 0.55, 1.0))
	run_hbox.add_child(run_l)

	var run_r := Label.new()
	run_r.text = "กลุ่มที่ 8 • รายงานฉบับสมบูรณ์"
	run_r.add_theme_font_override("font", FONT_THAI_REG)
	run_r.add_theme_font_size_override("font_size", 5)
	run_r.add_theme_color_override("font_color", Color(0.42, 0.47, 0.55, 1.0))
	run_hbox.add_child(run_r)

	var top_rule := ColorRect.new()
	top_rule.custom_minimum_size = Vector2(0, 1)
	top_rule.color = Color(0.78, 0.82, 0.88, 1.0)
	header_vbox.add_child(top_rule)

	var title_box := PanelContainer.new()
	var t_sb := StyleBoxFlat.new()
	t_sb.bg_color = Color(0.98, 0.99, 1.0, 1.0)
	t_sb.border_width_bottom = 2
	t_sb.border_color = Color(0.12, 0.16, 0.23, 1.0)
	t_sb.content_margin_left = 6.0
	t_sb.content_margin_right = 6.0
	t_sb.content_margin_top = 3.0
	t_sb.content_margin_bottom = 5.0
	title_box.add_theme_stylebox_override("panel", t_sb)
	header_vbox.add_child(title_box)

	var t_vbox := VBoxContainer.new()
	t_vbox.add_theme_constant_override("separation", 2)
	title_box.add_child(t_vbox)

	var type_lbl := Label.new()
	type_lbl.text = "รายงานการศึกษาค้นคว้าส่วนบุคคลและกลุ่ม (ACADEMIC TERM REPORT)"
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	type_lbl.add_theme_font_size_override("font_size", 5)
	type_lbl.add_theme_color_override("font_color", Color(0.35, 0.42, 0.52, 1.0))
	t_vbox.add_child(type_lbl)

	# Main report title (8px - within the 8-9px specification)
	var main_t := Label.new()
	main_t.text = "การวิเคราะห์กลไกการแพร่กระจายของมัลแวร์ผ่านเอกสารอิเล็กทรอนิกส์\nและแนวปฏิบัติมาตรฐานในการตรวจพิสูจน์หลักฐานเพื่อกู้คืนระบบ"
	main_t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_t.add_theme_font_override("font", FONT_THAI_BOLD)
	main_t.add_theme_font_size_override("font_size", 8)
	main_t.add_theme_color_override("font_color", Color(0.06, 0.1, 0.18, 1.0))
	main_t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t_vbox.add_child(main_t)

	var auth_lbl := Label.new()
	auth_lbl.text = "คณะผู้จัดทำ: นางสาวเมย์ และสมาชิกกลุ่มที่ 8  |  เสนอ: อาจารย์ประจำวิชา"
	auth_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	auth_lbl.add_theme_font_override("font", FONT_THAI_REG)
	auth_lbl.add_theme_font_size_override("font_size", 5)
	auth_lbl.add_theme_color_override("font_color", Color(0.28, 0.34, 0.42, 1.0))
	t_vbox.add_child(auth_lbl)

	_cutscene_sections_container = VBoxContainer.new()
	_cutscene_sections_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cutscene_sections_container.add_theme_constant_override("separation", 7)
	doc_vbox.add_child(_cutscene_sections_container)
	_section_nodes.clear()

# ---------------------------------------------------------------------------
# Cutscene Step 3: Live Typing & Stepwise Figure Expansion Execution
# ---------------------------------------------------------------------------
func _run_live_cutscene_sequence() -> void:
	for s_idx: int in range(CUTSCENE_SECTIONS.size()):
		if _is_skipped or not is_instance_valid(self) or not is_inside_tree():
			break

		var s_data: Dictionary = CUTSCENE_SECTIONS[s_idx]
		if clock_label:
			clock_label.text = s_data["time"]

		_show_cutscene_toast(s_data["notification"])

		# 1. Create section container
		var sec_vbox := VBoxContainer.new()
		sec_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sec_vbox.add_theme_constant_override("separation", 3)
		_cutscene_sections_container.add_child(sec_vbox)

		# 2. Section subtitle (7px - within the 6-7px specification)
		var s_title := Label.new()
		s_title.text = s_data["title"]
		s_title.add_theme_font_override("font", FONT_THAI_BOLD)
		s_title.add_theme_font_size_override("font_size", 7)
		s_title.add_theme_color_override("font_color", Color(0.08, 0.18, 0.36, 1.0))
		s_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sec_vbox.add_child(s_title)

		# 3. Live typing paragraph (6px - within the 5-6px specification)
		var s_rtl := RichTextLabel.new()
		s_rtl.bbcode_enabled = true
		s_rtl.fit_content = true
		s_rtl.scroll_active = false
		s_rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s_rtl.mouse_filter = Control.MOUSE_FILTER_PASS
		s_rtl.add_theme_font_override("normal_font", FONT_THAI_REG)
		s_rtl.add_theme_font_override("bold_font", FONT_THAI_BOLD)
		s_rtl.add_theme_font_size_override("normal_font_size", 6)
		s_rtl.add_theme_font_size_override("bold_font_size", 6)
		s_rtl.add_theme_color_override("default_color", Color(0.05, 0.08, 0.14, 1.0))
		s_rtl.add_theme_constant_override("line_separation", 2)
		s_rtl.text = s_data["text"]
		s_rtl.visible_ratio = 0.0
		sec_vbox.add_child(s_rtl)

		# Typing cursor indicator row
		var cursor_row := HBoxContainer.new()
		cursor_row.add_theme_constant_override("separation", 3)
		var cursor_lbl := Label.new()
		cursor_lbl.text = "▌ กำลังพิมพ์เรียบเรียงเนื้อหา..."
		cursor_lbl.add_theme_font_override("font", FONT_THAI_REG)
		cursor_lbl.add_theme_font_size_override("font_size", 5)
		cursor_lbl.add_theme_color_override("font_color", Color(0.15, 0.48, 0.88, 1.0))
		cursor_row.add_child(cursor_lbl)
		sec_vbox.add_child(cursor_row)

		# Smooth visible_ratio tween with auto scroll
		var typing_duration: float = 1.35
		var type_tw := create_tween()
		type_tw.tween_property(s_rtl, "visible_ratio", 1.0, typing_duration).set_trans(Tween.TRANS_LINEAR)

		while type_tw.is_running() and not _is_skipped and is_instance_valid(self) and is_inside_tree():
			await get_tree().create_timer(0.06).timeout
			_scroll_to_bottom_cutscene()

		if _is_skipped or not is_instance_valid(self) or not is_inside_tree():
			s_rtl.visible_ratio = 1.0
			break

		if is_instance_valid(cursor_row):
			cursor_row.queue_free()

		# 4. Figure generation status notice
		var gen_notice := Label.new()
		gen_notice.text = "   ⚙️ " + str(s_data["fig_badge"])
		gen_notice.add_theme_font_override("font", FONT_THAI_REG)
		gen_notice.add_theme_font_size_override("font_size", 5)
		gen_notice.add_theme_color_override("font_color", Color(0.2, 0.5, 0.8, 1.0))
		sec_vbox.add_child(gen_notice)
		_scroll_to_bottom_cutscene()

		var wait_gen: float = 0.0
		while wait_gen < 0.35 and not _is_skipped and is_instance_valid(self) and is_inside_tree():
			await get_tree().create_timer(0.05).timeout
			wait_gen += 0.05

		if is_instance_valid(gen_notice):
			gen_notice.queue_free()

		# 5. Expand & softly fade in Figure
		var fig_frame: Control = _create_figure_for_section(str(s_data["fig_type"]))
		sec_vbox.add_child(fig_frame)
		fig_frame.modulate = Color(1, 1, 1, 0.0)
		fig_frame.scale = Vector2(0.96, 0.85)
		fig_frame.pivot_offset = Vector2(200, 0)

		var fig_tw := create_tween().set_parallel(true)
		fig_tw.tween_property(fig_frame, "modulate:a", 1.0, 0.42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		fig_tw.tween_property(fig_frame, "scale", Vector2(1.0, 1.0), 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		while fig_tw.is_running() and not _is_skipped and is_instance_valid(self) and is_inside_tree():
			await get_tree().create_timer(0.05).timeout
			_scroll_to_bottom_cutscene()

		fig_frame.modulate = Color(1, 1, 1, 1.0)
		fig_frame.scale = Vector2(1.0, 1.0)

		_section_nodes.append({
			"sec_vbox": sec_vbox,
			"rtl": s_rtl,
			"fig_frame": fig_frame
		})

		# Update progress bar
		if _cutscene_progress_bar:
			var target_prog: float = float(s_idx + 1) * 25.0
			var p_tw := create_tween()
			p_tw.tween_property(_cutscene_progress_bar, "value", target_prog, 0.25)

		_scroll_to_bottom_cutscene()
		_hide_toast()

		var post_wait: float = 0.0
		while post_wait < 0.3 and not _is_skipped and is_instance_valid(self) and is_inside_tree():
			await get_tree().create_timer(0.05).timeout
			post_wait += 0.05

	if not _is_skipped and is_instance_valid(self) and is_inside_tree():
		if _cutscene_blink_tween and _cutscene_blink_tween.is_valid():
			_cutscene_blink_tween.kill()
		if _cutscene_live_status_lbl:
			_cutscene_live_status_lbl.modulate.a = 1.0
			_cutscene_live_status_lbl.text = "✓ เรียบเรียงและตรวจสอบเอกสารรายงานวิชาการเสร็จสมบูรณ์ (พร้อมบันทึกส่ง)"
		if _cutscene_progress_bar:
			_cutscene_progress_bar.value = 100.0
		_restore_cutscene_dimming(0.35)
		_scroll_to_bottom_cutscene()
		await get_tree().create_timer(0.4).timeout

	_ready_for_save_event()

func _scroll_to_bottom_cutscene() -> void:
	if not _cutscene_scroll or not is_instance_valid(_cutscene_scroll):
		return
	var vbar := _cutscene_scroll.get_v_scroll_bar()
	if vbar:
		_cutscene_scroll.scroll_vertical = int(vbar.max_value)

# ---------------------------------------------------------------------------
# Figure Construction Helpers (Strict Font Size <= 12, Icon 10x10, Pastel Style)
# ---------------------------------------------------------------------------
func _create_pastel_card(title_txt: String, body_txt: String, bg_col: Color, border_col: Color, title_col: Color, icon_tex: Texture2D = null) -> PanelContainer:
	var box := PanelContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_width_left = 1
	sb.border_width_top = 2
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = border_col
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 2
	sb.content_margin_left = 4.0
	sb.content_margin_right = 4.0
	sb.content_margin_top = 3.0
	sb.content_margin_bottom = 3.0
	box.add_theme_stylebox_override("panel", sb)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	box.add_child(vb)

	var t_row := HBoxContainer.new()
	t_row.add_theme_constant_override("separation", 3)
	vb.add_child(t_row)

	if icon_tex:
		var ico := TextureRect.new()
		ico.custom_minimum_size = Vector2(10, 10)
		ico.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		ico.texture = icon_tex
		ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t_row.add_child(ico)

	var t_lbl := Label.new()
	t_lbl.text = title_txt
	t_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	t_lbl.add_theme_font_size_override("font_size", 5)
	t_lbl.add_theme_color_override("font_color", title_col)
	t_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t_row.add_child(t_lbl)

	var b_lbl := Label.new()
	b_lbl.text = body_txt
	b_lbl.add_theme_font_override("font", FONT_THAI_REG)
	b_lbl.add_theme_font_size_override("font_size", 5)
	b_lbl.add_theme_color_override("font_color", Color(0.05, 0.08, 0.14, 1.0))
	b_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(b_lbl)

	return box

func _create_flow_arrow() -> Label:
	var arr := Label.new()
	arr.text = "➔"
	arr.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arr.add_theme_font_override("font", FONT_THAI_BOLD)
	arr.add_theme_font_size_override("font_size", 6)
	arr.add_theme_color_override("font_color", Color(0.4, 0.48, 0.6, 1.0))
	return arr

func _create_figure_frame() -> PanelContainer:
	var fig_panel := PanelContainer.new()
	fig_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.975, 0.985, 0.995, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.68, 0.74, 0.82, 1.0)
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 2
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	fig_panel.add_theme_stylebox_override("panel", sb)
	return fig_panel

func _create_caption_label(caption_str: String) -> Label:
	var cap := Label.new()
	cap.text = caption_str
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.add_theme_font_override("font", FONT_THAI_BOLD)
	cap.add_theme_font_size_override("font_size", 5)
	cap.add_theme_color_override("font_color", Color(0.3, 0.36, 0.46, 1.0))
	return cap

func _create_figure_for_section(fig_type: String) -> Control:
	var frame := _create_figure_frame()
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	frame.add_child(vb)

	match fig_type:
		"fig1":
			var hb := HBoxContainer.new()
			hb.add_theme_constant_override("separation", 3)
			vb.add_child(hb)
			hb.add_child(_create_pastel_card("1. โดเมนปลอมแปลง", "ของจริง: @chula.ac.th\nของปลอม: @chula.ac.co\nหลอกเปิดไฟล์แนบ", Color(1.0, 0.98, 0.92, 1.0), Color(0.95, 0.76, 0.4, 1.0), Color(0.55, 0.28, 0.05, 1.0), ICON_WARNING))
			hb.add_child(_create_flow_arrow())
			hb.add_child(_create_pastel_card("2. โครงสร้าง .docx", "ปกติไม่มีสคริปต์\nตรวจพบ: vbaProject.bin\nรันเมื่อกด Enable", Color(1.0, 0.95, 0.95, 1.0), Color(0.94, 0.6, 0.6, 1.0), Color(0.6, 0.12, 0.12, 1.0), ICON_DOC))
			hb.add_child(_create_flow_arrow())
			hb.add_child(_create_pastel_card("3. พรางคำสั่งอันตราย", "Base64 / Hex Strings\nOffice_Update_Helper\nคำสั่งแฝง: FILE_WIPE", Color(0.96, 0.95, 1.0, 1.0), Color(0.75, 0.66, 0.96, 1.0), Color(0.28, 0.16, 0.55, 1.0), ICON_SCRIPT))
			vb.add_child(_create_caption_label("ภาพที่ 1: แผนภาพลำดับการทำงานของภัยคุกคามและการเข้ารหัสพรางคำสั่งโจมตีด้วย Base64 และ Hex"))

		"fig2":
			var hb := HBoxContainer.new()
			hb.add_theme_constant_override("separation", 3)
			vb.add_child(hb)
			hb.add_child(_create_pastel_card("เครื่องที่ติดเชื้อ", "ไฟล์ถูกล็อก (.locked)\nมัลแวร์ทำงานเบื้องหลัง", Color(1.0, 0.95, 0.95, 1.0), Color(0.94, 0.6, 0.6, 1.0), Color(0.6, 0.12, 0.12, 1.0), ICON_COMPUTER))
			hb.add_child(_create_flow_arrow())
			hb.add_child(_create_pastel_card("จุดสกัดกั้น (ตัดเน็ต)", "ถอดสาย LAN / ปิด Wi-Fi\nระงับ Cloud Auto-Sync", Color(1.0, 0.98, 0.92, 1.0), Color(0.95, 0.76, 0.4, 1.0), Color(0.55, 0.28, 0.05, 1.0), ICON_WIFI_OFF))
			hb.add_child(_create_flow_arrow())
			hb.add_child(_create_pastel_card("คลาวด์สำรองข้อมูล", "✓ ก่อนเกิดเหตุ (16:30) ปลอดภัย\n✗ หลังติดเชื้อ (18:55) ไฟล์เสียทับ!", Color(0.93, 0.99, 0.96, 1.0), Color(0.45, 0.84, 0.65, 1.0), Color(0.06, 0.38, 0.24, 1.0), ICON_WIFI_ON))
			vb.add_child(_create_caption_label("ภาพที่ 2: แผนภาพแสดงความสำคัญของการตัดเครือข่ายเพื่อป้องกันการซิงค์ไฟล์ทับสำเนาข้อมูลบนคลาวด์"))

		"table1":
			vb.add_child(_create_caption_label("ตารางที่ 1: สรุปเครื่องมือและคำสั่งมาตรฐานสำหรับการตรวจพิสูจน์หลักฐานดิจิทัลในห้องปฏิบัติการแยกส่วน"))
			var hb := HBoxContainer.new()
			hb.add_theme_constant_override("separation", 3)
			vb.add_child(hb)
			hb.add_child(_create_pastel_card("1. ตรวจความสมบูรณ์", "certutil -hashfile MD5\nเทียบค่าแฮชกับ Manifest", Color(0.94, 0.97, 1.0, 1.0), Color(0.6, 0.78, 0.98, 1.0), Color(0.08, 0.28, 0.55, 1.0), ICON_MAGNIFIER))
			hb.add_child(_create_pastel_card("2. ตรวจโครงสร้าง", "Archive & Cyber Decoder\nตรวจ vbaProject และถอดรหัส", Color(0.96, 0.95, 1.0, 1.0), Color(0.75, 0.66, 0.96, 1.0), Color(0.28, 0.16, 0.55, 1.0), ICON_SCRIPT))
			hb.add_child(_create_pastel_card("3. ระบุเวลาเกิดเหตุ", "Windows System Logs\nหา Timestamp จุดเริ่มโจมตี", Color(0.93, 0.99, 0.96, 1.0), Color(0.45, 0.84, 0.65, 1.0), Color(0.06, 0.38, 0.24, 1.0), ICON_CLOCK))

		"fig3":
			var hb := HBoxContainer.new()
			hb.add_theme_constant_override("separation", 2)
			vb.add_child(hb)
			hb.add_child(_create_pastel_card("1. ตรวจ Log", "หาเวลาเกิดเหตุ", Color(0.94, 0.97, 1.0, 1.0), Color(0.6, 0.78, 0.98, 1.0), Color(0.08, 0.28, 0.55, 1.0), ICON_MAGNIFIER))
			hb.add_child(_create_flow_arrow())
			hb.add_child(_create_pastel_card("2. Safe Mode", "หยุดมัลแวร์ระบบ", Color(0.96, 0.95, 1.0, 1.0), Color(0.75, 0.66, 0.96, 1.0), Color(0.28, 0.16, 0.55, 1.0), ICON_SHIELD))
			hb.add_child(_create_flow_arrow())
			hb.add_child(_create_pastel_card("3. ลบ schtasks", "ตัดวงจรรันซ้ำ", Color(1.0, 0.98, 0.92, 1.0), Color(0.95, 0.76, 0.4, 1.0), Color(0.55, 0.28, 0.05, 1.0), ICON_DELETE))
			hb.add_child(_create_flow_arrow())
			hb.add_child(_create_pastel_card("4. 3-2-1 Backup", "กู้ Clean Snapshot", Color(0.93, 0.99, 0.96, 1.0), Color(0.45, 0.84, 0.65, 1.0), Color(0.06, 0.38, 0.24, 1.0), ICON_DISK_SAVE))
			vb.add_child(_create_caption_label("ภาพที่ 3: แผนผังลำดับขั้นตอนการกำจัดกลไกการฝังตัวของมัลแวร์และการกู้คืนข้อมูล 3-2-1 Backup"))

	return frame

func _reveal_all_cutscene_content() -> void:
	var workspace_margin: Control = _get_workspace_margin()
	if workspace_margin:
		workspace_margin.show()

	if not _cutscene_root or not is_instance_valid(_cutscene_root):
		_build_live_cutscene_ui()

	if _cutscene_sections_container:
		var current_count: int = _section_nodes.size()
		for s_idx: int in range(current_count, CUTSCENE_SECTIONS.size()):
			var s_data: Dictionary = CUTSCENE_SECTIONS[s_idx]
			var sec_vbox := VBoxContainer.new()
			sec_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			sec_vbox.add_theme_constant_override("separation", 3)
			_cutscene_sections_container.add_child(sec_vbox)

			var s_title := Label.new()
			s_title.text = s_data["title"]
			s_title.add_theme_font_override("font", FONT_THAI_BOLD)
			s_title.add_theme_font_size_override("font_size", 7)
			s_title.add_theme_color_override("font_color", Color(0.08, 0.18, 0.36, 1.0))
			s_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			sec_vbox.add_child(s_title)

			var s_rtl := RichTextLabel.new()
			s_rtl.bbcode_enabled = true
			s_rtl.fit_content = true
			s_rtl.scroll_active = false
			s_rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			s_rtl.add_theme_font_override("normal_font", FONT_THAI_REG)
			s_rtl.add_theme_font_override("bold_font", FONT_THAI_BOLD)
			s_rtl.add_theme_font_size_override("normal_font_size", 6)
			s_rtl.add_theme_font_size_override("bold_font_size", 6)
			s_rtl.add_theme_color_override("default_color", Color(0.05, 0.08, 0.14, 1.0))
			s_rtl.add_theme_constant_override("line_separation", 2)
			s_rtl.text = s_data["text"]
			s_rtl.visible_ratio = 1.0
			sec_vbox.add_child(s_rtl)

			var fig_frame: Control = _create_figure_for_section(str(s_data["fig_type"]))
			sec_vbox.add_child(fig_frame)
			fig_frame.modulate = Color(1, 1, 1, 1.0)
			fig_frame.scale = Vector2(1.0, 1.0)

			_section_nodes.append({
				"sec_vbox": sec_vbox,
				"rtl": s_rtl,
				"fig_frame": fig_frame
			})

		for sec_item: Dictionary in _section_nodes:
			var sec_node: Control = sec_item.get("sec_vbox", null) as Control
			if sec_node and is_instance_valid(sec_node):
				sec_node.show()
			var rtl_node: RichTextLabel = sec_item.get("rtl", null) as RichTextLabel
			if rtl_node and is_instance_valid(rtl_node):
				rtl_node.visible_ratio = 1.0
			var fig_node: Control = sec_item.get("fig_frame", null) as Control
			if fig_node and is_instance_valid(fig_node):
				fig_node.show()
				fig_node.modulate = Color(1, 1, 1, 1.0)
				fig_node.scale = Vector2(1.0, 1.0)

	if _cutscene_blink_tween and _cutscene_blink_tween.is_valid():
		_cutscene_blink_tween.kill()
	if _cutscene_live_status_lbl:
		_cutscene_live_status_lbl.modulate.a = 1.0
		_cutscene_live_status_lbl.text = "✓ เรียบเรียงและตรวจสอบเอกสารรายงานวิชาการเสร็จสมบูรณ์"
	if _cutscene_progress_bar:
		_cutscene_progress_bar.value = 100.0

	_scroll_to_bottom_cutscene()

func _show_cutscene_toast(message: String, duration: float = 3.0) -> void:
	if not notification_toast or not toast_label:
		return
	_toast_id += 1
	var current_toast_id: int = _toast_id
	toast_label.text = message
	notification_toast.show()
	notification_toast.move_to_front()
	if duration > 0.0:
		_toast_timer = get_tree().create_timer(duration)
		_toast_timer.timeout.connect(func() -> void:
			if is_instance_valid(self) and _toast_id == current_toast_id and notification_toast:
				notification_toast.hide()
		)

func _hide_toast() -> void:
	_toast_id += 1
	if notification_toast:
		notification_toast.hide()

func _on_skip_pressed() -> void:
	if _is_skipped:
		return
	_is_skipped = true

	if _loading_overlay and is_instance_valid(_loading_overlay):
		_loading_overlay.queue_free()
		_loading_overlay = null

	_restore_cutscene_dimming(0.2)

	var ws_margin: Control = _get_workspace_margin()
	if ws_margin:
		ws_margin.show()

	_reveal_all_cutscene_content()
	_ready_for_save_event()

func _ready_for_save_event() -> void:
	if _is_waiting_for_save or _is_ransomware_triggered:
		return
	_is_waiting_for_save = true
	_is_cutscene_running = false

	if skip_button:
		skip_button.hide()

	_restore_cutscene_dimming(0.3)

	var ws_margin: Control = _get_workspace_margin()
	if ws_margin:
		ws_margin.show()

	_reveal_all_cutscene_content()

	# Re-show ToolBar and RibbonTabs now that report is complete
	if ms_word_window:
		var toolbar: Control = ms_word_window.find_child("ToolBar", true, false) as Control
		if toolbar:
			toolbar.show()
		var ribbon_tabs: Control = ms_word_window.find_child("RibbonTabs", true, false) as Control
		if ribbon_tabs:
			ribbon_tabs.show()

	if clock_label:
		clock_label.text = "21:23"

	await get_tree().process_frame
	if not is_instance_valid(self) or not is_inside_tree():
		return

	_scroll_to_bottom_cutscene()

	if ms_word_window and ms_word_window.has_method("scroll_to_bottom"):
		ms_word_window.scroll_to_bottom()

	if ms_word_window and ms_word_window.has_method("highlight_save_button"):
		ms_word_window.call("highlight_save_button")

	var save_btn: Button = ms_word_window.find_child("SaveButton", true, false) as Button if ms_word_window else null
	if save_btn:
		var save_tw := create_tween().set_loops(6)
		save_tw.tween_property(save_btn, "modulate", Color(1.3, 1.3, 0.4, 1.0), 0.35)
		save_tw.tween_property(save_btn, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.35)

	_show_cutscene_toast("💡 เมย์: พิมพ์รายงานเสร็จแล้ว! กดปุ่ม 'Save' ด้านบนเพื่อบันทึกงาน")

func _on_save_clicked() -> void:
	if _is_ransomware_triggered:
		return
	if not _is_waiting_for_save:
		if ms_word_window and ms_word_window.has_method("is_macro_enabled") and not ms_word_window.call("is_macro_enabled"):
			_show_toast("💡 เมย์: ต้องกดปุ่ม 'Enable' ที่แถบสีเหลืองด้านบนเพื่อเปิดเนื้อหาและพิมพ์รายงานก่อนบันทึก!")
		elif _is_cutscene_running:
			_show_toast("💡 เมย์: รอพิมพ์รายงานให้เสร็จก่อน หรือกด 'Skip Cutscene' มุมขวาบน")
		else:
			_show_toast("💡 เมย์: ต้องพิมพ์ข้อความในรายงานให้ครบก่อนถึงจะกด Save ได้!")
		return
	_is_waiting_for_save = false
	_is_ransomware_triggered = true
	is_ransomware_triggered = true

	_hide_toast()
	_show_cutscene_toast("☁️ CloudSync: กำลังบันทึกและซิงค์ Report_Final.docx ขึ้น Cloud อัตโนมัติ...")
	# รอพักหนึ่ง 2.5 วินาที ตามข้อกำหนดก่อนเริ่มการติดเชื้อ
	await get_tree().create_timer(2.5).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return
	_hide_toast()

	# ปิดหน้าต่าง MS Word (หลังจากนี้จะไม่สามารถเปิด Word ได้อีก)
	if ms_word_window:
		ms_word_window.z_as_relative = true
		ms_word_window.z_index = 0
		_close_app_window(ms_word_window)

	if glitch_overlay:
		glitch_overlay.show()
		await get_tree().create_timer(0.18).timeout
		if not is_instance_valid(self) or not is_inside_tree():
			return
		glitch_overlay.hide()
		await get_tree().create_timer(0.08).timeout
		if not is_instance_valid(self) or not is_inside_tree():
			return
		glitch_overlay.show()
		await get_tree().create_timer(0.18).timeout
		if not is_instance_valid(self) or not is_inside_tree():
			return
		glitch_overlay.hide()

	_show_locked_files()

	await get_tree().create_timer(0.4).timeout
	if not is_instance_valid(self) or not is_inside_tree():
		return
	if ransom_note:
		ransom_note.show()
		ransom_note.move_to_front()

func _show_locked_files() -> void:
	if not downloaded_folder_window:
		return

	downloaded_folder_window.show()
	downloaded_folder_window.move_to_front()
	_update_taskbar_tab(downloaded_folder_window, "งานกลุ่ม", true)
	_highlight_active_tab(downloaded_folder_window)

	# ซ่อน Report_Final.docx ตามคำสั่ง "hide report ไปเลย"
	var report_panel: Control = downloaded_folder_window.find_child("MSWordReport", true, false) as Control
	if not report_panel:
		report_panel = downloaded_folder_window.find_child("PanelContainer", true, false) as Control
	if report_panel:
		report_panel.visible = false

	# แสดง AlertFile (ReadMe_to_recovery.txt)
	var alert_panel: Control = downloaded_folder_window.find_child("AlertFile", true, false) as Control
	if alert_panel:
		alert_panel.visible = true

	var title_lbl: Label = downloaded_folder_window.find_child("Label", true, false) as Label
	if title_lbl:
		title_lbl.text = "งานกลุ่มล้านแปด (ALL .LOCKED)"
		title_lbl.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))

	var pp_panel: Control = downloaded_folder_window.find_child("PPPresentation", true, false) as Control
	if pp_panel:
		var pp_lbl: Label = pp_panel.find_child("FileName", true, false) as Label
		if pp_lbl:
			pp_lbl.text = "Presentation.pptx.locked"
			pp_lbl.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2, 1.0))

	var png_panel: Control = downloaded_folder_window.find_child("PNGNetworkDiagram", true, false) as Control
	if png_panel:
		var png_lbl: Label = png_panel.find_child("FileName", true, false) as Label
		if png_lbl:
			png_lbl.text = "Network_Diagram.png.locked"
			png_lbl.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2, 1.0))

# บล็อกไม่ให้เปิด MS Word อีกเด็ดขาดหลังจาก Ransomware ทำงาน
func _on_app_activated(app_id: String) -> void:
	if app_id == "ms_word" and _is_ransomware_triggered:
		_show_cutscene_toast("⚠️ ไม่สามารถเปิด Microsoft Word ได้: โปรแกรมถูกล็อกและไฟล์เสียหาย (.locked)")
		return
	if app_id == "discord" and _is_ransomware_triggered:
		_show_cutscene_toast("💬 Discord: เล่น Roblox ป่าวน้อง")
		return
	super._on_app_activated(app_id)

func _open_app_window(win: Control, tab_title: String) -> void:
	if win == ms_word_window and _is_ransomware_triggered:
		_show_cutscene_toast("⚠️ ไม่สามารถเปิด Microsoft Word ได้: โปรแกรมถูกล็อกและไฟล์เสียหาย (.locked)")
		return
	super._open_app_window(win, tab_title)

func _on_file_opened_from_folder(file_name: String) -> void:
	if _is_ransomware_triggered:
		if file_name.to_lower().contains("readme"):
			if ransom_note:
				ransom_note.show()
				ransom_note.move_to_front()
			return
		_show_cutscene_toast("⚠️ ไม่สามารถเปิดไฟล์นี้ได้: ไฟล์ถูกเข้ารหัสโดย Ransomware (.locked)")
		return
	super._on_file_opened_from_folder(file_name)

func _on_ransom_dismissed() -> void:
	if ransom_note:
		ransom_note.hide()

	_can_exit_pc = true

	if leave_pc_button:
		leave_pc_button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2, 1.0))
		leave_pc_button.text = "ออก (Exit)"

	# แจ้งเตือนข้อความบนหน้าจอคอมพิวเตอร์หลัง Ransomware มีแค่ "เล่น Roblox ป่าวน้อง" (ที่เหลือดูได้ในมือถือ)
	_show_cutscene_toast("💬 Discord: เล่น Roblox ป่าวน้อง")

func _on_leave_pc_pressed() -> void:
	if not _can_exit_pc:
		_show_cutscene_toast("เมย์: ยังทำงานไม่เสร็จเลย ต้องดาวน์โหลดไฟล์ พิมพ์รายงาน และกด Save ก่อน!")
		return

	TelemetryManager.track_event(
		"Scene_03",
		"incident_ransomware",
		"cutscene_completed",
		0.0,
		true,
		1,
		false,
		{"files_locked": 4, "incident_time": "21:23"}
	)

	var result: Error = get_tree().change_scene_to_file(SCENE_04_PATH)
	if result != OK:
		push_error("Unable to load Scene 4: %s (error %d)" % [SCENE_04_PATH, result])
