extends Node

signal telemetry_sent(payload: Dictionary)
signal telemetry_failed(payload: Dictionary, error: int, response_code: int)
signal adaptive_gameplay_updated(cluster_name: String, hint_enabled: bool, difficulty_multiplier: float)

const BACKEND_URL: String = "http://127.0.0.1:8000/api/v1/telemetry/event"

const SCENARIO_MAPPING: Dictionary = {
	"T01": "Scenario_1",
	"T02": "Scenario_1",
	"T03": "Scenario_1",
	"T04": "Scenario_1",
	"T05": "Scenario_1",
	"T06": "Scenario_2",
	"T07": "Scenario_2",
	"T08": "Scenario_2",
	"T09": "Scenario_2",
	"T10": "Scenario_2",
	"T11": "Scenario_2",
	"T12": "Scenario_3",
	"T13": "Scenario_3",
	"T14": "Scenario_4",
	"T15": "Scenario_4",
	"Task_04": "Scenario_1",
	"Task_06": "Scenario_2",
	"Task_07": "Scenario_2",
	"Task_08": "Scenario_2",
	"Task_11": "Scenario_2",
	"Task_13": "Scenario_2",
	"Task_14": "Scenario_3",
	"Task_15": "Scenario_3",
	"Task_16": "Scenario_4"
}

var player_id: String = "player_test_01"
var session_id: String = ""
var current_player_cluster: String = "Beginner"
var is_adaptive_hint_enabled: bool = false
var current_difficulty_multiplier: float = 1.0
var active_timers: Dictionary = {}
var puzzle_submission_history: Array[Dictionary] = []
var pretest_score: int = -1
var posttest_score: int = -1
var session_task_records: Dictionary = {}

var _network_adapter: TelemetryNetworkAdapter

func _ready() -> void:
	session_id = _generate_uuid()
	_network_adapter = TelemetryNetworkAdapter.new()
	add_child(_network_adapter)
	_network_adapter.request_completed.connect(_on_request_completed)
	_network_adapter.request_failed.connect(_on_request_failed)

func start_task_timer(task_id: String) -> void:
	active_timers[task_id] = Time.get_ticks_msec()

func stop_task_timer(task_id: String) -> float:
	if not active_timers.has(task_id):
		return 0.0
	var start_time: int = int(active_timers[task_id])
	active_timers.erase(task_id)
	return float(Time.get_ticks_msec() - start_time) / 1000.0

func get_scenario_for_task(task_id: String) -> String:
	return SCENARIO_MAPPING.get(task_id, "Scenario_Unknown")

func track_event(
	scene_id: String,
	task_id: String,
	event_type: String,
	duration_seconds: float = 0.0,
	is_correct: Variant = null,
	attempt_count: int = 1,
	hint_used: bool = false,
	metrics: Dictionary = {}
) -> void:
	if not metrics.has("scenario_id") and not task_id.is_empty():
		metrics["scenario_id"] = get_scenario_for_task(task_id)

	var payload: Dictionary = {
		"session_id": session_id,
		"player_id": player_id,
		"scene_id": scene_id,
		"task_id": task_id,
		"event_type": event_type,
		"timestamp": Time.get_datetime_string_from_system(true),
		"duration_seconds": maxf(0.0, duration_seconds),
		"is_correct": is_correct,
		"attempt_count": maxi(1, attempt_count),
		"hint_used": hint_used,
		"metrics": metrics
	}
	if not task_id.is_empty():
		session_task_records[task_id] = payload

	if metrics.has("pretest_score"):
		pretest_score = int(metrics.get("pretest_score", -1))
		if pretest_score >= 0:
			if pretest_score < 7:
				current_player_cluster = "Beginner"
				is_adaptive_hint_enabled = true
				current_difficulty_multiplier = 0.8
			else:
				current_player_cluster = "Expert"
				is_adaptive_hint_enabled = false
				current_difficulty_multiplier = 1.0
			adaptive_gameplay_updated.emit(
				current_player_cluster,
				is_adaptive_hint_enabled,
				current_difficulty_multiplier
			)

	if metrics.has("posttest_score"):
		posttest_score = int(metrics.get("posttest_score", -1))

	_save_local_log(payload)
	_network_adapter.send_event(BACKEND_URL, payload)

func _save_local_log(payload: Dictionary) -> void:
	# 1. Append JSON Line to user://scenario_game_logs.json
	var json_file := FileAccess.open("user://scenario_game_logs.json", FileAccess.READ_WRITE if FileAccess.file_exists("user://scenario_game_logs.json") else FileAccess.WRITE)
	if json_file:
		json_file.seek_end()
		json_file.store_line(JSON.stringify(payload))
		json_file.close()

	# 2. Append CSV line to user://scenario_game_summary.csv
	var csv_exists := FileAccess.file_exists("user://scenario_game_summary.csv")
	var csv_file := FileAccess.open("user://scenario_game_summary.csv", FileAccess.READ_WRITE if csv_exists else FileAccess.WRITE)
	if csv_file:
		if not csv_exists:
			csv_file.store_line("timestamp,session_id,player_id,scenario_id,task_id,attempt_count,hint_used,analysis_time_seconds,decision_time_seconds,total_duration_seconds,is_correct")
		csv_file.seek_end()
		var metrics: Dictionary = payload.get("metrics", {})
		var analysis_sec: float = float(metrics.get("analysis_time_seconds", 0.0))
		var decision_sec: float = float(metrics.get("decision_time_seconds", float(payload.get("duration_seconds", 0.0))))
		var total_sec: float = float(payload.get("duration_seconds", 0.0))
		var row: String = "%s,%s,%s,%s,%s,%d,%s,%.2f,%.2f,%.2f,%s" % [
			str(payload.get("timestamp", "")),
			str(payload.get("session_id", "")),
			str(payload.get("player_id", "")),
			str(metrics.get("scenario_id", get_scenario_for_task(str(payload.get("task_id", ""))))),
			str(payload.get("task_id", "")),
			int(payload.get("attempt_count", 1)),
			str(payload.get("hint_used", false)),
			analysis_sec,
			decision_sec,
			total_sec,
			str(payload.get("is_correct", ""))
		]
		csv_file.store_line(row)
		csv_file.close()

func track_quick_event(scene_id: String, event_type: String, metrics: Dictionary = {}) -> void:
	track_event(scene_id, "", event_type, 0.0, null, 1, false, metrics)

func track_param(param: BaseTelemetryParam) -> void:
	if param.event_type == "puzzle_submitted":
		puzzle_submission_history.append(param.to_dictionary())
	track_event(
		param.scene_id,
		param.task_id,
		param.event_type,
		param.duration_seconds,
		param.is_correct,
		param.attempt_count,
		param.hint_used,
		param.metrics
	)

func get_assessment_summary() -> Dictionary:
	var attempted_tasks: Dictionary = {}
	var completed_tasks: Dictionary = {}
	var attempt_count: int = puzzle_submission_history.size()
	var hints_used: int = 0
	for submission: Dictionary in puzzle_submission_history:
		var task_id: String = str(submission.get("task_id", ""))
		if not task_id.is_empty():
			attempted_tasks[task_id] = true
			if bool(submission.get("is_correct", false)):
				completed_tasks[task_id] = true
		if bool(submission.get("hint_used", false)):
			hints_used += 1
	var task_count: int = attempted_tasks.size()
	var completed_count: int = completed_tasks.size()
	var knowledge_score: int = 0
	if task_count > 0:
		knowledge_score = roundi(100.0 * float(completed_count) / float(task_count))
	var extra_attempts: int = maxi(0, attempt_count - task_count)
	var skills_score: int = clampi(100 - extra_attempts * 8 - hints_used * 12, 0, 100)
	var attitude_score: int = 100
	if not completed_tasks.has("T13") or not completed_tasks.has("T14"):
		attitude_score = 0

	# สมรรถนะ 3 ด้านตรงตามบทคัดย่องานวิจัย (Abstract Competencies)
	var cause_tasks: Array[String] = ["T04", "T05", "T06", "T07", "T08", "T09", "T10", "T11"]
	var problem_tasks: Array[String] = ["T12", "T13"]
	var prevention_tasks: Array[String] = ["T14", "T15"]

	var cause_completed: int = 0
	var cause_total: int = 0
	for t: String in cause_tasks:
		if attempted_tasks.has(t):
			cause_total += 1
			if completed_tasks.has(t):
				cause_completed += 1
	var cause_analysis_score: int = roundi(100.0 * float(cause_completed) / float(maxi(1, cause_total))) if cause_total > 0 else knowledge_score

	var prob_completed: int = 0
	var prob_total: int = 0
	for t: String in problem_tasks:
		if attempted_tasks.has(t):
			prob_total += 1
			if completed_tasks.has(t):
				prob_completed += 1
	var problem_solving_score: int = roundi(100.0 * float(prob_completed) / float(maxi(1, prob_total))) if prob_total > 0 else skills_score

	var prev_completed: int = 0
	var prev_total: int = 0
	for t: String in prevention_tasks:
		if attempted_tasks.has(t):
			prev_total += 1
			if completed_tasks.has(t):
				prev_completed += 1
	var prevention_score: int = roundi(100.0 * float(prev_completed) / float(maxi(1, prev_total))) if prev_total > 0 else attitude_score

	var valid_pre: int = maxi(0, pretest_score)
	var valid_post: int = maxi(0, posttest_score)
	var learning_gain: int = (posttest_score - pretest_score) if (pretest_score >= 0 and posttest_score >= 0) else 0

	return {
		"attempted_task_count": task_count,
		"completed_task_count": completed_count,
		"attempt_count": attempt_count,
		"hints_used": hints_used,
		"knowledge_score": knowledge_score,
		"skills_score": skills_score,
		"attitude_score": attitude_score,
		"cause_analysis_score": cause_analysis_score,
		"problem_solving_score": problem_solving_score,
		"prevention_score": prevention_score,
		"pretest_score": valid_pre,
		"posttest_score": valid_post,
		"learning_gain": learning_gain
	}

func _on_request_completed(response_code: int, response_data: Dictionary, payload: Dictionary) -> void:
	if response_code < 200 or response_code >= 300:
		telemetry_failed.emit(payload, OK, response_code)
		return

	telemetry_sent.emit(payload)
	current_player_cluster = str(response_data.get("assigned_cluster", current_player_cluster))
	is_adaptive_hint_enabled = bool(response_data.get("adaptive_hint_enabled", is_adaptive_hint_enabled))
	current_difficulty_multiplier = float(response_data.get("difficulty_multiplier", current_difficulty_multiplier))
	adaptive_gameplay_updated.emit(
		current_player_cluster,
		is_adaptive_hint_enabled,
		current_difficulty_multiplier
	)

func _on_request_failed(error: int, payload: Dictionary) -> void:
	telemetry_failed.emit(payload, error, 0)

func _generate_uuid() -> String:
	var bytes: PackedByteArray = PackedByteArray()
	for _index: int in range(16):
		bytes.append(randi() % 256)
	bytes[6] = (bytes[6] & 0x0f) | 0x40
	bytes[8] = (bytes[8] & 0x3f) | 0x80
	var hex: String = bytes.hex_encode()
	return "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12)
	]
