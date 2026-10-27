class_name PhonePanelInvestigation
extends PhonePanelController

## Inherited phone controller for Scene 4 (Investigation Intro).
## March's chat is active here and starts empty before streaming the auto-run dialogue.

signal march_chat_completed

var march_chat_done: bool = false
var is_march_typing: bool = false

const MARCH_CHAT_LINES: Array[Dictionary] = [
	{ "sender": "March", "text": "Roblox ป่าวน้อง หรือทำการบ้านอยู่?" },
	{ "sender": "May", "text": "พี่มาร์ชคะ! แย่แล้ว คอมหนูโดนไวรัส ไฟล์งานเปลี่ยนนามสกุลเป็น .locked หมดเลย!" },
	{ "sender": "March", "text": "เฮ้ย โดน Ransomware เล่นงานแล้ว! เพิ่งเปิดไฟล์แปลกๆ หรือกดอะไรไปใช่มั้ย?" },
	{ "sender": "May", "text": "หนูเพิ่งเปิดไฟล์รายงานใน GG Disk แล้วเผลอกด 'Enable Content' ไปค่ะ..." },
	{ "sender": "March", "text": "นั่นแหละ Macro ไวรัส! รีบตัดเน็ตคอมเครื่องนั้นด่วนเลย อย่าให้ CloudSync ซิงค์ไฟล์เสียไปทับบนคลาวด์" },
	{ "sender": "March", "text": "ยังมีโน้ตบุ๊ก 'เต่าดำ' (TaoDam) อยู่ใช่มั้ย? ให้ใช้เครื่องเต่าดำที่แยกเน็ตมาตรวจสอบ Timeline กับหลักฐาน" },
	{ "sender": "May", "text": "เข้าใจแล้วค่ะ หนูจะรีบไปตรวจเครื่องเต่าดำเดี๋ยวนี้!" }
]

func _ready() -> void:
	current_contact = "march"
	march_history = ""
	super._ready()
	
	# ต้องเปิดไปแล้วว่างก่อนตามที่ผู้ใช้กำหนด (March's chat must be blank first)
	if messages_label:
		messages_label.text = ""

func open_phone() -> void:
	super.open_phone()
	switch_to_contact("march")
	if not march_chat_done and not is_march_typing:
		start_march_chat()

func close_phone() -> void:
	if is_march_typing:
		finish_march_chat()
	super.close_phone()

func start_march_chat() -> void:
	if is_march_typing:
		return
	is_march_typing = true
	current_contact = "march"
	
	# เริ่มต้นด้วยความว่างเปล่าตามโจทย์ (Open must be blank first)
	march_history = ""
	if messages_label:
		messages_label.text = ""
	
	if chat_name_btn:
		chat_name_btn.text = "March (พี่มาร์ช)"
	
	# หน่วงเวลาสั้นๆ ให้ผู้เล่นเห็นหน้าต่างแชทว่างก่อนเริ่มพิมพ์
	await get_tree().create_timer(0.6).timeout
	if not is_march_typing or not is_instance_valid(self):
		return
	
	for msg: Dictionary in MARCH_CHAT_LINES:
		if not is_march_typing:
			break
		if chat_name_btn:
			chat_name_btn.text = "%s (กำลังพิมพ์...)" % msg["sender"]
		await get_tree().create_timer(0.8).timeout
		if not is_instance_valid(messages_label) or not is_march_typing:
			return
		var line_str: String = "%s: %s\n\n" % [msg["sender"], msg["text"]]
		march_history += line_str
		if current_contact == "march":
			messages_label.text = march_history
		_scroll_to_bottom()
		await get_tree().create_timer(0.4).timeout
	
	finish_march_chat()

func finish_march_chat() -> void:
	is_march_typing = false
	march_chat_done = true
	if chat_name_btn:
		chat_name_btn.text = "March (พี่มาร์ช)"
	if march_history.is_empty():
		for msg: Dictionary in MARCH_CHAT_LINES:
			march_history += "%s: %s\n\n" % [msg["sender"], msg["text"]]
	if current_contact == "march" and messages_label:
		messages_label.text = march_history
	_scroll_to_bottom()
	march_chat_completed.emit()
