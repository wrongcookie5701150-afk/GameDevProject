class_name IncidentReportPuzzle
extends BasePuzzleUI

const CORRECT_SELECTIONS: Dictionary = {
	"entry": "macro_document",
	"payload": "ransomware_wiper",
	"mitigation": "isolated_network"
}

@onready var entry_selector: OptionButton = $Panel/Content/EntrySelector
@onready var payload_selector: OptionButton = $Panel/Content/PayloadSelector
@onready var mitigation_selector: OptionButton = $Panel/Content/MitigationSelector
@onready var submit_button: Button = $Panel/Content/SubmitButton
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

func _ready() -> void:
	super._ready()
	_add_options(entry_selector, [
		["Macro-enabled Word document", "macro_document"],
		["Removable media", "removable_media"],
		["Compromised cloud account", "cloud_account"]
	])
	_add_options(payload_selector, [
		["Ransomware / wiper", "ransomware_wiper"],
		["Credential stealer", "credential_stealer"],
		["Adware", "adware"]
	])
	_add_options(mitigation_selector, [
		["Isolated the affected network", "isolated_network"],
		["Reconnected devices to verify access", "reconnected_devices"],
		["Deleted the evidence immediately", "deleted_evidence"]
	])
	submit_button.pressed.connect(_on_submit_pressed)

func validate_answer(answer: Variant) -> bool:
	if not answer is Dictionary:
		return false
	var selections: Dictionary = answer
	return (
		str(selections.get("entry", "")) == str(CORRECT_SELECTIONS["entry"])
		and str(selections.get("payload", "")) == str(CORRECT_SELECTIONS["payload"])
		and str(selections.get("mitigation", "")) == str(CORRECT_SELECTIONS["mitigation"])
	)

func get_submission_metrics() -> Dictionary:
	var selections: Dictionary = _current_selections()
	var correct_count: int = 0
	for key: String in CORRECT_SELECTIONS:
		if str(selections.get(key, "")) == str(CORRECT_SELECTIONS[key]):
			correct_count += 1
	selections["conclusions_score"] = roundi(100.0 * float(correct_count) / float(CORRECT_SELECTIONS.size()))
	return selections

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
	param.assessment_type = "incident_report"
	param.sync_metrics()
	return param

func on_solve_success() -> void:
	feedback_label.text = "Incident report accepted."
	entry_selector.disabled = true
	payload_selector.disabled = true
	mitigation_selector.disabled = true
	submit_button.disabled = true

func on_solve_failed() -> void:
	feedback_label.text = "Review the evidence and containment actions, then try again."

func _on_submit_pressed() -> void:
	submit_puzzle(_current_selections())

func _current_selections() -> Dictionary:
	return {
		"entry": _selected_id(entry_selector),
		"payload": _selected_id(payload_selector),
		"mitigation": _selected_id(mitigation_selector)
	}

func _add_options(selector: OptionButton, options: Array) -> void:
	for option: Array in options:
		selector.add_item(str(option[0]))
		selector.set_item_metadata(selector.get_item_count() - 1, str(option[1]))
	selector.select(0)

func _selected_id(selector: OptionButton) -> String:
	if selector.selected < 0:
		return ""
	return str(selector.get_item_metadata(selector.selected))