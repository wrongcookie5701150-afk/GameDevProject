class_name IncidentReportPuzzle
extends BasePuzzleUI

const FONT_THAI_REG: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

# ---------------------------------------------------------------------------
# 1. ข้อมูลคำถามแบบเติมคำด้วย Dropdown 6 ช่อง (6 คะแนน)
# ---------------------------------------------------------------------------
const DROPDOWN_QUESTIONS: Array[Dictionary] = [
	{
		"blank_id": 1,
		"label": "ช่องว่าง __(1)__ :",
		"correct_id": "typosquatting",
		"options": [
			["-- เลือกคำตอบช่อง (1) --", ""],
			["Typosquatting (การสะกดชื่อโดเมนเลียนแบบของจริง)", "typosquatting"],
			["Brute Force (การสุ่มเดารหัสผ่านเข้าระบบ)", "brute_force"],
			["SQL Injection (การแทรกคำสั่งฐานข้อมูล)", "sql_injection"],
			["DDoS Attack (การยิงทราฟฟิกให้เซิร์ฟเวอร์ล่ม)", "ddos"]
		]
	},
	{
		"blank_id": 2,
		"label": "ช่องว่าง __(2)__ :",
		"correct_id": "ransomware_wiper",
		"options": [
			["-- เลือกคำตอบช่อง (2) --", ""],
			["Ransomware / Wiper (มัลแวร์เรียกค่าไถ่/ทำลายไฟล์)", "ransomware_wiper"],
			["Adware (โปรแกรมแสดงโฆษณาแฝง)", "adware"],
			["Keylogger (โปรแกรมดักจับการกดแป้นพิมพ์)", "keylogger"],
			["Spyware (สปายแวร์สอดแนมข้อมูลทั่วไป)", "spyware"]
		]
	},
	{
		"blank_id": 3,
		"label": "ช่องว่าง __(3)__ :",
		"correct_id": "network_isolation",
		"options": [
			["-- เลือกคำตอบช่อง (3) --", ""],
			["Network Isolation (การตัดเครือข่ายและหยุดซิงค์ทันที)", "network_isolation"],
			["Disk Defragment (การจัดเรียงพื้นที่ฮาร์ดดิสก์)", "disk_defrag"],
			["System Reboot (การรีสตาร์ทเครื่องซ้ำหลายครั้ง)", "system_reboot"],
			["Cloud Upload (การอัปโหลดไฟล์ทั้งหมดขึ้นคลาวด์ทันที)", "cloud_upload"]
		]
	},
	{
		"blank_id": 4,
		"label": "ช่องว่าง __(4)__ :",
		"correct_id": "forensic_image",
		"options": [
			["-- เลือกคำตอบช่อง (4) --", ""],
			["Forensic Image (สำเนาหลักฐานดิจิทัลสำหรับตรวจแยกส่วน)", "forensic_image"],
			["Shortcut File (ไฟล์ทางลัดบนหน้าเดสก์ท็อป)", "shortcut_file"],
			["Temp Cache (ไฟล์แคชชั่วคราวของเบราว์เซอร์)", "temp_cache"],
			["Screen Capture (ภาพถ่ายหน้าจอปกติ)", "screen_capture"]
		]
	},
	{
		"blank_id": 5,
		"label": "ช่องว่าง __(5)__ :",
		"correct_id": "file_hash",
		"options": [
			["-- เลือกคำตอบช่อง (5) --", ""],
			["File Hash / MD5 (ค่าแฮชตรวจสอบความสมบูรณ์ของไฟล์)", "file_hash"],
			["File Size (ขนาดไฟล์เบื้องต้นเป็นกิโลไบต์)", "file_size"],
			["File Extension (นามสกุลของไฟล์เอกสาร)", "file_ext"],
			["File Icon (รูปสัญลักษณ์ไอคอนของไฟล์)", "file_icon"]
		]
	},
	{
		"blank_id": 6,
		"label": "ช่องว่าง __(6)__ :",
		"correct_id": "backup_321",
		"options": [
			["-- เลือกคำตอบช่อง (6) --", ""],
			["3-2-1 Backup Rule (กู้คืนจากจุดเวลาก่อนติดเชื้อลงไดรฟ์แยก)", "backup_321"],
			["Overwrite Sync (เปิดซิงค์คลาวด์ทับไฟล์เดิมทันที)", "overwrite_sync"],
			["Pay Ransom (จ่ายเงินค่าไถ่ให้ผู้โจมตีเพื่อขอรหัสปลดล็อก)", "pay_ransom"],
			["Rename Extension (ลบคำว่า .locked ออกจากชื่อไฟล์ตรงๆ)", "rename_ext"]
		]
	}
]

# ---------------------------------------------------------------------------
# 2. ข้อมูลภาพประกอบที่ 1 (Figure 1): แบบติ๊กเลือก CheckBox 2 ส่วน (2 คะแนน)
# ---------------------------------------------------------------------------
const FIG1_PART_A_OPTIONS: Array[Dictionary] = [
	{"id": "doc_xml", "text": "word/document.xml (โครงสร้างข้อความปกติของเอกสาร)", "is_correct": false},
	{"id": "vba_bin", "text": "word/vbaProject.bin (โมดูลชุดคำสั่ง Macro ที่รันอัตโนมัติ)", "is_correct": true},
	{"id": "media_img", "text": "word/media/image1.png (ไฟล์รูปภาพประกอบในหน้ากระดาษ)", "is_correct": false},
	{"id": "b64_hex", "text": "สตริงข้อความในโค้ดที่ถูกแปลงรหัสด้วย Base64 / Hexadecimal (FILE_WIPE)", "is_correct": true}
]

const FIG1_PART_B_OPTIONS: Array[Dictionary] = [
	{"id": "unplug_net", "text": "ปิด Wi-Fi และถอดสาย LAN ออกทั้งหมดก่อนเสียบไดรฟ์หลักฐาน", "is_correct": true},
	{"id": "login_cloud", "text": "ล็อกอินบัญชี Cloud Drive ทิ้งไว้เพื่ออัปโหลดผลตรวจอัตโนมัติ", "is_correct": false},
	{"id": "clean_account", "text": "ไม่ล็อกอินบัญชีส่วนตัวและไม่มีไฟล์สำคัญเก็บไว้ในเครื่องวิเคราะห์", "is_correct": true},
	{"id": "enable_macro", "text": "เปิดไฟล์หลักฐานใน MS Word แล้วกด Enable Content ทันที", "is_correct": false}
]

# ---------------------------------------------------------------------------
# 3. ข้อมูลภาพประกอบที่ 2 (Figure 2): แบบลากวาง (Drag & Drop Flowchart) 4 ขั้นตอน (2 คะแนน)
# ---------------------------------------------------------------------------
const FIG2_CORRECT_ORDER: Array[String] = [
	"inspect_logs",
	"boot_safemode",
	"disable_task",
	"restore_clean"
]

const FIG2_STEP_ITEMS: Array[Dictionary] = [
	{
		"id": "boot_safemode",
		"short": "บูตเข้า Safe Mode เพื่อระงับการทำงานเบื้องหลังของมัลแวร์"
	},
	{
		"id": "restore_clean",
		"short": "กู้คืนไฟล์สะอาดจาก Clean Backup (18:55) โดยปิด Cloud Sync"
	},
	{
		"id": "inspect_logs",
		"short": "ตรวจ Windows Event Logs เพื่อระบุเวลาและชื่อโปรเซสต้นตอ"
	},
	{
		"id": "disable_task",
		"short": "ปิด Scheduled Task และกักกันไฟล์ตัวช่วยรัน (Quarantine Helper)"
	}
]

# ---------------------------------------------------------------------------
# Inner Classes สำหรับรองรับ Drag & Drop บนแผนผัง Figure 2
# ---------------------------------------------------------------------------
class PosttestDragPoolBtn extends Button:
	var step_id: String = ""
	var step_text: String = ""
	var font_ref: FontFile
	var puzzle_ref: Node

	func _get_drag_data(_at_position: Vector2) -> Variant:
		if disabled or step_id.is_empty():
			return null
		var preview := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.35, 0.65, 0.95)
		sb.border_width_left = 1
		sb.border_width_top = 1
		sb.border_width_right = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.6, 0.85, 1.0, 1.0)
		sb.corner_radius_top_left = 3
		sb.corner_radius_top_right = 3
		sb.corner_radius_bottom_left = 3
		sb.corner_radius_bottom_right = 3
		sb.content_margin_left = 6.0
		sb.content_margin_right = 6.0
		sb.content_margin_top = 3.0
		sb.content_margin_bottom = 3.0
		preview.add_theme_stylebox_override("panel", sb)
		var lbl := Label.new()
		lbl.text = "📌 " + step_text
		if font_ref:
			lbl.add_theme_font_override("font", font_ref)
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		preview.add_child(lbl)
		set_drag_preview(preview)
		return {
			"type": "posttest_flowchart_step",
			"step_id": step_id,
			"from_slot": -1
		}

	func _pressed() -> void:
		if puzzle_ref and puzzle_ref.has_method("_on_flowchart_pool_btn_clicked"):
			puzzle_ref.call("_on_flowchart_pool_btn_clicked", step_id)


class PosttestDropSlotBtn extends Button:
	var slot_index: int = 0
	var current_step_id: String = ""
	var current_step_text: String = ""
	var font_ref: FontFile
	var puzzle_ref: Node

	func _get_drag_data(_at_position: Vector2) -> Variant:
		if current_step_id.is_empty():
			return null
		var preview := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.12, 0.35, 0.65, 0.95)
		sb.corner_radius_top_left = 3
		sb.corner_radius_top_right = 3
		sb.corner_radius_bottom_left = 3
		sb.corner_radius_bottom_right = 3
		sb.content_margin_left = 6.0
		sb.content_margin_right = 6.0
		sb.content_margin_top = 3.0
		sb.content_margin_bottom = 3.0
		preview.add_theme_stylebox_override("panel", sb)
		var lbl := Label.new()
		lbl.text = "📌 " + current_step_text
		if font_ref:
			lbl.add_theme_font_override("font", font_ref)
		lbl.add_theme_font_size_override("font_size", 5)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		preview.add_child(lbl)
		set_drag_preview(preview)
		return {
			"type": "posttest_flowchart_step",
			"step_id": current_step_id,
			"from_slot": slot_index
		}

	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		if not data is Dictionary:
			return false
		var dict: Dictionary = data
		return str(dict.get("type", "")) == "posttest_flowchart_step"

	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		if not data is Dictionary:
			return
		var dict: Dictionary = data
		var incoming_id: String = str(dict.get("step_id", ""))
		var from_slot: int = int(dict.get("from_slot", -1))
		if puzzle_ref and puzzle_ref.has_method("_handle_flowchart_drop"):
			puzzle_ref.call("_handle_flowchart_drop", incoming_id, from_slot, slot_index)


# ---------------------------------------------------------------------------
# State Variables
# ---------------------------------------------------------------------------
var _dropdown_controls: Dictionary = {}
var _fig1_part_a_checks: Array[CheckBox] = []
var _fig1_part_b_checks: Array[CheckBox] = []
var _fig2_slots: Array[PosttestDropSlotBtn] = []
var _fig2_pool_btns: Dictionary = {}
var _selected_pool_step_id: String = ""

var _para1_rtl: RichTextLabel = null
var _para2_rtl: RichTextLabel = null
var _para3_rtl: RichTextLabel = null
var _progress_label: Label = null
var _status_msg_label: Label = null
var _submit_btn: Button = null
var _word_scroll: ScrollContainer = null

var _last_dropdown_score: int = 0
var _last_checkbox_score: int = 0
var _last_dragdrop_score: int = 0
var _last_posttest_score: int = 0
var _started_at_msec: int = 0
var _first_interaction_msec: int = 0

func _ready() -> void:
	hint_tier_1 = "ทบทวนการสืบสวน: ตรวจ Log, เข้า Safe Mode, ปิด Task & Helper, และกู้คืนข้อมูลก่อนติดเชื้อ 19:02"
	hint_tier_2 = "ข้อสอบ Post-test วัด 3 ด้าน: 1. ต้นตอมัลแวร์ (Macro/Wiper) 2. การสืบสวนและแยกส่วน (เต่าดำ/MD5) 3. การกู้คืน (3-2-1 Backup)"
	hint_tier_3 = "ช่อง (1) Typosquatting, (2) Ransomware/Wiper, (3) Network Isolation, (4) Forensic Image, (5) File Hash, (6) 3-2-1 Backup"
	super._ready()
	_build_word_posttest_ui()

func start_puzzle() -> void:
	super.start_puzzle()
	_started_at_msec = Time.get_ticks_msec()
	_first_interaction_msec = 0
	if _word_scroll:
		_word_scroll.show()
		_word_scroll.scroll_vertical = 0
	_refresh_paragraph_texts()
	_refresh_fig2_ui()
	_update_progress_status()

func _mark_first_interaction() -> void:
	if _first_interaction_msec == 0:
		_first_interaction_msec = Time.get_ticks_msec()
	mark_decision_started()

# ---------------------------------------------------------------------------
# สร้างหน้าต่าง MS Word สำหรับทำ Post-test (Window Shell + Ribbon + Paper)
# ---------------------------------------------------------------------------
func _build_word_posttest_ui() -> void:
	if _word_scroll and is_instance_valid(_word_scroll):
		return

	# กรอบหน้าต่างหลักโปรแกรม MS Word
	var window_panel := PanelContainer.new()
	window_panel.name = "WordWindowPanel"
	window_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	window_panel.offset_left = 6.0
	window_panel.offset_top = 4.0
	window_panel.offset_right = -6.0
	window_panel.offset_bottom = -4.0
	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.95, 0.96, 0.98, 1.0)
	win_style.border_width_left = 1
	win_style.border_width_top = 1
	win_style.border_width_right = 1
	win_style.border_width_bottom = 1
	win_style.border_color = Color(0.2, 0.45, 0.8, 0.95)
	win_style.corner_radius_top_left = 4
	win_style.corner_radius_top_right = 4
	win_style.corner_radius_bottom_left = 4
	win_style.corner_radius_bottom_right = 4
	win_style.shadow_size = 4
	win_style.shadow_color = Color(0, 0, 0, 0.35)
	window_panel.add_theme_stylebox_override("panel", win_style)
	add_child(window_panel)

	var win_vbox := VBoxContainer.new()
	win_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	win_vbox.add_theme_constant_override("separation", 0)
	window_panel.add_child(win_vbox)

	# 1. แถบชื่อหัวหน้าต่าง (Title Bar สไตล์ MS Word สีน้ำเงินเข้ม)
	var title_bar := PanelContainer.new()
	title_bar.custom_minimum_size = Vector2(0, 18)
	var tb_style := StyleBoxFlat.new()
	tb_style.bg_color = Color(0.09, 0.32, 0.65, 1.0)
	tb_style.corner_radius_top_left = 3
	tb_style.corner_radius_top_right = 3
	tb_style.content_margin_left = 8.0
	tb_style.content_margin_right = 8.0
	title_bar.add_theme_stylebox_override("panel", tb_style)
	win_vbox.add_child(title_bar)

	var tb_hbox := HBoxContainer.new()
	tb_hbox.add_theme_constant_override("separation", 6)
	title_bar.add_child(tb_hbox)

	var tb_title := Label.new()
	tb_title.text = "📘 Report_Final.docx - Microsoft Word (Post-test: แบบทดสอบประเมินผลการเรียนรู้ 10 คะแนน)"
	tb_title.add_theme_font_override("font", FONT_THAI_BOLD)
	tb_title.add_theme_font_size_override("font_size", 6)
	tb_title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	tb_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tb_hbox.add_child(tb_title)

	var tb_controls := Label.new()
	tb_controls.text = "—  🗖  ✕"
	tb_controls.add_theme_font_override("font", FONT_MONO)
	tb_controls.add_theme_font_size_override("font_size", 6)
	tb_controls.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.8))
	tb_hbox.add_child(tb_controls)

	# 2. แถบริบบอน (Ribbon Menu Tabs)
	var ribbon_bar := PanelContainer.new()
	ribbon_bar.custom_minimum_size = Vector2(0, 14)
	var rb_style := StyleBoxFlat.new()
	rb_style.bg_color = Color(0.92, 0.94, 0.97, 1.0)
	rb_style.border_width_bottom = 1
	rb_style.border_color = Color(0.8, 0.84, 0.9, 1.0)
	rb_style.content_margin_left = 8.0
	rb_style.content_margin_right = 8.0
	ribbon_bar.add_theme_stylebox_override("panel", rb_style)
	win_vbox.add_child(ribbon_bar)

	var rb_hbox := HBoxContainer.new()
	rb_hbox.add_theme_constant_override("separation", 10)
	ribbon_bar.add_child(rb_hbox)

	var tabs: Array[String] = ["ไฟล์", "หน้าแรก", "แทรก", "เค้าโครง", "การอ้างอิง", "ส่งตรวจ (Review)"]
	for i: int in range(tabs.size()):
		var t_lbl := Label.new()
		t_lbl.text = tabs[i]
		t_lbl.add_theme_font_override("font", FONT_THAI_REG)
		t_lbl.add_theme_font_size_override("font_size", 5)
		t_lbl.add_theme_color_override("font_color", Color(0.12, 0.35, 0.72, 1.0) if i == 1 else Color(0.3, 0.35, 0.42, 1.0))
		rb_hbox.add_child(t_lbl)

	# 3. พื้นที่ ScrollContainer สำหรับแสดงกระดาษเอกสาร A4
	_word_scroll = ScrollContainer.new()
	_word_scroll.name = "PosttestWordScroll"
	_word_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_word_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_word_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_word_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_word_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	win_vbox.add_child(_word_scroll)

	var page_margin := MarginContainer.new()
	page_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_margin.add_theme_constant_override("margin_left", 8)
	page_margin.add_theme_constant_override("margin_right", 10)
	page_margin.add_theme_constant_override("margin_top", 6)
	page_margin.add_theme_constant_override("margin_bottom", 8)
	_word_scroll.add_child(page_margin)

	# แผ่นกระดาษรายงานสีขาวสไตล์ MS Word
	var paper_panel := PanelContainer.new()
	paper_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var paper_style := StyleBoxFlat.new()
	paper_style.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	paper_style.border_width_left = 1
	paper_style.border_width_top = 1
	paper_style.border_width_right = 1
	paper_style.border_width_bottom = 2
	paper_style.border_color = Color(0.75, 0.78, 0.84, 1.0)
	paper_style.corner_radius_top_left = 2
	paper_style.corner_radius_top_right = 2
	paper_style.corner_radius_bottom_left = 2
	paper_style.corner_radius_bottom_right = 2
	paper_style.content_margin_left = 12.0
	paper_style.content_margin_right = 12.0
	paper_style.content_margin_top = 10.0
	paper_style.content_margin_bottom = 12.0
	paper_panel.add_theme_stylebox_override("panel", paper_style)
	page_margin.add_child(paper_panel)

	var doc_vbox := VBoxContainer.new()
	doc_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	doc_vbox.add_theme_constant_override("separation", 8)
	paper_panel.add_child(doc_vbox)

	# 1. ส่วนหัวกระดาษรายงาน (Document Header)
	_build_doc_header(doc_vbox)

	# 2. ย่อหน้าที่ 1 + Dropdown ช่อง (1) และ (2)
	_build_paragraph_1(doc_vbox)

	# 3. ภาพประกอบที่ 1 (Figure 1: แบบติ๊กเลือก CheckBox 2 ส่วน)
	_build_figure_1_checkbox_visual(doc_vbox)

	# 4. ย่อหน้าที่ 2 + Dropdown ช่อง (3), (4), (5)
	_build_paragraph_2(doc_vbox)

	# 5. ภาพประกอบที่ 2 (Figure 2: แบบลากวางเรียงลำดับ Flowchart 4 ขั้นตอน)
	_build_figure_2_dragdrop_visual(doc_vbox)

	# 6. ย่อหน้าที่ 3 + Dropdown ช่อง (6)
	_build_paragraph_3(doc_vbox)

	# 7. แถบตรวจสอบสถานะและปุ่มยืนยันท้ายกระดาษ
	_build_submit_footer(doc_vbox)

	# 4. Word Status Bar ด้านล่างสุด
	var status_bar := PanelContainer.new()
	status_bar.custom_minimum_size = Vector2(0, 12)
	var sb_style := StyleBoxFlat.new()
	sb_style.bg_color = Color(0.09, 0.32, 0.65, 1.0)
	sb_style.corner_radius_bottom_left = 3
	sb_style.corner_radius_bottom_right = 3
	sb_style.content_margin_left = 8.0
	sb_style.content_margin_right = 8.0
	status_bar.add_theme_stylebox_override("panel", sb_style)
	win_vbox.add_child(status_bar)

	var sb_hbox := HBoxContainer.new()
	sb_hbox.add_theme_constant_override("separation", 8)
	status_bar.add_child(sb_hbox)

	var status_lbl := Label.new()
	status_lbl.text = "หน้า 1 จาก 1  |  10 ข้อประเมิน (Post-test)  |  ภาษาไทย (ไทย)  |  ความพร้อมส่ง: 100%"
	status_lbl.add_theme_font_override("font", FONT_THAI_REG)
	status_lbl.add_theme_font_size_override("font_size", 5)
	status_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))
	status_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sb_hbox.add_child(status_lbl)

	_refresh_paragraph_texts()
	_refresh_fig2_ui()
	_update_progress_status()

func _build_doc_header(parent: VBoxContainer) -> void:
	var header_box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.93, 0.96, 1.0, 1.0)
	sb.border_width_left = 3
	sb.border_width_bottom = 1
	sb.border_color = Color(0.12, 0.38, 0.72, 1.0)
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 5.0
	sb.content_margin_bottom = 5.0
	header_box.add_theme_stylebox_override("panel", sb)
	parent.add_child(header_box)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	header_box.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "📄 รายงานกลุ่มฉบับสมบูรณ์: การวิเคราะห์และรับมือภัยคุกคามแรนซัมแวร์ (Post-test 10 คะแนน)"
	title_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	title_lbl.add_theme_font_size_override("font_size", 6)
	title_lbl.add_theme_color_override("font_color", Color(0.08, 0.24, 0.48, 1.0))
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "ผู้จัดทำ: เมย์ (กลุ่มที่ 8) | กู้คืนข้อมูลสำเร็จแล้ว นำองค์ความรู้จากการสืบสวนและกู้ระบบมาสรุปรายงานฉบับสมบูรณ์ส่งอาจารย์"
	sub_lbl.add_theme_font_override("font", FONT_THAI_REG)
	sub_lbl.add_theme_font_size_override("font_size", 5)
	sub_lbl.add_theme_color_override("font_color", Color(0.25, 0.32, 0.42, 1.0))
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(sub_lbl)

func _build_paragraph_1(parent: VBoxContainer) -> void:
	var sec_vbox := VBoxContainer.new()
	sec_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(sec_vbox)

	var sec_title := Label.new()
	sec_title.text = "1. ช่องทางการโจมตีและผลกระทบของมัลแวร์ (Threat Delivery & Impact)"
	sec_title.add_theme_font_override("font", FONT_THAI_BOLD)
	sec_title.add_theme_font_size_override("font_size", 6)
	sec_title.add_theme_color_override("font_color", Color(0.1, 0.28, 0.55, 1.0))
	sec_vbox.add_child(sec_title)

	_para1_rtl = _create_paragraph_rtl()
	sec_vbox.add_child(_para1_rtl)

	var dd_box := _create_dropdown_group_panel()
	sec_vbox.add_child(dd_box)
	var dd_vbox := VBoxContainer.new()
	dd_vbox.add_theme_constant_override("separation", 3)
	dd_box.add_child(dd_vbox)

	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[0]))
	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[1]))

func _build_figure_1_checkbox_visual(parent: VBoxContainer) -> void:
	var fig_panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.95, 0.97, 0.99, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 2
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.18, 0.45, 0.78, 1.0)
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	fig_panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(fig_panel)

	var fig_vbox := VBoxContainer.new()
	fig_vbox.add_theme_constant_override("separation", 5)
	fig_panel.add_child(fig_vbox)

	var fig_header := Label.new()
	fig_header.text = "🖼️ ภาพประกอบที่ 1 (Figure 1): แผนผังโครงสร้างไฟล์เอกสารและการวิเคราะห์ความปลอดภัย (เลือกติ๊กภาคละ 2 ข้อ)"
	fig_header.add_theme_font_override("font", FONT_THAI_BOLD)
	fig_header.add_theme_font_size_override("font_size", 6)
	fig_header.add_theme_color_override("font_color", Color(0.12, 0.32, 0.62, 1.0))
	fig_vbox.add_child(fig_header)

	var visual_grid := HBoxContainer.new()
	visual_grid.add_theme_constant_override("separation", 8)
	fig_vbox.add_child(visual_grid)

	# การ์ดภาพซ้าย: ข้อ 1.1 ตรวจสอบโครงสร้างและโค้ดแฝง
	var card_a := _create_visual_subcard()
	card_a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_grid.add_child(card_a)
	var card_a_vbox := VBoxContainer.new()
	card_a_vbox.add_theme_constant_override("separation", 3)
	card_a.add_child(card_a_vbox)

	var banner_a := PanelContainer.new()
	banner_a.add_theme_stylebox_override("panel", _create_diagram_banner_style(Color(0.88, 0.93, 1.0, 1.0)))
	card_a_vbox.add_child(banner_a)
	var banner_a_lbl := Label.new()
	banner_a_lbl.text = "📊 แผนภาพ 1.1: ผลตรวจ Report_Final.docx ในเต่าดำ\n(vbaProject.bin + Helper.dat + FILE_WIPE)"
	banner_a_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	banner_a_lbl.add_theme_font_size_override("font_size", 5)
	banner_a_lbl.add_theme_color_override("font_color", Color(0.08, 0.28, 0.58, 1.0))
	banner_a.add_child(banner_a_lbl)

	var prompt_a := Label.new()
	prompt_a.text = "ติ๊กเลือก 2 ส่วนประกอบที่เป็นพฤติกรรมของมัลแวร์จริง:"
	prompt_a.add_theme_font_override("font", FONT_THAI_BOLD)
	prompt_a.add_theme_font_size_override("font_size", 5)
	prompt_a.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35, 1.0))
	card_a_vbox.add_child(prompt_a)

	_fig1_part_a_checks.clear()
	for opt: Dictionary in FIG1_PART_A_OPTIONS:
		var cb := _create_word_checkbox(str(opt["text"]), str(opt["id"]))
		cb.toggled.connect(func(_val: bool) -> void:
			_mark_first_interaction()
			_update_progress_status()
		)
		card_a_vbox.add_child(cb)
		_fig1_part_a_checks.append(cb)

	# การ์ดภาพขวา: ข้อ 1.2 มาตรการเตรียมเครื่องตรวจแยกส่วน
	var card_b := _create_visual_subcard()
	card_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	visual_grid.add_child(card_b)
	var card_b_vbox := VBoxContainer.new()
	card_b_vbox.add_theme_constant_override("separation", 3)
	card_b.add_child(card_b_vbox)

	var banner_b := PanelContainer.new()
	banner_b.add_theme_stylebox_override("panel", _create_diagram_banner_style(Color(0.88, 0.96, 0.92, 1.0)))
	card_b_vbox.add_child(banner_b)
	var banner_b_lbl := Label.new()
	banner_b_lbl.text = "🛡️ แผนภาพ 1.2: การเตรียมเครื่องวิเคราะห์แยกส่วน (เต่าดำ)\n(Air-gapped Lab & Forensic Environment)"
	banner_b_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	banner_b_lbl.add_theme_font_size_override("font_size", 5)
	banner_b_lbl.add_theme_color_override("font_color", Color(0.06, 0.42, 0.25, 1.0))
	banner_b.add_child(banner_b_lbl)

	var prompt_b := Label.new()
	prompt_b.text = "ติ๊กเลือก 2 มาตรการความปลอดภัยที่ถูกต้อง:"
	prompt_b.add_theme_font_override("font", FONT_THAI_BOLD)
	prompt_b.add_theme_font_size_override("font_size", 5)
	prompt_b.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35, 1.0))
	card_b_vbox.add_child(prompt_b)

	_fig1_part_b_checks.clear()
	for opt: Dictionary in FIG1_PART_B_OPTIONS:
		var cb := _create_word_checkbox(str(opt["text"]), str(opt["id"]))
		cb.toggled.connect(func(_val: bool) -> void:
			_mark_first_interaction()
			_update_progress_status()
		)
		card_b_vbox.add_child(cb)
		_fig1_part_b_checks.append(cb)

func _build_paragraph_2(parent: VBoxContainer) -> void:
	var sec_vbox := VBoxContainer.new()
	sec_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(sec_vbox)

	var sec_title := Label.new()
	sec_title.text = "2. การจำกัดความเสียหายและการตรวจพิสูจน์พยานหลักฐาน (Containment & Forensic Triage)"
	sec_title.add_theme_font_override("font", FONT_THAI_BOLD)
	sec_title.add_theme_font_size_override("font_size", 6)
	sec_title.add_theme_color_override("font_color", Color(0.1, 0.28, 0.55, 1.0))
	sec_vbox.add_child(sec_title)

	_para2_rtl = _create_paragraph_rtl()
	sec_vbox.add_child(_para2_rtl)

	var dd_box := _create_dropdown_group_panel()
	sec_vbox.add_child(dd_box)
	var dd_vbox := VBoxContainer.new()
	dd_vbox.add_theme_constant_override("separation", 3)
	dd_box.add_child(dd_vbox)

	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[2]))
	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[3]))
	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[4]))

func _build_figure_2_dragdrop_visual(parent: VBoxContainer) -> void:
	var fig_panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.97, 1.0, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 2
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.28, 0.35, 0.75, 1.0)
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	fig_panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(fig_panel)

	var fig_vbox := VBoxContainer.new()
	fig_vbox.add_theme_constant_override("separation", 5)
	fig_panel.add_child(fig_vbox)

	var fig_header := Label.new()
	fig_header.text = "🔀 ภาพประกอบที่ 2 (Figure 2): แผนผังลำดับขั้นตอนการตอบสนองและกู้คืน (ลากบล็อกวาง หรือคลิกเพื่อเติม)"
	fig_header.add_theme_font_override("font", FONT_THAI_BOLD)
	fig_header.add_theme_font_size_override("font_size", 6)
	fig_header.add_theme_color_override("font_color", Color(0.2, 0.22, 0.58, 1.0))
	fig_vbox.add_child(fig_header)

	var flow_vbox := VBoxContainer.new()
	flow_vbox.add_theme_constant_override("separation", 3)
	fig_vbox.add_child(flow_vbox)

	_fig2_slots.clear()
	for i: int in range(4):
		var slot_row := HBoxContainer.new()
		slot_row.add_theme_constant_override("separation", 4)
		flow_vbox.add_child(slot_row)

		var badge := Label.new()
		badge.custom_minimum_size = Vector2(42, 16)
		badge.text = "ขั้นที่ %d ➔" % (i + 1)
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_theme_font_override("font", FONT_THAI_BOLD)
		badge.add_theme_font_size_override("font_size", 5)
		badge.add_theme_color_override("font_color", Color(0.22, 0.15, 0.48, 1.0))
		slot_row.add_child(badge)

		var slot_btn := PosttestDropSlotBtn.new()
		slot_btn.slot_index = i
		slot_btn.font_ref = FONT_THAI_REG
		slot_btn.puzzle_ref = self
		slot_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_btn.custom_minimum_size = Vector2(0, 17)
		slot_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		slot_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		slot_btn.clip_text = true
		slot_btn.add_theme_font_override("font", FONT_THAI_REG)
		slot_btn.add_theme_font_size_override("font_size", 5)
		slot_btn.pressed.connect(func() -> void:
			_on_flowchart_slot_clicked(i)
		)
		slot_row.add_child(slot_btn)
		_fig2_slots.append(slot_btn)

	var pool_title := Label.new()
	pool_title.text = "📦 คลังบล็อกขั้นตอน (ลากไปวางในช่อง ขั้นที่ 1-4 ด้านบน หรือคลิกที่บล็อกเพื่อเติมลงช่องว่าง):"
	pool_title.add_theme_font_override("font", FONT_THAI_BOLD)
	pool_title.add_theme_font_size_override("font_size", 5)
	pool_title.add_theme_color_override("font_color", Color(0.25, 0.28, 0.38, 1.0))
	fig_vbox.add_child(pool_title)

	var pool_vbox := VBoxContainer.new()
	pool_vbox.add_theme_constant_override("separation", 3)
	fig_vbox.add_child(pool_vbox)

	_fig2_pool_btns.clear()
	for item: Dictionary in FIG2_STEP_ITEMS:
		var sid := str(item["id"])
		var stext := str(item["short"])
		var pbtn := PosttestDragPoolBtn.new()
		pbtn.step_id = sid
		pbtn.step_text = stext
		pbtn.font_ref = FONT_THAI_REG
		pbtn.puzzle_ref = self
		pbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pbtn.custom_minimum_size = Vector2(0, 16)
		pbtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		pbtn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		pbtn.text = "⠿  " + stext
		pbtn.add_theme_font_override("font", FONT_THAI_REG)
		pbtn.add_theme_font_size_override("font_size", 5)
		pool_vbox.add_child(pbtn)
		_fig2_pool_btns[sid] = pbtn

	var reset_flow_btn := Button.new()
	reset_flow_btn.text = "🔄 ล้างคำตอบแผนผัง Figure 2 จัดเรียงใหม่"
	reset_flow_btn.custom_minimum_size = Vector2(0, 15)
	reset_flow_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset_flow_btn.add_theme_font_override("font", FONT_THAI_REG)
	reset_flow_btn.add_theme_font_size_override("font_size", 5)
	reset_flow_btn.pressed.connect(_on_fig2_reset_pressed)
	fig_vbox.add_child(reset_flow_btn)

func _build_paragraph_3(parent: VBoxContainer) -> void:
	var sec_vbox := VBoxContainer.new()
	sec_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(sec_vbox)

	var sec_title := Label.new()
	sec_title.text = "3. มาตรการกู้คืนระบบและความต่อเนื่องทางธุรกิจ (Business Continuity & Recovery)"
	sec_title.add_theme_font_override("font", FONT_THAI_BOLD)
	sec_title.add_theme_font_size_override("font_size", 6)
	sec_title.add_theme_color_override("font_color", Color(0.1, 0.28, 0.55, 1.0))
	sec_vbox.add_child(sec_title)

	_para3_rtl = _create_paragraph_rtl()
	sec_vbox.add_child(_para3_rtl)

	var dd_box := _create_dropdown_group_panel()
	sec_vbox.add_child(dd_box)
	var dd_vbox := VBoxContainer.new()
	dd_vbox.add_theme_constant_override("separation", 3)
	dd_box.add_child(dd_vbox)

	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[5]))

func _build_submit_footer(parent: VBoxContainer) -> void:
	var f_panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.97, 0.98, 1.0, 1.0)
	sb.border_width_top = 2
	sb.border_color = Color(0.15, 0.45, 0.8, 1.0)
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	f_panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(f_panel)

	var f_vbox := VBoxContainer.new()
	f_vbox.add_theme_constant_override("separation", 4)
	f_panel.add_child(f_vbox)

	_progress_label = Label.new()
	_progress_label.text = "สถานะการทำรายงาน: เติมคำ (0/6) | Figure 1 (0/2 ส่วน) | Figure 2 (0/4 ขั้นตอน)"
	_progress_label.add_theme_font_override("font", FONT_THAI_BOLD)
	_progress_label.add_theme_font_size_override("font_size", 5)
	_progress_label.add_theme_color_override("font_color", Color(0.1, 0.35, 0.7, 1.0))
	f_vbox.add_child(_progress_label)

	_status_msg_label = Label.new()
	_status_msg_label.text = ""
	_status_msg_label.add_theme_font_override("font", FONT_THAI_REG)
	_status_msg_label.add_theme_font_size_override("font_size", 5)
	_status_msg_label.add_theme_color_override("font_color", Color(0.85, 0.2, 0.1, 1.0))
	_status_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	f_vbox.add_child(_status_msg_label)

	_submit_btn = Button.new()
	_submit_btn.text = "💾 บันทึกและส่งรายงานฉบับสมบูรณ์ (Submit Final Report - Post-test 10 คะแนน)"
	_submit_btn.custom_minimum_size = Vector2(0, 22)
	_submit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_submit_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	_submit_btn.add_theme_font_size_override("font_size", 6)
	var btn_sb := StyleBoxFlat.new()
	btn_sb.bg_color = Color(0.12, 0.45, 0.85, 1.0)
	btn_sb.corner_radius_top_left = 3
	btn_sb.corner_radius_top_right = 3
	btn_sb.corner_radius_bottom_left = 3
	btn_sb.corner_radius_bottom_right = 3
	_submit_btn.add_theme_stylebox_override("normal", btn_sb)
	var btn_hover := btn_sb.duplicate() as StyleBoxFlat
	btn_hover.bg_color = Color(0.16, 0.55, 0.95, 1.0)
	_submit_btn.add_theme_stylebox_override("hover", btn_hover)
	_submit_btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_submit_btn.pressed.connect(_on_submit_posttest_pressed)
	f_vbox.add_child(_submit_btn)

# ---------------------------------------------------------------------------
# UI Helpers
# ---------------------------------------------------------------------------
func _create_paragraph_rtl() -> RichTextLabel:
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	rtl.scroll_active = false
	rtl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rtl.mouse_filter = Control.MOUSE_FILTER_PASS
	rtl.add_theme_font_override("normal_font", FONT_THAI_REG)
	rtl.add_theme_font_override("bold_font", FONT_THAI_BOLD)
	rtl.add_theme_font_size_override("normal_font_size", 6)
	rtl.add_theme_font_size_override("bold_font_size", 6)
	rtl.add_theme_color_override("default_color", Color(0.12, 0.14, 0.18, 1.0))
	rtl.add_theme_constant_override("line_separation", 2)
	return rtl

func _create_dropdown_group_panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.97, 0.99, 1.0)
	sb.border_width_left = 2
	sb.border_color = Color(0.25, 0.52, 0.85, 1.0)
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	p.add_theme_stylebox_override("panel", sb)
	return p

func _create_dropdown_row(q: Dictionary) -> HBoxContainer:
	var blank_id: int = int(q["blank_id"])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var lbl := Label.new()
	lbl.custom_minimum_size = Vector2(68, 0)
	lbl.text = str(q["label"])
	lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	lbl.add_theme_font_size_override("font_size", 5)
	lbl.add_theme_color_override("font_color", Color(0.08, 0.3, 0.65, 1.0))
	row.add_child(lbl)

	var opt_btn := OptionButton.new()
	opt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt_btn.custom_minimum_size = Vector2(0, 16)
	opt_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	opt_btn.clip_text = true
	opt_btn.add_theme_font_override("font", FONT_THAI_REG)
	opt_btn.add_theme_font_size_override("font_size", 5)
	var popup := opt_btn.get_popup()
	if popup:
		popup.add_theme_font_override("font", FONT_THAI_REG)
		popup.add_theme_font_size_override("font_size", 6)

	var options: Array = q["options"]
	for i: int in range(options.size()):
		var pair: Array = options[i]
		opt_btn.add_item(str(pair[0]))
		opt_btn.set_item_metadata(i, str(pair[1]))
	opt_btn.select(0)
	opt_btn.item_selected.connect(func(_idx: int) -> void:
		_mark_first_interaction()
		_refresh_paragraph_texts()
		_update_progress_status()
	)

	row.add_child(opt_btn)
	_dropdown_controls[blank_id] = opt_btn
	return row

func _create_visual_subcard() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.8, 0.84, 0.9, 1.0)
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_left = 3
	sb.corner_radius_bottom_right = 3
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	sb.content_margin_top = 5.0
	sb.content_margin_bottom = 5.0
	p.add_theme_stylebox_override("panel", sb)
	return p

func _create_diagram_banner_style(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_left = 3
	sb.corner_radius_bottom_right = 3
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	return sb

func _create_word_checkbox(text_label: String, meta_id: String) -> CheckBox:
	var cb := CheckBox.new()
	cb.text = text_label
	cb.set_meta("option_id", meta_id)
	cb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cb.add_theme_font_override("font", FONT_THAI_REG)
	cb.add_theme_font_size_override("font_size", 5)
	cb.add_theme_color_override("font_color", Color(0.15, 0.18, 0.24, 1.0))
	cb.add_theme_color_override("font_pressed_color", Color(0.06, 0.38, 0.72, 1.0))
	cb.add_theme_color_override("font_hover_color", Color(0.08, 0.32, 0.62, 1.0))
	return cb

# ---------------------------------------------------------------------------
# อัปเดตข้อความ Live Preview ในย่อหน้าเมื่อผู้เล่นเลือก Dropdown
# ---------------------------------------------------------------------------
func _format_blank_inline(blank_id: int) -> String:
	var opt_btn: OptionButton = _dropdown_controls.get(blank_id, null) as OptionButton
	if not opt_btn or opt_btn.selected <= 0:
		return "[b][color=#c8321e]__(%d)__[/color][/b]" % blank_id
	var full_text: String = opt_btn.get_item_text(opt_btn.selected)
	var short_text: String = full_text.get_slice(" (", 0)
	return "[b][color=#0d5c9e][u] (%d) %s [/u][/color][/b]" % [blank_id, short_text]

func _refresh_paragraph_texts() -> void:
	if _para1_rtl:
		_para1_rtl.text = (
			"      ผู้โจมตีมักส่งไฟล์เอกสารผ่านอีเมลหรือไดรฟ์แชร์โดยใช้เทคนิค %s "
			+ "เพื่อหลอกให้เหยื่อหลงเชื่อ เมื่อเปิดไฟล์เอกสารและกดยินยอมให้รัน Macro โค้ดที่แฝงอยู่จะดาวน์โหลดหรือสั่งรัน %s "
			+ "เข้ามาเข้ารหัสหรือทำลายไฟล์ข้อมูลสำคัญของเครื่องเป้าหมาย"
		) % [_format_blank_inline(1), _format_blank_inline(2)]

	if _para2_rtl:
		_para2_rtl.text = (
			"      เมื่อตรวจพบความผิดปกติ มาตรการแรกที่ต้องทำทันทีคือ %s "
			+ "เพื่อป้องกันการแพร่กระจายไปยังอุปกรณ์อื่นและระงับการซิงค์ไฟล์เสียขึ้นคลาวด์ จากนั้นจึงสร้าง %s "
			+ "ของระบบและไฟล์ต้องสงสัย แล้วจึงคำนวณและเทียบค่า %s "
			+ "เพื่อยืนยันว่าหลักฐานดิจิทัลที่นำไปตรวจในเครื่องแยกส่วนไม่มีการถูกแก้ไขหรือเปลี่ยนแปลงระหว่างการสืบสวน"
		) % [_format_blank_inline(3), _format_blank_inline(4), _format_blank_inline(5)]

	if _para3_rtl:
		_para3_rtl.text = (
			"      ในการกู้คืนระบบกลับสู่ภาวะปกติ องค์กรควรมีมาตรการสำรองข้อมูลตามหลัก %s "
			+ "โดยเลือกกู้คืนจากจุดเวลาก่อนเกิดเหตุการณ์การติดเชื้อลงบนพื้นที่สะอาด "
			+ "เพื่อให้มั่นใจว่าจะไม่นำไฟล์ที่ถูกฝังมัลแวร์หรือมัลแวร์ที่ยังแฝงตัวอยู่กลับเข้าสู่ระบบการทำงานจริง"
		) % [_format_blank_inline(6)]

# ---------------------------------------------------------------------------
# กลไก Flowchart Drag & Drop และ Click-to-Place
# ---------------------------------------------------------------------------
func _handle_flowchart_drop(incoming_id: String, from_slot: int, to_slot: int) -> void:
	_mark_first_interaction()
	if incoming_id.is_empty() or to_slot < 0 or to_slot >= _fig2_slots.size():
		return

	var incoming_text: String = ""
	for item: Dictionary in FIG2_STEP_ITEMS:
		if str(item["id"]) == incoming_id:
			incoming_text = str(item["short"])
			break

	var existing_target_id: String = _fig2_slots[to_slot].current_step_id
	var existing_target_text: String = _fig2_slots[to_slot].current_step_text

	_fig2_slots[to_slot].current_step_id = incoming_id
	_fig2_slots[to_slot].current_step_text = incoming_text

	if from_slot >= 0 and from_slot < _fig2_slots.size() and from_slot != to_slot:
		_fig2_slots[from_slot].current_step_id = existing_target_id
		_fig2_slots[from_slot].current_step_text = existing_target_text
	else:
		for s_idx: int in range(_fig2_slots.size()):
			if s_idx != to_slot and _fig2_slots[s_idx].current_step_id == incoming_id:
				_fig2_slots[s_idx].current_step_id = ""
				_fig2_slots[s_idx].current_step_text = ""

	_refresh_fig2_ui()
	_update_progress_status()

func _on_flowchart_pool_btn_clicked(step_id: String) -> void:
	_mark_first_interaction()
	var step_text: String = ""
	for item: Dictionary in FIG2_STEP_ITEMS:
		if str(item["id"]) == step_id:
			step_text = str(item["short"])
			break

	var first_empty_slot: int = -1
	for i: int in range(_fig2_slots.size()):
		if _fig2_slots[i].current_step_id.is_empty():
			first_empty_slot = i
			break

	if first_empty_slot != -1:
		_handle_flowchart_drop(step_id, -1, first_empty_slot)
	else:
		_handle_flowchart_drop(step_id, -1, 3)

func _on_flowchart_slot_clicked(slot_index: int) -> void:
	_mark_first_interaction()
	if slot_index < 0 or slot_index >= _fig2_slots.size():
		return
	var slot: PosttestDropSlotBtn = _fig2_slots[slot_index]
	if not slot.current_step_id.is_empty():
		slot.current_step_id = ""
		slot.current_step_text = ""
		_refresh_fig2_ui()
		_update_progress_status()

func _on_fig2_reset_pressed() -> void:
	_mark_first_interaction()
	for slot: PosttestDropSlotBtn in _fig2_slots:
		slot.current_step_id = ""
		slot.current_step_text = ""
	_selected_pool_step_id = ""
	_refresh_fig2_ui()
	_update_progress_status()

func _refresh_fig2_ui() -> void:
	var used_ids: Dictionary = {}
	for slot: PosttestDropSlotBtn in _fig2_slots:
		var sid: String = slot.current_step_id
		if sid.is_empty():
			slot.text = "[ ลากบล็อกจากด้านล่างมาวาง หรือคลิกบล็อกเพื่อเติม ]"
			var empty_sb := StyleBoxFlat.new()
			empty_sb.bg_color = Color(0.98, 0.99, 1.0, 1.0)
			empty_sb.border_width_left = 1
			empty_sb.border_width_top = 1
			empty_sb.border_width_right = 1
			empty_sb.border_width_bottom = 1
			empty_sb.border_color = Color(0.65, 0.72, 0.85, 1.0)
			empty_sb.corner_radius_top_left = 3
			empty_sb.corner_radius_top_right = 3
			empty_sb.corner_radius_bottom_left = 3
			empty_sb.corner_radius_bottom_right = 3
			empty_sb.content_margin_left = 6.0
			empty_sb.content_margin_right = 6.0
			slot.add_theme_stylebox_override("normal", empty_sb)
			slot.add_theme_color_override("font_color", Color(0.45, 0.5, 0.6, 1.0))
		else:
			used_ids[sid] = true
			slot.text = "✅ " + slot.current_step_text + "  (คลิกเพื่อนำออก)"
			var filled_sb := StyleBoxFlat.new()
			filled_sb.bg_color = Color(0.88, 0.94, 1.0, 1.0)
			filled_sb.border_width_left = 2
			filled_sb.border_width_top = 1
			filled_sb.border_width_right = 1
			filled_sb.border_width_bottom = 1
			filled_sb.border_color = Color(0.18, 0.48, 0.85, 1.0)
			filled_sb.corner_radius_top_left = 3
			filled_sb.corner_radius_top_right = 3
			filled_sb.corner_radius_bottom_left = 3
			filled_sb.corner_radius_bottom_right = 3
			filled_sb.content_margin_left = 6.0
			filled_sb.content_margin_right = 6.0
			slot.add_theme_stylebox_override("normal", filled_sb)
			slot.add_theme_color_override("font_color", Color(0.08, 0.25, 0.52, 1.0))

	for sid: String in _fig2_pool_btns.keys():
		var pbtn: PosttestDragPoolBtn = _fig2_pool_btns[sid]
		var is_used: bool = used_ids.has(sid)
		pbtn.disabled = is_used
		if is_used:
			pbtn.text = "✓ (วางในแผนผังแล้ว) " + pbtn.step_text
			pbtn.modulate = Color(1, 1, 1, 0.45)
		else:
			pbtn.text = "⠿  " + pbtn.step_text
			pbtn.modulate = Color(1, 1, 1, 1.0)

# ---------------------------------------------------------------------------
# การตรวจสอบและคำนวณคะแนน Post-test (เต็ม 10 คะแนน)
# ---------------------------------------------------------------------------
func _count_checked(group: Array[CheckBox]) -> int:
	var c: int = 0
	for cb: CheckBox in group:
		if cb.button_pressed:
			c += 1
	return c

func _is_all_answered() -> bool:
	for blank_id: int in _dropdown_controls.keys():
		var opt_btn: OptionButton = _dropdown_controls[blank_id]
		if not opt_btn or opt_btn.selected <= 0:
			return false
	if _count_checked(_fig1_part_a_checks) != 2:
		return false
	if _count_checked(_fig1_part_b_checks) != 2:
		return false
	for slot: PosttestDropSlotBtn in _fig2_slots:
		if slot.current_step_id.is_empty():
			return false
	return true

func _update_progress_status() -> void:
	if not _progress_label:
		return
	var filled_dd: int = 0
	for blank_id: int in _dropdown_controls.keys():
		var opt_btn: OptionButton = _dropdown_controls[blank_id]
		if opt_btn and opt_btn.selected > 0:
			filled_dd += 1
	var fig1_a_ok: int = 1 if _count_checked(_fig1_part_a_checks) == 2 else 0
	var fig1_b_ok: int = 1 if _count_checked(_fig1_part_b_checks) == 2 else 0
	var filled_slots: int = 0
	for slot: PosttestDropSlotBtn in _fig2_slots:
		if not slot.current_step_id.is_empty():
			filled_slots += 1

	_progress_label.text = (
		"สถานะการทำรายงาน: เติมคำ (%d/6) | Figure 1 ติ๊กเลือก (%d/2 ส่วน) | Figure 2 เรียงลำดับ (%d/4 ขั้นตอน)"
		% [filled_dd, fig1_a_ok + fig1_b_ok, filled_slots]
	)
	if _status_msg_label and _is_all_answered():
		_status_msg_label.text = ""

func _calculate_posttest_scores() -> void:
	# 1. คะแนน Dropdown 6 ข้อ (6 คะแนน)
	_last_dropdown_score = 0
	for q: Dictionary in DROPDOWN_QUESTIONS:
		var blank_id: int = int(q["blank_id"])
		var expected_id: String = str(q["correct_id"])
		var opt_btn: OptionButton = _dropdown_controls.get(blank_id, null) as OptionButton
		if opt_btn and opt_btn.selected > 0:
			var chosen_id: String = str(opt_btn.get_item_metadata(opt_btn.selected))
			if chosen_id == expected_id:
				_last_dropdown_score += 1

	# 2. คะแนน Figure 1 CheckBox (2 คะแนน: ส่วนละ 1 คะแนนเมื่อติ๊กถูกครบ 2 ข้อ)
	_last_checkbox_score = 0
	var part_a_correct: int = 0
	for i: int in range(_fig1_part_a_checks.size()):
		if _fig1_part_a_checks[i].button_pressed and bool(FIG1_PART_A_OPTIONS[i]["is_correct"]):
			part_a_correct += 1
	if part_a_correct == 2 and _count_checked(_fig1_part_a_checks) == 2:
		_last_checkbox_score += 1

	var part_b_correct: int = 0
	for i: int in range(_fig1_part_b_checks.size()):
		if _fig1_part_b_checks[i].button_pressed and bool(FIG1_PART_B_OPTIONS[i]["is_correct"]):
			part_b_correct += 1
	if part_b_correct == 2 and _count_checked(_fig1_part_b_checks) == 2:
		_last_checkbox_score += 1

	# 3. คะแนน Figure 2 Drag & Drop Flowchart (2 คะแนน: ครึ่งแรก 1 คะแนน + ครึ่งหลัง 1 คะแนน)
	_last_dragdrop_score = 0
	if _fig2_slots.size() == 4:
		if _fig2_slots[0].current_step_id == FIG2_CORRECT_ORDER[0] and _fig2_slots[1].current_step_id == FIG2_CORRECT_ORDER[1]:
			_last_dragdrop_score += 1
		if _fig2_slots[2].current_step_id == FIG2_CORRECT_ORDER[2] and _fig2_slots[3].current_step_id == FIG2_CORRECT_ORDER[3]:
			_last_dragdrop_score += 1

	_last_posttest_score = _last_dropdown_score + _last_checkbox_score + _last_dragdrop_score

func _on_submit_posttest_pressed() -> void:
	if is_resolved:
		return
	if not _is_all_answered():
		if _status_msg_label:
			_status_msg_label.text = "⚠️ กรุณาเลือก Dropdown ให้ครบทั้ง 6 ช่อง, ติ๊ก Figure 1 ภาคละ 2 ข้อ, และวางบล็อก Figure 2 ให้ครบ 4 ขั้นตอนก่อนส่งรายงาน"
		return

	_calculate_posttest_scores()
	submit_puzzle("POSTTEST_COMPLETED")

func validate_answer(answer: Variant) -> bool:
	if answer is String and str(answer) == "POSTTEST_COMPLETED":
		return _is_all_answered()
	return _is_all_answered()

func get_submission_metrics() -> Dictionary:
	_calculate_posttest_scores()
	var now_msec: int = Time.get_ticks_msec()
	var total_sec: float = maxf(0.1, float(now_msec - _started_at_msec) / 1000.0)
	var analysis_sec: float = 0.0
	if _first_interaction_msec > _started_at_msec:
		analysis_sec = float(_first_interaction_msec - _started_at_msec) / 1000.0
	var decision_sec: float = maxf(0.0, total_sec - analysis_sec)
	var conclusions_pct: int = int(round(float(_last_posttest_score) / 10.0 * 100.0))

	return {
		"puzzle_id": "P09",
		"assessment_type": "posttest",
		"conclusions_score": conclusions_pct,
		"posttest_score": _last_posttest_score,
		"max_score": 10,
		"dropdown_score": _last_dropdown_score,
		"checkbox_score": _last_checkbox_score,
		"dragdrop_score": _last_dragdrop_score,
		"analysis_duration_seconds": analysis_sec,
		"decision_duration_seconds": decision_sec
	}

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: AssessmentTelemetryParam = AssessmentTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "puzzle_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.metrics = metrics.duplicate(true)
	param.assessment_type = "posttest"
	param.sync_metrics()
	return param

func on_solve_success() -> void:
	if _submit_btn:
		_submit_btn.disabled = true
		_submit_btn.text = "✓ บันทึกผล Post-test เรียบร้อย (%d / 10 คะแนน)" % _last_posttest_score
	if _status_msg_label:
		_status_msg_label.add_theme_color_override("font_color", Color(0.1, 0.45, 0.22, 1.0))
		_status_msg_label.text = "บันทึกรายงานส่งอาจารย์เรียบร้อย (%d/10 คะแนน) กำลังไปยังหน้าประเมินสมรรถนะ KSA..."

func on_solve_failed() -> void:
	if _status_msg_label:
		_status_msg_label.text = "⚠️ กรุณาตอบคำถามในรายงานให้ครบทุกส่วนก่อนยืนยัน"
