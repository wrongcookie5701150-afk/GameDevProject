extends BaseSequencePuzzle

const CORRECT_SEQUENCE: Array[String] = [
	"safe_mode",
	"disable_task",
	"quarantine_helper",
	"check_persistence",
	"confirm_stopped",
	"pause_cloud_sync",
	"restore_backup"
]

const STEP_LABELS: Dictionary = {
	"safe_mode": "Start TaoDam in Safe Mode",
	"disable_task": "Disable the Office_Update_Helper scheduled task",
	"quarantine_helper": "Quarantine Office_Update_Helper.dat",
	"check_persistence": "Check and remove the persistence entry",
	"confirm_stopped": "Confirm the helper cannot restart",
	"pause_cloud_sync": "Keep cloud sync paused",
	"restore_backup": "Restore only from a verified clean backup"
}

@onready var step_selector: OptionButton = $Panel/Content/StepSelector
@onready var sequence_list: ItemList = $Panel/Content/SequenceList
@onready var add_button: Button = $Panel/Content/AddButton
@onready var remove_button: Button = $Panel/Content/RemoveButton
@onready var submit_button: Button = $Panel/Content/SubmitButton
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

func _ready() -> void:
	super._ready()
	for step_id: String in CORRECT_SEQUENCE:
		# แก้ไขตรงนี้: เรียก add_item ก่อน แล้วค่อยดึง Index ล่าสุดด้วย get_item_count() - 1
		step_selector.add_item(STEP_LABELS[step_id])
		var index: int = step_selector.get_item_count() - 1
		step_selector.set_item_metadata(index, step_id)
		
	add_button.pressed.connect(_on_add_pressed)
	remove_button.pressed.connect(_on_remove_pressed)
	submit_button.pressed.connect(_on_submit_pressed)

func validate_answer(answer: Variant) -> bool:
	if not answer is Array:
		return false
	var submitted_steps: Array = answer
	if submitted_steps.size() != CORRECT_SEQUENCE.size():
		return false
	for index: int in range(CORRECT_SEQUENCE.size()):
		if str(submitted_steps[index]) != CORRECT_SEQUENCE[index]:
			return false
	return true

func on_solve_success() -> void:
	feedback_label.text = "Persistence is stopped. Keep sync paused until clean recovery is ready."
	step_selector.disabled = true
	add_button.disabled = true
	remove_button.disabled = true
	submit_button.hide()

func on_solve_failed() -> void:
	feedback_label.text = "Sequence is unsafe. Contain the helper before restoring files."

func _on_add_pressed() -> void:
	if submitted_steps.size() >= CORRECT_SEQUENCE.size():
		return
	var step_id: String = str(step_selector.get_item_metadata(step_selector.selected))
	if submitted_steps.has(step_id):
		return
	submitted_steps.append(step_id)
	sequence_list.add_item("%d. %s" % [submitted_steps.size(), STEP_LABELS[step_id]])

func _on_remove_pressed() -> void:
	if submitted_steps.is_empty():
		return
	submitted_steps.pop_back()
	sequence_list.remove_item(sequence_list.item_count - 1)

func _on_submit_pressed() -> void:
	submit_sequence(submitted_steps)
