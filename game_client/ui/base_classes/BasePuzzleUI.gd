class_name BasePuzzleUI
extends Control

signal puzzle_submitted(is_correct: bool, attempt_count: int)
signal puzzle_resolved

@export var scene_id: String = ""
@export var task_id: StringName
@export var puzzle_id: StringName
@export var hint_delay_seconds: float = 5.0

var attempt_count: int = 0
var is_resolved: bool = false
var hint_used: bool = false
var _task_started: bool = false

func _ready() -> void:
	if visible:
		start_puzzle()

func start_puzzle() -> void:
	if _task_started or is_resolved:
		return
	if not String(task_id).is_empty():
		TelemetryManager.start_task_timer(String(task_id))
		_task_started = true

func submit_puzzle(answer: Variant) -> void:
	if is_resolved:
		return

	attempt_count += 1
	var is_correct: bool = validate_answer(answer)
	var duration_seconds: float = 0.0
	if _task_started:
		duration_seconds = TelemetryManager.stop_task_timer(String(task_id))
		_task_started = false

	var metrics: Dictionary = {}
	metrics.merge(get_submission_metrics(), true)
	if not String(puzzle_id).is_empty():
		metrics["puzzle_id"] = String(puzzle_id)
	TelemetryManager.track_param(_build_telemetry_param(is_correct, duration_seconds, metrics))
	puzzle_submitted.emit(is_correct, attempt_count)

	if is_correct:
		is_resolved = true
		puzzle_resolved.emit()
		on_solve_success()
	else:
		on_solve_failed()
		if not String(task_id).is_empty():
			TelemetryManager.start_task_timer(String(task_id))
			_task_started = true

func validate_answer(_answer: Variant) -> bool:
	return false

func get_submission_metrics() -> Dictionary:
	return {}

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: BaseTelemetryParam = BaseTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "puzzle_submitted"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.metrics = metrics.duplicate(true)
	return param

func on_solve_success() -> void:
	pass

func on_solve_failed() -> void:
	pass
