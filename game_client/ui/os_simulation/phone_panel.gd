class_name PhonePanelController
extends Panel

## Reusable simulated smartphone for May (Scenes 2 & 4).

signal closed
signal messages_read(contact: String)
signal message_sent(contact: String, text: String)

static var saved_view_mode: String = "chat" # Persists across scene changes
var current_view_mode: String = "chat" # "chat" or "task"
var current_tasks: Array = [] # [{ "id": String, "text": String, "completed": bool }]

@onready var toggle_btn: Button = find_child("Toggle", true, false) as Button
@onready var mesa_btn: Button = find_child("MesasIcon", true, false) as Button
@onready var march_btn: Button = find_child("MarchIcon", true, false) as Button
@onready var chat_name_btn: Button = find_child("ChatName", true, false) as Button
@onready var date_label: Label = find_child("DateLabel", true, false) as Label
@onready var messages_label: Label = find_child("MessagesLabel", true, false) as Label
@onready var scroll_container: ScrollContainer = find_child("ScrollContainer", true, false) as ScrollContainer
@onready var line_edit: LineEdit = find_child("LineEdit", true, false) as LineEdit
@onready var send_btn: Button = find_child("Button", true, false) as Button

# Task view elements
@onready var chat_content: Control = find_child("Content", true, false) as Control
@onready var task_content: Control = find_child("TaskContent", true, false) as Control
@onready var task_list_label: Label = find_child("TaskListLabel", true, false) as Label
@onready var task_scroll_container: ScrollContainer = find_child("TaskScrollContainer", true, false) as ScrollContainer

var current_contact: String = "mesa" # "mesa" or "march"
var mesa_read: bool = false
var _chime_player: AudioStreamPlayer = null

var mesa_messages: String = """14:33 | May
ทำส่วนไหนกันอยู่หรอ?

17:47 | Mesa
เราทำส่วนของเราเสร็จแล้ว เหลือแค่รายงานจ้า

18:48 | Mesa
ฮาโหลล มีใครอยู่มั้ย? ส่งรายงานมาได้เลยนะ"""

# March's chat is reserved for Scene 4; empty in base scenes
var march_history: String = ""

func _ready() -> void:
	_init_chime_player()

	if toggle_btn and not toggle_btn.pressed.is_connected(_on_toggle_pressed):
		toggle_btn.pressed.connect(_on_toggle_pressed)
	
	if mesa_btn and not mesa_btn.pressed.is_connected(_on_mesa_btn_pressed):
		mesa_btn.pressed.connect(_on_mesa_btn_pressed)
	
	if march_btn and not march_btn.pressed.is_connected(_on_march_btn_pressed):
		march_btn.pressed.connect(_on_march_btn_pressed)
	
	if send_btn and not send_btn.pressed.is_connected(_on_send_pressed):
		send_btn.pressed.connect(_on_send_pressed)
	
	if line_edit and not line_edit.text_submitted.is_connected(_on_text_submitted):
		line_edit.text_submitted.connect(_on_text_submitted)
	
	_setup_scrollbar()
	
	# Apply persisted view mode
	switch_view_mode(saved_view_mode)
	
	# Initial contact view (update labels without consuming mesa_read while hidden)
	_refresh_contact_view(current_contact)
	if visible and current_contact == "mesa" and current_view_mode == "chat":
		mesa_read = true
		messages_read.emit("mesa")

func _init_chime_player() -> void:
	if _chime_player:
		return
	_chime_player = AudioStreamPlayer.new()
	_chime_player.name = "TaskChimePlayer"
	var sfx_idx: int = AudioServer.get_bus_index("SFX")
	_chime_player.bus = "SFX" if sfx_idx != -1 else "Master"
	add_child(_chime_player)
	
	# Synthesize a pleasant two-tone chime (C6 -> G6) with gentle exponential decay
	var sample_rate: int = 22050
	var duration: float = 0.35
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var freq: float = 1046.50 if t < 0.12 else 1567.98 # C6 then G6
		var note_t: float = t if t < 0.12 else (t - 0.12)
		var env: float = exp(-note_t * 14.0)
		var sample_val: float = sin(note_t * freq * TAU) * env * 0.35
		var sample_int: int = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample_int)
	
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	_chime_player.stream = wav

func play_task_chime() -> void:
	if not _chime_player:
		_init_chime_player()
	if _chime_player and _chime_player.stream:
		_chime_player.play()

func _unhandled_input(event: InputEvent) -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return
	
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		if visible:
			close_phone()
			get_viewport().set_input_as_handled()
			return
	
	if event.is_action_pressed("Chat"):
		toggle_phone("chat")
		get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("Task"):
		toggle_phone("task")
		get_viewport().set_input_as_handled()
		return

func switch_view_mode(mode: String) -> void:
	if mode != "task" and mode != "chat":
		mode = "chat"
	current_view_mode = mode
	saved_view_mode = mode
	
	if mode == "task":
		if chat_content:
			chat_content.hide()
		if task_content:
			task_content.show()
		if toggle_btn:
			toggle_btn.tooltip_text = "ดูแชท (Chat [C])"
		refresh_task_view()
	else:
		if task_content:
			task_content.hide()
		if chat_content:
			chat_content.show()
		if toggle_btn:
			toggle_btn.tooltip_text = "ดูภารกิจ (Task [T])"
		if visible and current_contact == "mesa":
			mesa_read = true
			messages_read.emit("mesa")
		_scroll_to_bottom()

func _on_toggle_pressed() -> void:
	if current_view_mode == "chat":
		switch_view_mode("task")
	else:
		switch_view_mode("chat")

func set_tasks(tasks: Array) -> void:
	current_tasks = tasks.duplicate(true)
	refresh_task_view()

func add_task(task_id: String, text: String, play_chime: bool = true) -> void:
	for t: Dictionary in current_tasks:
		if t.get("id", "") == task_id:
			t["text"] = text
			refresh_task_view()
			if play_chime:
				play_task_chime()
			return
	current_tasks.append({
		"id": task_id,
		"text": text,
		"completed": false
	})
	refresh_task_view()
	if play_chime:
		play_task_chime()

func set_task_completed(task_id: String, completed: bool = true) -> void:
	for t: Dictionary in current_tasks:
		if t.get("id", "") == task_id:
			t["completed"] = completed
			break
	refresh_task_view()

func refresh_task_view() -> void:
	if not task_list_label:
		return
	if current_tasks.is_empty():
		task_list_label.text = "• ไม่มีภารกิจค้างอยู่"
		return
	var lines: Array[String] = []
	for t: Dictionary in current_tasks:
		var is_comp: bool = t.get("completed", false)
		var desc: String = t.get("text", "")
		if is_comp:
			lines.append("✓ %s (เสร็จสิ้น)" % desc)
		else:
			lines.append("• %s" % desc)
	task_list_label.text = "\n\n".join(lines)

func _refresh_contact_view(contact: String) -> void:
	current_contact = contact
	if contact == "mesa":
		if chat_name_btn:
			chat_name_btn.text = "Mesa"
		if messages_label:
			messages_label.text = mesa_messages
	elif contact == "march":
		if chat_name_btn:
			chat_name_btn.text = "March (พี่มาร์ช)"
		if messages_label:
			messages_label.text = march_history

func switch_to_contact(contact: String) -> void:
	_refresh_contact_view(contact)
	if contact == "mesa":
		mesa_read = true
		messages_read.emit("mesa")
	_scroll_to_bottom()

func _on_mesa_btn_pressed() -> void:
	switch_view_mode("chat")
	switch_to_contact("mesa")

func _on_march_btn_pressed() -> void:
	switch_view_mode("chat")
	switch_to_contact("march")

func toggle_phone(target_mode: String = "") -> void:
	if not visible:
		open_phone(target_mode)
	else:
		if target_mode.is_empty():
			close_phone()
		elif current_view_mode == target_mode:
			close_phone()
		else:
			switch_view_mode(target_mode)

func open_phone(target_mode: String = "") -> void:
	show()
	if target_mode.is_empty():
		target_mode = saved_view_mode
	switch_view_mode(target_mode)

func close_phone() -> void:
	hide()
	closed.emit()

func _on_send_pressed() -> void:
	if not line_edit:
		return
	var text: String = line_edit.text.strip_edges()
	if text.is_empty():
		return
	line_edit.clear()
	send_user_message(text)

func _on_text_submitted(text: String) -> void:
	var clean_text: String = text.strip_edges()
	if clean_text.is_empty():
		return
	if line_edit:
		line_edit.clear()
	send_user_message(clean_text)

func send_user_message(text: String) -> void:
	var msg: String = "May: %s\n\n" % text
	if current_contact == "mesa":
		mesa_messages += msg
		if messages_label:
			messages_label.text = mesa_messages
		_scroll_to_bottom()
		message_sent.emit("mesa", text)
		_mesa_auto_reply()
	elif current_contact == "march":
		march_history += msg
		if messages_label:
			messages_label.text = march_history
		_scroll_to_bottom()
		message_sent.emit("march", text)
		_march_auto_reply()

func _mesa_auto_reply() -> void:
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(self):
		return
	mesa_messages += "Mesa: สู้ๆ นะเมย์ รีบส่งนะ!\n\n"
	if current_contact == "mesa" and messages_label:
		messages_label.text = mesa_messages
		_scroll_to_bottom()

func _march_auto_reply() -> void:
	await get_tree().create_timer(1.0).timeout
	if not is_instance_valid(self):
		return
	march_history += "March: รีบไปตรวจเครื่องเต่าดำเร็วเข้า อย่าเพิ่งต่อเน็ตนะ!\n\n"
	if current_contact == "march" and messages_label:
		messages_label.text = march_history
		_scroll_to_bottom()

func _scroll_to_bottom() -> void:
	if scroll_container:
		await get_tree().process_frame
		if is_instance_valid(scroll_container):
			scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func _setup_scrollbar() -> void:
	_style_scroll_container(scroll_container)
	_style_scroll_container(task_scroll_container)

func _style_scroll_container(sc: ScrollContainer) -> void:
	if not sc:
		return
	var vsb: VScrollBar = sc.get_v_scroll_bar()
	if not vsb:
		return
	vsb.custom_minimum_size = Vector2(3, 0)
	
	if not vsb.has_theme_stylebox_override("scroll"):
		var track_box: StyleBoxFlat = StyleBoxFlat.new()
		track_box.bg_color = Color(0.366595, 0.366594, 0.366594, 1.0)
		track_box.corner_radius_top_left = 1
		track_box.corner_radius_top_right = 1
		track_box.corner_radius_bottom_right = 1
		track_box.corner_radius_bottom_left = 1
		track_box.content_margin_left = 1.0
		track_box.content_margin_right = 2.0
		vsb.add_theme_stylebox_override("scroll", track_box)
		vsb.add_theme_stylebox_override("scroll_focus", track_box)
	
	if not vsb.has_theme_stylebox_override("grabber"):
		var grabber_box: StyleBoxFlat = StyleBoxFlat.new()
		grabber_box.bg_color = Color(0.65, 0.70, 0.85, 0.85)
		grabber_box.corner_radius_top_left = 1
		grabber_box.corner_radius_top_right = 1
		grabber_box.corner_radius_bottom_right = 1
		grabber_box.corner_radius_bottom_left = 1
		grabber_box.content_margin_left = 1.0
		grabber_box.content_margin_right = 2.0
		vsb.add_theme_stylebox_override("grabber", grabber_box)
	
	if not vsb.has_theme_stylebox_override("grabber_highlight"):
		var hl_box: StyleBoxFlat = StyleBoxFlat.new()
		hl_box.bg_color = Color(0.85, 0.90, 1.0, 1.0)
		hl_box.corner_radius_top_left = 1
		hl_box.corner_radius_top_right = 1
		hl_box.corner_radius_bottom_right = 1
		hl_box.corner_radius_bottom_left = 1
		hl_box.content_margin_left = 1.0
		hl_box.content_margin_right = 2.0
		vsb.add_theme_stylebox_override("grabber_highlight", hl_box)

	if not vsb.has_theme_stylebox_override("grabber_pressed"):
		var pr_box: StyleBoxFlat = StyleBoxFlat.new()
		pr_box.bg_color = Color(1.0, 1.0, 1.0, 1.0)
		pr_box.corner_radius_top_left = 1
		pr_box.corner_radius_top_right = 1
		pr_box.corner_radius_bottom_right = 1
		pr_box.corner_radius_bottom_left = 1
		pr_box.content_margin_left = 1.0
		pr_box.content_margin_right = 2.0
		vsb.add_theme_stylebox_override("grabber_pressed", pr_box)
