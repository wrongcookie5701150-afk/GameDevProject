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
	hint_tier_1 = "ก่อนที่จะกู้คืนไฟล์ ต้องหยุดการทำงานของมัลแวร์และวงจรฝังตัว (Persistence) ให้สนิทก่อน"
	hint_tier_2 = "เริ่มจากเข้า Safe Mode เพื่อไม่ให้มัลแวร์ทำงาน -> ปิด Scheduled Task -> กักกันไฟล์ Helper.dat -> ตรวจสอบจุดฝังตัว -> ยืนยันว่าหยุดทำงานแล้ว -> ปิด Cloud Sync -> แล้วจึงกู้คืนไฟล์"
	hint_tier_3 = "เรียงตามลำดับ: 1. Safe Mode -> 2. Disable Task -> 3. Quarantine -> 4. Check Persistence -> 5. Confirm Stopped -> 6. Pause Cloud Sync -> 7. Restore Backup"
	super._ready()
	for step_id: String in CORRECT_SEQUENCE:
		step_selector.add_item(STEP_LABELS[step_id])
		var index: int = step_selector.get_item_count() - 1
		step_selector.set_item_metadata(index, step_id)
		
	add_button.pressed.connect(_on_add_pressed)
	remove_button.pressed.connect(_on_remove_pressed)
	submit_button.pressed.connect(_on_submit_pressed)

func validate_answer(answer: Variant) -> bool:
	if not answer is Array:
		return false
	var steps: Array = answer
	if steps.size() != CORRECT_SEQUENCE.size():
		return false
	for index: int in range(CORRECT_SEQUENCE.size()):
		if str(steps[index]) != CORRECT_SEQUENCE[index]:
			return false
	return true

func on_solve_success() -> void:
	feedback_label.text = "✅ ทดสอบสำเร็จ: หยุดการทำงานของ Persistence และกักกันมัลแวร์ครบทั้ง 7 ขั้นตอนอย่างปลอดภัย!"
	step_selector.disabled = true
	add_button.disabled = true
	remove_button.disabled = true
	submit_button.hide()

func on_solve_failed() -> void:
	# ระบบจำลองผลกระทบตามจุดผิดจริง (Trial & Error Simulation Feedback)
	if submitted_steps.size() < CORRECT_SEQUENCE.size():
		var next_idx: int = submitted_steps.size()
		var expected_label: String = str(STEP_LABELS.get(CORRECT_SEQUENCE[next_idx], ""))
		feedback_label.text = "⚠️ [ผลจำลอง]: ยังวางแผนไม่ครบทั้ง 7 ขั้นตอน (มี %d/7) ระบบยังมีความเสี่ยงสูง! (ขั้นที่ %d ควรเป็น: %s)" % [
			submitted_steps.size(), next_idx + 1, expected_label
		]
		return

	# ตรวจสอบจุดวิกฤตตามหลัก Cyber Incident Response
	var restore_idx: int = submitted_steps.find("restore_backup")
	var disable_idx: int = submitted_steps.find("disable_task")
	var quarantine_idx: int = submitted_steps.find("quarantine_helper")
	var sync_idx: int = submitted_steps.find("pause_cloud_sync")

	if restore_idx != -1 and disable_idx != -1 and restore_idx < disable_idx:
		feedback_label.text = "💥 [ผลการทดสอบล้มเหลว]: กู้คืนไฟล์ก่อนระงับ Scheduled Task! โปรเซส Office_Update_Helper ที่ยังฝังตัวทำงานซ้ำและลบไฟล์ที่เพิ่งกู้คืนทันที!"
		return

	if restore_idx != -1 and quarantine_idx != -1 and restore_idx < quarantine_idx:
		feedback_label.text = "💥 [ผลการทดสอบล้มเหลว]: กู้คืนไฟล์ก่อนกักกัน Helper.dat! ไฟล์มัลแวร์ยังคงอยู่ในระบบและทำการเข้ารหัสไฟล์ซ้ำ!"
		return

	if submitted_steps[0] != "safe_mode":
		feedback_label.text = "⚠️ [ผลการทดสอบล้มเหลว]: ไม่ได้เริ่มใน Safe Mode! โปรเซสมัลแวร์ที่กำลังรันอยู่เบื้องหลังบล็อกไม่ให้แก้ไข Service หรือลบ Persistence!"
		return

	if restore_idx != -1 and sync_idx != -1 and restore_idx < sync_idx:
		feedback_label.text = "⚠️ [ผลการทดสอบล้มเหลว]: กู้คืนไฟล์โดยยังไม่ระงับ Cloud Sync! ไฟล์เสียหายถูกซิงค์กลับไปทับไฟล์บนคลาวด์!"
		return

	for idx: int in range(CORRECT_SEQUENCE.size()):
		if str(submitted_steps[idx]) != CORRECT_SEQUENCE[idx]:
			var expected_step: String = str(STEP_LABELS.get(CORRECT_SEQUENCE[idx], ""))
			feedback_label.text = "❌ [ผลการทดสอบ]: ลำดับขั้นตอนที่ %d ยังไม่ถูกต้อง (ควรทำ: '%s' ก่อน)" % [
				idx + 1, expected_step
			]
			return

	feedback_label.text = "⚠️ ลำดับการกู้คืนยังไม่ปลอดภัย กรุณาลองปรับลำดับขั้นตอนใหม่"

func _advance_selector_to_next_unused() -> void:
	for idx: int in range(step_selector.item_count):
		var step_id: String = str(step_selector.get_item_metadata(idx))
		if not submitted_steps.has(step_id):
			step_selector.select(idx)
			return

func _on_add_pressed() -> void:
	mark_decision_started()
	if submitted_steps.size() >= CORRECT_SEQUENCE.size():
		feedback_label.text = "เพิ่มครบ 7 ขั้นตอนแล้ว กดปุ่ม Submit ด้านล่างเพื่อทดสอบผลลัพธ์"
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
		feedback_label.text = "ครบทั้ง 7 ขั้นตอนแล้ว กดปุ่ม Submit เพื่อทดลองผลการจำลอง"
	else:
		feedback_label.text = "เพิ่มขั้นตอนที่ %d/7 แล้ว" % submitted_steps.size()

func _on_remove_pressed() -> void:
	mark_decision_started()
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
	mark_decision_started()
	submit_sequence(submitted_steps)
