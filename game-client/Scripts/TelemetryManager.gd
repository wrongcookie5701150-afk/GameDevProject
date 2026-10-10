extends Node

## TelemetryManager.gd
## Autoload Singleton สำหรับ Godot Engine

signal adaptive_gameplay_updated(cluster_name: String, hint_enabled: bool, difficulty_multiplier: float)

const BACKEND_URL: String = "http://127.0.0.1:8000/api/v1/telemetry/event"
const REQUEST_TIMEOUT: float = 5.0

var player_id: String = "player_test_01"
var session_id: String = ""
var current_player_cluster: String = "Beginner"
var is_adaptive_hint_enabled: bool = false
var current_difficulty_multiplier: float = 1.0

var _task_start_times: Dictionary = {}
var _http_request: HTTPRequest

func _ready() -> void:
	session_id = _generate_uuid()
	_http_request = HTTPRequest.new()
	_http_request.timeout = REQUEST_TIMEOUT
	add_child(_http_request)
	_http_request.request_completed.connect(_on_http_request_completed)
	print("[TelemetryManager] Initialized. Session ID: ", session_id)

func start_task_timer(task_id: String) -> void:
	_task_start_times[task_id] = Time.get_ticks_msec()
	print("[TelemetryManager] Started timer for: ", task_id)

func stop_task_timer(task_id: String) -> float:
	if not _task_start_times.has(task_id):
		return 0.0
	var elapsed_msec: int = Time.get_ticks_msec() - _task_start_times[task_id]
	_task_start_times.erase(task_id)
	return float(elapsed_msec) / 1000.0

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
	var payload: Dictionary = {
		"session_id": session_id,
		"player_id": player_id,
		"scene_id": scene_id,
		"task_id": task_id,
		"event_type": event_type,
		"timestamp": Time.get_datetime_string_from_system(true),
		"duration_seconds": max(0.0, duration_seconds),
		"is_correct": is_correct,
		"attempt_count": attempt_count,
		"hint_used": hint_used,
		"metrics": metrics
	}
	_send_payload_to_backend(payload)

func _send_payload_to_backend(payload: Dictionary) -> void:
	var json_data: String = JSON.stringify(payload)
	var headers: PackedStringArray = ["Content-Type: application/json"]
	_http_request.request(BACKEND_URL, headers, HTTPClient.METHOD_POST, json_data)

func _on_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json: JSON = JSON.new()
		if json.parse(body.get_string_from_utf8()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			var res_data: Dictionary = json.data
			current_player_cluster = res_data.get("assigned_cluster", "Beginner")
			is_adaptive_hint_enabled = res_data.get("adaptive_hint_enabled", false)
			current_difficulty_multiplier = res_data.get("difficulty_multiplier", 1.0)
			adaptive_gameplay_updated.emit(
				current_player_cluster,
				is_adaptive_hint_enabled,
				current_difficulty_multiplier
			)

func _generate_uuid() -> String:
	var bytes: PackedByteArray = PackedByteArray()
	for i in range(16):
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