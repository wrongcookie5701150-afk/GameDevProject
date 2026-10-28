class_name PhonePanelController
extends Panel

## Reusable simulated smartphone for May (Scenes 2 & 4).

signal closed
signal messages_read(contact: String)
signal message_sent(contact: String, text: String)

@onready var toggle_btn: Button = find_child("Toggle", true, false) as Button
@onready var mesa_btn: Button = find_child("MesasIcon", true, false) as Button
@onready var march_btn: Button = find_child("MarchIcon", true, false) as Button
@onready var chat_name_btn: Button = find_child("ChatName", true, false) as Button
@onready var date_label: Label = find_child("DateLabel", true, false) as Label
@onready var messages_label: Label = find_child("MessagesLabel", true, false) as Label
@onready var scroll_container: ScrollContainer = find_child("ScrollContainer", true, false) as ScrollContainer
@onready var line_edit: LineEdit = find_child("LineEdit", true, false) as LineEdit
@onready var send_btn: Button = find_child("Button", true, false) as Button

var current_contact: String = "mesa" # "mesa" or "march"
var mesa_read: bool = false

var mesa_messages: String = """14:33 | May
ทำส่วนไหนกันอยู่หรอ?

17:47 | Mesa
เราทำส่วนของเราเสร็จแล้ว เหลือแค่รายงานจ้า

18:48 | Mesa
ฮาโหลล มีใครอยู่มั้ย? ส่งรายงานมาได้เลยนะ"""

# March's chat is reserved for Scene 4; empty in base scenes
var march_history: String = ""

func _ready() -> void:
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
	
	# Initial view
	switch_to_contact(current_contact)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		var focused: Control = get_viewport().gui_get_focus_owner()
		if focused is LineEdit or focused is TextEdit:
			return
		close_phone()
		get_viewport().set_input_as_handled()

func switch_to_contact(contact: String) -> void:
	current_contact = contact
	if contact == "mesa":
		if chat_name_btn:
			chat_name_btn.text = "Mesa"
		if messages_label:
			messages_label.text = mesa_messages
		if not mesa_read:
			mesa_read = true
			messages_read.emit("mesa")
	elif contact == "march":
		if chat_name_btn:
			chat_name_btn.text = "March (พี่มาร์ช)"
		if messages_label:
			messages_label.text = march_history
	_scroll_to_bottom()

func _on_mesa_btn_pressed() -> void:
	switch_to_contact("mesa")

func _on_march_btn_pressed() -> void:
	switch_to_contact("march")

func _on_toggle_pressed() -> void:
	toggle_phone()

func toggle_phone() -> void:
	if visible:
		close_phone()
	else:
		open_phone()

func open_phone() -> void:
	show()
	if current_contact == "mesa" and not mesa_read:
		mesa_read = true
		messages_read.emit("mesa")
	_scroll_to_bottom()

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
