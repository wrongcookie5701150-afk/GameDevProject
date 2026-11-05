class_name DecoderApp extends Control

## Controller for Decoder Application (Forensic OS Simulation)
## Provides decoding (HexCode, Base64, Binary, etc.) and hashing (MD5, SHA-256, etc.) tools.

signal closed()
signal mode_executed(mode_name: String, input_text: String, output_text: String)

@onready var input_edit: TextEdit = find_child("RawCode", true, false).find_child("TextEdit", true, false) as TextEdit
@onready var output_edit: TextEdit = find_child("Result", true, false).find_child("TextEdit", true, false) as TextEdit
@onready var status_label: Label = find_child("StatusLabel", true, false) as Label
@onready var minimize_button: Button = find_child("Minimize", true, false) as Button
@onready var exit_button: Button = find_child("Exit", true, false) as Button

# Scroll & Container Nodes
@onready var scroll_container: ScrollContainer = find_child("ScrollContainer", true, false) as ScrollContainer
@onready var mode_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/DecoderMode/VScrollBar")
@onready var raw_code_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/VBoxContainer/RawCode/VScrollBar")
@onready var result_scroll_bar: VScrollBar = get_node_or_null("ColorRect/HBoxContainer/VBoxContainer/Result/VScrollBar")

var _internal_mode_scroll: VScrollBar = null
var _internal_raw_scroll: VScrollBar = null
var _internal_result_scroll: VScrollBar = null

# Mode Buttons - Category 1: Decoders & Ciphers
@onready var btn_hex: Button = find_child("BtnHex", true, false) as Button
@onready var btn_base64: Button = find_child("BtnBase64", true, false) as Button
@onready var btn_binary: Button = find_child("BtnBinary", true, false) as Button
@onready var btn_rot13: Button = find_child("BtnROT13", true, false) as Button
@onready var btn_morse: Button = find_child("BtnMorse", true, false) as Button
@onready var btn_url: Button = find_child("BtnURL", true, false) as Button
@onready var btn_reverse: Button = find_child("BtnReverse", true, false) as Button
@onready var btn_atbash: Button = find_child("BtnAtbash", true, false) as Button

# Mode Buttons - Category 2: Hashes & Checksums
@onready var btn_md5: Button = find_child("BtnMD5", true, false) as Button
@onready var btn_sha256: Button = find_child("BtnSHA256", true, false) as Button
@onready var btn_sha1: Button = find_child("BtnSHA1", true, false) as Button
@onready var btn_crc32: Button = find_child("BtnCRC32", true, false) as Button

# Helper Action Buttons
@onready var btn_decode: Button = (find_child("BtnDecode", true, false) if find_child("BtnDecode", true, false) else find_child("BtnUseAsInput", true, false)) as Button
@onready var btn_clear: Button = find_child("BtnClear", true, false) as Button
@onready var btn_copy: Button = find_child("BtnCopy", true, false) as Button

var _current_mode_name: String = "HexCode"
var _current_decode_func: Callable = Callable()
var _mode_buttons: Array[Button] = []

const MORSE_TO_CHAR: Dictionary = {
	".-": "A", "-...": "B", "-.-.": "C", "-..": "D", ".": "E",
	"..-.": "F", "--.": "G", "....": "H", "..": "I", ".---": "J",
	"-.-": "K", ".-..": "L", "--": "M", "-.": "N", "---": "O",
	".--.": "P", "--.-": "Q", ".-.": "R", "...": "S", "-": "T",
	"..-": "U", "...-": "V", ".--": "W", "-..-": "X", "-.--": "Y",
	"--..": "Z", "-----": "0", ".----": "1", "..---": "2", "...--": "3",
	"....-": "4", ".....": "5", "-....": "6", "--...": "7", "---..": "8",
	"----.": "9", ".-.-.-": ".", "--..--": ",", "..--..": "?",
	".----.": "'", "-.-.--": "!", "-..-.": "/", "-.--.": "(",
	"-.--.-": ")", ".-...": "&", "---...": ":", "-.-.-.": ";",
	"-...-": "=", ".-.-.": "+", "-....-": "-", "..--.-": "_",
	".-..-.": "\"", "...-..-": "$", ".--.-.": "@"
}

var _char_to_morse: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for code in MORSE_TO_CHAR:
		_char_to_morse[MORSE_TO_CHAR[code]] = code
	_char_to_morse[" "] = "/"

	if minimize_button:
		minimize_button.pressed.connect(func() -> void: hide())
	if exit_button:
		exit_button.pressed.connect(func() -> void:
			hide()
			closed.emit()
		)
	
	_register_mode_button(btn_hex, "HexCode", _decode_hex)
	_register_mode_button(btn_base64, "Base64", _decode_base64)
	_register_mode_button(btn_binary, "Binary", _decode_binary)
	_register_mode_button(btn_rot13, "ROT13", _decode_rot13)
	_register_mode_button(btn_morse, "Morse Code", _decode_morse)
	_register_mode_button(btn_url, "URL Decode", _decode_url)
	_register_mode_button(btn_reverse, "Reverse Text", _decode_reverse)
	_register_mode_button(btn_atbash, "Atbash", _decode_atbash)
	
	_register_mode_button(btn_md5, "MD5 Hash", _hash_md5)
	_register_mode_button(btn_sha256, "SHA-256", _hash_sha256)
	_register_mode_button(btn_sha1, "SHA-1", _hash_sha1)
	_register_mode_button(btn_crc32, "CRC32", _hash_crc32)
	
	if btn_hex:
		_select_mode(btn_hex, "HexCode", _decode_hex)
		if status_label:
			status_label.text = "Status: 1. Select Mode -> 2. Enter Code -> 3. Click ▶ Decode"
	
	if btn_decode:
		btn_decode.pressed.connect(_on_decode_pressed)
	if btn_clear:
		btn_clear.pressed.connect(_on_clear_pressed)
	if btn_copy:
		btn_copy.pressed.connect(_on_copy_pressed)

	call_deferred("_post_init_scrollbars")

func _process(_delta: float) -> void:
	_sync_ranges_if_needed(_internal_mode_scroll, mode_scroll_bar)
	_sync_ranges_if_needed(_internal_raw_scroll, raw_code_scroll_bar)
	_sync_ranges_if_needed(_internal_result_scroll, result_scroll_bar)

func _sync_ranges_if_needed(internal: VScrollBar, custom: VScrollBar) -> void:
	if not is_instance_valid(internal) or not is_instance_valid(custom):
		return
	if not is_equal_approx(custom.max_value, internal.max_value) or not is_equal_approx(custom.page, internal.page):
		custom.min_value = internal.min_value
		custom.max_value = internal.max_value
		custom.page = internal.page
		custom.step = internal.step
	if not is_equal_approx(custom.value, internal.value):
		custom.value = internal.value

func _post_init_scrollbars() -> void:
	_setup_custom_scrollbars()

func _setup_custom_scrollbars() -> void:
	if not mode_scroll_bar:
		var mode_panel := get_node_or_null("ColorRect/HBoxContainer/DecoderMode")
		if mode_panel:
			mode_scroll_bar = mode_panel.get_node_or_null("VScrollBar") as VScrollBar
		elif scroll_container and scroll_container.get_parent():
			mode_scroll_bar = scroll_container.get_parent().get_node_or_null("VScrollBar") as VScrollBar

	if scroll_container and mode_scroll_bar:
		_internal_mode_scroll = _get_internal_v_scrollbar(scroll_container)
		if _internal_mode_scroll:
			_bind_scrollbar(_internal_mode_scroll, mode_scroll_bar)

	if input_edit and raw_code_scroll_bar:
		_internal_raw_scroll = _get_internal_v_scrollbar(input_edit)
		if _internal_raw_scroll:
			_bind_scrollbar(_internal_raw_scroll, raw_code_scroll_bar)

	if output_edit and result_scroll_bar:
		_internal_result_scroll = _get_internal_v_scrollbar(output_edit)
		if _internal_result_scroll:
			_bind_scrollbar(_internal_result_scroll, result_scroll_bar)

func _get_internal_v_scrollbar(control: Control) -> VScrollBar:
	if not control:
		return null
	if control.has_method("get_v_scroll_bar"):
		return control.call("get_v_scroll_bar") as VScrollBar
	for child in control.get_children(true):
		if child is VScrollBar:
			return child as VScrollBar
	var scrollbars := control.find_children("*", "VScrollBar", true, false)
	if scrollbars.size() > 0:
		return scrollbars[0] as VScrollBar
	return null

func _bind_scrollbar(internal: VScrollBar, custom: VScrollBar) -> void:
	if not internal or not custom:
		return

	# Visually hide the internal default scrollbar and pass mouse clicks through
	internal.modulate.a = 0.0
	internal.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Ensure custom scrollbar layout and grabber styling
	_ensure_scrollbar_styling(custom)

	# Sync range properties (min, max, page, step) whenever internal changes
	var sync_ranges := func() -> void:
		if is_instance_valid(internal) and is_instance_valid(custom):
			custom.min_value = internal.min_value
			custom.max_value = internal.max_value
			custom.page = internal.page
			custom.step = internal.step

	if not internal.changed.is_connected(sync_ranges):
		internal.changed.connect(sync_ranges)
	sync_ranges.call()

	# Custom scrollbar dragging -> internal scrolling
	if not custom.value_changed.is_connected(_on_custom_scroll_changed.bind(internal)):
		custom.value_changed.connect(_on_custom_scroll_changed.bind(internal))

	# Internal scrolling (mouse wheel, caret navigation) -> custom scrollbar
	if not internal.value_changed.is_connected(_on_internal_scroll_changed.bind(custom)):
		internal.value_changed.connect(_on_internal_scroll_changed.bind(custom))

func _on_custom_scroll_changed(new_val: float, internal: VScrollBar) -> void:
	if is_instance_valid(internal) and not is_equal_approx(internal.value, new_val):
		internal.value = new_val

func _on_internal_scroll_changed(new_val: float, custom: VScrollBar) -> void:
	if is_instance_valid(custom) and not is_equal_approx(custom.value, new_val):
		custom.value = new_val

func _ensure_scrollbar_styling(scrollbar: VScrollBar) -> void:
	if not scrollbar:
		return

	scrollbar.z_index = 2
	scrollbar.mouse_filter = Control.MOUSE_FILTER_STOP
	scrollbar.visible = true

	scrollbar.anchor_left = 1.0
	scrollbar.anchor_right = 1.0
	scrollbar.offset_left = -3.0
	scrollbar.offset_right = 0.0
	scrollbar.custom_minimum_size = Vector2(3, 0)

	if not scrollbar.has_theme_stylebox_override("grabber"):
		var grabber_box: StyleBoxFlat = StyleBoxFlat.new()
		grabber_box.bg_color = Color(0.50, 0.75, 0.90, 0.85)
		grabber_box.corner_radius_top_left = 1
		grabber_box.corner_radius_top_right = 1
		grabber_box.corner_radius_bottom_right = 1
		grabber_box.corner_radius_bottom_left = 1
		scrollbar.add_theme_stylebox_override("grabber", grabber_box)

	if not scrollbar.has_theme_stylebox_override("grabber_highlight"):
		var hl_box: StyleBoxFlat = StyleBoxFlat.new()
		hl_box.bg_color = Color(0.70, 0.90, 1.0, 1.0)
		hl_box.corner_radius_top_left = 1
		hl_box.corner_radius_top_right = 1
		hl_box.corner_radius_bottom_right = 1
		hl_box.corner_radius_bottom_left = 1
		scrollbar.add_theme_stylebox_override("grabber_highlight", hl_box)

	if not scrollbar.has_theme_stylebox_override("grabber_pressed"):
		var pr_box: StyleBoxFlat = StyleBoxFlat.new()
		pr_box.bg_color = Color(1.0, 1.0, 1.0, 1.0)
		pr_box.corner_radius_top_left = 1
		pr_box.corner_radius_top_right = 1
		pr_box.corner_radius_bottom_right = 1
		pr_box.corner_radius_bottom_left = 1
		scrollbar.add_theme_stylebox_override("grabber_pressed", pr_box)

func _register_mode_button(btn: Button, mode_name: String, decode_func: Callable) -> void:
	if not btn:
		return
	btn.toggle_mode = true
	_mode_buttons.append(btn)
	btn.pressed.connect(func() -> void:
		_select_mode(btn, mode_name, decode_func)
	)

func _select_mode(btn: Button, mode_name: String, decode_func: Callable) -> void:
	_current_mode_name = mode_name
	_current_decode_func = decode_func
	for b in _mode_buttons:
		b.button_pressed = (b == btn)
	if status_label:
		status_label.text = "Selected: %s | Enter code & click ▶ Decode" % mode_name

func _on_decode_pressed() -> void:
	if not input_edit or not output_edit:
		return
	var raw_text: String = input_edit.text
	if raw_text.strip_edges().is_empty():
		output_edit.text = "[!] Input is empty. Please enter or paste text in the top box."
		if status_label:
			status_label.text = "Status: Input is empty"
		return
	
	if not _current_decode_func.is_valid():
		output_edit.text = "[!] Please select a decoding mode on the left first."
		if status_label:
			status_label.text = "Status: Select a mode on the left"
		return
		
	var prev_status: String = status_label.text if status_label else ""
	var result: String = _current_decode_func.call(raw_text)
	output_edit.text = result
	if status_label and status_label.text == prev_status:
		status_label.text = "%s completed" % _current_mode_name
	mode_executed.emit(_current_mode_name, raw_text, result)

func _on_clear_pressed() -> void:
	if input_edit:
		input_edit.text = ""
	if output_edit:
		output_edit.text = ""
	if status_label:
		status_label.text = "Cleared"

func _on_copy_pressed() -> void:
	if not output_edit:
		return
	var text_to_copy: String = output_edit.text.strip_edges()
	if not text_to_copy.is_empty() and not text_to_copy.begins_with("[!]"):
		DisplayServer.clipboard_set(text_to_copy)
		if status_label:
			status_label.text = "Copied to clipboard! (%d chars)" % text_to_copy.length()

# ----------------- Decoder & Cipher Implementations -----------------

func _decode_hex(raw: String) -> String:
	var clean: String = raw.strip_edges()
	clean = clean.replace("0x", "").replace("0X", "").replace("\\x", "").replace("\\X", "")
	clean = clean.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "").replace(":", "").replace("-", "").replace(",", "")
	
	var is_hex: bool = clean.length() >= 2
	if is_hex:
		for i in range(clean.length()):
			var c: String = clean[i]
			if not ((c >= '0' and c <= '9') or (c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F')):
				is_hex = false
				break
				
	if is_hex and clean.length() % 2 == 0:
		var bytes: PackedByteArray = PackedByteArray()
		for i in range(0, clean.length(), 2):
			bytes.append(clean.substr(i, 2).hex_to_int())
		
		var decoded: String = bytes.get_string_from_utf8()
		if decoded.is_empty() and not bytes.is_empty():
			var ascii_str: String = ""
			for b in bytes:
				if b >= 32 and b <= 126:
					ascii_str += String.chr(b)
				elif b == 10:
					ascii_str += "\n"
				elif b == 13 or b == 9:
					ascii_str += " "
				else:
					ascii_str += "."
			decoded = ascii_str
			
		if not decoded.is_empty():
			if status_label:
				status_label.text = "HexCode Decoded (%d bytes)" % bytes.size()
			return decoded
			
	# If input is text or odd hex, ENCODE text -> HexCode
	var bytes_to_encode: PackedByteArray = raw.to_utf8_buffer()
	var hex_out: String = ""
	for i in range(bytes_to_encode.size()):
		hex_out += "%02X" % bytes_to_encode[i]
		if i < bytes_to_encode.size() - 1:
			hex_out += " "
			
	if status_label:
		status_label.text = "HexCode Encoded (%d bytes)" % bytes_to_encode.size()
	return hex_out

func _decode_base64(raw: String) -> String:
	var clean: String = raw.strip_edges()
	clean = clean.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "")
	clean = clean.replace("-", "+").replace("_", "/")
	
	var is_b64_chars: bool = clean.length() > 0
	for i in range(clean.length()):
		var c: String = clean[i]
		if not ((c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9') or c == '+' or c == '/' or c == '='):
			is_b64_chars = false
			break
			
	if is_b64_chars:
		var padded: String = clean
		while padded.length() % 4 != 0:
			padded += "="
			
		var bytes: PackedByteArray = Marshalls.base64_to_raw(padded)
		if not bytes.is_empty():
			var decoded: String = bytes.get_string_from_utf8()
			if decoded.is_empty():
				var ascii_str: String = ""
				var printable_count: int = 0
				for b in bytes:
					if (b >= 32 and b <= 126) or b == 10 or b == 13 or b == 9:
						ascii_str += String.chr(b)
						printable_count += 1
					else:
						ascii_str += "."
				if printable_count > bytes.size() / 2:
					decoded = ascii_str
					
			if not decoded.is_empty():
				if status_label:
					status_label.text = "Base64 Decoded (%d bytes)" % bytes.size()
				return decoded
				
	# Encode to Base64
	var encoded: String = Marshalls.raw_to_base64(raw.to_utf8_buffer())
	if status_label:
		status_label.text = "Base64 Encoded (%d chars)" % encoded.length()
	return encoded

func _decode_binary(raw: String) -> String:
	var clean: String = raw.strip_edges()
	clean = clean.replace("0b", "").replace("0B", "").replace(",", "")
	clean = clean.replace(" ", "").replace("\n", "").replace("\r", "").replace("\t", "")
	
	var is_pure_binary: bool = clean.length() >= 8
	for i in range(clean.length()):
		var c: String = clean[i]
		if c != "0" and c != "1":
			is_pure_binary = false
			break
			
	if is_pure_binary and clean.length() % 8 == 0:
		var bytes: PackedByteArray = PackedByteArray()
		for i in range(0, clean.length(), 8):
			var byte_str: String = clean.substr(i, 8)
			var val: int = 0
			for bit in byte_str:
				val = (val << 1) | (1 if bit == "1" else 0)
			bytes.append(val)
			
		var decoded: String = bytes.get_string_from_utf8()
		if decoded.is_empty() and not bytes.is_empty():
			var ascii_str: String = ""
			for b in bytes:
				if b >= 32 and b <= 126:
					ascii_str += String.chr(b)
				elif b == 10:
					ascii_str += "\n"
				else:
					ascii_str += "."
			decoded = ascii_str
			
		if not decoded.is_empty():
			if status_label:
				status_label.text = "Binary Decoded (%d bytes)" % bytes.size()
			return decoded
			
	# Encode to Binary
	var bytes_to_encode: PackedByteArray = raw.to_utf8_buffer()
	var bin_parts: PackedStringArray = PackedStringArray()
	for b in bytes_to_encode:
		var s: String = ""
		for bit_idx in range(7, -1, -1):
			s += "1" if ((b >> bit_idx) & 1) != 0 else "0"
		bin_parts.append(s)
		
	var result_bin: String = " ".join(bin_parts)
	if status_label:
		status_label.text = "Binary Encoded (%d bytes)" % bytes_to_encode.size()
	return result_bin

func _decode_rot13(raw: String) -> String:
	var res: String = ""
	for i in range(raw.length()):
		var code: int = raw.unicode_at(i)
		if code >= 65 and code <= 90:
			res += String.chr(((code - 65 + 13) % 26) + 65)
		elif code >= 97 and code <= 122:
			res += String.chr(((code - 97 + 13) % 26) + 97)
		else:
			res += raw[i]
	if status_label:
		status_label.text = "ROT13 Applied (Shift 13)"
	return res

func _decode_morse(raw: String) -> String:
	var clean: String = raw.strip_edges()
	
	var has_morse_symbols: bool = false
	var has_letters: bool = false
	
	for i in range(clean.length()):
		var c: String = clean[i]
		if c == "." or c == "-":
			has_morse_symbols = true
		elif (c >= "A" and c <= "Z") or (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			has_letters = true
			
	if has_morse_symbols and not has_letters:
		# DECODE Morse -> Text
		var normalized: String = clean.replace("\n", " / ").replace("|", " / ")
		var tokens: PackedStringArray = normalized.split(" ", false)
		var decoded: String = ""
		for token in tokens:
			token = token.strip_edges()
			if token.is_empty():
				continue
			if token == "/" or token == "//":
				if not decoded.ends_with(" "):
					decoded += " "
			elif MORSE_TO_CHAR.has(token):
				decoded += MORSE_TO_CHAR[token]
			else:
				decoded += "?"
		if status_label:
			status_label.text = "Morse Code Decoded"
		return decoded
	else:
		# ENCODE Text -> Morse
		var upper_text: String = clean.to_upper()
		var morse_parts: PackedStringArray = PackedStringArray()
		for i in range(upper_text.length()):
			var ch: String = upper_text[i]
			if ch == " ":
				morse_parts.append("/")
			elif _char_to_morse.has(ch):
				morse_parts.append(_char_to_morse[ch])
			elif ch == "\n":
				morse_parts.append("/")
		var result: String = " ".join(morse_parts)
		if status_label:
			status_label.text = "Morse Code Encoded"
		return result

func _decode_url(raw: String) -> String:
	if "%" in raw:
		var decoded: String = raw.replace("+", " ").uri_decode()
		if status_label:
			status_label.text = "URL Decoded"
		return decoded
	else:
		var encoded: String = raw.uri_encode()
		if status_label:
			status_label.text = "URL Encoded"
		return encoded

func _decode_reverse(raw: String) -> String:
	var res: String = ""
	for i in range(raw.length() - 1, -1, -1):
		res += raw[i]
	if status_label:
		status_label.text = "Text Reversed (%d chars)" % res.length()
	return res

func _decode_atbash(raw: String) -> String:
	var res: String = ""
	for i in range(raw.length()):
		var code: int = raw.unicode_at(i)
		if code >= 65 and code <= 90:
			res += String.chr(90 - (code - 65))
		elif code >= 97 and code <= 122:
			res += String.chr(122 - (code - 97))
		else:
			res += raw[i]
	if status_label:
		status_label.text = "Atbash Cipher Applied"
	return res

# ----------------- Hash & Checksum Implementations -----------------

func _hash_md5(raw: String) -> String:
	var hash_str: String = raw.md5_text().to_lower()
	if status_label:
		status_label.text = "MD5 Hash: 32 hex chars (128-bit)"
	return hash_str

func _hash_sha256(raw: String) -> String:
	var hash_str: String = raw.sha256_text().to_lower()
	if status_label:
		status_label.text = "SHA-256 Hash: 64 hex chars (256-bit)"
	return hash_str

func _hash_sha1(raw: String) -> String:
	var ctx: HashingContext = HashingContext.new()
	var err: Error = ctx.start(HashingContext.HASH_SHA1)
	if err != OK:
		return "[ERROR] Failed to initialize SHA-1 context."
	ctx.update(raw.to_utf8_buffer())
	var res: PackedByteArray = ctx.finish()
	var hash_str: String = res.hex_encode().to_lower()
	if status_label:
		status_label.text = "SHA-1 Hash: 40 hex chars (160-bit)"
	return hash_str

func _hash_crc32(raw: String) -> String:
	var bytes: PackedByteArray = raw.to_utf8_buffer()
	var crc: int = 0xFFFFFFFF
	for b in bytes:
		crc ^= b
		for _j in range(8):
			var mask: int = -(crc & 1)
			crc = (crc >> 1) ^ (0xEDB88320 & mask)
	var final_crc: int = (~crc & 0xFFFFFFFF)
	var crc_str: String = "%08X" % final_crc
	if status_label:
		status_label.text = "CRC32 Checksum (32-bit): 0x%s" % crc_str
	return crc_str
