class_name BaseTelemetryParam
extends RefCounted

var scene_id: String = ""
var task_id: String = ""
var event_type: String = ""
var duration_seconds: float = 0.0
var is_correct: Variant = null
var attempt_count: int = 1
var hint_used: bool = false
var metrics: Dictionary = {}

func to_dictionary() -> Dictionary:
	return {
		"scene_id": scene_id,
		"task_id": task_id,
		"event_type": event_type,
		"duration_seconds": duration_seconds,
		"is_correct": is_correct,
		"attempt_count": attempt_count,
		"hint_used": hint_used,
		"metrics": metrics.duplicate(true)
	}
