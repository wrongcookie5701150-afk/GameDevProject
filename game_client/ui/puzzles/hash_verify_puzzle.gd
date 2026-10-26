extends BaseDecoderPuzzle

const EVIDENCE_CONTENTS: Dictionary = {
	"Report_Final.docx": "forensic evidence sample: Report_Final.docx; read-only copy",
	"Windows_Event_Log.txt": "forensic evidence sample: event log copied from TaoDam",
	"Drive_Activity.log": "forensic evidence sample: shared drive activity history"
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
	manifest_label.text = "Select an evidence file to view its manifest MD5."

func validate_answer(answer: Variant) -> bool:
	_match_status = not _selected_file.is_empty() \
		and str(answer).strip_edges().to_lower() == _expected_hash
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
	evidence_list.disabled = true

func on_solve_failed() -> void:
	feedback_label.text = "Hash mismatch. Check the selected file and manifest value."

func _on_evidence_selected(index: int) -> void:
	_selected_file = str(evidence_list.get_item_metadata(index))
	_expected_hash = _calculate_md5(str(EVIDENCE_CONTENTS[_selected_file]))
	manifest_label.text = "Evidence_Manifest.txt | %s | MD5: %s" % [_selected_file, _expected_hash]

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
