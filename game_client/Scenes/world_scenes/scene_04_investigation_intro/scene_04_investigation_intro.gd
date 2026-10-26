extends BaseWorldScene

const SCENE_05_PATH: String = "res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn"

@onready var player: BasePlayer = $Playground/Player
@onready var dialogue_panel: Panel = $CanvasLayer/DialoguePanel
@onready var dialogue_label: Label = $CanvasLayer/DialoguePanel/Content/DialogueLabel
@onready var dialogue_button: Button = $CanvasLayer/DialoguePanel/Content/DialogueButton
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var checklist: BasePuzzleUI = $CanvasLayer/Checklist_UI
@onready var event_log_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Event_Log
@onready var drive_history_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Drive_History
@onready var tao_dam_object: InteractObject = $Interactables/TaoDam
@onready var bookshelf_object: InteractObject = $Interactables/Bookshelf
@onready var ev_drive_object: InteractObject = $Interactables/EVDrive
@onready var ev_drive_panel: Panel = $CanvasLayer/EVDrivePanel

var _dialogue_step: int = 0
var _checklist_complete: bool = false
var _event_log_complete: bool = false
var _drive_history_complete: bool = false
var _ev_drive_collected: bool = false

func _ready() -> void:
	super._ready()
	player.movement_enabled = false
	checklist.hide()
	event_log_puzzle.hide()
	drive_history_puzzle.hide()
	ev_drive_object.hide()
	ev_drive_panel.hide()
	dialogue_panel.show()
	dialogue_button.pressed.connect(_advance_dialogue)
	checklist.puzzle_resolved.connect(_on_checklist_completed)
	event_log_puzzle.puzzle_resolved.connect(_on_event_log_completed)
	drive_history_puzzle.puzzle_resolved.connect(_on_drive_history_completed)
	$CanvasLayer/EVDrivePanel/Content/CloseButton.pressed.connect(_on_open_evidence_pressed)
	for interact_object: InteractObject in [tao_dam_object, bookshelf_object, ev_drive_object]:
		interact_object.interaction_requested.connect(_on_interactable_requested)
	if player:
		player.interacted_with.connect(_on_player_interacted_with)

func _advance_dialogue() -> void:
	_dialogue_step += 1
	match _dialogue_step:
		1:
			dialogue_label.text = "May: พี่มาร์ชคะ คอมเปิดไฟล์งานไม่ได้ค่ะ ไฟล์ลงท้ายด้วย .locked"
			dialogue_button.text = "Incoming call from March"
		2:
			dialogue_label.text = "March calling: ยังมีเต่าดำอยู่ใช่มั้ย? May: ยังอยู่ค่ะ."
			dialogue_button.text = "Answer March's call"
		3:
			dialogue_label.text = "March: ตัดเน็ตคอมก่อน แล้วใช้เครื่องเต่าดำที่แยกจากบัญชีและไฟล์งานสำคัญ"
			dialogue_button.text = "Enter the room"
		_:
			dialogue_panel.hide()
			player.movement_enabled = true
			status_label.text = "Use Space near TaoDam to verify isolation before examining evidence."

func _on_player_interacted_with(target: Node) -> void:
	var interact_object: InteractObject = target as InteractObject
	if interact_object:
		interact_object.interact()

func _on_interactable_requested(interact_object: InteractObject) -> void:
	match interact_object.object_id:
		"taodam":
			if not _checklist_complete:
				checklist.show()
				checklist.start_puzzle()
			else:
				status_label.text = "TaoDam is isolated. Review the event log and Drive history."
		"bookshelf":
			if _drive_history_complete and not _ev_drive_collected:
				ev_drive_object.show()
				status_label.text = "EV Drive is ready beside the bookshelf. Press Space on it to pick it up."
			elif not _drive_history_complete:
				status_label.text = "March: Preserve the evidence review before taking the EV Drive."
			else:
				status_label.text = "The EV Drive has been collected."
		"ev_drive":
			if _drive_history_complete:
				_ev_drive_collected = true
				ev_drive_object.hide()
				ev_drive_panel.show()
				status_label.text = "Evidence drive collected. Open it to begin forensic analysis."
			else:
				status_label.text = "Complete the Drive History review before collecting the EV Drive."

func _on_checklist_completed() -> void:
	_checklist_complete = true
	checklist.hide()
	status_label.text = "Isolation confirmed. Select the Event Log terminal to inspect the timeline."
	event_log_puzzle.show()
	event_log_puzzle.start_puzzle()

func _on_event_log_completed() -> void:
	_event_log_complete = true
	event_log_puzzle.hide()
	status_label.text = "Timeline recorded. Review GG Disk Drive History for the spoofed sender."
	drive_history_puzzle.show()
	drive_history_puzzle.start_puzzle()

func _on_drive_history_completed() -> void:
	_drive_history_complete = true
	drive_history_puzzle.hide()
	status_label.text = "Spoofed report identified. Walk to the bookshelf and collect the EV Drive."

func _on_open_evidence_pressed() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_05_PATH)
	if result != OK:
		push_error("Unable to load Scene 5: %s (error %d)" % [SCENE_05_PATH, result])
