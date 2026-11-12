class_name IncidentReportPuzzle
extends BasePuzzleUI

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
# 1. ข้อมูลคำถามแบบเติมคำด้วย Dropdown 6 ช่อง (6 คะแนน)
# ---------------------------------------------------------------------------
const DROPDOWN_QUESTIONS: Array[Dictionary] = [
	{
		"blank_id": 1,
		"label": "ช่องว่าง __(1)__ :",
		"correct_id": "typosquatting_urgency",
		"options": [
			["-- เลือกคำตอบช่อง (1) --", ""],
			["Domain Typosquatting จดชื่อโดเมนเลียนแบบองค์กรร่วมกับการสร้างสถานการณ์เร่งด่วนหลอกเหยื่อ", "typosquatting_urgency"],
			["DNS Cache Poisoning แก้ไขตารางจับคู่ไอพีในเร้าเตอร์เพื่อเปลี่ยนเส้นทางเว็บท่าของมหาวิทยาลัย", "dns_poisoning"],
			["Session Hijacking ดักจับคุกกี้ยืนยันตัวตนขณะเหยื่อล็อกอินเข้าใช้งานระบบคลาวด์ผ่านเครือข่ายไร้สาย", "session_hijack"],
			["SMTP Header Relaying แทรกแซงเซิร์ฟเวอร์รับส่งเมลภายในเพื่อเปลี่ยนเนื้อหาไฟล์แนบระหว่างทาง", "smtp_relay"]
		]
	},
	{
		"blank_id": 2,
		"label": "ช่องว่าง __(2)__ :",
		"correct_id": "vba_macro_wiper",
		"options": [
			["-- เลือกคำตอบช่อง (2) --", ""],
			["โมดูล VBA Macro ที่พรางชุดคำสั่งทำลายและล็อกไฟล์ (Wiper / Ransomware) ไว้ด้วย Base64 และ Hex", "vba_macro_wiper"],
			["สคริปต์ Dynamic Data Exchange (DDE) ที่ฝังอยู่ในตารางคำนวณและเรียกใช้ไลบรารีการ์ดจอโดยตรง", "dde_script"],
			["โค้ด ActiveX Control ในเทมเพลตมาตรฐานที่บังคับให้ระบบปฏิบัติการเขียนทับพาร์ทิชันบูตหลัก", "activex_mbr"],
			["ชุดคำสั่ง XML External Entity (XXE) ในไฟล์โครงสร้างสไตล์ชีตที่ดึงเพย์โหลดผ่านพอร์ตเว็บเบราว์เซอร์", "xxe_stylesheet"]
		]
	},
	{
		"blank_id": 3,
		"label": "ช่องว่าง __(3)__ :",
		"correct_id": "net_sync_isolation",
		"options": [
			["-- เลือกคำตอบช่อง (3) --", ""],
			["ตัดการเชื่อมต่อเครือข่ายทุกช่องทางและระงับบริการ Cloud Auto-Sync เพื่อไม่ให้ไฟล์เสียซิงค์ทับสำเนาบนคลาวด์", "net_sync_isolation"],
			["สั่งล็อกพาร์ทิชันหลักด้วย BitLocker ทันทีและบังคับซิงค์สถานะระบบล่าสุดขึ้นเก็บไว้บน Cloud Drive สำรอง", "bitlocker_forcesync"],
			["ปิดโปรเซสงานเบื้องหลังผ่าน Task Manager แล้วเปิดแชร์โฟลเดอร์ผ่าน LAN เพื่อโอนย้ายไฟล์ออกไปยังเครื่องเพื่อน", "lan_share_transfer"],
			["รีเซ็ตการตั้งค่าไฟร์วอลล์กลับเป็นค่าเริ่มต้นและสั่งรันคำสั่งซ่อมแซมเซกเตอร์ฮาร์ดดิสก์ในโหมดการทำงานปกติ", "firewall_chkdsk"]
		]
	},
	{
		"blank_id": 4,
		"label": "ช่องว่าง __(4)__ :",
		"correct_id": "readonly_forensic_img",
		"options": [
			["-- เลือกคำตอบช่อง (4) --", ""],
			["สร้างและตรวจสอบผ่านสำเนาหลักฐานแบบอ่านอย่างเดียว (Read-Only Forensic Image) เพื่อรักษาค่า Timestamp และเนื้อหาเดิม", "readonly_forensic_img"],
			["โคลนนิ่งระบบเข้าสู่ดิสก์เสมือนแบบเขียนทับได้ (Read-Write Virtual Disk) แล้วเปิดไฟล์ด้วยโปรแกรม Word เพื่อจำลองเหตุการณ์", "readwrite_vdisk"],
			["ถอดรหัสโครงสร้างไบนารีของไฟล์ต้นฉบับโดยตรงบนสื่อบันทึกข้อมูลเดิมเพื่อบันทึกเวลาการตรวจพิสูจน์ลงใน Metadata", "inplace_decode"],
			["บีบอัดไฟล์ต้องสงสัยทั้งหมดเข้าด้วยกันพร้อมใส่รหัสผ่านใหม่บนเครื่องเกิดเหตุก่อนคัดลอกผ่านแฟลชไดรฟ์ส่วนตัว", "rezip_personal_usb"]
		]
	},
	{
		"blank_id": 5,
		"label": "ช่องว่าง __(5)__ :",
		"correct_id": "md5_hash_manifest",
		"options": [
			["-- เลือกคำตอบช่อง (5) --", ""],
			["ค่าแฮช MD5 (Cryptographic Hash) จากเนื้อหาไบนารีของไฟล์เพื่อพิสูจน์ความสมบูรณ์เทียบกับค่าอ้างอิงเดิม", "md5_hash_manifest"],
			["ค่า Cyclic Redundancy Check (CRC) ของตารางพาร์ทิชันเพื่อตรวจสอบจำนวนเซกเตอร์ที่ชำรุดทางกายภาพ", "crc_sector_check"],
			["หมายเลข Digital Signature Serial ของผู้ผลิตระบบปฏิบัติการที่ฝังอยู่ในส่วนหัวของไฟล์ระบบทุกไฟล์", "os_sig_serial"],
			["ค่า Entropy การกระจายตัวของบิตข้อมูลภายในไฟล์เทียบกับขนาดหน่วยความจำที่ใช้ขณะเปิดอ่านเอกสาร", "bit_entropy_ram"]
		]
	},
	{
		"blank_id": 6,
		"label": "ช่องว่าง __(6)__ :",
		"correct_id": "safemode_321_clean",
		"options": [
			["-- เลือกคำตอบช่อง (6) --", ""],
			["ถอนการฝังตัวใน Scheduled Task ภายใต้ Safe Mode ก่อนกู้คืนจาก Clean Version History ตามหลักการสำรองข้อมูล 3-2-1", "safemode_321_clean"],
			["ดึงไฟล์จาก Latest Cloud Sync เวอร์ชันล่าสุดหลังเวลาเกิดเหตุกลับมาทับทันที พร้อมสำรองไว้ 3 โฟลเดอร์ในไดรฟ์เดียวกัน", "latest_sync_samedrive"],
			["สั่งรันสคริปต์ล้างค่า Registry ในโหมดปกติ แล้วคัดลอกไฟล์สำรองจากแฟลชไดรฟ์ที่เสียบค้างไว้กับเครื่องตั้งแต่ก่อนเกิดเหตุ", "normal_reg_pluggedusb"],
			["ย้อนเวลาเครื่องด้วย System Restore ไปยังวันก่อนเกิดเหตุโดยไม่ต้องตรวจสอบ Scheduled Task หรือแยกเก็บสำเนาออฟไลน์", "sysrestore_notask"]
		]
	}
]

# ---------------------------------------------------------------------------
# 2. ข้อมูลภาพประกอบที่ 1 (Figure 1): แบบติ๊กเลือก CheckBox 2 ส่วน (2 คะแนน)
# ---------------------------------------------------------------------------
const FIG1_PART_A_OPTIONS: Array[Dictionary] = [
	{"id": "vba_bin", "text": "พบออบเจกต์ไบนารี word/vbaProject.bin แฝงอยู่ในโครงสร้าง ทั้งที่เอกสารนามสกุล .docx มาตรฐานจะต้องไม่มีโมดูลมาโคร", "is_correct": true},
	{"id": "b64_hex", "text": "พบสตริงที่ถูกเข้ารหัสอำพรางหลายชั้นด้วย Base64 และ Hexadecimal เพื่อซ่อนคำสั่งลบไฟล์และหลบเลี่ยงการตรวจจับ", "is_correct": true},
	{"id": "rels_xml", "text": "พบไฟล์กำหนดความสัมพันธ์ _rels/.rels และ [Content_Types].xml ที่ระบุโครงสร้างเอกสารตามมาตรฐาน OpenXML", "is_correct": false},
	{"id": "styles_xml", "text": "พบข้อมูลการจัดรูปแบบย่อหน้าและฟอนต์ภาษาไทยถูกแยกเก็บอยู่ในไฟล์ word/styles.xml และ word/document.xml", "is_correct": false}
]

const FIG1_PART_B_OPTIONS: Array[Dictionary] = [
	{"id": "airgap_offline", "text": "ตัดการเชื่อมต่อเครือข่ายขาออกทั้งหมด (Air-Gapped / Offline) เพื่อบล็อกไม่ให้สคริปต์ส่งข้อมูลหรือดึงคำสั่งจากเซิร์ฟเวอร์ภายนอก", "is_correct": true},
	{"id": "no_personal_sync", "text": "แยกสภาพแวดล้อมการวิเคราะห์ออกจากข้อมูลส่วนตัวโดยไม่ผูกบัญชี Cloud Sync หรือเสียบสื่อบันทึกข้อมูลงานจริงค้างไว้", "is_correct": true},
	{"id": "smb_lan_open", "text": "เปิดพอร์ตสื่อสารภายในวงแลนเดียวกันเฉพาะโปรโตคอล SMB เพื่อให้โอนย้ายไฟล์ตัวอย่างระหว่างเครื่องวิเคราะห์กับเครื่องหลักได้รวดเร็ว", "is_correct": false},
	{"id": "admin_online_cert", "text": "ตั้งค่าระบบให้รันโปรเซสทั้งหมดภายใต้สิทธิ์ System Administrator พร้อมเปิดใช้งานการซิงค์เวลาและใบรับรองผ่านอินเทอร์เน็ตตลอดการวิเคราะห์", "is_correct": false}
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
		"id": "inspect_logs",
		"short": "ตรวจสอบค่า MD5 Hash เทียบกับ Manifest และวิเคราะห์ System Log เพื่อระบุเวลาเกิดเหตุที่แน่ชัด"
	},
	{
		"id": "boot_safemode",
		"short": "รีสตาร์ทระบบเข้าสู่ Safe Mode เพื่อระงับการทำงานของโปรเซสและสคริปต์แปลกปลอมเบื้องหลัง"
	},
	{
		"id": "disable_task",
		"short": "ตรวจสอบและถอนการฝังตัวถาวร (Persistence) ของมัลแวร์ออกจาก Scheduled Task และ Startup"
	},
	{
		"id": "restore_clean",
		"short": "กู้คืนข้อมูลจาก Clean Snapshot ก่อนเวลาเกิดเหตุ และจัดเก็บสำเนาตามมาตรฐาน 3-2-1 Backup"
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
var _fig2_pool_title: Label = null
var _fig2_pool_container: VBoxContainer = null

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
	randomize()
	hint_tier_1 = "ทบทวนการสืบสวน: ตรวจ Log, เข้า Safe Mode, ปิด Task & Helper, และกู้คืนข้อมูลก่อนติดเชื้อ 19:02"
	hint_tier_2 = "ข้อสอบ Post-test วัด 3 ด้าน: 1. ต้นตอมัลแวร์ (Macro/Wiper) 2. การสืบสวนและแยกส่วน (เต่าดำ/MD5) 3. การกู้คืน (3-2-1 Backup)"
	hint_tier_3 = "ช่อง (1) Typosquatting, (2) VBA Macro Wiper, (3) Net & Sync Isolation, (4) Read-Only Forensic Image, (5) MD5 Hash, (6) Safe Mode 3-2-1"
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

	# กรอบหน้าต่างหลักโปรแกรม MS Word จัดกึ่งกลางจอ (384x220)
	var window_panel := PanelContainer.new()
	window_panel.name = "PaperPanel"
	window_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	window_panel.position = Vector2(48, 24)
	window_panel.size = Vector2(384, 220)
	window_panel.custom_minimum_size = Vector2(384, 220)
	var win_style := StyleBoxFlat.new()
	win_style.bg_color = Color(0.95, 0.96, 0.98, 1.0)
	win_style.border_width_left = 1
	win_style.border_width_top = 1
	win_style.border_width_right = 1
	win_style.border_width_bottom = 1
	win_style.border_color = Color(0.2, 0.45, 0.8, 0.95)
	win_style.corner_radius_top_left = 7
	win_style.corner_radius_top_right = 7
	win_style.corner_radius_bottom_left = 7
	win_style.corner_radius_bottom_right = 7
	win_style.shadow_size = 6
	win_style.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
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
	tb_style.corner_radius_top_left = 7
	tb_style.corner_radius_top_right = 7
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

	# 2. พื้นที่ ScrollContainer สำหรับแสดงกระดาษเอกสาร A4
	_word_scroll = ScrollContainer.new()
	_word_scroll.name = "PosttestWordScroll"
	_word_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_word_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_word_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_word_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_word_scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	win_vbox.add_child(_word_scroll)

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
	_word_scroll.add_child(desk_panel)

	# แผ่นกระดาษรายงานสีขาวสไตล์ MS Word กว้าง 348px กึ่งกลางโต๊ะทำงาน พร้อมเงาตกกระทบ
	var paper_panel := PanelContainer.new()
	paper_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	paper_panel.custom_minimum_size = Vector2(348, 0)
	var paper_style := StyleBoxFlat.new()
	paper_style.bg_color = Color(1.0, 1.0, 1.0, 1.0)
	paper_style.border_width_left = 1
	paper_style.border_width_top = 1
	paper_style.border_width_right = 1
	paper_style.border_width_bottom = 2
	paper_style.border_color = Color(0.75, 0.78, 0.84, 1.0)
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
	paper_style.corner_radius_top_left = 7
	paper_style.corner_radius_top_right = 7
	paper_style.corner_radius_bottom_left = 7
	paper_style.corner_radius_bottom_right = 7
	paper_style.shadow_size = 6
	paper_style.shadow_color = Color(0.04, 0.06, 0.12, 0.28)
	paper_style.content_margin_left = 8.0
	paper_style.content_margin_right = 8.0
	paper_style.content_margin_top = 6.0
	paper_style.content_margin_bottom = 6.0
	paper_panel.add_theme_stylebox_override("panel", paper_style)
	page_margin.add_child(paper_panel)

	var doc_vbox := VBoxContainer.new()
	doc_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	doc_vbox.add_theme_constant_override("separation", 4)
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
	sb_style.corner_radius_bottom_left = 7
	sb_style.corner_radius_bottom_right = 7
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
	var header_vbox := VBoxContainer.new()
	header_vbox.add_theme_constant_override("separation", 3)
	parent.add_child(header_vbox)

	# Running Head (หัวกระดาษรายงานมหาวิทยาลัย)
	var run_hbox := HBoxContainer.new()
	header_vbox.add_child(run_hbox)

	var run_left := Label.new()
	run_left.text = "รายงานสรุปผลการตรวจพิสูจน์หลักฐานดิจิทัลและการกู้คืนระบบ (Post-test 10 คะแนน)"
	run_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	run_left.add_theme_font_override("font", FONT_THAI_REG)
	run_left.add_theme_font_size_override("font_size", 5)
	run_left.add_theme_color_override("font_color", Color(0.42, 0.47, 0.55, 1.0))
	run_hbox.add_child(run_left)

	var run_right := Label.new()
	run_right.text = "กลุ่มที่ 8 • ฉบับสมบูรณ์"
	run_right.add_theme_font_override("font", FONT_THAI_REG)
	run_right.add_theme_font_size_override("font_size", 5)
	run_right.add_theme_color_override("font_color", Color(0.42, 0.47, 0.55, 1.0))
	run_hbox.add_child(run_right)

	var top_rule := ColorRect.new()
	top_rule.custom_minimum_size = Vector2(0, 1)
	top_rule.color = Color(0.78, 0.82, 0.88, 1.0)
	header_vbox.add_child(top_rule)

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
	type_lbl.text = "รายงานสรุปผลการปฏิบัติการทางนิติวิทยาศาสตร์ดิจิทัล (INCIDENT & FORENSIC REPORT)"
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	type_lbl.add_theme_font_size_override("font_size", 6)
	type_lbl.add_theme_color_override("font_color", Color(0.35, 0.42, 0.52, 1.0))
	t_vbox.add_child(type_lbl)

	var title_lbl := Label.new()
	title_lbl.text = "รายงานสรุปผลการสืบสวนเหตุการณ์ภัยคุกคามทางไซเบอร์และแนวทางการกู้คืนระบบ"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_override("font", FONT_THAI_BOLD)
	title_lbl.add_theme_font_size_override("font_size", 9)
	title_lbl.add_theme_color_override("font_color", Color(0.06, 0.1, 0.18, 1.0))
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t_vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "คณะผู้จัดทำ: นางสาวเมย์ และสมาชิกกลุ่มที่ 8  |  อ้างอิงผลตรวจจากเครื่องวิเคราะห์แยกส่วน (TaoDam Lab) และการกู้คืนระบบตามมาตรฐาน 3-2-1"
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
	sec_title.text = "1. การวิเคราะห์ต้นตอการโจมตีและกลไกของเพย์โหลดในเอกสาร (Threat Delivery & Payload Analysis)"
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
	fig_vbox.add_theme_constant_override("separation", 4)
	fig_panel.add_child(fig_vbox)

	# --- ภาพที่ 1.1: ผลตรวจโครงสร้าง Report_Final.docx ในแล็บเต่าดำ (สีพาสเทลอ่อน) ---
	var card_a := _create_visual_subcard()
	fig_vbox.add_child(card_a)
	var card_a_vbox := VBoxContainer.new()
	card_a_vbox.add_theme_constant_override("separation", 4)
	card_a.add_child(card_a_vbox)

	var schematic_a_hbox := HBoxContainer.new()
	schematic_a_hbox.add_theme_constant_override("separation", 4)
	card_a_vbox.add_child(schematic_a_hbox)

	var box_a1 := _create_pastel_diagram_box(
		"(ก) โครงสร้างภายในไฟล์ Report_Final.docx (ZIP Tree)",
		"├── [Content_Types].xml & _rels/.rels\n├── word/document.xml & word/styles.xml\n└── 🚨 word/vbaProject.bin [พบโมดูลมาโครแฝง!]",
		Color(1.0, 0.95, 0.95, 1.0),
		Color(0.94, 0.6, 0.6, 1.0),
		Color(0.6, 0.12, 0.12, 1.0),
		ICON_FOLDER
	)
	box_a1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_a_hbox.add_child(box_a1)

	schematic_a_hbox.add_child(_create_diagram_arrow_label())

	var box_a2 := _create_pastel_diagram_box(
		"(ข) ชุดคำสั่งอำพรางภายในโมดูล vbaProject.bin",
		"1. สตริง Base64: \"T2ZmaWNlX1VwZGF0ZV9IZWxwZXIuZXhl\"\n2. สตริงเลขฐานสิบหก (Hex): \"46 49 4C 45 5F 57 49 50 45\"\n   ➔ ถอดรหัสได้คำสั่งทำลายไฟล์ (FILE_WIPE)",
		Color(0.96, 0.95, 1.0, 1.0),
		Color(0.75, 0.66, 0.96, 1.0),
		Color(0.28, 0.16, 0.55, 1.0),
		ICON_WARN
	)
	box_a2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_a_hbox.add_child(box_a2)

	card_a_vbox.add_child(_create_academic_caption_label(
		"ภาพที่ 1.1: ผลการแยกวิเคราะห์โครงสร้าง OpenXML ของไฟล์ต้องสงสัย (ก) และชุดคำสั่งที่ถูกเข้ารหัสอำพรางภายในโมดูลมาโคร (ข)"
	))

	var prompt_a := Label.new()
	prompt_a.text = "[คำถามประกอบภาพที่ 1.1] ข้อใดคือ \"หลักฐานทางนิติวิทยาศาสตร์ 2 ประการ\" ที่พิสูจน์ว่าไฟล์นี้มีเพย์โหลดอันตรายแฝงอยู่? (ติ๊กเลือก 2 ข้อ)"
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

	# --- ภาพที่ 1.2: มาตรการตั้งค่าเครื่องวิเคราะห์แยกส่วน TaoDam (สีพาสเทลอ่อน) ---
	var card_b := _create_visual_subcard()
	fig_vbox.add_child(card_b)
	var card_b_vbox := VBoxContainer.new()
	card_b_vbox.add_theme_constant_override("separation", 4)
	card_b.add_child(card_b_vbox)

	var schematic_b_vbox := VBoxContainer.new()
	schematic_b_vbox.add_theme_constant_override("separation", 3)
	card_b_vbox.add_child(schematic_b_vbox)

	var box_b1 := _create_pastel_diagram_box(
		"(ก) การตัดขาดเครือข่าย (Air-Gapped Isolation)",
		"ปิด Wi-Fi และถอดสาย LAN ขาออกทั้งหมด\nเพื่อสกัดกั้นการติดต่อเซิร์ฟเวอร์ควบคุม (C2)",
		Color(0.93, 0.99, 0.96, 1.0),
		Color(0.45, 0.84, 0.65, 1.0),
		Color(0.06, 0.38, 0.24, 1.0),
		ICON_LOCK
	)
	box_b1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_b_vbox.add_child(box_b1)

	var box_b2 := _create_pastel_diagram_box(
		"(ข) การแยกบัญชีและข้อมูล (Account Hygiene)",
		"ไม่ล็อกอินบัญชี Cloud Sync ส่วนตัว\nและไม่เสียบสื่อบันทึกข้อมูลงานจริงค้างไว้",
		Color(0.94, 0.97, 1.0, 1.0),
		Color(0.58, 0.77, 0.98, 1.0),
		Color(0.08, 0.26, 0.52, 1.0),
		ICON_TOOL
	)
	box_b2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_b_vbox.add_child(box_b2)

	var box_b3 := _create_pastel_diagram_box(
		"(ค) การป้องกันการเขียนทับ (Write Protection)",
		"ตรวจสอบผ่านสำเนาหลักฐานแบบอ่านอย่างเดียว\nเพื่อรักษาค่า MD5 Hash และ Timestamp เดิม",
		Color(1.0, 0.98, 0.92, 1.0),
		Color(0.95, 0.76, 0.4, 1.0),
		Color(0.55, 0.28, 0.05, 1.0),
		ICON_DISK
	)
	box_b3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	schematic_b_vbox.add_child(box_b3)

	card_b_vbox.add_child(_create_academic_caption_label(
		"ภาพที่ 1.2: แผนภาพแสดงสถาปัตยกรรมความปลอดภัยของเครื่องคอมพิวเตอร์แยกส่วน (TaoDam Lab) สำหรับตรวจพิสูจน์มัลแวร์"
	))

	var prompt_b := Label.new()
	prompt_b.text = "[คำถามประกอบภาพที่ 1.2] ในการตั้งค่าเครื่องคอมพิวเตอร์แยกส่วน (TaoDam) เพื่อวิเคราะห์มัลแวร์โดยไม่ให้เกิดการรั่วไหล ต้องปฏิบัติตามข้อใด? (ติ๊กเลือก 2 ข้อ)"
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
	sec_title.text = "2. การจำกัดความเสียหายและการตรวจพิสูจน์พยานหลักฐานดิจิทัล (Containment & Digital Forensics)"
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

	var flow_diagram_hbox := HBoxContainer.new()
	flow_diagram_hbox.add_theme_constant_override("separation", 3)
	fig_vbox.add_child(flow_diagram_hbox)

	var step_badges: Array[Dictionary] = [
		{"title": "ระยะที่ 1: พิสูจน์หลักฐาน", "sub": "เทียบ MD5 Hash & Event Log", "bg": Color(0.94, 0.97, 1.0, 1.0), "bd": Color(0.6, 0.78, 0.98, 1.0), "fg": Color(0.08, 0.28, 0.55, 1.0), "icon": ICON_SEARCH},
		{"title": "ระยะที่ 2: ระงับโปรเซส", "sub": "บูตระบบเข้าสู่ Safe Mode", "bg": Color(0.96, 0.95, 1.0, 1.0), "bd": Color(0.75, 0.66, 0.96, 1.0), "fg": Color(0.28, 0.16, 0.55, 1.0), "icon": ICON_LOCK},
		{"title": "ระยะที่ 3: ถอนการฝังตัว", "sub": "ลบ Scheduled Task & Startup", "bg": Color(1.0, 0.98, 0.92, 1.0), "bd": Color(0.95, 0.76, 0.4, 1.0), "fg": Color(0.55, 0.28, 0.05, 1.0), "icon": ICON_TOOL},
		{"title": "ระยะที่ 4: กู้คืน 3-2-1", "sub": "ดึง Clean Snapshot ก่อนเกิดเหตุ", "bg": Color(0.93, 0.99, 0.96, 1.0), "bd": Color(0.45, 0.84, 0.65, 1.0), "fg": Color(0.06, 0.38, 0.24, 1.0), "icon": ICON_CHECK}
	]
	for idx: int in range(step_badges.size()):
		var sb_info: Dictionary = step_badges[idx]
		var sbox := _create_pastel_diagram_box(str(sb_info["title"]), str(sb_info["sub"]), sb_info["bg"], sb_info["bd"], sb_info["fg"], sb_info.get("icon") as Texture2D)
		sbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		flow_diagram_hbox.add_child(sbox)
		if idx < step_badges.size() - 1:
			flow_diagram_hbox.add_child(_create_diagram_arrow_label())

	fig_vbox.add_child(_create_academic_caption_label(
		"ภาพที่ 2.1: แผนผังลำดับขั้นตอนทางเทคนิคในการตรวจพิสูจน์ ถอนการฝังตัวถาวร (Persistence) และกู้คืนข้อมูลตามมาตรฐาน 3-2-1"
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

	var reset_flow_btn := Button.new()
	reset_flow_btn.text = "ล้างลำดับ"
	reset_flow_btn.custom_minimum_size = Vector2(44, 14)
	reset_flow_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	reset_flow_btn.add_theme_font_override("font", FONT_THAI_REG)
	reset_flow_btn.add_theme_font_size_override("font_size", 6)
	reset_flow_btn.pressed.connect(_on_fig2_reset_pressed)
	header_hbox.add_child(reset_flow_btn)

	var flow_vbox := VBoxContainer.new()
	flow_vbox.add_theme_constant_override("separation", 4)
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
		badge.add_theme_font_size_override("font_size", 6)
		badge.add_theme_color_override("font_color", Color(0.22, 0.15, 0.48, 1.0))
		slot_row.add_child(badge)

		var slot_btn := PosttestDropSlotBtn.new()
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
		var pbtn := PosttestDragPoolBtn.new()
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
		pbtn.puzzle_ref = self
		pbtn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pbtn.custom_minimum_size = Vector2(0, 16)
		pbtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		pbtn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		pbtn.text = "⠿  " + stext
		pbtn.add_theme_font_override("font", FONT_THAI_REG)
		pbtn.add_theme_font_size_override("font_size", 6)
		pool_vbox.add_child(pbtn)
		_fig2_pool_btns[sid] = pbtn

func _build_paragraph_3(parent: VBoxContainer) -> void:
	var sec_vbox := VBoxContainer.new()
	sec_vbox.add_theme_constant_override("separation", 4)
	parent.add_child(sec_vbox)

	var sec_title := Label.new()
	sec_title.text = "3. มาตรการกู้คืนระบบและความต่อเนื่องทางธุรกิจ (Business Continuity & Recovery)"
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
	_progress_label.add_theme_font_size_override("font_size", 6)
	_progress_label.add_theme_color_override("font_color", Color(0.1, 0.35, 0.7, 1.0))
	f_vbox.add_child(_progress_label)

	_status_msg_label = Label.new()
	_status_msg_label.text = ""
	_status_msg_label.add_theme_font_override("font", FONT_THAI_REG)
	_status_msg_label.add_theme_font_size_override("font_size", 6)
	_status_msg_label.add_theme_color_override("font_color", Color(0.85, 0.2, 0.1, 1.0))
	_status_msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	f_vbox.add_child(_status_msg_label)

	_submit_btn = Button.new()
	_submit_btn.text = "💾 บันทึกและส่งรายงานฉบับสมบูรณ์ (Submit Final Report - Post-test 10 คะแนน)"
	_submit_btn.custom_minimum_size = Vector2(0, 22)
	_submit_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_submit_btn.add_theme_font_override("font", FONT_THAI_BOLD)
	_submit_btn.add_theme_font_size_override("font_size", 7)
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
	cb.add_theme_font_size_override("font_size", 6)
	# บังคับสีฟอนต์เข้ม คมชัด ทุกสถานะป้องกันกลืนกับพื้นหลังขาว
	cb.add_theme_color_override("font_color", Color(0.06, 0.09, 0.15, 1.0))
	cb.add_theme_color_override("font_focus_color", Color(0.06, 0.09, 0.15, 1.0))
	cb.add_theme_color_override("font_hover_color", Color(0.02, 0.25, 0.55, 1.0))
	cb.add_theme_color_override("font_hover_pressed_color", Color(0.02, 0.25, 0.55, 1.0))
	cb.add_theme_color_override("font_pressed_color", Color(0.05, 0.32, 0.68, 1.0))
	cb.add_theme_color_override("font_disabled_color", Color(0.48, 0.52, 0.6, 1.0))
	return cb

func _on_fig1_checkbox_toggled(group: Array[CheckBox], changed_cb: CheckBox, pressed: bool) -> void:
	_mark_first_interaction()
	if pressed:
		var checked_list: Array[CheckBox] = []
		for cb: CheckBox in group:
			if cb.button_pressed and cb != changed_cb:
				checked_list.append(cb)
		if checked_list.size() >= 2:
			checked_list[0].set_pressed_no_signal(false)
	_update_progress_status()

# ---------------------------------------------------------------------------
# อัปเดตข้อความ Live Preview ในย่อหน้าเมื่อผู้เล่นเลือก Dropdown
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
			"      จากการสืบสวนบันทึกเหตุการณ์พบว่า ผู้โจมตีเริ่มต้นด้วยการทำ %s "
			+ "เพื่อหลอกให้เหยื่อเชื่อว่าเป็นอีเมลเร่งด่วนจากบุคลากรในมหาวิทยาลัย "
			+ "เมื่อเหยื่อดาวน์โหลดและเปิดไฟล์เอกสาร โค้ดอันตรายในรูปแบบ %s "
			+ "จึงถูกเรียกใช้งานและเข้าทำลายข้อมูลในเครื่องทันที"
		) % [_format_blank_inline(1), _format_blank_inline(2)]

	if _para2_rtl:
		_para2_rtl.text = (
			"      ในขั้นตอนการควบคุมสถานการณ์ ผู้สืบสวนต้องดำเนินการ %s "
			+ "เป็นอันดับแรกเพื่อป้องกันความเสียหายลุกลามไปยังพื้นที่จัดเก็บข้อมูลร่วม "
			+ "จากนั้นจึงนำข้อมูลจากเครื่องเกิดเหตุมาตรวจพิสูจน์บนเครื่องวิเคราะห์แยกส่วนโดยยึดหลักการ %s "
			+ "และใช้หน้าต่าง Command Prompt รันคำสั่งตรวจวัด %s เทียบกับตารางอ้างอิงในไฟล์ Manifest"
		) % [_format_blank_inline(3), _format_blank_inline(4), _format_blank_inline(5)]

	if _para3_rtl:
		_para3_rtl.text = (
			"      ในขั้นตอนสุดท้ายของการกู้คืนระบบ ผู้สืบสวนได้ดำเนินการ %s "
			+ "เพื่อให้มั่นใจว่าระบบและไฟล์ข้อมูลสำคัญทั้งหมดกลับมาใช้งานได้อย่างปลอดภัยโดยไม่เกิดการติดเชื้อซ้ำ"
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
	var filled_count: int = 0
	for slot: PosttestDropSlotBtn in _fig2_slots:
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
		var pbtn: PosttestDragPoolBtn = _fig2_pool_btns[sid]
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
