extends BaseDecoderPuzzle

const EVIDENCE_CONTENTS: Dictionary = {
	"Report_Final.docx": "forensic evidence sample: Report_Final.docx; read-only copy",
	"Windows_Event_Log.txt": "forensic evidence sample: event log copied from TaoDam",
	"Drive_Activity.log": "forensic evidence sample: shared drive activity history"
}

const MANIFEST_ALT_HASHES: Dictionary = {
	"Report_Final.docx": "7d4a2b6e1f0c3a8e9d5b7a1c4e2f6a8b",
	"Windows_Event_Log.txt": "3c9e1a7b4f2d8e0a6c5b9d3f1e4a7b2c",
	"Drive_Activity.log": "8a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d"
}

@onready var evidence_list: ItemList = $Panel/Content/EvidenceList
@onready var manifest_label: Label = $Panel/Content/ManifestLabel
@onready var open_terminal_btn: Button = find_child("OpenTerminalButton", true, false) as Button
@onready var hash_input: LineEdit = $Panel/Content/HashInput
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel
@onready var verify_button: Button = $Panel/Content/VerifyButton

var _selected_file: String = ""
var _expected_hash: String = ""
var _match_status: bool = false
var _terminal_instance: Control = null

func _ready() -> void:
	hint_tier_1 = "เปิด CMD (Terminal) แล้วพิมพ์ 'certutil -hashfile <ชื่อไฟล์> MD5' หรือดูค่าใน Evidence_Manifest.txt"
	hint_tier_2 = "ค่า MD5 Hash จะเป็นเลขฐาน 16 ความยาว 32 ตัวอักษร เช่น Report_Final.docx คือ 7d4a2b6e1f0c3a8e9d5b7a1c4e2f6a8b"
	hint_tier_3 = "กดปุ่ม 'เปิด CMD เพื่อเช็ค Hash' ด้านล่าง แล้วกดปุ่มลัด certutil เพื่อคัดลอกค่า MD5 มาวางในช่อง"
	super._ready()
	for file_name: String in EVIDENCE_CONTENTS:
		var item_index: int = evidence_list.add_item(file_name)
		evidence_list.set_item_metadata(item_index, file_name)
	evidence_list.item_selected.connect(_on_evidence_selected)
	verify_button.pressed.connect(_on_verify_pressed)
	hash_input.text_submitted.connect(func(_t: String) -> void: _on_verify_pressed())
	hash_input.text_changed.connect(func(_t: String) -> void: mark_decision_started())

	if open_terminal_btn:
		open_terminal_btn.pressed.connect(_on_open_terminal_pressed)

	manifest_label.text = "เปิด CMD (Terminal) แล้วรันคำสั่ง certutil -hashfile <ชื่อไฟล์> MD5 หรือดูใน Evidence_Manifest.txt เพื่อนำค่า MD5 มายืนยัน"
	hash_input.text = ""

	if evidence_list.item_count > 0 and _selected_file.is_empty():
		evidence_list.select(0)
		_on_evidence_selected(0)

func start_puzzle() -> void:
	super.start_puzzle()
	if not is_resolved and evidence_list and evidence_list.item_count > 0 and _selected_file.is_empty():
		evidence_list.select(0)
		_on_evidence_selected(0)

func validate_answer(answer: Variant) -> bool:
	var clean_ans: String = str(answer).strip_edges().to_lower()
	var alt_hash: String = str(MANIFEST_ALT_HASHES.get(_selected_file, "")).to_lower()
	_match_status = not _selected_file.is_empty() \
		and (clean_ans == _expected_hash or (not alt_hash.is_empty() and clean_ans == alt_hash))
	return _match_status

func get_submission_metrics() -> Dictionary:
	return {
		"evidence_file": _selected_file,
		"hash_algorithm": "MD5",
		"expected_hash": _expected_hash,
		"submitted_hash": hash_input.text.strip_edges().to_lower(),
		"match_status": _match_status
	}

func on_solve_success() -> void:
	feedback_label.text = "✅ ยืนยันความสมบูรณ์สำเร็จ: ค่า MD5 ของ %s ตรงกับ Manifest หลักฐานไม่ถูกดัดแปลง!" % _selected_file
	verify_button.disabled = true
	hash_input.editable = false
	if open_terminal_btn:
		open_terminal_btn.disabled = true
	for i: int in range(evidence_list.item_count):
		evidence_list.set_item_disabled(i, true)
	evidence_list.mouse_filter = Control.MOUSE_FILTER_IGNORE

func on_solve_failed() -> void:
	feedback_label.text = "❌ ค่า MD5 ไม่ตรงกับ Manifest! เปิด CMD แล้วรันคำสั่ง 'certutil -hashfile %s MD5' เพื่อตรวจสอบค่าที่ถูกต้อง" % _selected_file

func _on_evidence_selected(index: int) -> void:
	mark_decision_started()
	_selected_file = str(evidence_list.get_item_metadata(index))
	_expected_hash = _calculate_md5(str(EVIDENCE_CONTENTS[_selected_file]))
	manifest_label.text = "ไฟล์หลักฐาน: %s | เปิด CMD แล้วรัน 'certutil -hashfile %s MD5' หรือดูใน Evidence_Manifest.txt" % [_selected_file, _selected_file]
	# ไม่ใส่ค่าอัตโนมัติ ให้ผู้เล่นใช้ Terminal หรือ Manifest ค้นหาค่าเอง
	hash_input.text = ""
	feedback_label.text = "คลิกปุ่ม 'เปิด CMD' หรือพิมพ์คำสั่งใน Terminal เพื่อหาค่า MD5 ของ %s" % _selected_file

func _on_verify_pressed() -> void:
	mark_decision_started()
	submit_puzzle(hash_input.text)

func _on_open_terminal_pressed() -> void:
	mark_decision_started()
	var term: Control = null
	var nodes := get_tree().get_nodes_in_group("terminal_apps")
	if not nodes.is_empty():
		term = nodes[0] as Control

	if not term and is_instance_valid(_terminal_instance):
		term = _terminal_instance

	if not term:
		var term_scene = load("res://ui/os_simulation/Application/terminal.tscn")
		if term_scene:
			term = term_scene.instantiate() as Control
			_terminal_instance = term
			var p = get_parent()
			if p:
				p.add_child(term)
			else:
				add_child(term)

	if term:
		if not term.hash_verified_via_cmd.is_connected(_on_hash_from_cmd):
			term.hash_verified_via_cmd.connect(_on_hash_from_cmd)
		term.open_terminal()

func _on_hash_from_cmd(file_name: String, md5_hash: String) -> void:
	if _selected_file.is_empty() or file_name.to_lower() == _selected_file.to_lower():
		hash_input.text = md5_hash
		feedback_label.text = "📋 รับค่า MD5 จาก CMD (%s): %s พร้อมกด Verify MD5 แล้ว" % [file_name, md5_hash]

func _calculate_md5(content: String) -> String:
	var context: HashingContext = HashingContext.new()
	var error: Error = context.start(HashingContext.HASH_MD5)
	if error != OK:
		push_error("Unable to start MD5 hash context: %d" % error)
		return ""
	context.update(content.to_utf8_buffer())
	return context.finish().hex_encode()
