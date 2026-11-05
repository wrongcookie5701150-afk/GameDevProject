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
@onready var hash_input: LineEdit = $Panel/Content/HashInput
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel
@onready var verify_button: Button = $Panel/Content/VerifyButton

var _selected_file: String = ""
var _expected_hash: String = ""
var _match_status: bool = false

func _ready() -> void:
	super._ready()
	for file_name: String in EVIDENCE_CONTENTS:
		var item_index: int = evidence_list.add_item(file_name)
		evidence_list.set_item_metadata(item_index, file_name)
	evidence_list.item_selected.connect(_on_evidence_selected)
	verify_button.pressed.connect(_on_verify_pressed)
	hash_input.text_submitted.connect(func(_t: String) -> void: _on_verify_pressed())
	manifest_label.text = "Select an evidence file to view its manifest MD5."
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
	feedback_label.text = "Evidence integrity verified: MD5 values match the manifest."
	verify_button.disabled = true
	hash_input.editable = false
	for i: int in range(evidence_list.item_count):
		evidence_list.set_item_disabled(i, true)
	evidence_list.mouse_filter = Control.MOUSE_FILTER_IGNORE

func on_solve_failed() -> void:
	feedback_label.text = "Hash mismatch. Check the selected file and manifest value."

func _on_evidence_selected(index: int) -> void:
	_selected_file = str(evidence_list.get_item_metadata(index))
	_expected_hash = _calculate_md5(str(EVIDENCE_CONTENTS[_selected_file]))
	manifest_label.text = "Evidence_Manifest.txt | %s | MD5: %s" % [_selected_file, _expected_hash]
	hash_input.text = _expected_hash
	feedback_label.text = "คำนวณค่า MD5 ของไฟล์ %s แล้ว กด Verify MD5 เพื่อเทียบกับ Manifest" % _selected_file

func _on_verify_pressed() -> void:
	submit_puzzle(hash_input.text)

func _calculate_md5(content: String) -> String:
	var context: HashingContext = HashingContext.new()
	var error: Error = context.start(HashingContext.HASH_MD5)
	if error != OK:
		push_error("Unable to start MD5 hash context: %d" % error)
		return ""
	context.update(content.to_utf8_buffer())
	return context.finish().hex_encode()
