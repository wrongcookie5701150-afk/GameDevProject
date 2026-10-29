extends BasePuzzleUI

@onready var wifi_check: CheckBox = find_child("WifiCheck", true, false) as CheckBox
@onready var lan_check: CheckBox = find_child("LanCheck", true, false) as CheckBox
@onready var accounts_check: CheckBox = find_child("AccountsCheck", true, false) as CheckBox
@onready var files_check: CheckBox = find_child("FilesCheck", true, false) as CheckBox
@onready var submit_button: Button = find_child("SubmitButton", true, false) as Button
@onready var feedback_label: Label = find_child("FeedbackLabel", true, false) as Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var task_obj: Control = find_child("TaskObjective", true, false) as Control
	if task_obj:
		task_obj.mouse_filter = Control.MOUSE_FILTER_IGNORE
	super._ready()
	_resolve_nodes()
	_setup_automated_checks()
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)

func _resolve_nodes() -> void:
	if not wifi_check:
		wifi_check = find_child("WifiCheck", true, false) as CheckBox
	if not lan_check:
		lan_check = find_child("LanCheck", true, false) as CheckBox
	if not accounts_check:
		accounts_check = find_child("AccountsCheck", true, false) as CheckBox
	if not files_check:
		files_check = find_child("FilesCheck", true, false) as CheckBox
	if not submit_button:
		submit_button = find_child("SubmitButton", true, false) as Button
	if not feedback_label:
		feedback_label = find_child("FeedbackLabel", true, false) as Label

func _setup_automated_checks() -> void:
	for cb: CheckBox in [wifi_check, lan_check, accounts_check, files_check]:
		if cb:
			# Automated: read-only to player mouse clicks, toggled by game system detection
			cb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cb.focus_mode = Control.FOCUS_NONE

func start_puzzle() -> void:
	super.start_puzzle()
	_resolve_nodes()
	_setup_automated_checks()

func update_condition(condition_key: String, value: bool) -> void:
	_resolve_nodes()
	match condition_key:
		"wifi_disabled":
			if wifi_check:
				wifi_check.button_pressed = value
		"lan_unplugged":
			if lan_check:
				lan_check.button_pressed = value
		"personal_accounts_unlinked":
			if accounts_check:
				accounts_check.button_pressed = value
		"no_important_files":
			if files_check:
				files_check.button_pressed = value
	
	if is_all_conditions_met() and not is_resolved:
		submit_puzzle(_checklist_values())

func is_all_conditions_met() -> bool:
	var vals: Dictionary = _checklist_values()
	return bool(vals.get("wifi_disabled", false)) \
		and bool(vals.get("lan_unplugged", false)) \
		and bool(vals.get("personal_accounts_unlinked", false)) \
		and bool(vals.get("no_important_files", false))

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
	if feedback_label:
		feedback_label.text = "TaoDam is isolated and ready for evidence review."
	_set_checklist_enabled(false)
	if submit_button:
		submit_button.hide()

func on_solve_failed() -> void:
	if feedback_label:
		feedback_label.text = "Verify all four isolation conditions before continuing."

func _on_submit_pressed() -> void:
	submit_puzzle(_checklist_values())

func _checklist_values() -> Dictionary:
	_resolve_nodes()
	return {
		"wifi_disabled": wifi_check.button_pressed if wifi_check else false,
		"lan_unplugged": lan_check.button_pressed if lan_check else false,
		"personal_accounts_unlinked": accounts_check.button_pressed if accounts_check else false,
		"no_important_files": files_check.button_pressed if files_check else false
	}

func _set_checklist_enabled(enabled: bool) -> void:
	if wifi_check:
		wifi_check.disabled = not enabled
	if lan_check:
		lan_check.disabled = not enabled
	if accounts_check:
		accounts_check.disabled = not enabled
	if files_check:
		files_check.disabled = not enabled
