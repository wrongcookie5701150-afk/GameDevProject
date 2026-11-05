class_name TypingGamePuzzle
extends BasePuzzleUI

signal scene_completion_requested

const TARGET_TEXT: String = "Cybersecurity protects people systems and information from malicious software and unsafe attachments."

const FONT_THAI_REG: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

# ---------------------------------------------------------------------------
# 1. ข้อมูลคำถามแบบเติมคำด้วย Dropdown 6 ช่อง (ข้อ 1, 3, 4, 5, 6, 10 เดิม = 6 คะแนน)
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
	{"id": "b64_hex", "text": "สตริงข้อความในโค้ดที่ถูกแปลงรหัสด้วย Base64 / Hexadecimal", "is_correct": true}
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
		"short": "กู้คืนไฟล์สะอาดจาก Backup หลังจากยืนยันว่ามัลแวร์หยุดทำงานแล้ว"
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
class PretestDragPoolBtn extends Button:
	var step_id: String = ""
	var step_text: String = ""
	var font_ref: FontFile
	var puzzle_ref: Node

	func _get_drag_data(_at_position: Vector2) -> Variant:
		if disabled or step_id.is_empty():
			return null
		var preview := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.15, 0.36, 0.65, 0.95)
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
			"type": "pretest_flowchart_step",
			"step_id": step_id,
			"from_slot": -1
		}


class PretestDropSlotBtn extends Button:
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
		sb.bg_color = Color(0.15, 0.36, 0.65, 0.95)
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
			"type": "pretest_flowchart_step",
			"step_id": current_step_id,
			"from_slot": slot_index
		}

	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		return data is Dictionary and str(data.get("type", "")) == "pretest_flowchart_step"

	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		if puzzle_ref and puzzle_ref.has_method("_on_flowchart_item_dropped") and data is Dictionary:
			puzzle_ref.call("_on_flowchart_item_dropped", slot_index, data)


# ---------------------------------------------------------------------------
# Node & State References
# ---------------------------------------------------------------------------
@onready var passage_label: RichTextLabel = get_node_or_null("PassageLabel") as RichTextLabel
@onready var feedback_label: Label = get_node_or_null("FeedbackLabel") as Label

var answer_input: TextEdit
var _started_at_msec: int = 0
var _first_interaction_msec: int = 0
var _last_accuracy: float = 0.0
var _last_wpm: float = 40.0
var _last_pretest_score: int = 0
var _last_dropdown_score: int = 0
var _last_checkbox_score: int = 0
var _last_dragdrop_score: int = 0

var _pretest_scroll: ScrollContainer
var _para1_rtl: RichTextLabel
var _para2_rtl: RichTextLabel
var _para3_rtl: RichTextLabel
var _dropdown_controls: Dictionary = {} # blank_id (1..6) -> OptionButton
var _fig1_part_a_checks: Array[CheckBox] = []
var _fig1_part_b_checks: Array[CheckBox] = []
var _fig2_slots: Array[PretestDropSlotBtn] = []
var _fig2_pool_btns: Dictionary = {} # step_id -> PretestDragPoolBtn
var _selected_pool_step_id: String = ""
var _progress_label: Label
var _status_msg_label: Label
var _submit_btn: Button
var _is_cutscene_mode: bool = false

func _ready() -> void:
	if not passage_label:
		passage_label = find_child("PassageLabel", true, false) as RichTextLabel
	if not feedback_label:
		feedback_label = find_child("FeedbackLabel", true, false) as Label
	if feedback_label:
		feedback_label.hide()
	var te := find_child("TextEdit", true, false) as Control
	if te:
		te.hide()
	if passage_label:
		passage_label.bbcode_enabled = true
		passage_label.hide()

	_build_pretest_word_ui()

	if is_visible_in_tree():
		start_puzzle()

func configure_input(input: TextEdit) -> void:
	answer_input = input
	if answer_input:
		answer_input.hide()

func is_pretest_active() -> bool:
	return not _is_cutscene_mode and _pretest_scroll != null and _pretest_scroll.visible

func get_pretest_scroll_container() -> ScrollContainer:
	return _pretest_scroll

func prepare_for_cutscene() -> void:
	_is_cutscene_mode = true
	if _pretest_scroll:
		_pretest_scroll.hide()
	if answer_input:
		answer_input.hide()
	if passage_label:
		passage_label.show()
		passage_label.position.y = 0.0

func start_puzzle() -> void:
	super.start_puzzle()
	_started_at_msec = Time.get_ticks_msec()
	_first_interaction_msec = 0
	_is_cutscene_mode = false
	if passage_label:
		passage_label.hide()
	if answer_input:
		answer_input.hide()
	if _pretest_scroll:
		_pretest_scroll.show()
		_pretest_scroll.scroll_vertical = 0
	_refresh_paragraph_texts()
	_update_progress_status()

func _mark_first_interaction() -> void:
	if _first_interaction_msec == 0:
		_first_interaction_msec = Time.get_ticks_msec()

# ---------------------------------------------------------------------------
# สร้างหน้ากระดาษรายงาน MS Word สำหรับทำ Pre-test (Dropdown 6 + Visual 2 ภาพ)
# ---------------------------------------------------------------------------
func _build_pretest_word_ui() -> void:
	if _pretest_scroll and is_instance_valid(_pretest_scroll):
		return

	_pretest_scroll = ScrollContainer.new()
	_pretest_scroll.name = "PretestScroll"
	_pretest_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pretest_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_pretest_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_pretest_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_pretest_scroll)

	var page_margin := MarginContainer.new()
	page_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_margin.add_theme_constant_override("margin_left", 6)
	page_margin.add_theme_constant_override("margin_right", 8)
	page_margin.add_theme_constant_override("margin_top", 4)
	page_margin.add_theme_constant_override("margin_bottom", 8)
	_pretest_scroll.add_child(page_margin)

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
	title_lbl.text = "📄 รายงานกลุ่ม: การวิเคราะห์และรับมือภัยคุกคามแรนซัมแวร์ (Ransomware Response)"
	title_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	title_lbl.add_theme_font_size_override("font_size", 6)
	title_lbl.add_theme_color_override("font_color", Color(0.08, 0.24, 0.48, 1.0))
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "ผู้จัดทำ: เมย์ และกลุ่มที่ 8 | คำชี้แจง: เลือก Dropdown เติมคำในช่อง __(1)__ ถึง __(6)__ และทำกิจกรรมในภาพประกอบ Figure 1 - 2 ให้ครบถ้วน"
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
	fig_header.text = "📊 Figure 1: แผนภาพตรวจสอบสัญญาณอันตรายในไฟล์ และการตั้งค่าเครื่องวิเคราะห์ (ติ๊กถูกภาคละ 2 ข้อ)"
	fig_header.add_theme_font_override("font", FONT_THAI_BOLD)
	fig_header.add_theme_font_size_override("font_size", 5)
	fig_header.add_theme_color_override("font_color", Color(0.08, 0.3, 0.62, 1.0))
	fig_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fig_vbox.add_child(fig_header)

	# --- Card 1.1: โครงสร้างไฟล์ .docx & โค้ดต้องสงสัย ---
	var card_a := _create_visual_subcard()
	fig_vbox.add_child(card_a)
	var card_a_vbox := VBoxContainer.new()
	card_a_vbox.add_theme_constant_override("separation", 3)
	card_a.add_child(card_a_vbox)

	# แผนภาพจำลองโครงสร้างไฟล์ในรายงาน
	var diag_a := PanelContainer.new()
	diag_a.add_theme_stylebox_override("panel", _create_diagram_banner_style(Color(0.11, 0.16, 0.24, 1.0)))
	card_a_vbox.add_child(diag_a)
	var diag_a_lbl := Label.new()
	diag_a_lbl.text = "📦 โครงสร้างภายใน Report_Final.docx (Archive Tree)\n ├─ 📄 word/document.xml          ├─ ⚙️ word/vbaProject.bin\n └─ 🖼️ word/media/image1.png      └─ 🔐 Code String: \"T2ZmaWNlX1VwZGF0ZQ==\""
	diag_a_lbl.add_theme_font_override("font", FONT_MONO)
	diag_a_lbl.add_theme_font_size_override("font_size", 5)
	diag_a_lbl.add_theme_color_override("font_color", Color(0.55, 0.9, 1.0, 1.0))
	diag_a.add_child(diag_a_lbl)

	var prompt_a := Label.new()
	prompt_a.text = "[1.1] จากแผนภาพโครงสร้างไฟล์ด้านบน ข้อใดบ่งชี้ว่ามีการฝังโค้ดอัตโนมัติและอำพรางคำสั่งอันตราย? (ติ๊กเลือก 2 ข้อ)"
	prompt_a.add_theme_font_override("font", FONT_THAI_BOLD)
	prompt_a.add_theme_font_size_override("font_size", 5)
	prompt_a.add_theme_color_override("font_color", Color(0.15, 0.2, 0.3, 1.0))
	prompt_a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_a_vbox.add_child(prompt_a)

	_fig1_part_a_checks.clear()
	for opt: Dictionary in FIG1_PART_A_OPTIONS:
		var cb := _create_word_checkbox(str(opt["text"]), str(opt["id"]))
		cb.toggled.connect(func(pressed: bool) -> void:
			_on_fig1_checkbox_toggled(_fig1_part_a_checks, cb, pressed)
		)
		card_a_vbox.add_child(cb)
		_fig1_part_a_checks.append(cb)

	# --- Card 1.2: แผนภาพการเตรียมเครื่อง Isolated Notebook ---
	var card_b := _create_visual_subcard()
	fig_vbox.add_child(card_b)
	var card_b_vbox := VBoxContainer.new()
	card_b_vbox.add_theme_constant_override("separation", 3)
	card_b.add_child(card_b_vbox)

	var diag_b := PanelContainer.new()
	diag_b.add_theme_stylebox_override("panel", _create_diagram_banner_style(Color(0.12, 0.2, 0.18, 1.0)))
	card_b_vbox.add_child(diag_b)
	var diag_b_lbl := Label.new()
	diag_b_lbl.text = "💻 แผนผังจำลองเครื่องวิเคราะห์หลักฐานแยกส่วน (Isolated Forensic Notebook)\n [ 🌐 Wi-Fi / LAN Status: ? ]   [ ☁️ Cloud Account: ? ]   [ 📁 Local Files: ? ]"
	diag_b_lbl.add_theme_font_override("font", FONT_MONO)
	diag_b_lbl.add_theme_font_size_override("font_size", 5)
	diag_b_lbl.add_theme_color_override("font_color", Color(0.55, 1.0, 0.75, 1.0))
	diag_b.add_child(diag_b_lbl)

	var prompt_b := Label.new()
	prompt_b.text = "[1.2] ในการเตรียมเครื่องวิเคราะห์แยกส่วน (Isolated Lab) ก่อนเสียบไดรฟ์หลักฐาน ต้องตั้งค่าอย่างไร? (ติ๊กเลือก 2 ข้อ)"
	prompt_b.add_theme_font_override("font", FONT_THAI_BOLD)
	prompt_b.add_theme_font_size_override("font_size", 5)
	prompt_b.add_theme_color_override("font_color", Color(0.15, 0.2, 0.3, 1.0))
	prompt_b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_b_vbox.add_child(prompt_b)

	_fig1_part_b_checks.clear()
	for opt: Dictionary in FIG1_PART_B_OPTIONS:
		var cb := _create_word_checkbox(str(opt["text"]), str(opt["id"]))
		cb.toggled.connect(func(pressed: bool) -> void:
			_on_fig1_checkbox_toggled(_fig1_part_b_checks, cb, pressed)
		)
		card_b_vbox.add_child(cb)
		_fig1_part_b_checks.append(cb)

func _build_paragraph_2(parent: VBoxContainer) -> void:
	var sec_vbox := VBoxContainer.new()
	sec_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(sec_vbox)

	var sec_title := Label.new()
	sec_title.text = "2. การควบคุมความเสียหายและการเก็บสำเนาหลักฐาน (Containment & Evidence Preservation)"
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
	sb.bg_color = Color(0.96, 0.95, 0.99, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 2
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.42, 0.28, 0.72, 1.0)
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

	var header_hbox := HBoxContainer.new()
	fig_vbox.add_child(header_hbox)

	var fig_header := Label.new()
	fig_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig_header.text = "🔄 Figure 2: แผนผังลำดับการสืบสวนและกำจัด Persistence (ลากบล็อกด้านล่างมาวางเรียง 1 ➔ 4 หรือคลิกเลือก)"
	fig_header.add_theme_font_override("font", FONT_THAI_BOLD)
	fig_header.add_theme_font_size_override("font_size", 5)
	fig_header.add_theme_color_override("font_color", Color(0.28, 0.16, 0.55, 1.0))
	fig_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header_hbox.add_child(fig_header)

	var reset_btn := Button.new()
	reset_btn.text = "ล้างลำดับ"
	reset_btn.custom_minimum_size = Vector2(44, 14)
	reset_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset_btn.add_theme_font_override("font", FONT_THAI_REG)
	reset_btn.add_theme_font_size_override("font_size", 5)
	reset_btn.pressed.connect(_on_fig2_reset_pressed)
	header_hbox.add_child(reset_btn)

	# แผนผัง Flowchart 4 ช่อง (เรียงลงมาพร้อมลูกศรเชื่อมเพื่อให้ข้อความยาวอ่านง่าย)
	var flow_panel := PanelContainer.new()
	var flow_sb := StyleBoxFlat.new()
	flow_sb.bg_color = Color(0.91, 0.93, 0.97, 1.0)
	flow_sb.border_width_left = 1
	flow_sb.border_width_top = 1
	flow_sb.border_width_right = 1
	flow_sb.border_width_bottom = 1
	flow_sb.border_color = Color(0.7, 0.74, 0.85, 1.0)
	flow_sb.corner_radius_top_left = 3
	flow_sb.corner_radius_top_right = 3
	flow_sb.corner_radius_bottom_left = 3
	flow_sb.corner_radius_bottom_right = 3
	flow_sb.content_margin_left = 6.0
	flow_sb.content_margin_right = 6.0
	flow_sb.content_margin_top = 5.0
	flow_sb.content_margin_bottom = 5.0
	flow_panel.add_theme_stylebox_override("panel", flow_sb)
	fig_vbox.add_child(flow_panel)

	var flow_vbox := VBoxContainer.new()
	flow_vbox.add_theme_constant_override("separation", 3)
	flow_panel.add_child(flow_vbox)

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

		var slot_btn := PretestDropSlotBtn.new()
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

	# คลังบล็อกสำหรับลากวาง (Drag & Drop Pool)
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
		var pbtn := PretestDragPoolBtn.new()
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
		pbtn.pressed.connect(func() -> void:
			_on_flowchart_pool_btn_clicked(sid)
		)
		pool_vbox.add_child(pbtn)
		_fig2_pool_btns[sid] = pbtn

func _build_paragraph_3(parent: VBoxContainer) -> void:
	var sec_vbox := VBoxContainer.new()
	sec_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(sec_vbox)

	var sec_title := Label.new()
	sec_title.text = "3. การกู้คืนข้อมูลสำรองอย่างปลอดภัย (Safe Backup Recovery)"
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
	var footer_panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.92, 0.96, 0.93, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.25, 0.62, 0.38, 1.0)
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	footer_panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(footer_panel)

	var f_vbox := VBoxContainer.new()
	f_vbox.add_theme_constant_override("separation", 4)
	footer_panel.add_child(f_vbox)

	_progress_label = Label.new()
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress_label.add_theme_font_override("font", FONT_THAI_BOLD)
	_progress_label.add_theme_font_size_override("font_size", 5)
	_progress_label.add_theme_color_override("font_color", Color(0.12, 0.35, 0.22, 1.0))
	f_vbox.add_child(_progress_label)

	_status_msg_label = Label.new()
	_status_msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_msg_label.add_theme_font_override("font", FONT_THAI_REG)
	_status_msg_label.add_theme_font_size_override("font_size", 5)
	_status_msg_label.add_theme_color_override("font_color", Color(0.75, 0.22, 0.15, 1.0))
	f_vbox.add_child(_status_msg_label)

	_submit_btn = Button.new()
	_submit_btn.custom_minimum_size = Vector2(0, 20)
	_submit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_submit_btn.text = "✅ ยืนยันเนื้อหารายงานและส่งคำตอบ (Submit Pre-test)"
	_submit_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	_submit_btn.add_theme_font_size_override("font_size", 6)
	var btn_sb := StyleBoxFlat.new()
	btn_sb.bg_color = Color(0.12, 0.52, 0.28, 1.0)
	btn_sb.corner_radius_top_left = 3
	btn_sb.corner_radius_top_right = 3
	btn_sb.corner_radius_bottom_left = 3
	btn_sb.corner_radius_bottom_right = 3
	_submit_btn.add_theme_stylebox_override("normal", btn_sb)
	var btn_hover := btn_sb.duplicate() as StyleBoxFlat
	btn_hover.bg_color = Color(0.16, 0.62, 0.34, 1.0)
	_submit_btn.add_theme_stylebox_override("hover", btn_hover)
	_submit_btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_submit_btn.pressed.connect(_on_submit_pretest_pressed)
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
# การอัปเดตข้อความย่อหน้าแบบ Live เมื่อผู้เล่นเลือก Dropdown
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
			+ "ซึ่งเป็นการตั้งชื่อโดเมนผู้ส่งให้สะกดคล้ายกับองค์กรจริงเพื่อหลอกเหยื่อ "
			+ "เมื่อเหยื่อหลงเชื่อและเปิดไฟล์ โค้ดอันตรายจะทำงานและทำให้ระบบติดมัลแวร์ประเภท %s "
			+ "ที่ทำการเข้ารหัสล็อกไฟล์ (.locked) หรือทำลายข้อมูลสำคัญในเครื่องทันที"
		) % [_format_blank_inline(1), _format_blank_inline(2)]

	if _para2_rtl:
		_para2_rtl.text = (
			"      เมื่อพบว่าเครื่องคอมพิวเตอร์หลักถูกโจมตี สิ่งแรกที่ต้องทำทันทีคือการทำ %s "
			+ "โดยตัดการเชื่อมต่อเครือข่ายและหยุดระบบซิงค์อัตโนมัติเพื่อไม่ให้ไฟล์ที่เสียหายซิงค์ไปทับไฟล์บนคลาวด์ "
			+ "จากนั้นควรคัดลอกหลักฐานออกมาเป็น %s ลงในอุปกรณ์จัดเก็บภายนอกเพื่อนำไปตรวจบนเครื่องที่แยกส่วน "
			+ "โดยก่อนเริ่มวิเคราะห์ต้องตรวจเทียบค่า %s (เช่น MD5) เสมอ เพื่อยืนยันว่าไฟล์หลักฐานไม่ถูกดัดแปลงแก้ไข"
		) % [_format_blank_inline(3), _format_blank_inline(4), _format_blank_inline(5)]

	if _para3_rtl:
		_para3_rtl.text = (
			"      ในขั้นตอนสุดท้ายของการกู้คืนระบบ ผู้ดูแลควรปฏิบัติตามหลักการ %s "
			+ "โดยเลือกกู้คืนจากไฟล์สำรองในจุดเวลาที่ปลอดภัยก่อนเกิดเหตุ (Clean Recovery Point) "
			+ "ลงในอุปกรณ์จัดเก็บแยกต่างหาก ในขณะที่ยังคงปิดการทำงานของ Cloud Sync ไว้จนกว่าจะตรวจสอบเสร็จสมบูรณ์"
		) % [_format_blank_inline(6)]

# ---------------------------------------------------------------------------
# Logic สำหรับ Figure 1 (CheckBox ภาคละ 2 ข้อ)
# ---------------------------------------------------------------------------
func _on_fig1_checkbox_toggled(group: Array[CheckBox], changed_cb: CheckBox, pressed: bool) -> void:
	_mark_first_interaction()
	if pressed:
		var checked_list: Array[CheckBox] = []
		for cb: CheckBox in group:
			if cb.button_pressed and cb != changed_cb:
				checked_list.append(cb)
		# หากติ๊กเกิน 2 ข้อ ให้เอาข้อแรกที่เคยติ๊กออกอัตโนมัติเพื่อให้เลือกได้พอดี 2 ข้อ
		if checked_list.size() >= 2:
			checked_list[0].set_pressed_no_signal(false)
	_update_progress_status()

# ---------------------------------------------------------------------------
# Logic สำหรับ Figure 2 (Drag & Drop + Click เรียงลำดับ Flowchart 4 ขั้นตอน)
# ---------------------------------------------------------------------------
func _get_step_text_by_id(step_id: String) -> String:
	for item: Dictionary in FIG2_STEP_ITEMS:
		if str(item["id"]) == step_id:
			return str(item["short"])
	return ""

func _on_flowchart_item_dropped(target_slot_idx: int, data: Dictionary) -> void:
	_mark_first_interaction()
	var step_id: String = str(data.get("step_id", ""))
	var from_slot: int = int(data.get("from_slot", -1))
	if step_id.is_empty() or target_slot_idx < 0 or target_slot_idx >= _fig2_slots.size():
		return

	var target_slot: PretestDropSlotBtn = _fig2_slots[target_slot_idx]
	var prev_target_id: String = target_slot.current_step_id

	# หากลากมาจากช่องอื่น ให้สลับค่ากัน
	if from_slot >= 0 and from_slot < _fig2_slots.size() and from_slot != target_slot_idx:
		var source_slot: PretestDropSlotBtn = _fig2_slots[from_slot]
		source_slot.current_step_id = prev_target_id
		source_slot.current_step_text = _get_step_text_by_id(prev_target_id)
	else:
		# หากstep_id เคยอยู่ในช่องอื่นมาก่อน ให้ล้างช่องเดิม
		for i: int in range(_fig2_slots.size()):
			if i != target_slot_idx and _fig2_slots[i].current_step_id == step_id:
				_fig2_slots[i].current_step_id = ""
				_fig2_slots[i].current_step_text = ""

	target_slot.current_step_id = step_id
	target_slot.current_step_text = _get_step_text_by_id(step_id)
	_selected_pool_step_id = ""
	_refresh_fig2_ui()
	_update_progress_status()

func _on_flowchart_pool_btn_clicked(step_id: String) -> void:
	_mark_first_interaction()
	# หาช่องว่างแรกใน Flowchart แล้วใส่ลงไปทันทีเพื่อความสะดวกทั้งเมาส์และทัชแพด
	for slot: PretestDropSlotBtn in _fig2_slots:
		if slot.current_step_id.is_empty():
			slot.current_step_id = step_id
			slot.current_step_text = _get_step_text_by_id(step_id)
			_selected_pool_step_id = ""
			_refresh_fig2_ui()
			_update_progress_status()
			return
	# หากเต็มทุกช่องแล้ว ให้จำไว้เพื่อรอสลับเมื่อคลิกช่องด้านบน
	_selected_pool_step_id = step_id
	_refresh_fig2_ui()

func _on_flowchart_slot_clicked(slot_idx: int) -> void:
	_mark_first_interaction()
	if slot_idx < 0 or slot_idx >= _fig2_slots.size():
		return
	var slot: PretestDropSlotBtn = _fig2_slots[slot_idx]
	if not _selected_pool_step_id.is_empty():
		_on_flowchart_item_dropped(slot_idx, {
			"type": "pretest_flowchart_step",
			"step_id": _selected_pool_step_id,
			"from_slot": -1
		})
		return
	if not slot.current_step_id.is_empty():
		slot.current_step_id = ""
		slot.current_step_text = ""
		_refresh_fig2_ui()
		_update_progress_status()

func _on_fig2_reset_pressed() -> void:
	_mark_first_interaction()
	for slot: PretestDropSlotBtn in _fig2_slots:
		slot.current_step_id = ""
		slot.current_step_text = ""
	_selected_pool_step_id = ""
	_refresh_fig2_ui()
	_update_progress_status()

func _refresh_fig2_ui() -> void:
	var used_ids: Dictionary = {}
	for slot: PretestDropSlotBtn in _fig2_slots:
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
		var pbtn: PretestDragPoolBtn = _fig2_pool_btns[sid]
		var is_used: bool = used_ids.has(sid)
		pbtn.disabled = is_used
		if is_used:
			pbtn.text = "✓ (วางในแผนผังแล้ว) " + pbtn.step_text
			pbtn.modulate = Color(1, 1, 1, 0.45)
		else:
			pbtn.text = "⠿  " + pbtn.step_text
			pbtn.modulate = Color(1, 1, 1, 1.0)

# ---------------------------------------------------------------------------
# การตรวจสอบความครบถ้วนและการคำนวณคะแนน Pre-test (เต็ม 10 คะแนน)
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
	for slot: PretestDropSlotBtn in _fig2_slots:
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
	for slot: PretestDropSlotBtn in _fig2_slots:
		if not slot.current_step_id.is_empty():
			filled_slots += 1

	_progress_label.text = (
		"สถานะการทำรายงาน: เติมคำ (%d/6) | Figure 1 ติ๊กเลือก (%d/2 ส่วน) | Figure 2 เรียงลำดับ (%d/4 ขั้นตอน)"
		% [filled_dd, fig1_a_ok + fig1_b_ok, filled_slots]
	)
	if _status_msg_label and _is_all_answered():
		_status_msg_label.text = ""

func _calculate_pretest_scores() -> void:
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

	_last_pretest_score = _last_dropdown_score + _last_checkbox_score + _last_dragdrop_score
	_last_accuracy = float(_last_pretest_score) * 10.0

	var elapsed_sec: float = maxf(1.0, float(Time.get_ticks_msec() - _started_at_msec) / 1000.0)
	_last_wpm = roundf((100.0 / elapsed_sec) * 60.0 * 10.0) / 10.0

func _on_submit_pretest_pressed() -> void:
	if is_resolved:
		return
	if not _is_all_answered():
		if _status_msg_label:
			_status_msg_label.text = "⚠️ กรุณาเลือก Dropdown ให้ครบทั้ง 6 ช่อง, ติ๊ก Figure 1 ภาคละ 2 ข้อ, และวางบล็อก Figure 2 ให้ครบ 4 ขั้นตอนก่อนส่ง"
		return

	_calculate_pretest_scores()
	submit_puzzle("PRETEST_COMPLETED")

func validate_answer(answer: Variant) -> bool:
	if answer is String and str(answer) == "PRETEST_COMPLETED":
		return _is_all_answered()
	return _is_all_answered()

func get_submission_metrics() -> Dictionary:
	_calculate_pretest_scores()
	var now_msec: int = Time.get_ticks_msec()
	var total_sec: float = maxf(0.1, float(now_msec - _started_at_msec) / 1000.0)
	var analysis_sec: float = 0.0
	if _first_interaction_msec > _started_at_msec:
		analysis_sec = float(_first_interaction_msec - _started_at_msec) / 1000.0
	var decision_sec: float = maxf(0.0, total_sec - analysis_sec)

	return {
		"puzzle_id": "P00",
		"assessment_type": "pretest",
		"wpm": _last_wpm,
		"accuracy": _last_accuracy,
		"pretest_score": _last_pretest_score,
		"max_score": 10,
		"dropdown_score": _last_dropdown_score,
		"checkbox_score": _last_checkbox_score,
		"dragdrop_score": _last_dragdrop_score,
		"analysis_duration_seconds": analysis_sec,
		"decision_duration_seconds": decision_sec
	}

func on_solve_success() -> void:
	if _submit_btn:
		_submit_btn.disabled = true
		_submit_btn.text = "✓ บันทึกผล Pre-test เรียบร้อย (%d / 10 คะแนน)" % _last_pretest_score
	if _status_msg_label:
		_status_msg_label.add_theme_color_override("font_color", Color(0.1, 0.45, 0.22, 1.0))
		_status_msg_label.text = "บันทึกคำตอบลงในรายงานแล้ว กำลังประมวลผลเอกสาร..."
	scene_completion_requested.emit()

func on_solve_failed() -> void:
	if _status_msg_label:
		_status_msg_label.text = "⚠️ กรุณาตอบคำถามในรายงานให้ครบทุกส่วนก่อนยืนยัน"
