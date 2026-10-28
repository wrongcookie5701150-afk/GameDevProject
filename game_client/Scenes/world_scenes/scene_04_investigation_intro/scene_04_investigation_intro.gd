extends BaseWorldScene

const SCENE_05_PATH: String = "res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn"

@onready var player: BasePlayer = $Playground/Player
@onready var status_label: Label = $CanvasLayer2/TaskObjective
@onready var phone_toggle_button: Button = $CanvasLayer2/PhoneToggleButton
@onready var inspect_hint: Button = $CanvasLayer2/InspectHint
@onready var phone_panel: Control = $CanvasLayer2/PhonePanel

@onready var checklist: BasePuzzleUI = $CanvasLayer/Checklist_UI
@onready var event_log_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Event_Log
@onready var drive_history_puzzle: BaseClickSelectPuzzle = $CanvasLayer/Puzzle_Drive_History
@onready var playground: Node = $Playground
@onready var tao_dam_object: InteractObject = $Playground.get_interact_object("taodam") if $Playground and $Playground.has_method("get_interact_object") else get_node_or_null("Playground/Map/InteractObject/Notebook")
@onready var bookshelf_object: InteractObject = $Playground.get_interact_object("bookshelf") if $Playground and $Playground.has_method("get_interact_object") else get_node_or_null("Playground/Map/InteractObject/BookShelf")
@onready var ev_drive_object: InteractObject = $Playground.get_interact_object("ev_drive") if $Playground and $Playground.has_method("get_interact_object") else get_node_or_null("Playground/Map/InteractObject/EVDrive")
@onready var ev_drive_panel: Panel = $CanvasLayer/EVDrivePanel
@onready var notebook_screen: Control = get_node_or_null("CanvasLayer2/NotebookScreen")

var _chat_with_march_completed: bool = false
var _checklist_complete: bool = false
var _event_log_complete: bool = false
var _drive_history_complete: bool = false
var _ev_drive_collected: bool = false

func _ready() -> void:
	super._ready()
	
	if checklist:
		checklist.hide()
	if event_log_puzzle:
		event_log_puzzle.hide()
	if drive_history_puzzle:
		drive_history_puzzle.hide()
	if ev_drive_object:
		ev_drive_object.hide()
	if ev_drive_panel:
		ev_drive_panel.hide()
	if inspect_hint:
		inspect_hint.hide()
	if notebook_screen:
		notebook_screen.hide()
	
	if status_label:
		status_label.text = "     ภารกิจ: กด [P] เพื่อเปิดมือถือ\n           - คุยกับพี่มาร์ช (March)"
	
	if phone_panel:
		phone_panel.hide()
		if phone_panel.has_method("switch_to_contact"):
			phone_panel.current_contact = "march"
		if phone_panel.has_signal("march_chat_completed"):
			phone_panel.march_chat_completed.connect(_on_march_chat_completed)
		if phone_panel.has_signal("closed"):
			phone_panel.closed.connect(_on_phone_closed)
	
	if phone_toggle_button:
		phone_toggle_button.pressed.connect(_toggle_phone)
	
	if checklist:
		checklist.puzzle_resolved.connect(_on_checklist_completed)
	if event_log_puzzle:
		event_log_puzzle.puzzle_resolved.connect(_on_event_log_completed)
	if drive_history_puzzle:
		drive_history_puzzle.puzzle_resolved.connect(_on_drive_history_completed)
	
	var ev_close_btn = get_node_or_null("CanvasLayer/EVDrivePanel/Content/CloseButton")
	if ev_close_btn:
		ev_close_btn.pressed.connect(_on_open_evidence_pressed)
	
	if not tao_dam_object and playground and playground.has_method("get_interact_object"):
		tao_dam_object = playground.get_interact_object("taodam")
	if not bookshelf_object and playground and playground.has_method("get_interact_object"):
		bookshelf_object = playground.get_interact_object("bookshelf")
	if not ev_drive_object and playground and playground.has_method("get_interact_object"):
		ev_drive_object = playground.get_interact_object("ev_drive")
	
	for interact_object: InteractObject in [tao_dam_object, bookshelf_object, ev_drive_object]:
		if interact_object:
			interact_object.interaction_requested.connect(_on_interactable_requested)
			interact_object.player_approached.connect(_on_interactable_approached)
			interact_object.player_left.connect(_on_interactable_left)
	
	if player:
		player.interacted_with.connect(_on_player_interacted_with)
		player.set_movement_enabled(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		if _close_active_overlay():
			get_viewport().set_input_as_handled()
			return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P:
			_toggle_phone()
			get_viewport().set_input_as_handled()

func _close_active_overlay() -> bool:
	if note_board_ui and note_board_ui.visible:
		if note_board_ui.has_method("close_board"):
			note_board_ui.close_board()
		else:
			note_board_ui.hide()
		return true
	if phone_panel and phone_panel.visible:
		_toggle_phone()
		return true
	if notebook_screen and notebook_screen.visible:
		notebook_screen.hide()
		if player:
			player.set_movement_enabled(true)
		return true
	if ev_drive_panel and ev_drive_panel.visible:
		ev_drive_panel.hide()
		if player:
			player.set_movement_enabled(true)
		return true
	if checklist and checklist.visible:
		checklist.hide()
		if player:
			player.set_movement_enabled(true)
		return true
	if event_log_puzzle and event_log_puzzle.visible:
		event_log_puzzle.hide()
		if player:
			player.set_movement_enabled(true)
		return true
	if drive_history_puzzle and drive_history_puzzle.visible:
		drive_history_puzzle.hide()
		if player:
			player.set_movement_enabled(true)
		return true
	return false

func _toggle_phone() -> void:
	if not phone_panel:
		return
	if not phone_panel.visible:
		if phone_panel.has_method("open_phone"):
			phone_panel.open_phone()
			phone_panel.switch_to_contact("march")
		else:
			phone_panel.show()
		
		if not _chat_with_march_completed:
			if player:
				player.set_movement_enabled(false)
			if phone_panel.has_method("start_march_chat"):
				phone_panel.start_march_chat()
	else:
		if phone_panel.has_method("close_phone"):
			phone_panel.close_phone()
		else:
			phone_panel.hide()

func _on_march_chat_completed() -> void:
	_chat_with_march_completed = true
	if is_instance_valid(status_label):
		status_label.text = "     ภารกิจ: ไปที่โน้ตบุ๊ก 'เต่าดำ' (TaoDam)\n           - กด [Spacebar] เพื่อเริ่มตรวจสอบ"
	if is_instance_valid(player):
		player.set_movement_enabled(true)

func _on_phone_closed() -> void:
	if is_instance_valid(player):
		player.set_movement_enabled(true)

func _on_interactable_approached(_object: InteractObject, _player: Node2D) -> void:
	if inspect_hint:
		inspect_hint.show()

func _on_interactable_left(_object: InteractObject, _player: Node2D) -> void:
	if inspect_hint:
		inspect_hint.hide()

func _on_player_interacted_with(target: Node) -> void:
	var interact_object: InteractObject = target as InteractObject
	if interact_object:
		interact_object.interact()

func _on_interactable_requested(interact_object: InteractObject) -> void:
	match interact_object.object_id:
		"taodam":
			if not _chat_with_march_completed:
				if status_label:
					status_label.text = "     ภารกิจ: กด [P] เพื่อคุยกับพี่มาร์ชก่อน!"
				return
			
			if not _checklist_complete:
				checklist.show()
				checklist.start_puzzle()
			else:
				if status_label:
					status_label.text = "เต่าดำถูกตัดเน็ตแล้ว ตรวจสอบ Event Log และ Drive History"
		"bookshelf":
			if _drive_history_complete and not _ev_drive_collected:
				ev_drive_object.show()
				if status_label:
					status_label.text = "     ภารกิจ: EV Drive ปรากฏข้างชั้นหนังสือ\n           - กด [Spacebar] เพื่อเก็บแฟลชไดรฟ์"
			elif not _drive_history_complete:
				if status_label:
					status_label.text = "     คำเตือน: ต้องตรวจวิเคราะห์หลักฐานบนเต่าดำให้เสร็จก่อน"
			else:
				if status_label:
					status_label.text = "     ภารกิจ: เก็บ EV Drive แล้ว"
		"ev_drive":
			if _drive_history_complete:
				_ev_drive_collected = true
				ev_drive_object.hide()
				ev_drive_panel.show()
				if status_label:
					status_label.text = "     ภารกิจ: เก็บ EV Drive แล้ว\n           - เปิดไดรฟ์เพื่อเริ่มการวิเคราะห์เชิงลึก"
			else:
				if status_label:
					status_label.text = "     คำเตือน: ต้องตรวจวิเคราะห์ให้เสร็จก่อนเก็บ EV Drive"
		"note_board":
			open_note_board()

func _on_checklist_completed() -> void:
	_checklist_complete = true
	checklist.hide()
	if status_label:
		status_label.text = "     ภารกิจ: ยืนยันการตัดเน็ตแล้ว\n           - ตรวจสอบ Timeline ใน Event Log"
	event_log_puzzle.show()
	event_log_puzzle.start_puzzle()

func _on_event_log_completed() -> void:
	_event_log_complete = true
	event_log_puzzle.hide()
	if status_label:
		status_label.text = "     ภารกิจ: บันทึก Timeline แล้ว\n           - ตรวจสอบ GG Disk Drive History หาผู้ส่งปลอม"
	drive_history_puzzle.show()
	drive_history_puzzle.start_puzzle()

func _on_drive_history_completed() -> void:
	_drive_history_complete = true
	drive_history_puzzle.hide()
	if status_label:
		status_label.text = "     ภารกิจ: พบผู้ส่งปลอมแปลงแล้ว\n           - เดินไปที่ชั้นหนังสือเพื่อเก็บ EV Drive"

func _on_open_evidence_pressed() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_05_PATH)
	if result != OK:
		push_error("Unable to load Scene 5: %s (error %d)" % [SCENE_05_PATH, result])
