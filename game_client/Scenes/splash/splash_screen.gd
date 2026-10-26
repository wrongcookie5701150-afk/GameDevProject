extends Control

@onready var content_container: VBoxContainer = %ContentContainer
@onready var studio_label: Label = %StudioLabel
@onready var status_label: Label = %StatusLabel

const MAIN_MENU_PATH: String = "res://ui/menus/MainMenu.tscn"

var _is_transitioning: bool = false
var _main_tween: Tween
var _pulse_tween: Tween

func _ready() -> void:
	if content_container:
		content_container.modulate.a = 0.0
	_start_pulse_animation()
	_start_splash_sequence()

func _start_pulse_animation() -> void:
	if not status_label:
		return
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(status_label, "modulate:a", 0.35, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(status_label, "modulate:a", 1.0, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func _start_splash_sequence() -> void:
	if not content_container:
		_go_to_main_menu()
		return

	_main_tween = create_tween()
	# 1. Fade-in ข้อความเข้ามาประมาณ 0.8 วินาที
	_main_tween.tween_property(content_container, "modulate:a", 1.0, 0.8)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	# 2. แสดงค้างไว้ 1.0 วินาที
	_main_tween.tween_interval(1.0)

	# 3. Fade-out 0.5 วินาที
	_main_tween.tween_property(content_container, "modulate:a", 0.0, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	# 4. เมื่อเสร็จแล้วเปลี่ยนฉากไปยัง Main Menu
	_main_tween.tween_callback(_go_to_main_menu)

func _unhandled_input(event: InputEvent) -> void:
	if _is_transitioning:
		return
	# ให้ผู้เล่นกดปุ่มใดๆ หรือคลิกเพื่อข้าม Splash Screen ได้ทันที
	if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
		_skip_to_main_menu()

func _skip_to_main_menu() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	if _main_tween and _main_tween.is_valid():
		_main_tween.kill()
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()

	if content_container:
		var skip_tween: Tween = create_tween()
		skip_tween.tween_property(content_container, "modulate:a", 0.0, 0.2)
		skip_tween.tween_callback(_go_to_main_menu)
	else:
		_go_to_main_menu()

func _go_to_main_menu() -> void:
	if _is_transitioning and not is_inside_tree():
		return
	_is_transitioning = true
	if ResourceLoader.exists(MAIN_MENU_PATH):
		var err: Error = get_tree().change_scene_to_file(MAIN_MENU_PATH)
		if err != OK:
			push_error("ไม่สามารถเปลี่ยนฉากไปยัง %s ได้ (Error code: %d)" % [MAIN_MENU_PATH, err])
	else:
		push_error("ไม่พบฉาก %s ในระบบ" % MAIN_MENU_PATH)
