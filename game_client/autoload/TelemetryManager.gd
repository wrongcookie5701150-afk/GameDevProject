extends Node

signal telemetry_sent(payload: Dictionary)
signal telemetry_failed(payload: Dictionary, error: int, response_code: int)
signal adaptive_gameplay_updated(cluster_name: String, hint_enabled: bool, difficulty_multiplier: float)

const BACKEND_URL: String = "http://127.0.0.1:8000/api/v1/telemetry/event"

var player_id: String = "player_test_01"
var session_id: String = ""
var current_player_cluster: String = "Beginner"
var is_adaptive_hint_enabled: bool = false
var current_difficulty_multiplier: float = 1.0
var active_timers: Dictionary = {}

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
		"duration_seconds": maxf(0.0, duration_seconds),
		"is_correct": is_correct,
		"attempt_count": maxi(1, attempt_count),
		"hint_used": hint_used,
		"metrics": metrics
	}
	_network_adapter.send_event(BACKEND_URL, payload)

func track_quick_event(scene_id: String, event_type: String, metrics: Dictionary = {}) -> void:
	track_event(scene_id, "", event_type, 0.0, null, 1, false, metrics)

func track_param(param: BaseTelemetryParam) -> void:
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
