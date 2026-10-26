extends Node

## GlobalSettings: ระบบจัดการและปรับแต่งค่าภาพ/เสียงกลางของโปรเจกต์

signal language_changed(index: int)
signal text_speed_changed(speed_multiplier: float)

const SETTINGS_FILE_PATH: String = "user://settings.cfg"

# รายการความละเอียดหน้าจอ (ตรงกับใน SettingsModal)
const RESOLUTIONS: Array[Dictionary] = [
	{"label": "960 x 540 (2x)", "size": Vector2i(960, 540)},
	{"label": "1280 x 720 (16:9)", "size": Vector2i(1280, 720)},
	{"label": "1600 x 900 (16:9)", "size": Vector2i(1600, 900)},
	{"label": "1920 x 1080 (FHD)", "size": Vector2i(1920, 1080)},
]

# --- Variable States ---
var is_fullscreen: bool = false
var is_vsync: bool = true
var resolution_index: int = 1

var current_language: int = 0
var text_speed_index: int = 0
var text_speed_multiplier: float = 1.0

var master_volume: float = 80.0
var bgm_volume: float = 80.0
var sfx_volume: float = 80.0
var is_mute_all: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE_PATH) != OK:
		apply_all_settings()
		return
		
	# Load Video Settings
	is_fullscreen = config.get_value("video", "fullscreen", false)
	is_vsync = config.get_value("video", "vsync", true)
	resolution_index = config.get_value("video", "resolution_index", 1)
	
	# Load General Settings
	current_language = config.get_value("general", "language", 0)
	text_speed_index = config.get_value("general", "text_speed", 0)
	_update_text_speed_multiplier(text_speed_index)
	
	# Load Audio Settings
	master_volume = config.get_value("audio", "master_volume", 80.0)
	bgm_volume = config.get_value("audio", "bgm_volume", 80.0)
	sfx_volume = config.get_value("audio", "sfx_volume", 80.0)
	is_mute_all = config.get_value("audio", "mute_all", false)
	
	apply_all_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_FILE_PATH)
	
	config.set_value("video", "fullscreen", is_fullscreen)
	config.set_value("video", "vsync", is_vsync)
	config.set_value("video", "resolution_index", resolution_index)
	
	config.set_value("general", "language", current_language)
	config.set_value("general", "text_speed", text_speed_index)
	
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "mute_all", is_mute_all)
	
	config.save(SETTINGS_FILE_PATH)

func apply_all_settings() -> void:
	set_fullscreen(is_fullscreen)
	set_vsync(is_vsync)
	if not is_fullscreen:
		set_resolution_by_index(resolution_index)
		
	_update_bus("Master", master_volume, is_mute_all)
	_update_bus("BGM", bgm_volume, is_mute_all)
	_update_bus("SFX", sfx_volume, is_mute_all)

# --- Video Setting Functions ---
func set_fullscreen(fullscreen_on: bool) -> void:
	is_fullscreen = fullscreen_on
	var win := get_window()
	if not win:
		return

	if fullscreen_on:
		# Use EXCLUSIVE_FULLSCREEN for Windows (required for proper fullscreen)
		win.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		win.mode = Window.MODE_WINDOWED
		# Re-apply resolution when exiting fullscreen
		set_resolution_by_index(resolution_index)

func set_vsync(vsync_on: bool) -> void:
	is_vsync = vsync_on
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync_on else DisplayServer.VSYNC_DISABLED
	)

func set_resolution_by_index(idx: int) -> void:
	if idx < 0 or idx >= RESOLUTIONS.size():
		return
	resolution_index = idx

	var win := get_window()
	if not win:
		return

	# Only apply resolution in windowed mode
	if not is_fullscreen:
		# Ensure we're in windowed mode
		win.mode = Window.MODE_WINDOWED
		var target_size: Vector2i = RESOLUTIONS[idx]["size"]
		win.size = target_size
		_center_window(target_size)

func _center_window(target_size: Vector2i) -> void:
	var screen_idx: int = DisplayServer.window_get_current_screen()
	var rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_idx)
	if rect.size.x <= 0 or rect.size.y <= 0:
		rect = Rect2i(Vector2i.ZERO, DisplayServer.screen_get_size(screen_idx))
	if rect.size.x > 0 and rect.size.y > 0:
		var target_pos: Vector2i = rect.position + (rect.size - target_size) / 2
		target_pos.x = maxi(target_pos.x, rect.position.x)
		target_pos.y = maxi(target_pos.y, rect.position.y)
		DisplayServer.window_set_position(target_pos)

func set_text_speed(idx: int) -> void:
	text_speed_index = idx
	_update_text_speed_multiplier(idx)
	text_speed_changed.emit(text_speed_multiplier)

func _update_text_speed_multiplier(idx: int) -> void:
	match idx:
		0: text_speed_multiplier = 1.0
		1: text_speed_multiplier = 1.8
		2: text_speed_multiplier = 0.5
		3: text_speed_multiplier = 0.0

func set_language(idx: int) -> void:
	current_language = idx
	language_changed.emit(idx)

func _update_bus(bus_name: String, vol_pct: float, mute: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		if mute or vol_pct <= 0.0:
			AudioServer.set_bus_mute(idx, true)
		else:
			AudioServer.set_bus_mute(idx, false)
			AudioServer.set_bus_volume_db(idx, linear_to_db(vol_pct / 100.0))
