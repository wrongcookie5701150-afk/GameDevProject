extends Control

## ContinueModal Controller for Godot 4.x
## ควบคุมหน้าต่างเลือกปริศนาที่บันทึกไว้ (Continue Modal)

signal closed()

@onready var continue_back_button: Button = %ContinueBackButton
@onready var continue_subtitle: Label = %ContinueSubtitle
@onready var continue_esc_hint: Label = %ContinueEscHint
@onready var puzzle_01_button: Button = %Puzzle01Button

const PUZZLE_01_SCENE_PATH: String = "res://scenes/Puzzle_Drive_History.tscn"

func _ready() -> void:
	if continue_back_button and not continue_back_button.pressed.is_connected(_on_back_pressed):
		continue_back_button.pressed.connect(_on_back_pressed)
	if puzzle_01_button and not puzzle_01_button.pressed.is_connected(_on_puzzle_01_pressed):
		puzzle_01_button.pressed.connect(_on_puzzle_01_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		close()
		get_viewport().set_input_as_handled()

func open() -> void:
	show()
	if puzzle_01_button:
		puzzle_01_button.grab_focus()

func close() -> void:
	hide()
	closed.emit()

func _on_back_pressed() -> void:
	print("ปิดหน้าต่าง ContinueModal (Back Button)")
	close()

func _on_puzzle_01_pressed() -> void:
	print("เลือกเล่นปริศนา: 01 ตรวจ Drive History (Typosquatting)")
	if ResourceLoader.exists(PUZZLE_01_SCENE_PATH):
		get_tree().change_scene_to_file(PUZZLE_01_SCENE_PATH)
	else:
		print("ไม่พบฉาก %s ในระบบ (กำลังเตรียมพร้อมสำหรับการพัฒนา)" % PUZZLE_01_SCENE_PATH)

func apply_language(idx: int) -> void:
	if idx == 0:
		if continue_subtitle: continue_subtitle.text = "Select a saved puzzle to continue"
		if continue_back_button: continue_back_button.text = "← Back"
		if continue_esc_hint: continue_esc_hint.text = "Press ESC to close"
	else:
		if continue_subtitle: continue_subtitle.text = "เลือกปริศนาที่บันทึกไว้เพื่อเล่นต่อ"
		if continue_back_button: continue_back_button.text = "← ย้อนกลับ"
		if continue_esc_hint: continue_esc_hint.text = "กด ESC เพื่อปิด"
