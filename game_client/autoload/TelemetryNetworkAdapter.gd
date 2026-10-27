class_name TelemetryNetworkAdapter
extends Node

signal request_completed(response_code: int, response_data: Dictionary, payload: Dictionary)
signal request_failed(error: int, payload: Dictionary)

const REQUEST_TIMEOUT: float = 5.0
const OFFLINE_QUEUE_PATH: String = "user://telemetry_queue.json"
const MAX_QUEUED_EVENTS: int = 500
const RETRY_INTERVAL_SECONDS: float = 15.0

var _http_request: HTTPRequest
var _pending_requests: Array[Dictionary] = []
var _active_payload: Dictionary = {}
var _active_url: String = ""
var _request_active: bool = false
var _retry_blocked: bool = false
var _retry_timer: Timer

func _ready() -> void:
	_http_request = HTTPRequest.new()
	_http_request.timeout = REQUEST_TIMEOUT
	add_child(_http_request)
	_http_request.request_completed.connect(_on_http_request_completed)
	_retry_timer = Timer.new()
	_retry_timer.wait_time = RETRY_INTERVAL_SECONDS
	_retry_timer.timeout.connect(_on_retry_timer_timeout)
	add_child(_retry_timer)
	_retry_timer.start()
	_load_offline_queue()
	_send_next_request()

func send_event(url: String, payload: Dictionary) -> void:
	_pending_requests.append({"url": url, "payload": payload.duplicate(true)})
	if _pending_requests.size() > MAX_QUEUED_EVENTS:
		_pending_requests.pop_front()
	_persist_queue()
	_retry_blocked = false
	_send_next_request()

func _on_http_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	var completed_payload: Dictionary = _active_payload
	_request_active = false
	_active_payload = {}

	if result != HTTPRequest.RESULT_SUCCESS:
		request_failed.emit(result, completed_payload)
		_retry_blocked = true
		return

	var response_data: Dictionary = {}
	var response_text: String = body.get_string_from_utf8()
	if not response_text.is_empty():
		var json: JSON = JSON.new()
		if json.parse(response_text) == OK and json.data is Dictionary:
			response_data = json.data
	request_completed.emit(response_code, response_data, completed_payload)
	if response_code >= 200 and response_code < 300:
		_pending_requests.pop_front()
		_persist_queue()
		_send_next_request()
	elif response_code == 0 or response_code == 408 or response_code == 429 or response_code >= 500:
		_retry_blocked = true
	else:
		_pending_requests.pop_front()
		_persist_queue()
		_send_next_request()

func _on_retry_timer_timeout() -> void:
	if not _pending_requests.is_empty():
		_retry_blocked = false
		_send_next_request()

func _load_offline_queue() -> void:
	if not FileAccess.file_exists(OFFLINE_QUEUE_PATH):
		return
	var file: FileAccess = FileAccess.open(OFFLINE_QUEUE_PATH, FileAccess.READ)
	if file == null:
		return
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK or not json.data is Array:
		return
	for entry: Variant in json.data:
		if entry is Dictionary and entry.get("payload") is Dictionary:
			_pending_requests.append(entry)
	if _pending_requests.size() > MAX_QUEUED_EVENTS:
		_pending_requests = _pending_requests.slice(-MAX_QUEUED_EVENTS)

func _persist_queue() -> void:
	var file: FileAccess = FileAccess.open(OFFLINE_QUEUE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_pending_requests))

func _send_next_request() -> void:
	if _request_active or _retry_blocked or _pending_requests.is_empty():
		return

	var request: Dictionary = _pending_requests[0]
	_active_url = str(request.get("url", ""))
	_active_payload = (request.get("payload", {}) as Dictionary).duplicate(true)
	var headers: PackedStringArray = ["Content-Type: application/json"]
	var error: Error = _http_request.request(
		_active_url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(_active_payload)
	)
	if error != OK:
		request_failed.emit(error, _active_payload)
		_active_payload = {}
		_retry_blocked = true
		return
	_request_active = true
