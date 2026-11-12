class_name TypingGamePuzzle
extends BasePuzzleUI

signal scene_completion_requested

const TARGET_TEXT: String = "Cybersecurity protects people systems and information from malicious software and unsafe attachments."

const FONT_THAI_REG: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-SemiBold.ttf")
const FONT_THAI_BOLD: FontFile = preload("res://assets/fonts/Noto_Sans_Thai/static/NotoSansThai-Bold.ttf")
const FONT_MONO: FontFile = preload("res://assets/fonts/Share_Tech_Mono/ShareTechMono-Regular.ttf")

const ICON_INFO: Texture2D = preload("res://assets/Icon32x32/information.png")
const ICON_WARN: Texture2D = preload("res://assets/Icon32x32/warning.png")
const ICON_DISK: Texture2D = preload("res://assets/Icon32x32/disk.png")
const ICON_TOOL: Texture2D = preload("res://assets/Icon32x32/tools.png")
const ICON_FOLDER: Texture2D = preload("res://assets/Icon32x32/folder.png")
const ICON_SEARCH: Texture2D = preload("res://assets/Icon32x32/folder_search.png")
const ICON_LOCK: Texture2D = preload("res://assets/Icon32x32/lock.png")
const ICON_CHECK: Texture2D = preload("res://assets/Icon32x32/checkmark.png")

# ---------------------------------------------------------------------------
# 1. ข้อมูลคำถามแบบเติมคำด้วย Dropdown 6 ช่อง (ข้อ 1, 3, 4, 5, 6, 10 เดิม = 6 คะแนน)
# ---------------------------------------------------------------------------
const DROPDOWN_QUESTIONS: Array[Dictionary] = [
	{
		"blank_id": 1,
		"label": "ช่องว่าง __(1)__ :",
		"correct_id": "phishing_spoof",
		"options": [
			["-- เลือกคำตอบช่อง (1) --", ""],
			["อีเมลล่อลวงที่ปลอมแปลงชื่อหรือโดเมนผู้ส่งให้คล้ายคลึงกับหน่วยงานที่เหยื่อคุ้นเคย", "phishing_spoof"],
			["อีเมลแจ้งเตือนอัตโนมัติที่แนบใบรับรองความปลอดภัยดิจิทัล (SSL Certificate) จากเซิร์ฟเวอร์หลัก", "ssl_notice"],
			["ข้อความระบบที่ส่งผ่านโปรโตคอลเข้ารหัสต้นทางถึงปลายทาง (End-to-End Encryption) ขององค์กร", "e2ee_msg"],
			["แพ็กเก็ตข้อมูลตรวจสอบสถานะเครือข่าย (Network Ping Request) ที่ส่งมาจากเกตเวย์ภายใน", "ping_packet"]
		]
	},
	{
		"blank_id": 2,
		"label": "ช่องว่าง __(2)__ :",
		"correct_id": "malware_ransom",
		"options": [
			["-- เลือกคำตอบช่อง (2) --", ""],
			["โปรแกรมประสงค์ร้ายหรือมัลแวร์ที่ถูกตั้งค่าให้ล็อกรหัสและทำลายไฟล์ข้อมูลของผู้ใช้", "malware_ransom"],
			["บริการจัดทำดัชนีค้นหาไฟล์อัตโนมัติ (Search Indexer) ที่กำลังสแกนพาร์ทิชันในฮาร์ดดิสก์", "search_indexer"],
			["โมดูลตรวจสอบความเข้ากันได้ของไดรเวอร์ที่รันสคริปต์วิเคราะห์ฮาร์ดแวร์ในโหมดเบื้องหลัง", "driver_compat"],
			["โปรเซสจัดการหน่วยความจำเสมือน (Virtual Memory Paging) ที่กำลังโอนย้ายข้อมูลลงดิสก์", "vmem_paging"]
		]
	},
	{
		"blank_id": 3,
		"label": "ช่องว่าง __(3)__ :",
		"correct_id": "disconnect_network",
		"options": [
			["-- เลือกคำตอบช่อง (3) --", ""],
			["ตัดการเชื่อมต่ออินเทอร์เน็ตและเครือข่ายทั้งหมดเพื่อบล็อกการสื่อสารกับภายนอก", "disconnect_network"],
			["สั่งบีบอัดโฟลเดอร์ระบบทั้งหมดเป็นไฟล์เดียวเพื่อจำกัดพื้นที่การทำงานของโปรเซสแปลกปลอม", "compress_sys"],
			["เปลี่ยนสิทธิ์บัญชีผู้ใช้ปัจจุบันให้เป็น Guest ชั่วคราวขณะยังเชื่อมต่อเครือข่ายตามปกติ", "switch_guest"],
			["ล้างข้อมูลในหน่วยความจำแคชของเบราว์เซอร์และรีเซ็ตค่า DNS ผ่านหน้าต่างคำสั่งระบบ", "clear_dns_cache"]
		]
	},
	{
		"blank_id": 4,
		"label": "ช่องว่าง __(4)__ :",
		"correct_id": "copy_isolated",
		"options": [
			["-- เลือกคำตอบช่อง (4) --", ""],
			["คัดลอกไฟล์แยกออกมาตรวจสอบในพื้นที่จำกัดโดยไม่เปิดหรือแก้ไขไฟล์ต้นฉบับโดยตรง", "copy_isolated"],
			["เปิดไฟล์ต้นฉบับในโหมดแก้ไขเพื่อบันทึกประวัติการเปลี่ยนแปลงลงในบันทึกของโปรแกรม", "open_edit_mode"],
			["ย้ายไฟล์ต้นฉบับไปไว้ในโฟลเดอร์ระบบเพื่อให้วินโดวส์จำกัดสิทธิ์การเข้าถึงโดยอัตโนมัติ", "move_sys_folder"],
			["เปลี่ยนนามสกุลไฟล์ต้นฉบับให้เป็นรูปแบบไฟล์ข้อความก่อนดับเบิลคลิกเปิดดูบนเครื่องเดิม", "rename_txt_open"]
		]
	},
	{
		"blank_id": 5,
		"label": "ช่องว่าง __(5)__ :",
		"correct_id": "file_checksum",
		"options": [
			["-- เลือกคำตอบช่อง (5) --", ""],
			["ค่าลายนิ้วมือดิจิทัลของไฟล์ (File Checksum / Hash) ที่คำนวณจากเนื้อหาข้อมูลภายใน", "file_checksum"],
			["ขนาดพื้นที่จัดเก็บจริงบนดิสก์ (Size on Disk) ที่แสดงในหน้าต่างคุณสมบัติของระบบไฟล์", "size_on_disk"],
			["หมายเลขลำดับเซกเตอร์เริ่มต้น (Starting Cluster Number) ที่ระบบปฏิบัติการใช้เก็บข้อมูล", "cluster_num"],
			["รายการสิทธิ์การเข้าถึงไฟล์ (Access Control List) ที่ระบุรายชื่อบัญชีผู้ใช้ในเครื่อง", "acl_list"]
		]
	},
	{
		"blank_id": 6,
		"label": "ช่องว่าง __(6)__ :",
		"correct_id": "multi_location_backup",
		"options": [
			["-- เลือกคำตอบช่อง (6) --", ""],
			["การสำรองข้อมูลแยกเก็บไว้หลายแหล่ง ทั้งในอุปกรณ์คนละประเภทและพื้นที่จัดเก็บนอกเครื่อง", "multi_location_backup"],
			["การแบ่งพาร์ทิชันฮาร์ดดิสก์ในเครื่องเดิมออกเป็นหลายไดรฟ์แล้วคัดลอกไฟล์ไว้ทุกพาร์ทิชัน", "same_disk_partition"],
			["การตั้งค่าให้ระบบสร้างจุดคืนค่า (System Restore Point) ลงในไดรฟ์หลักทุกครั้งที่เปิดเครื่อง", "sys_restore_point"],
			["การเข้ารหัสโฟลเดอร์งานสำคัญด้วยรหัสผ่านระดับสูงแล้วเก็บไว้ในเดสก์ท็อปของเครื่องหลักเพียงจุดเดียว", "single_desktop_enc"]
		]
	}
]

# ---------------------------------------------------------------------------
# 2. ข้อมูลภาพประกอบที่ 1 (Figure 1): แบบติ๊กเลือก CheckBox 2 ส่วน (2 คะแนน)
# ---------------------------------------------------------------------------
const FIG1_PART_A_OPTIONS: Array[Dictionary] = [
	{"id": "domain_mismatch", "text": "โดเมนหลังเครื่องหมาย @ ของผู้ส่งสะกดผิดเพี้ยนไปจากโดเมนทางการของหน่วยงานแม้ชื่อที่แสดงจะตรงกัน", "is_correct": true},
	{"id": "macro_prompt", "text": "ไฟล์เอกสารแนบแจ้งเตือนให้ผู้ใช้กดเปิดสิทธิ์รันคำสั่งอัตโนมัติ (Enable Macro / Content) ทันทีที่เปิดไฟล์", "is_correct": true},
	{"id": "smtp_limit", "text": "อีเมลถูกส่งผ่านโปรโตคอลมาตรฐาน SMTP และมีขนาดไฟล์แนบรวมกันไม่เกินขีดจำกัดของเมลเซิร์ฟเวอร์", "is_correct": false},
	{"id": "utc_html", "text": "ส่วนหัวของอีเมลระบุเวลาส่งตามเขตเวลามาตรฐานสากลและมีการจัดรูปแบบข้อความด้วยภาษา HTML", "is_correct": false}
]

const FIG1_PART_B_OPTIONS: Array[Dictionary] = [
	{"id": "unplug_backup", "text": "ถอดอุปกรณ์จัดเก็บข้อมูลสำรองภายนอกออกทุกครั้งหลังสำรองข้อมูลเสร็จเพื่อป้องกันการถูกล็อกไฟล์พ่วง", "is_correct": true},
	{"id": "disable_auto_script", "text": "ปิดการทำงานอัตโนมัติของสคริปต์และมาโครในโปรแกรมเอกสารสำหรับไฟล์ที่ดาวน์โหลดมาจากภายนอก", "is_correct": true},
	{"id": "realtime_sync_ext", "text": "ตั้งค่าให้ไดรฟ์สำรองข้อมูลภายนอกเชื่อมต่อและซิงค์ทับไฟล์ทุกการเปลี่ยนแปลงแบบเรียลไทม์ตลอดเวลา", "is_correct": false},
	{"id": "single_dir_mix", "text": "รวมไฟล์งานสำคัญและไฟล์ติดตั้งโปรแกรมที่ดาวน์โหลดจากอินเทอร์เน็ตไว้ในไดเรกทอรีเดียวกันเพื่อให้ง่ายต่อการสแกน", "is_correct": false}
]

# ---------------------------------------------------------------------------
# 3. ข้อมูลภาพประกอบที่ 2 (Figure 2): แบบลากวาง (Drag & Drop Flowchart) 4 ขั้นตอน (2 คะแนน)
# ---------------------------------------------------------------------------
const FIG2_CORRECT_ORDER: Array[String] = [
	"notice_stop",
	"disconnect_net",
	"scan_remove",
	"restore_verified"
]

const FIG2_STEP_ITEMS: Array[Dictionary] = [
	{
		"id": "notice_stop",
		"short": "สังเกตความผิดปกติของระบบและหยุดการเปิดใช้งานไฟล์หรือโปรแกรมที่ต้องสงสัยทันที"
	},
	{
		"id": "disconnect_net",
		"short": "ตัดการเชื่อมต่อเครือข่ายทั้งสาย LAN และ Wi-Fi เพื่อสกัดกั้นการแพร่กระจายข้อมูล"
	},
	{
		"id": "scan_remove",
		"short": "ตรวจสอบโปรเซสในระบบและกำจัดโปรแกรมแปลกปลอมออกจากเครื่องให้หมดสิ้น"
	},
	{
		"id": "restore_verified",
		"short": "นำข้อมูลจากแหล่งสำรองที่ตรวจสอบความสมบูรณ์แล้วกลับคืนสู่ระบบตามปกติ"
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
var _cutscene_scroll: ScrollContainer
var _cutscene_sections_ui: Array[Control] = []
var _para1_rtl: RichTextLabel
var _para2_rtl: RichTextLabel
var _para3_rtl: RichTextLabel
var _dropdown_controls: Dictionary = {} # blank_id (1..6) -> OptionButton
var _fig1_part_a_checks: Array[CheckBox] = []
var _fig1_part_b_checks: Array[CheckBox] = []
var _fig2_slots: Array[PretestDropSlotBtn] = []
var _fig2_pool_btns: Dictionary = {} # step_id -> PretestDragPoolBtn
var _selected_pool_step_id: String = ""
var _fig2_pool_title: Label = null
var _fig2_pool_container: VBoxContainer = null
var _progress_label: Label
var _status_msg_label: Label
var _submit_btn: Button
var _is_cutscene_mode: bool = false

func _ready() -> void:
	randomize()
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
	_build_cutscene_word_ui()

	if is_visible_in_tree():
		start_puzzle()

func configure_input(input: TextEdit) -> void:
	answer_input = input
	if answer_input:
		answer_input.hide()

func is_pretest_active() -> bool:
	return (_pretest_scroll != null and _pretest_scroll.visible) or (_cutscene_scroll != null and _cutscene_scroll.visible)

func get_pretest_scroll_container() -> ScrollContainer:
	if _is_cutscene_mode and _cutscene_scroll:
		return _cutscene_scroll
	return _pretest_scroll

func prepare_for_cutscene() -> void:
	_is_cutscene_mode = true
	if _pretest_scroll:
		_pretest_scroll.hide()
	if answer_input:
		answer_input.hide()
	if passage_label:
		passage_label.hide()
	if not _cutscene_scroll or not is_instance_valid(_cutscene_scroll):
		_build_cutscene_word_ui()
	if _cutscene_scroll:
		for sec: Control in _cutscene_sections_ui:
			if is_instance_valid(sec):
				sec.hide()
		_cutscene_scroll.show()
		_cutscene_scroll.scroll_vertical = 0

func reveal_cutscene_section(section_idx: int) -> void:
	if not _cutscene_scroll or not is_instance_valid(_cutscene_scroll):
		_build_cutscene_word_ui()
	if _passage_label_should_hide():
		passage_label.hide()
	if _cutscene_scroll:
		_cutscene_scroll.show()
	for i: int in range(_cutscene_sections_ui.size()):
		var sec: Control = _cutscene_sections_ui[i]
		if is_instance_valid(sec):
			sec.visible = (i <= section_idx)
	await get_tree().process_frame
	if is_instance_valid(self) and is_instance_valid(_cutscene_scroll):
		var vbar := _cutscene_scroll.get_v_scroll_bar()
		if vbar:
			var tw := create_tween()
			tw.tween_property(_cutscene_scroll, "scroll_vertical", int(vbar.max_value), 0.45)

func reveal_all_cutscene_sections() -> void:
	if not _cutscene_scroll or not is_instance_valid(_cutscene_scroll):
		_build_cutscene_word_ui()
	if _passage_label_should_hide():
		passage_label.hide()
	if _cutscene_scroll:
		_cutscene_scroll.show()
	for sec: Control in _cutscene_sections_ui:
		if is_instance_valid(sec):
			sec.show()
	await get_tree().process_frame
	if is_instance_valid(self) and is_instance_valid(_cutscene_scroll):
		var vbar := _cutscene_scroll.get_v_scroll_bar()
		if vbar:
			_cutscene_scroll.scroll_vertical = int(vbar.max_value)

func _passage_label_should_hide() -> bool:
	return passage_label != null and is_instance_valid(passage_label)

func start_puzzle() -> void:
	super.start_puzzle()
	_started_at_msec = Time.get_ticks_msec()
	_first_interaction_msec = 0
	_is_cutscene_mode = false
	if passage_label:
		passage_label.hide()
	if answer_input:
		answer_input.hide()
	if _cutscene_scroll:
		_cutscene_scroll.hide()
	if _pretest_scroll:
		_pretest_scroll.show()
		_pretest_scroll.scroll_vertical = 0
	_refresh_paragraph_texts()
	_refresh_fig2_ui()
	_update_progress_status()

func _mark_first_interaction() -> void:
	if _first_interaction_msec == 0:
		_first_interaction_msec = Time.get_ticks_msec()

# ---------------------------------------------------------------------------
# สร้างหน้ากระดาษรายงานวิชาการ A4 สำหรับทำ Pre-test (Dropdown 6 + Academic Figure 1 & 2)
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

	# พื้นหลังโต๊ะทำงานโปรแกรม Word สีเทาอมฟ้าอ่อน (ขนาบข้างละ ~35px)
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
	_pretest_scroll.add_child(desk_panel)

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
	paper_style.content_margin_bottom = 6.0
	paper_panel.add_theme_stylebox_override("panel", paper_style)
	desk_panel.add_child(paper_panel)

	var doc_vbox := VBoxContainer.new()
	doc_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	doc_vbox.add_theme_constant_override("separation", 4)
	paper_panel.add_child(doc_vbox)

	# 1. ส่วนหัวกระดาษรายงานวิชาการ (Running Head + Formal Title Block)
	_build_doc_header(doc_vbox)

	# 2. ย่อหน้าที่ 1 + Dropdown ช่อง (1) และ (2)
	_build_paragraph_1(doc_vbox)

	# 3. ภาพประกอบที่ 1 (Figure 1.1 & 1.2 แบบรายงานวิชาการสีพาสเทลอ่อน)
	_build_figure_1_checkbox_visual(doc_vbox)

	# 4. ย่อหน้าที่ 2 + Dropdown ช่อง (3), (4), (5)
	_build_paragraph_2(doc_vbox)

	# 5. ภาพประกอบที่ 2 (Figure 2.1: แผนผัง Flowchart วิชาการสีพาสเทลอ่อน)
	_build_figure_2_dragdrop_visual(doc_vbox)

	# 6. ย่อหน้าที่ 3 + Dropdown ช่อง (6)
	_build_paragraph_3(doc_vbox)

	# 7. แถบตรวจสอบสถานะและปุ่มยืนยันท้ายกระดาษ
	_build_submit_footer(doc_vbox)

	_refresh_paragraph_texts()
	_refresh_fig2_ui()
	_update_progress_status()

func _build_doc_header(parent: VBoxContainer) -> void:
	var header_vbox := VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 3)
	parent.add_child(header_vbox)

	# Running Head (หัวกระดาษรายงานมหาวิทยาลัย)
	var run_hbox := HBoxContainer.new()
	header_vbox.add_child(run_hbox)

	var run_left := Label.new()
	run_left.text = "รายวิชา 2110xxx ความมั่นคงปลอดภัยไซเบอร์เบื้องต้น (ภาคการศึกษาต้น)"
	run_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run_left.add_theme_font_override("font", FONT_THAI_REG)
	run_left.add_theme_font_size_override("font_size", 5)
	run_left.add_theme_color_override("font_color", Color(0.42, 0.47, 0.55, 1.0))
	run_hbox.add_child(run_left)

	var run_right := Label.new()
	run_right.text = "กลุ่มที่ 8 • แบบร่างก่อนส่ง (Pre-test)"
	run_right.add_theme_font_override("font", FONT_THAI_REG)
	run_right.add_theme_font_size_override("font_size", 5)
	run_right.add_theme_color_override("font_color", Color(0.42, 0.47, 0.55, 1.0))
	run_hbox.add_child(run_right)

	var top_rule := ColorRect.new()
	top_rule.custom_minimum_size = Vector2(0, 1)
	top_rule.color = Color(0.78, 0.82, 0.88, 1.0)
	header_vbox.add_child(top_rule)

	# Formal Centered Academic Title Block
	var title_box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.98, 0.99, 1.0, 1.0)
	sb.border_width_bottom = 2
	sb.border_color = Color(0.12, 0.16, 0.23, 1.0)
	sb.content_margin_left = 6.0
	sb.content_margin_right = 6.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 6.0
	title_box.add_theme_stylebox_override("panel", sb)
	header_vbox.add_child(title_box)

	var t_vbox := VBoxContainer.new()
	t_vbox.add_theme_constant_override("separation", 2)
	title_box.add_child(t_vbox)

	var type_lbl := Label.new()
	type_lbl.text = "รายงานการศึกษาค้นคว้าส่วนบุคคลและกลุ่ม (ACADEMIC TERM REPORT)"
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	type_lbl.add_theme_font_size_override("font_size", 6)
	type_lbl.add_theme_color_override("font_color", Color(0.35, 0.42, 0.52, 1.0))
	t_vbox.add_child(type_lbl)

	var title_lbl := Label.new()
	title_lbl.text = "หลักการพื้นฐานในการป้องกันและรับมือภัยคุกคามทางไซเบอร์เบื้องต้น"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	title_lbl.add_theme_font_size_override("font_size", 9)
	title_lbl.add_theme_color_override("font_color", Color(0.06, 0.1, 0.18, 1.0))
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t_vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "คณะผู้จัดทำ: นางสาวเมย์ และสมาชิกกลุ่มที่ 8  |  คำชี้แจง: เลือกข้อความทางวิชาการเติมลงในช่อง (1)-(6) และระบุคำตอบจากภาพประกอบที่ 1-2"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_override("font", FONT_THAI_REG)
	sub_lbl.add_theme_font_size_override("font_size", 5)
	sub_lbl.add_theme_color_override("font_color", Color(0.28, 0.34, 0.42, 1.0))
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t_vbox.add_child(sub_lbl)

func _build_paragraph_1(parent: VBoxContainer) -> void:
	var sec_vbox := VBoxContainer.new()
	sec_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(sec_vbox)

	var sec_title := Label.new()
	sec_title.text = "1. กลไกการล่อลวงทางวิศวกรรมสังคมและผลกระทบของโปรแกรมประสงค์ร้าย"
	sec_title.add_theme_font_override("font", FONT_THAI_BOLD)
	sec_title.add_theme_font_size_override("font_size", 7)
	sec_title.add_theme_color_override("font_color", Color(0.08, 0.14, 0.24, 1.0))
	sec_vbox.add_child(sec_title)

	_para1_rtl = _create_paragraph_rtl()
	sec_vbox.add_child(_para1_rtl)

	var dd_box := _create_dropdown_group_panel()
	sec_vbox.add_child(dd_box)
	var dd_vbox := VBoxContainer.new()
	dd_vbox.add_theme_constant_override("separation", 4)
	dd_box.add_child(dd_vbox)

	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[0]))
	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[1]))

func _build_figure_1_checkbox_visual(parent: VBoxContainer) -> void:
	var fig_panel := _create_academic_figure_frame()
	parent.add_child(fig_panel)

	var fig_vbox := VBoxContainer.new()
	fig_vbox.add_theme_constant_override("separation", 6)
	fig_panel.add_child(fig_vbox)

	# --- ภาพที่ 1.1: แผนภาพองค์ประกอบอีเมลล่อลวงและคำเตือนมาโคร (สีพาสเทลอ่อน) ---
	var card_a := _create_visual_subcard()
	fig_vbox.add_child(card_a)
	var card_a_vbox := VBoxContainer.new()
	card_a_vbox.add_theme_constant_override("separation", 4)
	card_a.add_child(card_a_vbox)

	var schematic_a_hbox := HBoxContainer.new()
	schematic_a_hbox.add_theme_constant_override("separation", 4)
	card_a_vbox.add_child(schematic_a_hbox)

	var box_a1 := _create_pastel_diagram_box(
		"(ก) ส่วนหัวของอีเมลจากภายนอก (Email Header)",
		"ชื่อผู้ส่งที่แสดง: \"ฝ่ายทะเบียนมหาวิทยาลัย\"\nที่อยู่จริง: <registrar@university-verify-portal.net>\n[จุดสังเกต: ชื่อผู้ส่งดูน่าเชื่อถือ แต่โดเมนหลัง @ ไม่ใช่ของสถาบัน]",
		Color(0.94, 0.97, 1.0, 1.0),
		Color(0.58, 0.77, 0.98, 1.0),
		Color(0.08, 0.26, 0.52, 1.0),
		ICON_INFO
	)
	box_a1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_a_hbox.add_child(box_a1)

	schematic_a_hbox.add_child(_create_diagram_arrow_label())

	var box_a2 := _create_pastel_diagram_box(
		"(ข) การแจ้งเตือนขณะเปิดไฟล์เอกสารแนบ (.docm)",
		"ไฟล์แนบ: แบบฟอร์มยืนยันสิทธิ์_ด่วน.docm\n⚠️ คำเตือนความปลอดภัย: เอกสารนี้ขอเปิดใช้งาน Macro\n[หากกด Enable Content สคริปต์แฝงจะรันอัตโนมัติทันที]",
		Color(1.0, 0.98, 0.92, 1.0),
		Color(0.96, 0.76, 0.38, 1.0),
		Color(0.55, 0.28, 0.04, 1.0),
		ICON_WARN
	)
	box_a2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_a_hbox.add_child(box_a2)

	card_a_vbox.add_child(_create_academic_caption_label(
		"ภาพที่ 1.1: แผนภาพแสดงองค์ประกอบของอีเมลล่อลวง (ก) และการขอสิทธิ์รันชุดคำสั่งอัตโนมัติในไฟล์เอกสารแนบ (ข)"
	))

	var prompt_a := Label.new()
	prompt_a.text = "[คำถามประกอบภาพที่ 1.1] จากแผนภาพข้างต้น ข้อใดคือ \"สัญญาณเตือนความเสี่ยงทางเทคนิค\" ที่บ่งชี้ว่าอาจเป็นภัยคุกคาม? (ติ๊กเลือก 2 ข้อ)"
	prompt_a.add_theme_font_override("font", FONT_THAI_BOLD)
	prompt_a.add_theme_font_size_override("font_size", 6)
	prompt_a.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
	prompt_a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_a_vbox.add_child(prompt_a)

	_fig1_part_a_checks.clear()
	var shuffled_a: Array[Dictionary] = FIG1_PART_A_OPTIONS.duplicate()
	shuffled_a.shuffle()
	for opt: Dictionary in shuffled_a:
		var cb := _create_word_checkbox(str(opt["text"]), str(opt["id"]), bool(opt["is_correct"]))
		cb.toggled.connect(func(pressed: bool) -> void:
			_on_fig1_checkbox_toggled(_fig1_part_a_checks, cb, pressed)
		)
		card_a_vbox.add_child(cb)
		_fig1_part_a_checks.append(cb)

	# --- ภาพที่ 1.2: แผนภาพแนวปฏิบัติในการดูแลอุปกรณ์และข้อมูลสำรอง (สีพาสเทลอ่อน) ---
	var card_b := _create_visual_subcard()
	fig_vbox.add_child(card_b)
	var card_b_vbox := VBoxContainer.new()
	card_b_vbox.add_theme_constant_override("separation", 4)
	card_b.add_child(card_b_vbox)

	var schematic_b_vbox := VBoxContainer.new()
	schematic_b_vbox.add_theme_constant_override("separation", 3)
	card_b_vbox.add_child(schematic_b_vbox)

	var box_b1 := _create_pastel_diagram_box(
		"(ก) สื่อสำรองข้อมูลภายนอก (External Drive)",
		"เชื่อมต่อเฉพาะขณะสำรองข้อมูล\nและถอดออกทันทีเมื่อเสร็จสิ้นเพื่อกันถูกล็อกพ่วง",
		Color(0.93, 0.99, 0.96, 1.0),
		Color(0.45, 0.84, 0.65, 1.0),
		Color(0.06, 0.38, 0.24, 1.0),
		ICON_DISK
	)
	box_b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_b_vbox.add_child(box_b1)

	var box_b2 := _create_pastel_diagram_box(
		"(ข) นโยบายสคริปต์อัตโนมัติ (Macro Policy)",
		"ปิดการรันสคริปต์และมาโครอัตโนมัติ\nสำหรับไฟล์ที่ดาวน์โหลดจากแหล่งภายนอก",
		Color(0.96, 0.95, 1.0, 1.0),
		Color(0.74, 0.66, 0.96, 1.0),
		Color(0.28, 0.16, 0.58, 1.0),
		ICON_TOOL
	)
	box_b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_b_vbox.add_child(box_b2)

	var box_b3 := _create_pastel_diagram_box(
		"(ค) การจัดระเบียบไดเรกทอรี (Directory Hygiene)",
		"แยกโฟลเดอร์เก็บงานสำคัญออกจาก\nโฟลเดอร์ไฟล์ติดตั้งที่ดาวน์โหลดจากเน็ต",
		Color(0.94, 0.98, 1.0, 1.0),
		Color(0.56, 0.82, 0.96, 1.0),
		Color(0.08, 0.32, 0.54, 1.0),
		ICON_FOLDER
	)
	box_b3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_b_vbox.add_child(box_b3)

	card_b_vbox.add_child(_create_academic_caption_label(
		"ภาพที่ 1.2: แผนภาพแสดงแนวปฏิบัติพื้นฐานในการจัดสภาพแวดล้อมของอุปกรณ์และสื่อสำรองข้อมูลเพื่อลดความเสี่ยง"
	))

	var prompt_b := Label.new()
	prompt_b.text = "[คำถามประกอบภาพที่ 1.2] ข้อใดคือ \"แนวปฏิบัติที่ถูกต้อง\" ในการตั้งค่าและใช้งานอุปกรณ์เพื่อลดความเสี่ยงจากการสูญเสียข้อมูลสำคัญ? (ติ๊กเลือก 2 ข้อ)"
	prompt_b.add_theme_font_override("font", FONT_THAI_BOLD)
	prompt_b.add_theme_font_size_override("font_size", 6)
	prompt_b.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
	prompt_b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_b_vbox.add_child(prompt_b)

	_fig1_part_b_checks.clear()
	var shuffled_b: Array[Dictionary] = FIG1_PART_B_OPTIONS.duplicate()
	shuffled_b.shuffle()
	for opt: Dictionary in shuffled_b:
		var cb := _create_word_checkbox(str(opt["text"]), str(opt["id"]), bool(opt["is_correct"]))
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
	sec_title.text = "2. การควบคุมความเสียหายเบื้องต้นและการตรวจสอบความสมบูรณ์ของข้อมูล"
	sec_title.add_theme_font_override("font", FONT_THAI_BOLD)
	sec_title.add_theme_font_size_override("font_size", 7)
	sec_title.add_theme_color_override("font_color", Color(0.08, 0.14, 0.24, 1.0))
	sec_vbox.add_child(sec_title)

	_para2_rtl = _create_paragraph_rtl()
	sec_vbox.add_child(_para2_rtl)

	var dd_box := _create_dropdown_group_panel()
	sec_vbox.add_child(dd_box)
	var dd_vbox := VBoxContainer.new()
	dd_vbox.add_theme_constant_override("separation", 4)
	dd_box.add_child(dd_vbox)

	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[2]))
	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[3]))
	dd_vbox.add_child(_create_dropdown_row(DROPDOWN_QUESTIONS[4]))

func _build_figure_2_dragdrop_visual(parent: VBoxContainer) -> void:
	var fig_panel := _create_academic_figure_frame()
	parent.add_child(fig_panel)

	var fig_vbox := VBoxContainer.new()
	fig_vbox.add_theme_constant_override("separation", 4)
	fig_panel.add_child(fig_vbox)

	# แผนภาพจำลองขั้นตอนมาตรฐานสีพาสเทลอ่อนด้านบน
	var flow_diagram_hbox := HBoxContainer.new()
	flow_diagram_hbox.add_theme_constant_override("separation", 3)
	fig_vbox.add_child(flow_diagram_hbox)

	var step_badges: Array[Dictionary] = [
		{"title": "ระยะที่ 1: สังเกตอาการ", "sub": "หยุดเปิดไฟล์ต้องสงสัย", "bg": Color(0.94, 0.97, 1.0, 1.0), "bd": Color(0.6, 0.78, 0.98, 1.0), "fg": Color(0.08, 0.28, 0.55, 1.0), "icon": ICON_SEARCH},
		{"title": "ระยะที่ 2: จำกัดวง", "sub": "ตัดการเชื่อมต่อเครือข่าย", "bg": Color(1.0, 0.98, 0.92, 1.0), "bd": Color(0.95, 0.76, 0.4, 1.0), "fg": Color(0.55, 0.28, 0.05, 1.0), "icon": ICON_LOCK},
		{"title": "ระยะที่ 3: กำจัดต้นตอ", "sub": "สแกนและลบโปรเซสแปลกปลอม", "bg": Color(0.96, 0.95, 1.0, 1.0), "bd": Color(0.75, 0.66, 0.96, 1.0), "fg": Color(0.28, 0.16, 0.55, 1.0), "icon": ICON_TOOL},
		{"title": "ระยะที่ 4: ฟื้นฟูระบบ", "sub": "กู้คืนจากแหล่งสำรองที่ปลอดภัย", "bg": Color(0.93, 0.99, 0.96, 1.0), "bd": Color(0.45, 0.84, 0.65, 1.0), "fg": Color(0.06, 0.38, 0.24, 1.0), "icon": ICON_CHECK}
	]
	for idx: int in range(step_badges.size()):
		var sb_info: Dictionary = step_badges[idx]
		var sbox := _create_pastel_diagram_box(str(sb_info["title"]), str(sb_info["sub"]), sb_info["bg"], sb_info["bd"], sb_info["fg"], sb_info.get("icon") as Texture2D)
		sbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		flow_diagram_hbox.add_child(sbox)
		if idx < step_badges.size() - 1:
			flow_diagram_hbox.add_child(_create_diagram_arrow_label())

	fig_vbox.add_child(_create_academic_caption_label(
		"ภาพที่ 2.1: แผนผังลำดับขั้นตอนมาตรฐานในการรับมือเหตุผิดปกติเบื้องต้นและการฟื้นฟูข้อมูลกลับสู่ระบบ"
	))

	var header_hbox := HBoxContainer.new()
	fig_vbox.add_child(header_hbox)

	var fig_header := Label.new()
	fig_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig_header.text = "[กิจกรรมประกอบภาพที่ 2.1] ลากบล็อกขั้นตอนด้านล่างมาวางเรียงลำดับ ขั้นที่ 1 ➔ 4 (หรือคลิกที่บล็อกเพื่อเติม):"
	fig_header.add_theme_font_override("font", FONT_THAI_BOLD)
	fig_header.add_theme_font_size_override("font_size", 6)
	fig_header.add_theme_color_override("font_color", Color(0.12, 0.16, 0.24, 1.0))
	fig_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header_hbox.add_child(fig_header)

	var reset_btn := Button.new()
	reset_btn.text = "ล้างลำดับ"
	reset_btn.custom_minimum_size = Vector2(44, 14)
	reset_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset_btn.add_theme_font_override("font", FONT_THAI_REG)
	reset_btn.add_theme_font_size_override("font_size", 6)
	reset_btn.pressed.connect(_on_fig2_reset_pressed)
	header_hbox.add_child(reset_btn)

	# แผนผัง Flowchart 4 ช่อง
	var flow_panel := PanelContainer.new()
	var flow_sb := StyleBoxFlat.new()
	flow_sb.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	flow_sb.border_width_left = 1
	flow_sb.border_width_top = 1
	flow_sb.border_width_right = 1
	flow_sb.border_width_bottom = 1
	flow_sb.border_color = Color(0.75, 0.8, 0.86, 1.0)
	flow_sb.corner_radius_top_left = 2
	flow_sb.corner_radius_top_right = 2
	flow_sb.corner_radius_bottom_left = 2
	flow_sb.corner_radius_bottom_right = 2
	flow_sb.content_margin_left = 6.0
	flow_sb.content_margin_right = 6.0
	flow_sb.content_margin_top = 5.0
	flow_sb.content_margin_bottom = 5.0
	flow_panel.add_theme_stylebox_override("panel", flow_sb)
	fig_vbox.add_child(flow_panel)

	var flow_vbox := VBoxContainer.new()
	flow_vbox.add_theme_constant_override("separation", 4)
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
		badge.add_theme_font_size_override("font_size", 6)
		badge.add_theme_color_override("font_color", Color(0.22, 0.15, 0.48, 1.0))
		slot_row.add_child(badge)

		var slot_btn := PretestDropSlotBtn.new()
		slot_btn.slot_index = i
		slot_btn.font_ref = FONT_THAI_REG
		slot_btn.puzzle_ref = self
		slot_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_btn.custom_minimum_size = Vector2(0, 16)
		slot_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		slot_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		slot_btn.clip_text = true
		slot_btn.add_theme_font_override("font", FONT_THAI_REG)
		slot_btn.add_theme_font_size_override("font_size", 6)
		slot_btn.add_theme_color_override("font_color", Color(0.06, 0.09, 0.15, 1.0))
		slot_btn.add_theme_color_override("font_focus_color", Color(0.06, 0.09, 0.15, 1.0))
		slot_btn.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
		slot_btn.add_theme_color_override("font_pressed_color", Color(0.02, 0.25, 0.55, 1.0))
		slot_btn.pressed.connect(func() -> void:
			_on_flowchart_slot_clicked(i)
		)
		slot_row.add_child(slot_btn)
		_fig2_slots.append(slot_btn)

	# คลังบล็อกสำหรับลากวาง (Drag & Drop Pool)
	var pool_title := Label.new()
	pool_title.text = "📦 คลังบล็อกขั้นตอน (ลากไปวางในช่อง ขั้นที่ 1-4 ด้านบน หรือคลิกที่บล็อกเพื่อเติมลงช่องว่าง):"
	pool_title.add_theme_font_override("font", FONT_THAI_BOLD)
	pool_title.add_theme_font_size_override("font_size", 6)
	pool_title.add_theme_color_override("font_color", Color(0.25, 0.28, 0.38, 1.0))
	fig_vbox.add_child(pool_title)

	var pool_vbox := VBoxContainer.new()
	pool_vbox.add_theme_constant_override("separation", 3)
	fig_vbox.add_child(pool_vbox)

	_fig2_pool_title = pool_title
	_fig2_pool_container = pool_vbox

	_fig2_pool_btns.clear()
	var shuffled_steps: Array[Dictionary] = FIG2_STEP_ITEMS.duplicate()
	shuffled_steps.shuffle()

	var matches_correct: bool = true
	if shuffled_steps.size() == FIG2_CORRECT_ORDER.size():
		for idx: int in range(shuffled_steps.size()):
			if str(shuffled_steps[idx]["id"]) != FIG2_CORRECT_ORDER[idx]:
				matches_correct = false
				break
	else:
		matches_correct = false

	if matches_correct and shuffled_steps.size() >= 2:
		var tmp: Dictionary = shuffled_steps[0]
		shuffled_steps[0] = shuffled_steps[1]
		shuffled_steps[1] = tmp

	for item: Dictionary in shuffled_steps:
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
		pbtn.clip_text = true
		pbtn.text = "⠿  " + stext
		pbtn.add_theme_font_override("font", FONT_THAI_REG)
		pbtn.add_theme_font_size_override("font_size", 6)

		var pool_sb := StyleBoxFlat.new()
		pool_sb.bg_color = Color(0.97, 0.98, 1.0, 1.0)
		pool_sb.border_width_left = 2
		pool_sb.border_width_top = 1
		pool_sb.border_width_right = 1
		pool_sb.border_width_bottom = 1
		pool_sb.border_color = Color(0.55, 0.65, 0.8, 1.0)
		pool_sb.corner_radius_top_left = 3
		pool_sb.corner_radius_top_right = 3
		pool_sb.corner_radius_bottom_left = 3
		pool_sb.corner_radius_bottom_right = 3
		pool_sb.content_margin_left = 6.0
		pool_sb.content_margin_right = 6.0
		pool_sb.content_margin_top = 2.0
		pool_sb.content_margin_bottom = 2.0
		pbtn.add_theme_stylebox_override("normal", pool_sb)

		var pool_hover := pool_sb.duplicate() as StyleBoxFlat
		pool_hover.bg_color = Color(0.9, 0.95, 1.0, 1.0)
		pool_hover.border_color = Color(0.2, 0.48, 0.85, 1.0)
		pbtn.add_theme_stylebox_override("hover", pool_hover)
		pbtn.add_theme_stylebox_override("focus", pool_hover)

		var pool_pressed := pool_sb.duplicate() as StyleBoxFlat
		pool_pressed.bg_color = Color(0.82, 0.9, 1.0, 1.0)
		pool_pressed.border_color = Color(0.15, 0.4, 0.75, 1.0)
		pbtn.add_theme_stylebox_override("pressed", pool_pressed)

		pbtn.add_theme_color_override("font_color", Color(0.06, 0.09, 0.15, 1.0))
		pbtn.add_theme_color_override("font_focus_color", Color(0.06, 0.09, 0.15, 1.0))
		pbtn.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
		pbtn.add_theme_color_override("font_pressed_color", Color(0.02, 0.25, 0.55, 1.0))
		pbtn.add_theme_color_override("font_disabled_color", Color(0.5, 0.55, 0.65, 1.0))

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
	sec_title.add_theme_font_size_override("font_size", 7)
	sec_title.add_theme_color_override("font_color", Color(0.1, 0.28, 0.55, 1.0))
	sec_vbox.add_child(sec_title)

	_para3_rtl = _create_paragraph_rtl()
	sec_vbox.add_child(_para3_rtl)

	var dd_box := _create_dropdown_group_panel()
	sec_vbox.add_child(dd_box)
	var dd_vbox := VBoxContainer.new()
	dd_vbox.add_theme_constant_override("separation", 4)
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
	_progress_label.add_theme_font_size_override("font_size", 6)
	_progress_label.add_theme_color_override("font_color", Color(0.12, 0.35, 0.22, 1.0))
	f_vbox.add_child(_progress_label)

	_status_msg_label = Label.new()
	_status_msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_msg_label.add_theme_font_override("font", FONT_THAI_REG)
	_status_msg_label.add_theme_font_size_override("font_size", 6)
	_status_msg_label.add_theme_color_override("font_color", Color(0.75, 0.22, 0.15, 1.0))
	f_vbox.add_child(_status_msg_label)

	_submit_btn = Button.new()
	_submit_btn.custom_minimum_size = Vector2(0, 20)
	_submit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_submit_btn.text = "✅ ยืนยันเนื้อหารายงานและส่งคำตอบ (Submit Pre-test)"
	_submit_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	_submit_btn.add_theme_font_size_override("font_size", 7)
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
	rtl.add_theme_color_override("default_color", Color(0.05, 0.08, 0.14, 1.0))
	rtl.add_theme_constant_override("line_separation", 2)
	return rtl

func _create_dropdown_group_panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.97, 0.99, 1.0)
	sb.border_width_left = 2
	sb.border_color = Color(0.25, 0.52, 0.85, 1.0)
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	p.add_theme_stylebox_override("panel", sb)
	return p

func _create_dropdown_row(q: Dictionary) -> HBoxContainer:
	var blank_id: int = int(q["blank_id"])
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var lbl := Label.new()
	lbl.custom_minimum_size = Vector2(56, 0)
	lbl.text = str(q["label"])
	lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	lbl.add_theme_font_size_override("font_size", 6)
	lbl.add_theme_color_override("font_color", Color(0.06, 0.22, 0.52, 1.0))
	row.add_child(lbl)

	var opt_btn := OptionButton.new()
	opt_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt_btn.custom_minimum_size = Vector2(0, 16)
	opt_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	opt_btn.clip_text = true
	opt_btn.add_theme_font_override("font", FONT_THAI_REG)
	opt_btn.add_theme_font_size_override("font_size", 6)

	# บังคับสีฟอนต์ทุกสถานะให้มี Contrast สูง คมชัด
	opt_btn.add_theme_color_override("font_color", Color(0.05, 0.12, 0.25, 1.0))
	opt_btn.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
	opt_btn.add_theme_color_override("font_focus_color", Color(0.05, 0.12, 0.25, 1.0))
	opt_btn.add_theme_color_override("font_pressed_color", Color(0.02, 0.25, 0.55, 1.0))
	opt_btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.5, 0.6, 1.0))

	var dd_sb := StyleBoxFlat.new()
	dd_sb.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	dd_sb.border_width_left = 1
	dd_sb.border_width_top = 1
	dd_sb.border_width_right = 1
	dd_sb.border_width_bottom = 1
	dd_sb.border_color = Color(0.65, 0.72, 0.82, 1.0)
	dd_sb.corner_radius_top_left = 2
	dd_sb.corner_radius_top_right = 2
	dd_sb.corner_radius_bottom_left = 2
	dd_sb.corner_radius_bottom_right = 2
	dd_sb.content_margin_left = 5.0
	dd_sb.content_margin_right = 5.0
	dd_sb.content_margin_top = 2.0
	dd_sb.content_margin_bottom = 2.0
	opt_btn.add_theme_stylebox_override("normal", dd_sb)
	var dd_hover := dd_sb.duplicate() as StyleBoxFlat
	dd_hover.border_color = Color(0.2, 0.48, 0.85, 1.0)
	dd_hover.bg_color = Color(0.96, 0.98, 1.0, 1.0)
	opt_btn.add_theme_stylebox_override("hover", dd_hover)
	var dd_pressed := dd_sb.duplicate() as StyleBoxFlat
	dd_pressed.bg_color = Color(0.92, 0.96, 1.0, 1.0)
	opt_btn.add_theme_stylebox_override("pressed", dd_pressed)

	var popup: PopupMenu = opt_btn.get_popup()
	if popup:
		popup.add_theme_font_override("font", FONT_THAI_REG)
		popup.add_theme_font_size_override("font_size", 6)
		popup.add_theme_color_override("font_color", Color(0.06, 0.09, 0.16, 1.0))
		popup.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
		popup.add_theme_color_override("font_accelerator_color", Color(0.06, 0.09, 0.16, 1.0))
		popup.add_theme_color_override("font_disabled_color", Color(0.55, 0.6, 0.68, 1.0))

		var pop_sb := StyleBoxFlat.new()
		pop_sb.bg_color = Color(0.99, 0.99, 1.0, 1.0)
		pop_sb.border_width_left = 1
		pop_sb.border_width_top = 1
		pop_sb.border_width_right = 1
		pop_sb.border_width_bottom = 1
		pop_sb.border_color = Color(0.45, 0.62, 0.85, 1.0)
		pop_sb.shadow_size = 4
		pop_sb.shadow_color = Color(0.05, 0.08, 0.15, 0.22)
		pop_sb.content_margin_left = 4.0
		pop_sb.content_margin_right = 4.0
		pop_sb.content_margin_top = 2.0
		pop_sb.content_margin_bottom = 2.0
		popup.add_theme_stylebox_override("panel", pop_sb)

		var hover_item_sb := StyleBoxFlat.new()
		hover_item_sb.bg_color = Color(0.85, 0.92, 1.0, 1.0)
		hover_item_sb.border_width_left = 1
		hover_item_sb.border_color = Color(0.25, 0.55, 0.9, 1.0)
		hover_item_sb.corner_radius_top_left = 2
		hover_item_sb.corner_radius_top_right = 2
		hover_item_sb.corner_radius_bottom_right = 2
		hover_item_sb.corner_radius_bottom_left = 2
		hover_item_sb.content_margin_left = 4.0
		hover_item_sb.content_margin_right = 4.0
		hover_item_sb.content_margin_top = 2.0
		hover_item_sb.content_margin_bottom = 2.0
		popup.add_theme_stylebox_override("hover", hover_item_sb)

	var options: Array = q["options"]
	if options.size() > 0:
		opt_btn.add_item(str(options[0][0]))
		opt_btn.set_item_metadata(0, str(options[0][1]))

	var choices: Array = options.slice(1).duplicate()
	choices.shuffle()
	for i: int in range(choices.size()):
		var pair: Array = choices[i]
		opt_btn.add_item(str(pair[0]))
		opt_btn.set_item_metadata(i + 1, str(pair[1]))

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
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	p.add_theme_stylebox_override("panel", sb)
	return p

func _create_academic_figure_frame() -> PanelContainer:
	var fig_panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.98, 0.985, 0.995, 1.0)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.62, 0.68, 0.76, 1.0)
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_left = 3
	sb.corner_radius_bottom_right = 3
	sb.content_margin_left = 8.0
	sb.content_margin_right = 8.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	fig_panel.add_theme_stylebox_override("panel", sb)
	return fig_panel

func _create_pastel_diagram_box(title_txt: String, body_txt: String, bg_col: Color, border_col: Color, title_col: Color, icon_tex: Texture2D = null) -> PanelContainer:
	var box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_width_left = 1
	sb.border_width_top = 2
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = border_col
	sb.corner_radius_top_left = 3
	sb.corner_radius_top_right = 3
	sb.corner_radius_bottom_left = 3
	sb.corner_radius_bottom_right = 3
	sb.content_margin_left = 4.0
	sb.content_margin_right = 4.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	box.add_theme_stylebox_override("panel", sb)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 2)
	box.add_child(vb)

	var title_hbox := HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 3)
	vb.add_child(title_hbox)

	if icon_tex != null:
		var icon_rect := TextureRect.new()
		icon_rect.texture = icon_tex
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(12, 12)
		title_hbox.add_child(icon_rect)

	var bullet_lbl := Label.new()
	bullet_lbl.text = "•"
	bullet_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bullet_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	bullet_lbl.add_theme_font_size_override("font_size", 6)
	bullet_lbl.add_theme_color_override("font_color", title_col)
	title_hbox.add_child(bullet_lbl)

	var t_lbl := Label.new()
	t_lbl.text = title_txt
	t_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	t_lbl.add_theme_font_size_override("font_size", 6)
	t_lbl.add_theme_color_override("font_color", title_col)
	t_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_hbox.add_child(t_lbl)

	var b_lbl := Label.new()
	b_lbl.text = body_txt
	b_lbl.add_theme_font_override("font", FONT_THAI_REG)
	b_lbl.add_theme_font_size_override("font_size", 5)
	b_lbl.add_theme_color_override("font_color", Color(0.05, 0.08, 0.14, 1.0))
	b_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vb.add_child(b_lbl)
	return box

func _create_diagram_arrow_label() -> Label:
	var arr := Label.new()
	arr.text = "➔"
	arr.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arr.add_theme_font_override("font", FONT_THAI_BOLD)
	arr.add_theme_font_size_override("font_size", 6)
	arr.add_theme_color_override("font_color", Color(0.35, 0.42, 0.52, 1.0))
	return arr

func _create_academic_caption_label(caption_text: String) -> Label:
	var cap := Label.new()
	cap.text = caption_text
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cap.add_theme_font_override("font", FONT_THAI_BOLD)
	cap.add_theme_font_size_override("font_size", 5)
	cap.add_theme_color_override("font_color", Color(0.28, 0.34, 0.44, 1.0))
	return cap

func _build_cutscene_word_ui() -> void:
	if _cutscene_scroll and is_instance_valid(_cutscene_scroll):
		return

	_cutscene_scroll = ScrollContainer.new()
	_cutscene_scroll.name = "CutsceneScroll"
	_cutscene_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cutscene_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_cutscene_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_cutscene_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	_cutscene_scroll.hide()
	add_child(_cutscene_scroll)

	# พื้นหลังโต๊ะทำงานโปรแกรม Word สีเทาอมฟ้าอ่อน (ขนาบข้างละ ~35px)
	var desk_panel := PanelContainer.new()
	desk_panel.name = "DeskBackgroundCutscene"
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
	paper_style.content_margin_bottom = 6.0
	paper_panel.add_theme_stylebox_override("panel", paper_style)
	desk_panel.add_child(paper_panel)

	var doc_vbox := VBoxContainer.new()
	doc_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	doc_vbox.add_theme_constant_override("separation", 4)
	paper_panel.add_child(doc_vbox)

	# หัวกระดาษรายงานวิชาการฉบับเต็ม (Cutscene)
	var header_vbox := VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 3)
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
	t_sb.content_margin_top = 4.0
	t_sb.content_margin_bottom = 6.0
	title_box.add_theme_stylebox_override("panel", t_sb)
	header_vbox.add_child(title_box)

	var t_vbox := VBoxContainer.new()
	t_vbox.add_theme_constant_override("separation", 2)
	title_box.add_child(t_vbox)

	var type_lbl := Label.new()
	type_lbl.text = "รายงานการศึกษาค้นคว้าส่วนบุคคลและกลุ่ม (ACADEMIC TERM REPORT)"
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	type_lbl.add_theme_font_size_override("font_size", 6)
	type_lbl.add_theme_color_override("font_color", Color(0.35, 0.42, 0.52, 1.0))
	t_vbox.add_child(type_lbl)

	var main_t := Label.new()
	main_t.text = "การวิเคราะห์กลไกการแพร่กระจายของมัลแวร์ผ่านเอกสารอิเล็กทรอนิกส์\nและแนวปฏิบัติมาตรฐานในการตรวจพิสูจน์หลักฐานเพื่อกู้คืนระบบ"
	main_t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_t.add_theme_font_override("font", FONT_THAI_BOLD)
	main_t.add_theme_font_size_override("font_size", 9)
	main_t.add_theme_color_override("font_color", Color(0.06, 0.1, 0.18, 1.0))
	main_t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t_vbox.add_child(main_t)

	var auth_lbl := Label.new()
	auth_lbl.text = "คณะผู้จัดทำ: นางสาวเมย์ และสมาชิกกลุ่มที่ 8  |  เสนอ: อาจารย์ประจำวิชาความมั่นคงปลอดภัยของระบบสารสนเทศ"
	auth_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	auth_lbl.add_theme_font_override("font", FONT_THAI_REG)
	auth_lbl.add_theme_font_size_override("font_size", 5)
	auth_lbl.add_theme_color_override("font_color", Color(0.28, 0.34, 0.42, 1.0))
	t_vbox.add_child(auth_lbl)

	_cutscene_sections_ui.clear()

	# --- ส่วนที่ 1 (19:30 น.): กลไกการหลอกลวง + ภาพที่ 1 ---
	var sec1 := VBoxContainer.new()
	sec1.add_theme_constant_override("separation", 4)
	doc_vbox.add_child(sec1)
	_cutscene_sections_ui.append(sec1)

	var s1_title := Label.new()
	s1_title.text = "1. กลไกการหลอกลวงทางวิศวกรรมสังคมและการฝังสคริปต์มาโครในเอกสาร"
	s1_title.add_theme_font_override("font", FONT_THAI_BOLD)
	s1_title.add_theme_font_size_override("font_size", 7)
	s1_title.add_theme_color_override("font_color", Color(0.08, 0.14, 0.24, 1.0))
	sec1.add_child(s1_title)

	var s1_rtl := _create_paragraph_rtl()
	s1_rtl.text = "      จากการศึกษาพฤติกรรมการโจมตีทางไซเบอร์พบว่า ผู้โจมตีนิยมใช้เทคนิคจดชื่อโดเมนเลียนแบบหน่วยงานจริง หรือ [b][color=#0d5c9e]Domain Typosquatting[/color][/b] (เช่น เปลี่ยนรหัสจาก [b].ac.th[/b] เป็น [b][color=#b91c1c].ac.co[/color][/b]) ร่วมกับการเร่งรัดให้เปิดไฟล์แนบ เมื่อเหยื่อกดอนุญาต [b]Enable Content[/b] โมดูลมาโครแฝง ([b]word/vbaProject.bin[/b]) จะถอดรหัสสตริง [b]Base64[/b] และ [b]Hexadecimal[/b] เพื่อรันคำสั่งทำลายข้อมูลทันที"
	sec1.add_child(s1_rtl)

	var fig1_frame := _create_academic_figure_frame()
	sec1.add_child(fig1_frame)
	var fig1_vb := VBoxContainer.new()
	fig1_vb.add_theme_constant_override("separation", 4)
	fig1_frame.add_child(fig1_vb)
	var fig1_hb := HBoxContainer.new()
	fig1_hb.add_theme_constant_override("separation", 4)
	fig1_vb.add_child(fig1_hb)

	var f1_b1 := _create_pastel_diagram_box(
		"1. อีเมลโดเมนเลียนแบบ",
		"ของจริง: @chula.ac.th\nของปลอม: @chula.ac.co\n(หลอกให้ดาวน์โหลดไฟล์แนบ)",
		Color(1.0, 0.98, 0.92, 1.0), Color(0.95, 0.76, 0.4, 1.0), Color(0.55, 0.28, 0.05, 1.0)
	)
	f1_b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig1_hb.add_child(f1_b1)
	fig1_hb.add_child(_create_diagram_arrow_label())

	var f1_b2 := _create_pastel_diagram_box(
		"2. โครงสร้างไฟล์ .docx ต้องสงสัย",
		"เอกสาร .docx ปกติจะไม่มีมาโคร\nแต่ตรวจพบ: word/vbaProject.bin\n(ทำงานทันทีที่กด Enable Content)",
		Color(1.0, 0.95, 0.95, 1.0), Color(0.94, 0.6, 0.6, 1.0), Color(0.6, 0.12, 0.12, 1.0)
	)
	f1_b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig1_hb.add_child(f1_b2)
	fig1_hb.add_child(_create_diagram_arrow_label())

	var f1_b3 := _create_pastel_diagram_box(
		"3. การพรางคำสั่งอันตราย",
		"เข้ารหัสสตริงด้วย Base64 / Hex\nตัวช่วย: Office_Update_Helper.exe\nคำสั่งแฝง: FILE_WIPE (ทำลายไฟล์)",
		Color(0.96, 0.95, 1.0, 1.0), Color(0.75, 0.66, 0.96, 1.0), Color(0.28, 0.16, 0.55, 1.0)
	)
	f1_b3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig1_hb.add_child(f1_b3)
	fig1_vb.add_child(_create_academic_caption_label(
		"ภาพที่ 1: แผนภาพลำดับการทำงานของภัยคุกคามตั้งแต่การปลอมแปลงโดเมนผู้ส่งจนถึงการรันโค้ดมาโครที่ถูกพรางด้วย Base64 และ Hex"
	))

	# --- ส่วนที่ 2 (20:15 น.): การจำกัดวงความเสียหาย + ภาพที่ 2 ---
	var sec2 := VBoxContainer.new()
	sec2.add_theme_constant_override("separation", 4)
	doc_vbox.add_child(sec2)
	_cutscene_sections_ui.append(sec2)

	var s2_title := Label.new()
	s2_title.text = "2. การจำกัดขอบเขตความเสียหาย (Containment) และผลกระทบต่อระบบซิงค์คลาวด์"
	s2_title.add_theme_font_override("font", FONT_THAI_BOLD)
	s2_title.add_theme_font_size_override("font_size", 7)
	s2_title.add_theme_color_override("font_color", Color(0.08, 0.14, 0.24, 1.0))
	sec2.add_child(s2_title)

	var s2_rtl := _create_paragraph_rtl()
	s2_rtl.text = "      เมื่อพบว่าเครื่องคอมพิวเตอร์มีอาการผิดปกติหรือสงสัยว่าติดมัลแวร์ มาตรการแรกที่สำคัญที่สุดคือ [b][color=#0d5c9e]การตัดการเชื่อมต่อเครือข่ายและระงับบริการซิงค์ข้อมูลอัตโนมัติ (Network & Cloud Sync Isolation)[/color][/b] ทันที เพราะหากปล่อยให้เชื่อมต่ออินเทอร์เน็ตต่อไป ระบบ Cloud Auto-Sync จะอัปโหลดไฟล์ที่ถูกล็อก ([b].locked[/b]) ขึ้นไปเขียนทับสำเนาที่ปลอดภัยบนคลาวด์โดยอัตโนมัติ"
	sec2.add_child(s2_rtl)

	var fig2_frame := _create_academic_figure_frame()
	sec2.add_child(fig2_frame)
	var fig2_vb := VBoxContainer.new()
	fig2_vb.add_theme_constant_override("separation", 4)
	fig2_frame.add_child(fig2_vb)
	var fig2_hb := HBoxContainer.new()
	fig2_hb.add_theme_constant_override("separation", 4)
	fig2_vb.add_child(fig2_hb)

	var f2_b1 := _create_pastel_diagram_box(
		"เครื่องคอมพิวเตอร์ที่ติดมัลแวร์",
		"ไฟล์งานในเครื่องถูกเปลี่ยนเป็น .locked\nสถานะ: มัลแวร์กำลังทำงานเบื้องหลัง",
		Color(1.0, 0.95, 0.95, 1.0), Color(0.94, 0.6, 0.6, 1.0), Color(0.6, 0.12, 0.12, 1.0)
	)
	f2_b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig2_hb.add_child(f2_b1)
	fig2_hb.add_child(_create_diagram_arrow_label())

	var f2_b2 := _create_pastel_diagram_box(
		"จุดสกัดกั้น (ต้องตัดเน็ตทันที!)",
		"ถอดสาย LAN / ปิด Wi-Fi\nและระงับบริการ Cloud Auto-Sync",
		Color(1.0, 0.98, 0.92, 1.0), Color(0.95, 0.76, 0.4, 1.0), Color(0.55, 0.28, 0.05, 1.0)
	)
	f2_b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig2_hb.add_child(f2_b2)
	fig2_hb.add_child(_create_diagram_arrow_label())

	var f2_b3 := _create_pastel_diagram_box(
		"พื้นที่จัดเก็บข้อมูลบนคลาวด์ (Version History)",
		"✓ เวอร์ชันก่อนเวลาเกิดเหตุ (16:30 น.) = ปลอดภัย\n✗ เวอร์ชันล่าสุดหลังติดเชื้อ (18:55 น.) = ไฟล์เสียทับ!",
		Color(0.93, 0.99, 0.96, 1.0), Color(0.45, 0.84, 0.65, 1.0), Color(0.06, 0.38, 0.24, 1.0)
	)
	f2_b3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fig2_hb.add_child(f2_b3)
	fig2_vb.add_child(_create_academic_caption_label(
		"ภาพที่ 2: แผนภาพแสดงความสำคัญของการตัดเครือข่ายเพื่อป้องกันการซิงค์ไฟล์ที่เสียหายทับสำเนาข้อมูลบนคลาวด์"
	))

	# --- ส่วนที่ 3 (21:00 น.): มาตรฐานนิติวิทยาศาสตร์ดิจิทัล + ตารางที่ 1 ---
	var sec3 := VBoxContainer.new()
	sec3.add_theme_constant_override("separation", 4)
	doc_vbox.add_child(sec3)
	_cutscene_sections_ui.append(sec3)

	var s3_title := Label.new()
	s3_title.text = "3. มาตรฐานการตรวจพิสูจน์หลักฐานดิจิทัลบนเครื่องวิเคราะห์แยกส่วน (Digital Forensics)"
	s3_title.add_theme_font_override("font", FONT_THAI_BOLD)
	s3_title.add_theme_font_size_override("font_size", 7)
	s3_title.add_theme_color_override("font_color", Color(0.08, 0.14, 0.24, 1.0))
	sec3.add_child(s3_title)

	var s3_rtl := _create_paragraph_rtl()
	s3_rtl.text = "      ผู้ตรวจสอบจะต้องไม่เปิดหรือซ่อมไฟล์บนเครื่องที่เกิดเหตุโดยตรง แต่ต้องคัดลอกออกมาเป็น [b][color=#0d5c9e]สำเนาหลักฐานแบบอ่านอย่างเดียว (Read-Only Forensic Image)[/color][/b] เพื่อนำไปตรวจสอบในเครื่องคอมพิวเตอร์แยกส่วนที่ตัดการเชื่อมต่อเครือข่าย (Air-Gapped Lab) ตามตารางเครื่องมือมาตรฐานดังนี้"
	sec3.add_child(s3_rtl)

	var tbl_frame := _create_academic_figure_frame()
	sec3.add_child(tbl_frame)
	var tbl_vb := VBoxContainer.new()
	tbl_vb.add_theme_constant_override("separation", 3)
	tbl_frame.add_child(tbl_vb)

	tbl_vb.add_child(_create_academic_caption_label(
		"ตารางที่ 1: สรุปเครื่องมือและคำสั่งมาตรฐานสำหรับการตรวจพิสูจน์หลักฐานดิจิทัลในห้องปฏิบัติการแยกส่วน"
	))

	var rows_data: Array[Dictionary] = [
		{"step": "1. ตรวจความสมบูรณ์ของไฟล์", "tool": "CMD: certutil -hashfile <ชื่อไฟล์> MD5", "desc": "คำนวณค่าแฮช MD5 เทียบกับตาราง Manifest เดิมเพื่อระบุไฟล์ที่ถูกดัดแปลง", "bg": Color(0.94, 0.97, 1.0, 1.0), "bd": Color(0.6, 0.78, 0.98, 1.0), "fg": Color(0.08, 0.28, 0.55, 1.0)},
		{"step": "2. ตรวจโครงสร้างเอกสาร", "tool": "Archive Inspector & Cyber Decoder", "desc": "ตรวจสอบโมดูลแฝง word/vbaProject.bin และถอดรหัสสตริง Base64 / Hex", "bg": Color(0.96, 0.95, 1.0, 1.0), "bd": Color(0.75, 0.66, 0.96, 1.0), "fg": Color(0.28, 0.16, 0.55, 1.0)},
		{"step": "3. ระบุเวลาเกิดเหตุจริง", "tool": "Windows System Event Logs", "desc": "ค้นหา Timestamp ที่มัลแวร์เริ่มทำงาน (เช่น 18:55 น.) เพื่อเลือกจุดกู้คืนข้อมูล", "bg": Color(0.93, 0.99, 0.96, 1.0), "bd": Color(0.45, 0.84, 0.65, 1.0), "fg": Color(0.06, 0.38, 0.24, 1.0)}
	]
	var tbl_hb := HBoxContainer.new()
	tbl_hb.add_theme_constant_override("separation", 4)
	tbl_vb.add_child(tbl_hb)
	for r_info: Dictionary in rows_data:
		var r_box := _create_pastel_diagram_box(
			str(r_info["step"]) + "\n[" + str(r_info["tool"]) + "]",
			str(r_info["desc"]),
			r_info["bg"], r_info["bd"], r_info["fg"]
		)
		r_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tbl_hb.add_child(r_box)

	# --- ส่วนที่ 4 (21:20 น.): ขั้นตอนการถอน Persistence & 3-2-1 Backup + ภาพที่ 3 ---
	var sec4 := VBoxContainer.new()
	sec4.add_theme_constant_override("separation", 4)
	doc_vbox.add_child(sec4)
	_cutscene_sections_ui.append(sec4)

	var s4_title := Label.new()
	s4_title.text = "4. ขั้นตอนการถอนการฝังตัวถาวร (Persistence) และการกู้คืนตามหลักการ 3-2-1 Backup"
	s4_title.add_theme_font_override("font", FONT_THAI_BOLD)
	s4_title.add_theme_font_size_override("font_size", 7)
	s4_title.add_theme_color_override("font_color", Color(0.08, 0.14, 0.24, 1.0))
	sec4.add_child(s4_title)

	var s4_rtl := _create_paragraph_rtl()
	s4_rtl.text = "      ก่อนทำการกู้คืนข้อมูล ผู้ดูแลระบบต้องเข้าสู่ [b][color=#0d5c9e]Safe Mode[/color][/b] เพื่อระงับการทำงานของมัลแวร์เบื้องหลัง และถอนรายการที่ฝังตัวอยู่ใน [b][color=#b91c1c]Scheduled Task[/color][/b] ออกให้หมดสิ้น จากนั้นจึงกู้คืนไฟล์จากจุดเวลาที่ปลอดภัยก่อนเกิดเหตุ ([b]Clean Snapshot[/b]) ตามหลักการสำรองข้อมูล [b][color=#065f46]3-2-1 Backup Rule[/color][/b] (มีข้อมูล 3 ชุด เก็บในสื่อ 2 ประเภท และแยกเก็บนอกสถานที่หรือคลาวด์ 1 ชุด)"
	sec4.add_child(s4_rtl)

	var fig3_frame := _create_academic_figure_frame()
	sec4.add_child(fig3_frame)
	var fig3_vb := VBoxContainer.new()
	fig3_vb.add_theme_constant_override("separation", 4)
	fig3_frame.add_child(fig3_vb)
	var fig3_hb := HBoxContainer.new()
	fig3_hb.add_theme_constant_override("separation", 3)
	fig3_vb.add_child(fig3_hb)

	var f3_steps: Array[Dictionary] = [
		{"t": "ขั้นที่ 1: ตรวจ Log & Hash", "d": "ระบุเวลาเกิดเหตุที่แน่ชัด", "bg": Color(0.94, 0.97, 1.0, 1.0), "bd": Color(0.6, 0.78, 0.98, 1.0), "fg": Color(0.08, 0.28, 0.55, 1.0)},
		{"t": "ขั้นที่ 2: บูตเข้า Safe Mode", "d": "หยุดโปรเซสมัลแวร์เบื้องหลัง", "bg": Color(0.96, 0.95, 1.0, 1.0), "bd": Color(0.75, 0.66, 0.96, 1.0), "fg": Color(0.28, 0.16, 0.55, 1.0)},
		{"t": "ขั้นที่ 3: ลบ Scheduled Task", "d": "ตัดวงจรการรันซ้ำอัตโนมัติ", "bg": Color(1.0, 0.98, 0.92, 1.0), "bd": Color(0.95, 0.76, 0.4, 1.0), "fg": Color(0.55, 0.28, 0.05, 1.0)},
		{"t": "ขั้นที่ 4: กู้คืน 3-2-1 Backup", "d": "ดึง Snapshot ก่อนติดเชื้อ", "bg": Color(0.93, 0.99, 0.96, 1.0), "bd": Color(0.45, 0.84, 0.65, 1.0), "fg": Color(0.06, 0.38, 0.24, 1.0)}
	]
	for idx: int in range(f3_steps.size()):
		var st_info: Dictionary = f3_steps[idx]
		var st_box := _create_pastel_diagram_box(str(st_info["t"]), str(st_info["d"]), st_info["bg"], st_info["bd"], st_info["fg"])
		st_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fig3_hb.add_child(st_box)
		if idx < f3_steps.size() - 1:
			fig3_hb.add_child(_create_diagram_arrow_label())

	fig3_vb.add_child(_create_academic_caption_label(
		"ภาพที่ 3: แผนผังลำดับขั้นตอนมาตรฐานในการกำจัดกลไกการฝังตัวของมัลแวร์และการกู้คืนข้อมูลอย่างปลอดภัย"
	))

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

func _create_word_checkbox(text_label: String, meta_id: String, is_correct: bool = false) -> CheckBox:
	var cb := CheckBox.new()
	cb.text = text_label
	cb.set_meta("option_id", meta_id)
	cb.set_meta("is_correct", is_correct)
	cb.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	cb.add_theme_font_override("font", FONT_THAI_REG)
	cb.add_theme_font_size_override("font_size", 5)
	# บังคับสีฟอนต์เข้ม คมชัด ทุกสถานะป้องกันกลืนกับพื้นหลังขาว
	cb.add_theme_color_override("font_color", Color(0.06, 0.09, 0.15, 1.0))
	cb.add_theme_color_override("font_focus_color", Color(0.06, 0.09, 0.15, 1.0))
	cb.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
	cb.add_theme_color_override("font_hover_pressed_color", Color(0.02, 0.25, 0.55, 1.0))
	cb.add_theme_color_override("font_pressed_color", Color(0.05, 0.32, 0.68, 1.0))
	cb.add_theme_color_override("font_disabled_color", Color(0.48, 0.52, 0.6, 1.0))
	return cb

# ---------------------------------------------------------------------------
# การอัปเดตข้อความย่อหน้าแบบ Live เมื่อผู้เล่นเลือก Dropdown
# ---------------------------------------------------------------------------
func _format_blank_inline(blank_id: int) -> String:
	var opt_btn: OptionButton = _dropdown_controls.get(blank_id, null) as OptionButton
	if not opt_btn or opt_btn.selected <= 0:
		return "[b][color=#c8321e]__(%d)__[/color][/b]" % blank_id
	var full_text: String = opt_btn.get_item_text(opt_btn.selected)
	return "[b][color=#0d5c9e][u] (%d) %s [/u][/color][/b]" % [blank_id, full_text]

func _refresh_paragraph_texts() -> void:
	if _para1_rtl:
		_para1_rtl.text = (
			"      ภัยคุกคามทางไซเบอร์ใกล้ตัวที่พบบ่อยมักเริ่มต้นจากการส่ง %s "
			+ "เพื่อหลอกล่อให้เป้าหมายหลงเชื่อและดาวน์โหลดไฟล์แนบลงในเครื่อง "
			+ "หากผู้ใช้เปิดไฟล์ดังกล่าวโดยไม่ตรวจสอบ อาจทำให้ %s "
			+ "เริ่มทำงานเบื้องหลังและเข้าควบคุมหรือทำลายไฟล์ข้อมูลสำคัญในระบบทันที"
		) % [_format_blank_inline(1), _format_blank_inline(2)]

	if _para2_rtl:
		_para2_rtl.text = (
			"      เมื่อสังเกตเห็นว่าคอมพิวเตอร์เริ่มทำงานผิดปกติหรือสงสัยว่าติดมัลแวร์ สิ่งแรกที่ควรปฏิบัติทันทีคือ %s "
			+ "เพื่อจำกัดขอบเขตความเสียหายไม่ให้ลุกลามไปยังระบบอื่น จากนั้นหากต้องการนำไฟล์ที่ต้องสงสัยมาตรวจสอบหาสาเหตุ เราควร %s "
			+ "และตรวจสอบความถูกต้องของข้อมูลด้วยการเทียบ %s กับค่าอ้างอิงเดิมเพื่อพิสูจน์ว่าไฟล์ไม่ถูกแอบดัดแปลงแก้ไข"
		) % [_format_blank_inline(3), _format_blank_inline(4), _format_blank_inline(5)]

	if _para3_rtl:
		_para3_rtl.text = (
			"      เพื่อลดผลกระทบหากเกิดเหตุการณ์ข้อมูลสูญหายหรือถูกทำลาย ผู้ใช้งานทุกคนควรวางแผน %s "
			+ "ไว้อย่างเป็นระบบ เพื่อให้สามารถนำข้อมูลที่ปลอดภัยกลับมาใช้งานได้โดยไม่ต้องเริ่มต้นทำงานใหม่ทั้งหมด"
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
	var filled_count: int = 0
	for slot: PretestDropSlotBtn in _fig2_slots:
		var sid: String = slot.current_step_id
		if sid.is_empty():
			slot.text = "[ ลากบล็อกจากด้านล่างมาวาง หรือคลิกบล็อกเพื่อเติม ]"
			var empty_sb := StyleBoxFlat.new()
			empty_sb.bg_color = Color(0.96, 0.98, 1.0, 1.0)
			empty_sb.border_width_left = 1
			empty_sb.border_width_top = 1
			empty_sb.border_width_right = 1
			empty_sb.border_width_bottom = 1
			empty_sb.border_color = Color(0.55, 0.65, 0.8, 1.0)
			empty_sb.corner_radius_top_left = 3
			empty_sb.corner_radius_top_right = 3
			empty_sb.corner_radius_bottom_left = 3
			empty_sb.corner_radius_bottom_right = 3
			empty_sb.content_margin_left = 6.0
			empty_sb.content_margin_right = 6.0
			slot.add_theme_stylebox_override("normal", empty_sb)
			var empty_hover := empty_sb.duplicate() as StyleBoxFlat
			empty_hover.bg_color = Color(0.91, 0.95, 1.0, 1.0)
			empty_hover.border_color = Color(0.25, 0.52, 0.85, 1.0)
			slot.add_theme_stylebox_override("hover", empty_hover)
			slot.add_theme_stylebox_override("focus", empty_hover)
			slot.add_theme_color_override("font_color", Color(0.22, 0.32, 0.45, 1.0))
			slot.add_theme_color_override("font_focus_color", Color(0.22, 0.32, 0.45, 1.0))
			slot.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
			slot.add_theme_color_override("font_pressed_color", Color(0.02, 0.25, 0.55, 1.0))
		else:
			used_ids[sid] = true
			filled_count += 1
			slot.text = "✅ " + slot.current_step_text + "  (คลิกเพื่อนำออก)"
			var filled_sb := StyleBoxFlat.new()
			filled_sb.bg_color = Color(0.9, 0.95, 1.0, 1.0)
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
			var filled_hover := filled_sb.duplicate() as StyleBoxFlat
			filled_hover.bg_color = Color(0.82, 0.91, 1.0, 1.0)
			slot.add_theme_stylebox_override("hover", filled_hover)
			slot.add_theme_stylebox_override("focus", filled_hover)
			slot.add_theme_color_override("font_color", Color(0.06, 0.09, 0.15, 1.0))
			slot.add_theme_color_override("font_focus_color", Color(0.06, 0.09, 0.15, 1.0))
			slot.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
			slot.add_theme_color_override("font_pressed_color", Color(0.02, 0.25, 0.55, 1.0))

	for sid: String in _fig2_pool_btns.keys():
		var pbtn: PretestDragPoolBtn = _fig2_pool_btns[sid]
		var is_used: bool = used_ids.has(sid)
		pbtn.visible = not is_used
		pbtn.disabled = is_used
		if is_used:
			pbtn.text = "✓ (วางในแผนผังแล้ว) " + pbtn.step_text
			pbtn.modulate = Color(1, 1, 1, 0.45)
		else:
			pbtn.text = "⠿  " + pbtn.step_text
			pbtn.modulate = Color(1, 1, 1, 1.0)

	var all_slots_filled: bool = (filled_count >= _fig2_slots.size()) and (_fig2_slots.size() > 0)
	if _fig2_pool_title and is_instance_valid(_fig2_pool_title):
		_fig2_pool_title.visible = not all_slots_filled
	if _fig2_pool_container and is_instance_valid(_fig2_pool_container):
		_fig2_pool_container.visible = not all_slots_filled

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
	for cb: CheckBox in _fig1_part_a_checks:
		if cb.button_pressed and bool(cb.get_meta("is_correct", false)):
			part_a_correct += 1
	if part_a_correct == 2 and _count_checked(_fig1_part_a_checks) == 2:
		_last_checkbox_score += 1

	var part_b_correct: int = 0
	for cb: CheckBox in _fig1_part_b_checks:
		if cb.button_pressed and bool(cb.get_meta("is_correct", false)):
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
