extends Control

## ContinueModal Controller for Godot 4.x
## ควบคุมหน้าต่างเลือกฉากเข้าเล่น (Continue Modal / Chapter & Scene Selection)

signal closed()

@onready var continue_back_button: Button = %ContinueBackButton
@onready var continue_subtitle: Label = %ContinueSubtitle
@onready var continue_esc_hint: Label = %ContinueEscHint
@onready var scene_01_button: Button = %Scene01Button
@onready var scroll_container: ScrollContainer = %ScrollContainer

const SCENE_ROUTES: Dictionary = {
	1: {
		"btn_name": "Scene01Button",
		"scene": "res://scenes/scene_01_intro/Scene_01_Intro.tscn",
		"name_th": "01 Intro: สายเรียกเข้าจากเมษา (19:02)",
		"name_en": "01 Intro: Call from Mesa (19:02)"
	},
	2: {
		"btn_name": "Scene02Button",
		"scene": "res://scenes/world_scenes/scene_02_tutorial/Scene_02_Tutorial.tscn",
		"name_th": "02 ห้องนอน & มือถือ: Tutorial (T01-T02)",
		"name_en": "02 Bedroom & Phone: Tutorial (T01-T02)"
	},
	3: {
		"btn_name": "Scene03Button",
		"scene": "res://scenes/scene_03_incident/Scene_03_Incident.tscn",
		"name_th": "03 คอมเมย์: Typing & Incident (T03-T04)",
		"name_en": "03 May's PC: Typing & Incident (T03-T04)"
	},
	4: {
		"btn_name": "Scene04Button",
		"scene": "res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn",
		"name_th": "04 ห้องนอน: เตรียมเต่าดำ & Forensic Image",
		"name_en": "04 Bedroom: Prep TaoDam & Forensic Image"
	},
	5: {
		"btn_name": "Scene05Button",
		"scene": "res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn",
		"name_th": "05 โน้ตบุ๊กเต่าดำ: ตรวจสอบการตัดเน็ต (T05)",
		"name_en": "05 TaoDam Notebook: Network Isolation (T05)"
	},
	6: {
		"btn_name": "Scene06Button",
		"scene": "res://scenes/scene_06_taodam_investigation/Scene_06_TaoDam_Investigation.tscn",
		"name_th": "06 โน้ตบุ๊กเต่าดำ: สืบสวนหลักฐาน 6 ขั้นตอน (T06-T12)",
		"name_en": "06 TaoDam Notebook: 6 Forensic Steps (T06-T12)"
	},
	7: {
		"btn_name": "Scene07Button",
		"scene": "res://scenes/scene_07_recovery/Scene_07_Recovery.tscn",
		"name_th": "07 คอมเมย์: กู้คืน 3-2-1 & สรุปผล KSA (T13-T15)",
		"name_en": "07 May's PC: 3-2-1 Recovery & KSA Report (T13-T15)"
	}
}

func _ready() -> void:
	_setup_cyber_scrollbar()
	_connect_buttons()

func _connect_buttons() -> void:
	if continue_back_button and not continue_back_button.pressed.is_connected(_on_back_pressed):
		continue_back_button.pressed.connect(_on_back_pressed)
	
	for idx: int in SCENE_ROUTES:
		var route: Dictionary = SCENE_ROUTES[idx]
		var btn: Button = find_child(route["btn_name"], true, false) as Button
		if btn and not btn.pressed.is_connected(_on_scene_button_pressed.bind(idx)):
			btn.pressed.connect(_on_scene_button_pressed.bind(idx))

func _setup_cyber_scrollbar() -> void:
	if not scroll_container:
		return
	var v_bar = scroll_container.get_v_scroll_bar()
	if v_bar:
		v_bar.custom_minimum_size.x = 4
		v_bar.custom_step = 22.0
		v_bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("Exit") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		close()
		get_viewport().set_input_as_handled()

func open() -> void:
	show()
	if scene_01_button:
		scene_01_button.grab_focus()

func close() -> void:
	hide()
	closed.emit()

func _on_back_pressed() -> void:
	print("ปิดหน้าต่าง ContinueModal (Back Button)")
	close()

func _on_scene_button_pressed(idx: int) -> void:
	if not SCENE_ROUTES.has(idx):
		return
	var route: Dictionary = SCENE_ROUTES[idx]
	var scene_path: String = route["scene"]
	print("เลือกเล่นฉาก: %s (%s)" % [route["name_th"], scene_path])
	
	if not ResourceLoader.exists(scene_path):
		print("ไม่พบฉาก %s ในระบบ (กำลังเตรียมพร้อมสำหรับการพัฒนา)" % scene_path)
		return
	
	var err: Error = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("ไม่สามารถเปลี่ยนฉากไปยัง %s ได้ (error %d)" % [scene_path, err])

func apply_language(idx: int) -> void:
	if idx == 0:
		if continue_subtitle: continue_subtitle.text = "Select a chapter or scene to continue"
		if continue_back_button: continue_back_button.text = "← Back"
		if continue_esc_hint: continue_esc_hint.text = "Press Q to close"
	else:
		if continue_subtitle: continue_subtitle.text = "เลือกฉากที่ต้องการเล่นต่อ"
		if continue_back_button: continue_back_button.text = "← ย้อนกลับ"
		if continue_esc_hint: continue_esc_hint.text = "กด Q เพื่อปิด"
	
	for scene_idx: int in SCENE_ROUTES:
		var route: Dictionary = SCENE_ROUTES[scene_idx]
		var btn: Button = find_child(route["btn_name"], true, false) as Button
		if btn:
			var name_lbl: Label = btn.find_child("Name", true, false) as Label
			if name_lbl:
				name_lbl.text = route["name_en"] if idx == 0 else route["name_th"]
