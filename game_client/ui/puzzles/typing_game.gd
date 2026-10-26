class_name TypingGamePuzzle
extends BasePuzzleUI

signal scene_completion_requested

const TARGET_TEXT: String = "Cybersecurity protects people systems and information from malicious software and unsafe attachments."

@onready var passage_label: Label = $Panel/Content/PassageLabel
@onready var answer_input: TextEdit = $Panel/Content/AnswerInput
@onready var submit_button: Button = $Panel/Content/SubmitButton
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel
@onready var complete_button: Button = $Panel/Content/CompleteButton

var _started_at_msec: int = 0
var _last_accuracy: float = 0.0
var _last_wpm: float = 0.0

func _ready() -> void:
	super._ready()
	_started_at_msec = Time.get_ticks_msec()
	passage_label.text = TARGET_TEXT
	submit_button.pressed.connect(_on_submit_pressed)
	complete_button.pressed.connect(_on_complete_pressed)
	complete_button.hide()

func validate_answer(answer: Variant) -> bool:
	if not answer is String:
		return false
	return _normalize_text(answer) == _normalize_text(TARGET_TEXT) and _last_accuracy >= 90.0

func get_submission_metrics() -> Dictionary:
	_calculate_metrics(answer_input.text)
	return {
		"puzzle_id": "P00",
		"wpm": _last_wpm,
		"accuracy": _last_accuracy,
		"word_count": _word_count(answer_input.text)
	}

func on_solve_success() -> void:
	feedback_label.text = "Complete. WPM: %.1f | Accuracy: %.1f%%" % [_last_wpm, _last_accuracy]
	answer_input.editable = false
	submit_button.hide()
	complete_button.show()

func on_solve_failed() -> void:
	feedback_label.text = "Keep typing the passage accurately, then submit again. Accuracy: %.1f%%" % _last_accuracy

func _on_submit_pressed() -> void:
	_calculate_metrics(answer_input.text)
	submit_puzzle(answer_input.text)

func _on_complete_pressed() -> void:
	scene_completion_requested.emit()

func _calculate_metrics(typed_text: String) -> void:
	var elapsed_seconds: float = maxf(1.0, float(Time.get_ticks_msec() - _started_at_msec) / 1000.0)
	var compare_length: int = maxi(typed_text.length(), TARGET_TEXT.length())
	var matching_characters: int = 0
	for index: int in range(mini(typed_text.length(), TARGET_TEXT.length())):
		if typed_text[index].to_lower() == TARGET_TEXT[index].to_lower():
			matching_characters += 1
	_last_accuracy = 100.0 * float(matching_characters) / float(maxi(1, compare_length))
	var matched_words: int = 0
	var typed_words: PackedStringArray = typed_text.strip_edges().split(" ", false)
	var target_words: PackedStringArray = TARGET_TEXT.split(" ", false)
	for index: int in range(mini(typed_words.size(), target_words.size())):
		if typed_words[index].to_lower() != target_words[index].to_lower():
			break
		matched_words += 1
	_last_wpm = float(matched_words) * 60.0 / elapsed_seconds

func _word_count(value: String) -> int:
	var words: PackedStringArray = value.strip_edges().split(" ", false)
	return words.size()

func _normalize_text(value: String) -> String:
	return " ".join(value.strip_edges().to_lower().split(" ", false))
