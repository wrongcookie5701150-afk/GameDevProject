extends BaseWorldScene

const SCENE_03_PATH: String = "res://scenes/scene_03_incident/Scene_03_Incident.tscn"

var float_menu: Control
var phone_panel: Panel
var message_status_label: Label
var workstation_prompt: Label
var inspection_panel: Panel
var inspection_label: Label
var desktop_ui: Control
var typing_puzzle: Node
var completion_panel: Panel
var computer_object: InteractObject
var bookshelf_object: InteractObject
var notebook_object: InteractObject
var lamp_object: InteractObject

var _messages_read: bool = false
var _computer_interaction_tracked: bool = false
var _nearby_object: InteractObject

func _ready() -> void:
	super._ready()
	
	# Resolve all nodes with null checks
	float_menu = get_node_or_null("CanvasLayer/FloatMenu")
	phone_panel = get_node_or_null("CanvasLayer/PhonePanel")
	message_status_label = get_node_or_null("CanvasLayer/PhonePanel/Content/MessageStatusLabel")
	workstation_prompt = get_node_or_null("CanvasLayer/WorkstationPrompt")
	inspection_panel = get_node_or_null("CanvasLayer/InspectionPanel")
	inspection_label = get_node_or_null("CanvasLayer/InspectionPanel/InspectionLabel")
	desktop_ui = get_node_or_null("DesktopScreen")
	typing_puzzle = get_node_or_null("TypingPuzzle")
	completion_panel = get_node_or_null("CanvasLayer/CompletionPanel")
	computer_object = get_node_or_null("Interactables/Computer")
	bookshelf_object = get_node_or_null("Interactables/Bookshelf")
	notebook_object = get_node_or_null("Interactables/Notebook")
	lamp_object = get_node_or_null("Interactables/Lamp")
	
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if phone_panel:
		phone_panel.hide()
	if workstation_prompt:
		workstation_prompt.text = "WASD: Move   Space: Interact with room objects"
		workstation_prompt.hide()
	if inspection_panel:
		inspection_panel.hide()
	if desktop_ui:
		desktop_ui.hide()
	if typing_puzzle:
		typing_puzzle.hide()
	if completion_panel:
		completion_panel.hide()
	
	# Connect UI buttons
	var phone_toggle_btn = get_node_or_null("CanvasLayer/PhoneToggleButton")
	if phone_toggle_btn and not phone_toggle_btn.pressed.is_connected(_toggle_phone):
		phone_toggle_btn.pressed.connect(_toggle_phone)
	
	var read_msg_btn = get_node_or_null("CanvasLayer/PhonePanel/Content/ReadMessagesButton")
	if read_msg_btn and not read_msg_btn.pressed.is_connected(_on_read_messages_pressed):
		read_msg_btn.pressed.connect(_on_read_messages_pressed)
	
	var continue_btn = get_node_or_null("CanvasLayer/CompletionPanel/ContinueToIncidentButton")
	if continue_btn and not continue_btn.pressed.is_connected(_on_continue_to_incident_pressed):
		continue_btn.pressed.connect(_on_continue_to_incident_pressed)
	
	# Connect to desktop screen signals if available
	if desktop_ui and desktop_ui.has_signal("wifi_toggled"):
		desktop_ui.wifi_toggled.connect(_on_wifi_toggled)
	
	# Connect typing puzzle signals
	if typing_puzzle and typing_puzzle.has_signal("scene_completion_requested"):
		typing_puzzle.scene_completion_requested.connect(_on_scene_completion_requested)
	
	# Connect interactable objects
	for interact_object: InteractObject in [computer_object, bookshelf_object, notebook_object, lamp_object]:
		if interact_object:
			if not interact_object.player_approached.is_connected(_on_interactable_approached):
				interact_object.player_approached.connect(_on_interactable_approached)
			if not interact_object.player_left.is_connected(_on_interactable_left):
				interact_object.player_left.connect(_on_interactable_left)
			if not interact_object.interaction_requested.is_connected(_on_interactable_requested):
				interact_object.interaction_requested.connect(_on_interactable_requested)
	
	if player_node and not player_node.interacted_with.is_connected(_on_player_interacted_with):
		player_node.interacted_with.connect(_on_player_interacted_with)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause_menu()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_P:
			_toggle_phone()
			get_viewport().set_input_as_handled()

func _on_player_interacted_with(target: Node) -> void:
	var interact_object: InteractObject = target as InteractObject
	if interact_object:
		interact_object.interact()

func _on_interactable_approached(interact_object: InteractObject, _player: Node2D) -> void:
	_nearby_object = interact_object
	if workstation_prompt:
		workstation_prompt.text = interact_object.prompt_message
		workstation_prompt.show()

func _on_interactable_left(interact_object: InteractObject, _player: Node2D) -> void:
	if _nearby_object == interact_object:
		_nearby_object = null
		if workstation_prompt:
			workstation_prompt.hide()

func _on_interactable_requested(interact_object: InteractObject) -> void:
	if interact_object.object_id != "computer" and inspection_panel and inspection_panel.visible and _nearby_object == interact_object:
		inspection_panel.hide()
		return

	if inspection_panel:
		inspection_panel.hide()
	
	match interact_object.object_id:
		"computer":
			if not _computer_interaction_tracked:
				_computer_interaction_tracked = true
				TelemetryManager.track_event("Scene_02", "T02", "workstation_interacted", 0.0, true)
			if desktop_ui:
				desktop_ui.show()
		"bookshelf":
			_show_inspection("Bookshelf: The black laptop and evidence drive are stored here.")
		"notebook":
			_show_inspection("Notebook: Record important times and evidence as you investigate.")
		"lamp":
			_show_inspection("Lamp: A quiet study corner for May's unfinished report.")
		_:
			_show_inspection("There is nothing to inspect here.")

func _show_inspection(message: String) -> void:
	if inspection_label:
		inspection_label.text = "%s\nPress Space again to close." % message
	if inspection_panel:
		inspection_panel.show()

func _toggle_phone() -> void:
	if phone_panel:
		phone_panel.visible = not phone_panel.visible

func _on_read_messages_pressed() -> void:
	if not _messages_read:
		_messages_read = true
		if message_status_label:
			message_status_label.text = "Messages read"
		TelemetryManager.track_event(
			"Scene_02",
			"T01",
			"messages_read",
			0.0,
			true,
			1,
			false,
			{"message_count": 4}
		)
	if phone_panel:
			phone_panel.hide()

func _on_wifi_toggled(is_connected: bool) -> void:
	# Track when user disconnects Wi-Fi from the desktop
	if not is_connected:
		TelemetryManager.track_event("Scene_02", "T03", "wifi_disconnected", 0.0, true)

func _on_scene_completion_requested() -> void:
	if desktop_ui:
		desktop_ui.hide()
	if typing_puzzle:
		typing_puzzle.hide()
	if completion_panel:
		completion_panel.show()

func _on_continue_to_incident_pressed() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_03_PATH)
	if result != OK:
		push_error("Unable to load Scene 3: %s (error %d)" % [SCENE_03_PATH, result])

func _toggle_pause_menu() -> void:
	if float_menu:
		var new_pause_state: bool = not get_tree().paused
		get_tree().paused = new_pause_state
		float_menu.visible = new_pause_state

		if new_pause_state and float_menu.has_node("%Resume"):
			float_menu.get_node("%Resume").grab_focus()
	else:
		push_warning("[Tutorial] ไม่พบโหนด FloatMenu ใน Scene 2")
