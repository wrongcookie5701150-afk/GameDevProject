class_name KsaEvaluation
extends BasePuzzleUI

@onready var results_label: Label = $Panel/Content/ResultsLabel
@onready var acknowledge_button: Button = $Panel/Content/AcknowledgeButton

func _ready() -> void:
	super._ready()
	acknowledge_button.pressed.connect(_on_acknowledge_pressed)
	_refresh_results()

func start_puzzle() -> void:
	super.start_puzzle()
	_refresh_results()

func validate_answer(answer: Variant) -> bool:
	return bool(answer)

func get_submission_metrics() -> Dictionary:
	var summary: Dictionary = TelemetryManager.get_assessment_summary()
	return {
		"knowledge_score": int(summary.get("knowledge_score", 0)),
		"skills_score": int(summary.get("skills_score", 0)),
		"attitude_score": int(summary.get("attitude_score", 0)),
		"cause_analysis_score": int(summary.get("cause_analysis_score", 0)),
		"problem_solving_score": int(summary.get("problem_solving_score", 0)),
		"prevention_score": int(summary.get("prevention_score", 0)),
		"attempt_count": int(summary.get("attempt_count", 0)),
		"hints_used": int(summary.get("hints_used", 0))
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
	param.assessment_type = "ksa_evaluation"
	param.sync_metrics()
	return param

func on_solve_success() -> void:
	acknowledge_button.disabled = true

func _on_acknowledge_pressed() -> void:
	submit_puzzle(true)

func _refresh_results() -> void:
	var summary: Dictionary = TelemetryManager.get_assessment_summary()
	results_label.text = (
		"=== ผลการประเมินทักษะการป้องกันภัยคุกคามไซเบอร์ (Abstract Competencies) ===\n"
		+ "1. การวิเคราะห์สาเหตุ (Cause Analysis): %d / 100\n"
		+ "2. การแก้ปัญหาและกู้คืน (Problem Solving): %d / 100\n"
		+ "3. การป้องกันแรนซัมแวร์ (Ransomware Prevention): %d / 100\n\n"
		+ "[KSA Scores] Knowledge: %d | Skills: %d | Attitude: %d\n"
		+ "ภารกิจที่สำเร็จ: %d/%d | จำนวนครั้งที่ทดลอง: %d | คำใบ้ที่ใช้: %d"
	) % [
		int(summary.get("cause_analysis_score", 0)),
		int(summary.get("problem_solving_score", 0)),
		int(summary.get("prevention_score", 0)),
		int(summary.get("knowledge_score", 0)),
		int(summary.get("skills_score", 0)),
		int(summary.get("attitude_score", 0)),
		int(summary.get("completed_task_count", 0)),
		int(summary.get("attempted_task_count", 0)),
		int(summary.get("attempt_count", 0)),
		int(summary.get("hints_used", 0))
	]
