extends Node

## Global GameState singleton managing game time, current scene phase, file states, chat history, and quest progress.

signal time_changed(new_time: String)
signal task_updated(header: String, text: String)
signal file_lock_status_changed(is_locked: bool)
signal notebook_state_changed(has_notebook: bool, placed_on_desk: bool)

# Game Time (19:02 -> 21:21 -> 21:25)
var clock: String = "19:02":
	set(val):
		if clock != val:
			clock = val
			time_changed.emit(clock)

# Scene Flow & Modes
var scene_phase: String = "SCENE_01_INTRO"
var is_scene_4: bool = false

# Quest & Task State
var current_task_header: String = "• การโต้ตอบ"
var current_task_text: String = "- กด [P] เพื่อใช้มือถือ"
var is_notebook_picked_up: bool = false
var has_club_notebook: bool = false
var notebook_placed_on_desk: bool = false

# Desktop & File State
var are_files_locked: bool = false:
	set(val):
		if are_files_locked != val:
			are_files_locked = val
			file_lock_status_changed.emit(val)

var is_wifi_connected: bool = true
var word_typed_count: int = 0
var is_report_doc_submitted: bool = false
var is_typing_game_completed: bool = false
var is_event_log_completed: bool = false

# Shared Mesa Chat History (Scene 2)
const MESA_CHAT_MESSAGES: Array[Dictionary] = [
	{ "time": "14:33", "sender": "เมษา", "text": "เมย์" },
	{ "time": "14:33", "sender": "เมษา", "text": "การบ้านเธอจะทำส่วนไหน" },
	{ "time": "17:47", "sender": "เมษา", "text": "ฉันทำหมดแล้วล่ะ เหลือส่วนของรายงาน" },
	{ "time": "18:48", "sender": "เมษา", "text": "ฮาโหลลลลลล มีใครอยู่มั้ย" }
]

# Shared March Chat History (Scene 4)
const MARCH_CHAT_MESSAGES: Array[Dictionary] = [
	{ "time": "21:25", "sender": "M4rchupikchu_inw101", "text": "Roblox ป่าวน้อง" },
	{ "time": "21:26", "sender": "Mayicomeinpls", "text": "พี่มาร์ชคะ คอมเปิดไฟล์ไม่ได้ค่ะ" },
	{ "time": "21:28", "sender": "M4rchupikchu_inw101", "text": "ไฟล์อะไร" },
	{ "time": "21:28", "sender": "Mayicomeinpls", "text": "ไฟล์ docx แล้ว .locked ค่ะ" },
	{ "time": "21:28", "sender": "M4rchupikchu_inw101", "text": "ยังไงนะ ถ่ายรูปมาหน่อย" },
	{ "time": "21:29", "sender": "Mayicomeinpls", "text": "[รูปถ่ายหน้าจอไฟล์ .locked]" },
	{ "time": "21:30", "sender": "M4rchupikchu_inw101", "text": "อืมม ตัดเน็ตคอมก่อน แล้วไปหยิบโน้ตบุ๊กเต่าดำมาเช็คสภาพ" }
]

func _ready() -> void:
	reset_to_initial_state()

func reset_to_initial_state() -> void:
	clock = "19:02"
	scene_phase = "SCENE_01_INTRO"
	is_scene_4 = false
	is_notebook_picked_up = false
	has_club_notebook = false
	notebook_placed_on_desk = false
	are_files_locked = false
	is_wifi_connected = true
	word_typed_count = 0
	is_report_doc_submitted = false
	is_typing_game_completed = false
	is_event_log_completed = false
	set_task("• การโต้ตอบ", "- กด [P] เพื่อใช้มือถือ")

func set_task(header: String, text: String) -> void:
	current_task_header = header
	current_task_text = text
	task_updated.emit(header, text)

func set_notebook_picked_up(picked: bool) -> void:
	is_notebook_picked_up = picked
	has_club_notebook = picked
	notebook_placed_on_desk = picked
	notebook_state_changed.emit(has_club_notebook, notebook_placed_on_desk)
