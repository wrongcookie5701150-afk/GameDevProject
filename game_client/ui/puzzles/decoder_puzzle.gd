class_name DecoderPuzzle
extends BaseDecoderPuzzle

signal all_decoding_complete

const HELPER_BASE64: String = "T2ZmaWNlX1VwZGF0ZV9IZWxwZXI="
const MODE_HEX: String = "526B6c4D5256395853564246"
const MODE_BASE64: String = "RklMRV9XSVBF"

@onready var title_label: Label = $Panel/Content/TitleLabel
@onready var instruction_label: Label = $Panel/Content/InstructionLabel
@onready var encoded_label: Label = $Panel/Content/EncodedLabel
@onready var answer_input: LineEdit = $Panel/Content/AnswerInput
@onready var submit_button: Button = $Panel/Content/SubmitButton
@onready var hint_button: Button = $Panel/Content/HintButton
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

var decode_stage: int = 0
var _decoded_output: String = ""
var _decoded_mode: String = ""

func _ready() -> void:
	super._ready()
	_refresh_stage()
	submit_button.pressed.connect(_on_submit_pressed)
	hint_button.pressed.connect(_on_hint_pressed)
	answer_input.text_submitted.connect(func(_t: String) -> void: _on_submit_pressed())

func validate_answer(answer: Variant) -> bool:
	var submitted_value: String = str(answer).strip_edges().trim_suffix(".dat").trim_suffix(".exe")
	if decode_stage == 0:
		return submitted_value.to_lower() == "office_update_helper"
	return submitted_value.to_upper() == "FILE_WIPE"

func get_submission_metrics() -> Dictionary:
	if decode_stage == 0:
		return {
			"decoded_output": _decoded_output,
			"encoded_value": HELPER_BASE64,
			"encoding": "Base64"
		}
	return {
		"decoded_target": "Project_Folder",
		"decoded_mode": _decoded_mode,
		"hex_value": MODE_HEX,
		"base64_value": MODE_BASE64,
		"encoding": "Hex then Base64"
	}

func resume_at_task(resume_task_id: String) -> void:
	if resume_task_id == "T11":
		decode_stage = 1
		task_id = &"T11"
		puzzle_id = &"P06"
	else:
		decode_stage = 0
		task_id = &"T10"
		puzzle_id = &"P05"
	_refresh_stage()

func on_solve_success() -> void:
	if decode_stage == 0:
		_decoded_output = "Office_Update_Helper"
		decode_stage = 1
		is_resolved = false
		attempt_count = 0
		hint_used = false
		task_id = &"T11"
		puzzle_id = &"P06"
		start_puzzle()
		_refresh_stage()
		feedback_label.text = "✅ ถอดรหัสขั้นที่ 1 (Office_Update_Helper) สำเร็จ! ขั้นที่ 2: ถอดรหัสโหมดการทำงาน (Hex -> Base64)"
		return

	_decoded_mode = "FILE_WIPE"
	feedback_label.text = "✅ ยืนยันโหมดมัลแวร์: %s (ทำลายไฟล์ในโฟลเดอร์โปรเจกต์)" % _decoded_mode
	answer_input.editable = false
	submit_button.hide()
	hint_button.hide()
	all_decoding_complete.emit()

func on_solve_failed() -> void:
	if decode_stage == 0:
		feedback_label.text = "❌ ค่าที่ถอดรหัสยังไม่ตรง (สามารถกดปุ่ม คำใบ้ / เติมค่า ด้านบนเพื่อดูผลจาก Decoder ได้)"
	else:
		feedback_label.text = "❌ โหมดการทำงานยังไม่ตรง (ต้องแปลง Hex เป็น Base64 แล้วแปลงซ้ำเป็นข้อความ หรือกดปุ่ม คำใบ้)"

func _on_submit_pressed() -> void:
	var clean_input: String = answer_input.text.strip_edges().trim_suffix(".dat").trim_suffix(".exe")
	if decode_stage == 0:
		_decoded_output = "Office_Update_Helper" if clean_input.to_lower() == "office_update_helper" else clean_input
	else:
		_decoded_mode = clean_input.to_upper()
	set_forensic_metrics(get_submission_metrics())
	submit_puzzle(clean_input)

func _on_hint_pressed() -> void:
	hint_used = true
	if decode_stage == 0:
		answer_input.text = "Office_Update_Helper"
		feedback_label.text = "💡 ถอดรหัส Base64 ได้ชื่อไฟล์: Office_Update_Helper (เติมค่าลงในช่องแล้ว กด Submit ได้เลย)"
	else:
		answer_input.text = "FILE_WIPE"
		feedback_label.text = "💡 ถอดรหัส Hex -> Base64 (RklMRV9XSVBF) ได้โหมด: FILE_WIPE (เติมค่าลงในช่องแล้ว กด Submit ได้เลย)"

func _refresh_stage() -> void:
	answer_input.clear()
	answer_input.editable = true
	submit_button.show()
	hint_button.show()
	if decode_stage == 0:
		title_label.text = "[5/6] T10 / P05: Decode Helper Name (1/2)"
		instruction_label.text = "ขั้นที่ 1/2: ถอดรหัส Base64 เพื่อหาชื่อไฟล์ Helper ที่ถูกฝังไว้"
		encoded_label.text = HELPER_BASE64
		feedback_label.text = "คัดลอกไปถอดรหัสในแอป Decoder หรือกดปุ่ม 'คำใบ้ / เติมค่า' เพื่อดึงผลลัพธ์"
		answer_input.placeholder_text = "ระบุชื่อไฟล์ Helper..."
	else:
		title_label.text = "[5/6] T11 / P06: Decode Helper Mode (2/2)"
		instruction_label.text = "ขั้นที่ 2/2: ถอดรหัส MODE จาก Hex -> Base64 -> ข้อความ"
		encoded_label.text = "TARGET: UHJvamVjdF9Gb2xkZXI= (Project_Folder)\nMODE (Hex): %s" % MODE_HEX
		feedback_label.text = "ถอดรหัส Hex จะได้ Base64 แล้วถอดรหัส Base64 อีกครั้งเพื่อหาโหมดการทำงาน"
		answer_input.placeholder_text = "ระบุโหมดการทำงาน..."
