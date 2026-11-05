class_name TypingGamePuzzle
extends BasePuzzleUI

signal scene_completion_requested

const TARGET_TEXT: String = "Cybersecurity protects people systems and information from malicious software and unsafe attachments."

@onready var passage_label: RichTextLabel = get_node_or_null("PassageLabel") as RichTextLabel
@onready var feedback_label: Label = get_node_or_null("FeedbackLabel") as Label

var answer_input: TextEdit
var _started_at_msec: int = 0
var _last_accuracy: float = 0.0
var _last_wpm: float = 0.0

func _ready() -> void:
	super._ready()
	if not passage_label:
		passage_label = find_child("PassageLabel", true, false) as RichTextLabel
	if not feedback_label:
		feedback_label = find_child("FeedbackLabel", true, false) as Label
	if feedback_label:
		feedback_label.hide()
	if passage_label:
		passage_label.bbcode_enabled = true
		_update_passage_display("")

func configure_input(input: TextEdit) -> void:
	answer_input = input
	if not answer_input.text_changed.is_connected(_on_answer_changed):
		answer_input.text_changed.connect(_on_answer_changed)

func start_puzzle() -> void:
	super.start_puzzle()
	if _started_at_msec == 0:
		_started_at_msec = Time.get_ticks_msec()
	if passage_label:
		passage_label.bbcode_enabled = true
		_update_passage_display("")
	if answer_input:
		answer_input.text = ""
		answer_input.editable = true
		answer_input.grab_focus()

func validate_answer(answer: Variant) -> bool:
	if not answer is String:
		return false
	return _normalize_text(answer) == _normalize_text(TARGET_TEXT) and _last_accuracy >= 90.0

func get_submission_metrics() -> Dictionary:
	var text: String = answer_input.text if answer_input else TARGET_TEXT
	_calculate_metrics(text)
	return {
		"puzzle_id": "P00",
		"wpm": _last_wpm,
		"accuracy": _last_accuracy,
		"word_count": _word_count(text)
	}

func on_solve_success() -> void:
	if feedback_label:
		feedback_label.text = "Complete. WPM: %.1f | Accuracy: %.1f%%" % [_last_wpm, _last_accuracy]
	if answer_input:
		answer_input.editable = false
	scene_completion_requested.emit()

func on_solve_failed() -> void:
	if feedback_label:
		feedback_label.text = "Keep typing the passage."

func _on_answer_changed() -> void:
	if is_resolved:
		return

	var typed_text: String = answer_input.text if answer_input else ""
	_calculate_metrics(typed_text)
	_update_passage_display(typed_text)
	
	if feedback_label:
		feedback_label.text = ""

	if _first_mismatch_index(typed_text) == -1 and typed_text.length() == TARGET_TEXT.length():
		submit_puzzle(typed_text)

func _update_passage_display(typed_text: String) -> void:
	if not passage_label:
		return
	passage_label.bbcode_enabled = true
	
	var bb: String = ""
	var target_len: int = TARGET_TEXT.length()
	var typed_len: int = typed_text.length()
	
	for i: int in range(target_len):
		var target_char: String = TARGET_TEXT[i]
		if i < typed_len:
			var typed_char: String = typed_text[i]
			if typed_char == target_char or typed_char.to_lower() == target_char.to_lower():
				bb += "[color=black]%s[/color]" % target_char
			else:
				if target_char == " ":
					bb += "[color=red]_[/color]"
				else:
					bb += "[color=red]%s[/color]" % target_char
		else:
			bb += "[color=#888888]%s[/color]" % target_char
			
	if typed_len > target_len:
		var extra: String = typed_text.substr(target_len)
		bb += "[color=red]%s[/color]" % extra
		
	passage_label.text = bb

func _first_mismatch_index(typed_text: String) -> int:
	var shared_length: int = mini(typed_text.length(), TARGET_TEXT.length())
	for index: int in range(shared_length):
		if typed_text[index].to_lower() != TARGET_TEXT[index].to_lower():
			return index
	if typed_text.length() != TARGET_TEXT.length():
		return shared_length
	return -1

func _calculate_metrics(typed_text: String) -> void:
	var elapsed_msec: int = Time.get_ticks_msec() - _started_at_msec
	var elapsed_seconds: float = maxf(1.0, float(elapsed_msec) / 1000.0)
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
