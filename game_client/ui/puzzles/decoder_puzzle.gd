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

func validate_answer(answer: Variant) -> bool:
	var submitted_value: String = str(answer).strip_edges()
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
		feedback_label.text = "Decoded: %s. The helper file was created after active content was enabled." % _decoded_output
		decode_stage = 1
		is_resolved = false
		attempt_count = 0
		hint_used = false
		await get_tree().process_frame
		task_id = &"T11"
		puzzle_id = &"P06"
		start_puzzle()
		_refresh_stage()
		return

	_decoded_mode = "FILE_WIPE"
	feedback_label.text = "Wiper mode confirmed: %s. The payload destroys project files." % _decoded_mode
	answer_input.editable = false
	submit_button.hide()
	hint_button.hide()
	all_decoding_complete.emit()

func on_solve_failed() -> void:
	feedback_label.text = "That decoded value does not match the expected tool output. Try again."

func _on_submit_pressed() -> void:
	if decode_stage == 0:
		_decoded_output = answer_input.text.strip_edges()
	else:
		_decoded_mode = answer_input.text.strip_edges().to_upper()
	set_forensic_metrics(get_submission_metrics())
	submit_puzzle(answer_input.text)

func _on_hint_pressed() -> void:
	hint_used = true
	if decode_stage == 0:
		feedback_label.text = "Hint: Base64 often uses letters, digits, and trailing '=' padding."
	else:
		feedback_label.text = "Hint: Hex decodes to a Base64 string; decode that result too."

func _refresh_stage() -> void:
	answer_input.clear()
	if decode_stage == 0:
		title_label.text = "T10 / P05: Decode the helper name"
		instruction_label.text = "Decode this Base64 value."
		encoded_label.text = HELPER_BASE64
	else:
		title_label.text = "T11 / P06: Decode the helper mode"
		instruction_label.text = "Decode the hex to Base64, then decode the Base64 output. Enter the final mode."
		encoded_label.text = "TARGET: UHJvamVjdF9Gb2xkZXI=\nMODE (hex): %s" % MODE_HEX
	feedback_label.text = ""
