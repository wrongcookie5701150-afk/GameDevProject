extends BasePuzzleUI

@onready var wifi_check: CheckBox = $Panel/Content/WifiCheck
@onready var lan_check: CheckBox = $Panel/Content/LanCheck
@onready var accounts_check: CheckBox = $Panel/Content/AccountsCheck
@onready var files_check: CheckBox = $Panel/Content/FilesCheck
@onready var submit_button: Button = $Panel/Content/SubmitButton
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

func _ready() -> void:
	super._ready()
	submit_button.pressed.connect(_on_submit_pressed)

func validate_answer(answer: Variant) -> bool:
	if not answer is Dictionary:
		return false
	return bool(answer.get("wifi_disabled", false)) \
		and bool(answer.get("lan_unplugged", false)) \
		and bool(answer.get("personal_accounts_unlinked", false)) \
		and bool(answer.get("no_important_files", false))

func get_submission_metrics() -> Dictionary:
	return _checklist_values()

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: IncidentTelemetryParam = IncidentTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "isolation_checklist_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.wifi_disabled = bool(metrics.get("wifi_disabled", false))
	param.lan_unplugged = bool(metrics.get("lan_unplugged", false))
	param.personal_accounts_unlinked = bool(metrics.get("personal_accounts_unlinked", false))
	param.no_important_files = bool(metrics.get("no_important_files", false))
	param.sync_metrics()
	return param

func on_solve_success() -> void:
	feedback_label.text = "TaoDam is isolated and ready for evidence review."
	_set_checklist_enabled(false)
	submit_button.hide()

func on_solve_failed() -> void:
	feedback_label.text = "Verify all four isolation conditions before continuing."

func _on_submit_pressed() -> void:
	submit_puzzle(_checklist_values())

func _checklist_values() -> Dictionary:
	return {
		"wifi_disabled": wifi_check.button_pressed,
		"lan_unplugged": lan_check.button_pressed,
		"personal_accounts_unlinked": accounts_check.button_pressed,
		"no_important_files": files_check.button_pressed
	}

func _set_checklist_enabled(enabled: bool) -> void:
	wifi_check.disabled = not enabled
	lan_check.disabled = not enabled
	accounts_check.disabled = not enabled
	files_check.disabled = not enabled
