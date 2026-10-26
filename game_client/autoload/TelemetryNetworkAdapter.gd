class_name TelemetryNetworkAdapter
extends Node

signal request_completed(response_code: int, response_data: Dictionary, payload: Dictionary)
signal request_failed(error: int, payload: Dictionary)

const REQUEST_TIMEOUT: float = 5.0

var _http_request: HTTPRequest
var _pending_requests: Array[Dictionary] = []
var _active_payload: Dictionary = {}
var _active_url: String = ""
var _request_active: bool = false

func _ready() -> void:
	_http_request = HTTPRequest.new()
	_http_request.timeout = REQUEST_TIMEOUT
	add_child(_http_request)
	_http_request.request_completed.connect(_on_http_request_completed)

func send_event(url: String, payload: Dictionary) -> void:
	_pending_requests.append({"url": url, "payload": payload.duplicate(true)})
	_send_next_request()

func _send_next_request() -> void:
	if _request_active or _pending_requests.is_empty():
		return

	var request: Dictionary = _pending_requests.pop_front()
	_active_url = str(request["url"])
	_active_payload = request["payload"] as Dictionary
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
		_send_next_request()
		return
	_request_active = true

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
		_send_next_request()
		return

	var response_data: Dictionary = {}
	var response_text: String = body.get_string_from_utf8()
	if not response_text.is_empty():
		var json: JSON = JSON.new()
		if json.parse(response_text) == OK and json.data is Dictionary:
			response_data = json.data
	request_completed.emit(response_code, response_data, completed_payload)
	_send_next_request()
