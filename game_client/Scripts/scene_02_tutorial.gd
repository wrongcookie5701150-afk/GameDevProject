extends BaseWorldScene

## Scene 2: Tutorial Scene

# --- Nodes ---
@onready var float_menu: Control = $CanvasLayer/FloatMenu # ปรับ Path ให้ตรงกับ Scene Tree ของคุณ

# --- Local Tutorial State ---
var has_moved_up: bool = false
var has_moved_down: bool = false
var has_moved_left: bool = false
var has_moved_right: bool = false
var is_movement_done: bool = false

func _ready() -> void:
	# เรียกฟังก์ชันเริ่มของ BaseWorldScene เพื่อเชื่อมต่อ Player และ Setup ฉาก
	super._ready()
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _unhandled_input(event: InputEvent) -> void:
	# 1. กด ESC เพื่อเปิด/ปิด Pause FloatMenu
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_pause_menu()
			get_viewport().set_input_as_handled()
			return

	# 2. ตรวจเช็กการเดิน
	if not is_movement_done and event is InputEventKey and event.pressed:
		_check_movement_tutorial(event.keycode)

func _check_movement_tutorial(keycode: int) -> void:
	match keycode:
		KEY_W, KEY_UP:
			has_moved_up = true
		KEY_S, KEY_DOWN:
			has_moved_down = true
		KEY_A, KEY_LEFT:
			has_moved_left = true
		KEY_D, KEY_RIGHT:
			has_moved_right = true

	# เมื่อผู้เล่นกดเดินครบทุกทิศทาง สั่งยิง event "tutorial_finish" ไปยังคลาสแม่
	if has_moved_up and has_moved_down and has_moved_left and has_moved_right:
		is_movement_done = true
		print("[Tutorial] เรียนรู้การเดินครบทุกทิศทางแล้ว!")
		trigger_event("tutorial_finish") # 👈 เรียกใช้ฟังก์ชันส่ง Signal จากคลาสแม่[cite: 8]

func _toggle_pause_menu() -> void:
	if float_menu:
		var new_pause_state: bool = not get_tree().paused
		get_tree().paused = new_pause_state
		float_menu.visible = new_pause_state
		
		if new_pause_state and float_menu.has_node("%Resume"):
			float_menu.get_node("%Resume").grab_focus()
	else:
		push_warning("[Tutorial] ไม่พบโหนด FloatMenu ใน Scene 2")
