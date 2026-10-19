extends Control

## SettingsModal Controller for Godot 4.x
## ควบคุมระบบตั้งค่า (General, Audio, Video, Other) และ Confirm Dialog

signal closed()
signal language_changed(index: int)

# --- Settings Header & Footer ---
@onready var settings_back_button: Button = %SettingsBackButton
@onready var settings_save_button: Button = %SettingsSaveButton
@onready var settings_subtitle: Label = %SettingsSubtitle

# --- Settings Tabs & Panels ---
@onready var tab_general: Button = %TabGeneral
@onready var tab_audio: Button = %TabAudio
@onready var tab_video: Button = %TabVideo
@onready var tab_other: Button = %TabOther

@onready var panel_general: Control = %PanelGeneral
@onready var panel_audio: Control = %PanelAudio
@onready var panel_video: Control = %PanelVideo
@onready var panel_other: Control = %PanelOther

# --- General Tab Controls ---
@onready var lang_label: Label = %LangLabel
@onready var language_option: OptionButton = %LanguageOption
@onready var text_speed_label: Label = %TextSpeedLabel
@onready var text_speed_option: OptionButton = %TextSpeedOption
@onready var save_data_label: Label = %SaveDataLabel
@onready var reset_save_button: Button = %ResetSaveButton
@onready var delete_all_button: Button = %DeleteAllButton

# --- Confirmation Modal ---
@onready var confirm_modal: Control = %ConfirmModal
@onready var confirm_message: Label = %ConfirmMessage
@onready var confirm_cancel_button: Button = %ConfirmCancelButton
@onready var confirm_ok_button: Button = %ConfirmOkButton

# --- Audio Tab Controls ---
@onready var master_label: Label = %MasterLabel
@onready var master_slider: HSlider = %MasterSlider
@onready var master_val_label: Label = %MasterValLabel

@onready var bgm_label: Label = %BGMLabel
@onready var bgm_slider: HSlider = %BGMSlider
@onready var bgm_val_label: Label = %BGMValLabel

@onready var sfx_label: Label = %SFXLabel
@onready var sfx_slider: HSlider = %SFXSlider
@onready var sfx_val_label: Label = %SFXValLabel

@onready var mute_all_check_box: CheckBox = %MuteAllCheckBox
@onready var mute_all_label: Label = %MuteAllLabel

# --- Video Tab Controls ---
@onready var fullscreen_check_box: CheckBox = %FullscreenCheckBox
@onready var fullscreen_label: Label = %FullscreenLabel
@onready var vsync_check_box: CheckBox = %VsyncCheckBox
@onready var vsync_label: Label = %VsyncLabel
@onready var resolution_label: Label = %ResolutionLabel
@onready var resolution_option: OptionButton = %ResolutionOption

# --- Other Tab Controls ---
@onready var studio_label: Label = %StudioLabel
@onready var studio_val: Label = %StudioVal
@onready var ver_label: Label = %VerLabel
@onready var version_val: Label = %VersionVal
@onready var dev_title_label: Label = %DevTitleLabel
@onready var control_guide_title: Label = %ControlGuideTitle
@onready var desc_1: Label = %Desc1
@onready var desc_2: Label = %Desc2
@onready var desc_3: Label = %Desc3
@onready var desc_4: Label = %Desc4

# StyleBoxes for Tabs
@export var tab_active_style: StyleBox
@export var tab_active_hover_style: StyleBox
@export var tab_inactive_style: StyleBox
@export var tab_inactive_hover_style: StyleBox

# StyleBoxes for OptionButton PopupMenu
@export var popup_panel_style: StyleBox
@export var popup_hover_style: StyleBox

var current_language_idx: int = 0 # 0: English, 1: Thai
var _pending_confirm_action: String = ""

func _ready() -> void:
	_init_tab_styles()
	_init_option_popups()
	_connect_signals()
	_init_settings_values()
	_apply_language(0)
	_select_tab("general")

func _init_option_popups() -> void:
	for opt in [language_option, text_speed_option, resolution_option]:
		if opt:
			var popup: PopupMenu = opt.get_popup()
			if popup:
				popup.transparent_bg = true
				if popup_panel_style:
					popup.add_theme_stylebox_override("panel", popup_panel_style)
				if popup_hover_style:
					popup.add_theme_stylebox_override("hover", popup_hover_style)
				popup.add_theme_color_override("font_color", Color(0.91, 0.953, 1.0, 1.0))
				popup.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))

func _init_tab_styles() -> void:
	if not tab_active_style and tab_general and tab_general.has_theme_stylebox("normal"):
		tab_active_style = tab_general.get_theme_stylebox("normal")
	if not tab_inactive_style and tab_audio and tab_audio.has_theme_stylebox("normal"):
		tab_inactive_style = tab_audio.get_theme_stylebox("normal")

func _connect_signals() -> void:
	# Footer buttons
	if settings_back_button and not settings_back_button.pressed.is_connected(_on_back_pressed):
		settings_back_button.pressed.connect(_on_back_pressed)
	if settings_save_button and not settings_save_button.pressed.is_connected(_on_settings_save_pressed):
		settings_save_button.pressed.connect(_on_settings_save_pressed)

	# Settings Tabs
	if tab_general and not tab_general.pressed.is_connected(func() -> void: _select_tab("general")):
		tab_general.pressed.connect(func() -> void: _select_tab("general"))
	if tab_audio and not tab_audio.pressed.is_connected(func() -> void: _select_tab("audio")):
		tab_audio.pressed.connect(func() -> void: _select_tab("audio"))
	if tab_video and not tab_video.pressed.is_connected(func() -> void: _select_tab("video")):
		tab_video.pressed.connect(func() -> void: _select_tab("video"))
	if tab_other and not tab_other.pressed.is_connected(func() -> void: _select_tab("other")):
		tab_other.pressed.connect(func() -> void: _select_tab("other"))

	# Audio Controls
	if master_slider and not master_slider.value_changed.is_connected(_on_master_slider_changed):
		master_slider.value_changed.connect(_on_master_slider_changed)
	if bgm_slider and not bgm_slider.value_changed.is_connected(_on_bgm_slider_changed):
		bgm_slider.value_changed.connect(_on_bgm_slider_changed)
	if sfx_slider and not sfx_slider.value_changed.is_connected(_on_sfx_slider_changed):
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	if mute_all_check_box and not mute_all_check_box.toggled.is_connected(_on_mute_all_toggled):
		mute_all_check_box.toggled.connect(_on_mute_all_toggled)
	if mute_all_label and not mute_all_label.gui_input.is_connected(_on_mute_all_label_gui_input):
		mute_all_label.gui_input.connect(_on_mute_all_label_gui_input)

	# Video Controls
	if fullscreen_check_box and not fullscreen_check_box.toggled.is_connected(_on_fullscreen_toggled):
		fullscreen_check_box.toggled.connect(_on_fullscreen_toggled)
	if fullscreen_label and not fullscreen_label.gui_input.is_connected(_on_fullscreen_label_gui_input):
		fullscreen_label.gui_input.connect(_on_fullscreen_label_gui_input)
	if vsync_check_box and not vsync_check_box.toggled.is_connected(_on_vsync_toggled):
		vsync_check_box.toggled.connect(_on_vsync_toggled)
	if vsync_label and not vsync_label.gui_input.is_connected(_on_vsync_label_gui_input):
		vsync_label.gui_input.connect(_on_vsync_label_gui_input)
	if resolution_option and not resolution_option.item_selected.is_connected(_on_resolution_selected):
		resolution_option.item_selected.connect(_on_resolution_selected)

	# General Controls
	if language_option and not language_option.item_selected.is_connected(_on_language_selected):
		language_option.item_selected.connect(_on_language_selected)
	if text_speed_option and not text_speed_option.item_selected.is_connected(_on_text_speed_selected):
		text_speed_option.item_selected.connect(_on_text_speed_selected)
	if reset_save_button and not reset_save_button.pressed.is_connected(_on_reset_save_pressed):
		reset_save_button.pressed.connect(_on_reset_save_pressed)
	if delete_all_button and not delete_all_button.pressed.is_connected(_on_delete_all_pressed):
		delete_all_button.pressed.connect(_on_delete_all_pressed)

	# Confirmation Modal
	if confirm_cancel_button and not confirm_cancel_button.pressed.is_connected(_close_confirm_modal):
		confirm_cancel_button.pressed.connect(_close_confirm_modal)
	if confirm_ok_button and not confirm_ok_button.pressed.is_connected(_on_confirm_ok_pressed):
		confirm_ok_button.pressed.connect(_on_confirm_ok_pressed)

func _init_settings_values() -> void:
	if language_option:
		language_option.clear()
		language_option.add_item("English", 0)
		language_option.add_item("ไทย", 1)
		language_option.select(0)

	if text_speed_option:
		text_speed_option.clear()
		text_speed_option.add_item("Normal", 0)
		text_speed_option.add_item("Slow", 1)
		text_speed_option.add_item("Fast", 2)
		text_speed_option.add_item("Instant", 3)
		text_speed_option.select(0)

	if fullscreen_check_box:
		var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
		fullscreen_check_box.set_pressed_no_signal(mode == DisplayServer.WINDOW_MODE_FULLSCREEN)

	if vsync_check_box:
		var is_vsync: bool = (DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED)
		vsync_check_box.set_pressed_no_signal(is_vsync)

	if master_slider and master_val_label:
		master_val_label.text = "%d%%" % int(master_slider.value)
		_update_bus_volume("Master", master_slider.value)

	if bgm_slider and bgm_val_label:
		bgm_val_label.text = "%d%%" % int(bgm_slider.value)
		_update_bus_volume("BGM", bgm_slider.value)
		_update_bus_volume("Music", bgm_slider.value)

	if sfx_slider and sfx_val_label:
		sfx_val_label.text = "%d%%" % int(sfx_slider.value)
		_update_bus_volume("SFX", sfx_slider.value)

	if mute_all_check_box:
		var master_idx: int = AudioServer.get_bus_index("Master")
		if master_idx != -1:
			mute_all_check_box.set_pressed_no_signal(AudioServer.is_bus_mute(master_idx))

func open() -> void:
	show()
	_select_tab("general")
	if tab_general:
		tab_general.grab_focus()

func close() -> void:
	hide()
	closed.emit()

func _on_back_pressed() -> void:
	print("ปิดหน้าต่าง SettingsModal (Back Button)")
	close()

func _on_settings_save_pressed() -> void:
	print("บันทึกการตั้งค่าและปิด SettingsModal")
	close()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if confirm_modal and confirm_modal.visible:
			_close_confirm_modal()
			get_viewport().set_input_as_handled()
		else:
			close()
			get_viewport().set_input_as_handled()

func _select_tab(tab_name: String) -> void:
	if panel_general: panel_general.visible = (tab_name == "general")
	if panel_audio: panel_audio.visible = (tab_name == "audio")
	if panel_video: panel_video.visible = (tab_name == "video")
	if panel_other: panel_other.visible = (tab_name == "other")

	_set_tab_button_state(tab_general, tab_name == "general")
	_set_tab_button_state(tab_audio, tab_name == "audio")
	_set_tab_button_state(tab_video, tab_name == "video")
	_set_tab_button_state(tab_other, tab_name == "other")

func _set_tab_button_state(btn: Button, is_active: bool) -> void:
	if not btn:
		return
	if is_active:
		if tab_active_style:
			btn.add_theme_stylebox_override("normal", tab_active_style)
			btn.add_theme_stylebox_override("hover", tab_active_hover_style if tab_active_hover_style else tab_active_style)
			btn.add_theme_stylebox_override("pressed", tab_active_style)
			btn.add_theme_stylebox_override("focus", tab_active_style)
		btn.add_theme_color_override("font_color", Color(0.05, 0.08, 0.15, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.05, 0.08, 0.15, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(0.05, 0.08, 0.15, 1.0))
		btn.add_theme_color_override("font_focus_color", Color(0.05, 0.08, 0.15, 1.0))
	else:
		if tab_inactive_style:
			btn.add_theme_stylebox_override("normal", tab_inactive_style)
			btn.add_theme_stylebox_override("hover", tab_inactive_hover_style if tab_inactive_hover_style else tab_inactive_style)
			btn.add_theme_stylebox_override("pressed", tab_inactive_style)
			btn.add_theme_stylebox_override("focus", tab_inactive_style)
		btn.add_theme_color_override("font_color", Color(0.62, 0.73, 0.84, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(0.92, 0.96, 1.0, 1.0))
		btn.add_theme_color_override("font_pressed_color", Color(0.62, 0.73, 0.84, 1.0))
		btn.add_theme_color_override("font_focus_color", Color(0.62, 0.73, 0.84, 1.0))

func apply_language(idx: int) -> void:
	_apply_language(idx)

func _apply_language(idx: int) -> void:
	current_language_idx = idx
	if language_option and language_option.selected != idx:
		language_option.select(idx)

	# Dynamic Text Speed Option
	if text_speed_option:
		var curr_speed: int = text_speed_option.selected if text_speed_option.selected >= 0 else 0
		text_speed_option.clear()
		if idx == 0:
			text_speed_option.add_item("Normal", 0)
			text_speed_option.add_item("Slow", 1)
			text_speed_option.add_item("Fast", 2)
			text_speed_option.add_item("Instant", 3)
		else:
			text_speed_option.add_item("ปกติ", 0)
			text_speed_option.add_item("ช้า", 1)
			text_speed_option.add_item("เร็ว", 2)
			text_speed_option.add_item("ทันที", 3)
		text_speed_option.select(curr_speed)

	# Dynamic Resolution Option
	if resolution_option:
		var curr_res: int = resolution_option.selected if resolution_option.selected >= 0 else 0
		resolution_option.clear()
		if idx == 0:
			resolution_option.add_item("1280 x 720 (Recommended 16:9)", 0)
			resolution_option.add_item("1920 x 1080 (Full HD)", 1)
		else:
			resolution_option.add_item("1280 x 720 (แนะนำ 16:9)", 0)
			resolution_option.add_item("1920 x 1080 (Full HD)", 1)
		resolution_option.select(curr_res)

	if idx == 0:
		# --- English (Default) ---
		if settings_subtitle: settings_subtitle.text = "Adjust game settings"
		if settings_back_button: settings_back_button.text = "← Back"
		if settings_save_button: settings_save_button.text = "Save & Close"

		# Tab Buttons
		if tab_general: tab_general.text = "General"
		if tab_audio: tab_audio.text = "Audio"
		if tab_video: tab_video.text = "Video"
		if tab_other: tab_other.text = "Other"

		# General Panel
		if lang_label: lang_label.text = "Language:"
		if text_speed_label: text_speed_label.text = "Text Speed:"
		if save_data_label: save_data_label.text = "Save Data Management:"
		if reset_save_button: reset_save_button.text = "Reset Save Data"
		if delete_all_button: delete_all_button.text = "Delete All Save Data"

		# Audio Panel
		if master_label: master_label.text = "Master Volume"
		if bgm_label: bgm_label.text = "BGM Volume"
		if sfx_label: sfx_label.text = "SFX Volume"
		if mute_all_label: mute_all_label.text = "Mute All"

		# Video Panel
		if fullscreen_label: fullscreen_label.text = "Fullscreen"
		if vsync_label: vsync_label.text = "V-Sync"
		if resolution_label: resolution_label.text = "Resolution:"

		# Other Panel
		if studio_label: studio_label.text = "Studio:"
		if studio_val: studio_val.text = "GAME STUDIO"
		if ver_label: ver_label.text = "Game Version:"
		if dev_title_label: dev_title_label.text = "Development Team:"
		if control_guide_title: control_guide_title.text = "Control Guide:"
		if desc_1: desc_1.text = "Character Movement"
		if desc_2: desc_2.text = "Interact / Inspect"
		if desc_3: desc_3.text = "Open Smartphone"
		if desc_4: desc_4.text = "Pause Menu / Back"

		# Confirm Modal
		if confirm_cancel_button: confirm_cancel_button.text = "Cancel"
		if confirm_ok_button: confirm_ok_button.text = "Confirm"
	else:
		# --- ไทย (Thai) ---
		if settings_subtitle: settings_subtitle.text = "ปรับแต่งการตั้งค่าของเกม"
		if settings_back_button: settings_back_button.text = "← ย้อนกลับ"
		if settings_save_button: settings_save_button.text = "บันทึกและปิด"

		# Tab Buttons (Pure Thai, no English)
		if tab_general: tab_general.text = "ทั่วไป"
		if tab_audio: tab_audio.text = "เสียง"
		if tab_video: tab_video.text = "ภาพ"
		if tab_other: tab_other.text = "อื่นๆ"

		# General Panel
		if lang_label: lang_label.text = "ภาษา:"
		if text_speed_label: text_speed_label.text = "ความเร็วข้อความ:"
		if save_data_label: save_data_label.text = "จัดการข้อมูลบันทึก:"
		if reset_save_button: reset_save_button.text = "รีเซ็ตข้อมูลบันทึก"
		if delete_all_button: delete_all_button.text = "ลบข้อมูลบันทึกทั้งหมด"

		# Audio Panel
		if master_label: master_label.text = "ระดับเสียงหลัก"
		if bgm_label: bgm_label.text = "เสียงดนตรีประกอบ"
		if sfx_label: sfx_label.text = "เสียงเอฟเฟกต์"
		if mute_all_label: mute_all_label.text = "ปิดเสียงทั้งหมด"

		# Video Panel
		if fullscreen_label: fullscreen_label.text = "เต็มจอ"
		if vsync_label: vsync_label.text = "เปิดใช้งาน V-Sync"
		if resolution_label: resolution_label.text = "ความละเอียดหน้าจอ:"

		# Other Panel
		if studio_label: studio_label.text = "สตูดิโอ:"
		if studio_val: studio_val.text = "GAME STUDIO"
		if ver_label: ver_label.text = "เวอร์ชันของเกม:"
		if dev_title_label: dev_title_label.text = "ทีมพัฒนา:"
		if control_guide_title: control_guide_title.text = "คู่มือปุ่มควบคุม:"
		if desc_1: desc_1.text = "เดินควบคุมตัวละคร"
		if desc_2: desc_2.text = "สำรวจ / โต้ตอบ"
		if desc_3: desc_3.text = "เปิดโทรศัพท์มือถือ"
		if desc_4: desc_4.text = "เมนูหยุดเกม / ย้อนกลับ"

		# Confirm Modal
		if confirm_cancel_button: confirm_cancel_button.text = "ยกเลิก"
		if confirm_ok_button: confirm_ok_button.text = "ยืนยัน"

func _on_language_selected(index: int) -> void:
	print("เปลี่ยนภาษาเป็น: %s" % ("English" if index == 0 else "ไทย"))
	_apply_language(index)
	language_changed.emit(index)

func _on_text_speed_selected(index: int) -> void:
	var speeds_en: Array[String] = ["Normal", "Slow", "Fast", "Instant"]
	var speeds_th: Array[String] = ["ปกติ", "ช้า", "เร็ว", "ทันที"]
	var selected_name: String = speeds_th[index] if current_language_idx == 1 else speeds_en[index]
	print("ตั้งค่าความเร็วข้อความ: %s" % selected_name)

# --- Settings Audio Controls ---
func _on_master_slider_changed(value: float) -> void:
	if master_val_label:
		master_val_label.text = "%d%%" % int(value)
	_update_bus_volume("Master", value)

func _on_bgm_slider_changed(value: float) -> void:
	if bgm_val_label:
		bgm_val_label.text = "%d%%" % int(value)
	_update_bus_volume("BGM", value)
	_update_bus_volume("Music", value)

func _on_sfx_slider_changed(value: float) -> void:
	if sfx_val_label:
		sfx_val_label.text = "%d%%" % int(value)
	_update_bus_volume("SFX", value)

func _update_bus_volume(bus_name: String, percentage: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		if percentage <= 0.0:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			var db: float = linear_to_db(percentage / 100.0)
			AudioServer.set_bus_volume_db(bus_idx, db)

func _on_mute_all_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if mute_all_check_box:
			mute_all_check_box.button_pressed = not mute_all_check_box.button_pressed

func _on_mute_all_toggled(toggled_on: bool) -> void:
	print("สลับสถานะ Mute All: %s" % toggled_on)
	var bus_idx: int = AudioServer.get_bus_index("Master")
	if bus_idx != -1:
		AudioServer.set_bus_mute(bus_idx, toggled_on)

# --- Settings Video Controls ---
func _on_fullscreen_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if fullscreen_check_box:
			fullscreen_check_box.button_pressed = not fullscreen_check_box.button_pressed

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	print("สลับโหมดหน้าจอ: Fullscreen = %s" % toggled_on)
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_vsync_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if vsync_check_box:
			vsync_check_box.button_pressed = not vsync_check_box.button_pressed

func _on_vsync_toggled(toggled_on: bool) -> void:
	print("ตั้งค่า V-Sync: %s" % toggled_on)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if toggled_on else DisplayServer.VSYNC_DISABLED
	)

func _on_resolution_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		1:
			DisplayServer.window_set_size(Vector2i(1920, 1080))

# --- Settings General Controls & Confirmation ---
func _on_reset_save_pressed() -> void:
	_pending_confirm_action = "reset_save"
	if confirm_message:
		if current_language_idx == 0:
			confirm_message.text = "Are you sure you want to reset save data? This action cannot be undone."
		else:
			confirm_message.text = "คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตข้อมูลบันทึก? ข้อมูลจะไม่สามารถกู้คืนได้"
	if confirm_modal:
		confirm_modal.show()
		if confirm_cancel_button:
			confirm_cancel_button.grab_focus()

func _on_delete_all_pressed() -> void:
	_pending_confirm_action = "delete_all"
	if confirm_message:
		if current_language_idx == 0:
			confirm_message.text = "Are you sure you want to delete all save data? This action cannot be undone."
		else:
			confirm_message.text = "คุณแน่ใจหรือไม่ว่าต้องการลบข้อมูลบันทึกทั้งหมด? ข้อมูลจะไม่สามารถกู้คืนได้"
	if confirm_modal:
		confirm_modal.show()
		if confirm_cancel_button:
			confirm_cancel_button.grab_focus()

func _close_confirm_modal() -> void:
	if confirm_modal:
		confirm_modal.hide()
	_pending_confirm_action = ""

func _on_confirm_ok_pressed() -> void:
	if _pending_confirm_action == "reset_save":
		print("ยืนยันการดำเนินการ: รีเซ็ตข้อมูลบันทึกเรียบร้อยแล้ว")
	elif _pending_confirm_action == "delete_all":
		print("ยืนยันการดำเนินการ: ลบข้อมูลบันทึกทั้งหมดเรียบร้อยแล้ว")
	_close_confirm_modal()
