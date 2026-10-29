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
	feedback_label.text = "✅ หยุดการทำงานของ Persistence และกักกันมัลแวร์ครบทั้ง 7 ขั้นตอนเรียบร้อย!"
	step_selector.disabled = true
	add_button.disabled = true
	remove_button.disabled = true
	submit_button.hide()

func on_solve_failed() -> void:
	if submitted_steps.size() < CORRECT_SEQUENCE.size():
		var next_idx: int = submitted_steps.size()
		var expected_label: String = str(STEP_LABELS.get(CORRECT_SEQUENCE[next_idx], ""))
		feedback_label.text = "⚠️ กรุณาเพิ่มให้ครบทั้ง 7 ขั้นตอน (ตอนนี้มี %d/7 | ขั้นตอนที่ %d ควรเป็น: %s)" % [
			submitted_steps.size(), next_idx + 1, expected_label
		]
		return
	for idx: int in range(CORRECT_SEQUENCE.size()):
		if str(submitted_steps[idx]) != CORRECT_SEQUENCE[idx]:
			var expected_step: String = str(STEP_LABELS.get(CORRECT_SEQUENCE[idx], ""))
			feedback_label.text = "❌ ขั้นตอนที่ %d ยังไม่ถูกต้อง: ควรเป็น '%s' (กดปุ่มลบขั้นตอนเพื่อแก้ไข)" % [
				idx + 1, expected_step
			]
			return
	feedback_label.text = "Sequence is unsafe. Contain the helper before restoring files."

func _advance_selector_to_next_unused() -> void:
	for idx: int in range(step_selector.item_count):
		var step_id: String = str(step_selector.get_item_metadata(idx))
		if not submitted_steps.has(step_id):
			step_selector.select(idx)
			return

func _on_add_pressed() -> void:
	if submitted_steps.size() >= CORRECT_SEQUENCE.size():
		feedback_label.text = "เพิ่มครบ 7 ขั้นตอนแล้ว กดปุ่ม Submit ด้านล่างเพื่อยืนยัน"
		return
	var step_id: String = str(step_selector.get_item_metadata(step_selector.selected))
	if submitted_steps.has(step_id):
		_advance_selector_to_next_unused()
		step_id = str(step_selector.get_item_metadata(step_selector.selected))
		if submitted_steps.has(step_id):
			return
	submitted_steps.append(step_id)
	sequence_list.add_item("%d. %s" % [submitted_steps.size(), STEP_LABELS[step_id]])
	_advance_selector_to_next_unused()
	if submitted_steps.size() == CORRECT_SEQUENCE.size():
		feedback_label.text = "ครบทั้ง 7 ขั้นตอนแล้ว กดปุ่ม Submit เพื่อตรวจสอบความถูกต้อง"
	else:
		feedback_label.text = "เพิ่มขั้นตอนที่ %d/7 แล้ว" % submitted_steps.size()

func _on_remove_pressed() -> void:
	if submitted_steps.is_empty():
		return
	var removed_id: String = submitted_steps.pop_back()
	sequence_list.remove_item(sequence_list.item_count - 1)
	for idx: int in range(step_selector.item_count):
		if str(step_selector.get_item_metadata(idx)) == removed_id:
			step_selector.select(idx)
			break
	feedback_label.text = "ลบขั้นตอนล่าสุดแล้ว (เหลือ %d/7 ขั้นตอน)" % submitted_steps.size()

func _on_submit_pressed() -> void:
	submit_sequence(submitted_steps)
