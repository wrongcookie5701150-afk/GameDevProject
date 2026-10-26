extends BaseWorldScene

const SCENE_03_PATH: String = "res://scenes/scene_03_incident/Scene_03_Incident.tscn"

var float_menu: Control
var phone_panel: Panel
var message_status_label: Label
var task_objective: Label
var object_detail: Label
var desktop_ui: Control
var ms_word_window: Control
var playground: Node2D
var room_map: Node2D

var _messages_read: bool = false
var _nearby_object: InteractObject

func _ready() -> void:
	super._ready()
	
	# Resolve all nodes with null checks
	playground = get_node_or_null("Playground")
	room_map = get_node_or_null("Playground/Map")
	player_node = get_node_or_null("Playground/Player")
	float_menu = get_node_or_null("CanvasLayer/FloatMenu")
	phone_panel = get_node_or_null("CanvasLayer/PhonePanel")
	message_status_label = get_node_or_null("CanvasLayer/PhonePanel/Content/MessageStatusLabel")
	task_objective = get_node_or_null("CanvasLayer/TaskObjective")
	object_detail = get_node_or_null("Playground/Player/ObjectDatail")
	desktop_ui = get_node_or_null("CanvasLayer/DesktopScreen")
	ms_word_window = get_node_or_null("CanvasLayer/DesktopScreen/WindowContainer/MsWord")
	
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if phone_panel:
		phone_panel.hide()
	if task_objective:
		task_objective.show()
	if object_detail:
		object_detail.hide()
		print("DEBUG: ObjectDatail found at runtime")
	else:
		print("DEBUG: ObjectDatail NOT found - check path: Playground/Player/ObjectDatail")
	if desktop_ui:
		desktop_ui.hide()
	
	# Connect UI buttons
	var phone_toggle_btn = get_node_or_null("CanvasLayer/PhoneToggleButton")
	if phone_toggle_btn and not phone_toggle_btn.pressed.is_connected(_toggle_phone):
		phone_toggle_btn.pressed.connect(_toggle_phone)
	
	var read_msg_btn = get_node_or_null("CanvasLayer/PhonePanel/Content/ReadMessagesButton")
	if read_msg_btn and not read_msg_btn.pressed.is_connected(_on_read_messages_pressed):
		read_msg_btn.pressed.connect(_on_read_messages_pressed)
	
	# Connect to desktop screen signals if available
	if desktop_ui and desktop_ui.has_signal("wifi_toggled"):
		desktop_ui.wifi_toggled.connect(_on_wifi_toggled)
	
	# Connect MS Word typing completion signal
	if ms_word_window and ms_word_window.has_signal("typing_completed"):
		ms_word_window.typing_completed.connect(_on_typing_completed)
	
	# Find and connect interact objects inside the room map
	if room_map:
		_connect_interact_objects(room_map)

func _connect_interact_objects(node: Node) -> void:
	# Recursively find all InteractObject nodes in the scene tree
	for child in node.get_children():
		if child is InteractObject:
			if not child.player_approached.is_connected(_on_interactable_approached):
				child.player_approached.connect(_on_interactable_approached)
			if not child.player_left.is_connected(_on_interactable_left):
				child.player_left.connect(_on_interactable_left)
			if not child.interaction_requested.is_connected(_on_interactable_requested):
				child.interaction_requested.connect(_on_interactable_requested)
		# Recursively check children
		_connect_interact_objects(child)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause_menu()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_P:
			_toggle_phone()
			get_viewport().set_input_as_handled()
		if event.keycode == KEY_SPACE and _nearby_object:
			_nearby_object.interact()
			get_viewport().set_input_as_handled()

func _on_interactable_approached(interact_object: InteractObject, _player: Node2D) -> void:
	_nearby_object = interact_object
	var object_name = interact_object.name if interact_object.name else "Unknown Object"
	print("DEBUG: Approached object: ", object_name, " object_id: ", interact_object.object_id)
	
	if task_objective:
		task_objective.text = interact_object.prompt_message if interact_object.prompt_message else "Press Space to interact"
	
	if object_detail:
		match interact_object.object_id:
			"computer":
				object_detail.text = object_name + ": Computer workstation for research"
			"notebook":
				object_detail.text = object_name + ": Record important times and evidence as you investigate."
			"lamp":
				object_detail.text = object_name + ": A quiet study corner for May's unfinished report."
			_:
				object_detail.text = object_name + ": There is nothing to inspect here."
		object_detail.show()
		print("DEBUG: ObjectDetail text set to: ", object_detail.text)
	else:
		print("DEBUG: ObjectDetail is null!")

func _on_interactable_left(interact_object: InteractObject, _player: Node2D) -> void:
	if _nearby_object == interact_object:
		_nearby_object = null
		if task_objective:
			task_objective.text = "     Task 01 ไปที่คอมพิวเตอร์\n           - กด [W] [A] [S] [D] เพื่อเคลื่อนที่"
		if object_detail:
			object_detail.hide()

func _on_interactable_requested(interact_object: InteractObject) -> void:
	match interact_object.object_id:
		"computer":
			if desktop_ui:
				desktop_ui.show()
		_:
			pass

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

func _on_typing_completed() -> void:
	if desktop_ui:
		desktop_ui.hide()
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
