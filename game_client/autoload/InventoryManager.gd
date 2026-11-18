# res://autoload/InventoryManager.gd
extends Node

## ระบบ Inventory สำหรับผู้เล่น (Player Item Inventory)
## - จัดเก็บไอเทมได้สูงสุด 3 ช่อง (Slot 0=ปุ่ม 1, Slot 1=ปุ่ม 2, Slot 2=ปุ่ม 3)
## - ไอเทมที่หยิบก่อนจะอยู่ช่องเลขน้อยกว่า
## - กดเลข 1, 2, 3 เพื่อสลับเลือกไอเทม
## - กดเลขเดิมซ้ำ หรือกดปุ่ม V เพื่อไม่ถือไอเทมชิ้นใดเลย

signal slot_selected(slot_index: int, item_data: Dictionary)
signal item_added(slot_index: int, item_data: Dictionary)
signal item_removed(slot_index: int, item_data: Dictionary)
signal inventory_updated()
signal visibility_changed(is_visible: bool)

const MAX_SLOTS: int = 3

## One-way investigation progression phase
## 0 = Before TaoDam (Scene 4 initial)
## 1 = Investigating on TaoDam (Scene 5 & 6)
## 2 = TaoDam investigation done (Returned to bedroom in Scene 4 to pin notes and go to PC)
## 3 = Recovery & Post-test in Scene 7
var investigation_phase: int = 0
var pinned_notes: Array[String] = []

## รายการ note_id ของโน้ตความรู้ที่ผู้เล่นถืออยู่ในกระเป๋าขณะนี้
var knowledge_notes: Array[String]:
	get:
		var held: Array[String] = []
		for slot in slots:
			if not slot.is_empty():
				var item_id: String = slot.get("id", "")
				if item_id.begins_with("note_"):
					held.append(item_id)
		return held

const KNOWLEDGE_NOTES: Dictionary = {
	"note_forensic_prep": {
		"name": "📝 โน้ต #1: การเก็บสำเนาหลักฐาน",
		"short_title": "Forensic Image",
		"description": "บันทึกการทำ Forensic Image แบบ Read-only ลงแฟลชไดรฟ์แยก (นำไปแปะที่ NoteBoard เพื่ออ่านสรุป)"
	},
	"note_isolation_logs": {
		"name": "📝 โน้ต #2: การแยกเครื่อง & ตรวจ Log",
		"short_title": "Isolation & Logs",
		"description": "บันทึกการ Isolate เต่าดำ, MD5 Hash, Event Log และ Typosquatting (นำไปแปะที่ NoteBoard เพื่ออ่านสรุป)"
	},
	"note_malware_payload": {
		"name": "📝 โน้ต #3: โครงสร้างมาโคร & เพย์โหลด",
		"short_title": "Macro & Payload",
		"description": "บันทึกโค้ด vbaProject.bin และการถอดรหัส Base64/Hex (นำไปแปะที่ NoteBoard เพื่ออ่านสรุป)"
	},
	"note_persistence_stop": {
		"name": "📝 โน้ต #4: การตัดวงจรฝังตัว",
		"short_title": "Persistence Stop",
		"description": "บันทึกขั้นตอนหยุด Persistence 7 ขั้นตอนใน Safe Mode (นำไปแปะที่ NoteBoard เพื่ออ่านสรุป)"
	},
	"note_backup_recovery": {
		"name": "📝 โน้ต #5: กฎสำรองข้อมูล 3-2-1",
		"short_title": "3-2-1 Backup",
		"description": "บันทึกกฎสำรองข้อมูล 3-2-1 และการปิด Cloud Sync (นำไปแปะที่ NoteBoard เพื่ออ่านสรุป)"
	}
}

var _pencil_sfx_player: AudioStreamPlayer = null
var _paper_pin_player: AudioStreamPlayer = null

# ช่องเก็บไอเทม: Array ขนาด MAX_SLOTS เก็บ Dictionary ของแต่ละไอเทม (หรือ {} ถ้าว่าง)
# โครงสร้างของ Dictionary:
# {
#   "id": "ev_drive",
#   "name": "EV Drive",
#   "icon": Texture2D,
#   "description": "Flash drive containing evidence"
# }
var slots: Array[Dictionary] = []

# ช่องที่กำลังเลือกอยู่ (-1 = ไม่ได้เลือก / ไม่ถือของชิ้นใดเลย)
var selected_slot: int = -1

# สถานะการเปิด/ปิดแสดงผล Inventory (ซ่อนเมื่อไม่ได้อยู่ใน Playground เช่น ตอนใช้คอม)
var is_visible: bool = true:
	set(value):
		if is_visible != value:
			is_visible = value
			visibility_changed.emit(is_visible)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_slots()

func _init_slots() -> void:
	slots.clear()
	for i in range(MAX_SLOTS):
		slots.append({})

## เพิ่มไอเทมเข้ากระเป๋า:
## ไอเทมที่หยิบก่อนจะเข้าช่องเลขน้อยกว่าเสมอ (Slot 0 = [1], Slot 1 = [2], Slot 2 = [3])
## คืนค่า slot_index ที่เก็บได้ (0..2) หรือ -1 ถ้ากระเป๋าเต็ม
func add_item(item_id: String, item_name: String = "", icon: Texture2D = null, description: String = "") -> int:
	if item_id.is_empty():
		return -1

	# 1. หากมีไอเทมนี้อยู่ในกระเป๋าแล้ว ไม่เพิ่มซ้ำ และคืนตำแหน่งเดิม
	for i in range(MAX_SLOTS):
		if not slots[i].is_empty() and slots[i].get("id", "") == item_id:
			return i

	# 2. หาช่องว่างที่มี index ต่ำที่สุด (เลขน้อยกว่า)
	for i in range(MAX_SLOTS):
		if slots[i].is_empty():
			var default_icon: Texture2D = icon
			if not default_icon:
				if "disk" in item_id or "drive" in item_id or "usb" in item_id:
					default_icon = load("res://assets/Icon32x32/disk.png")
				elif "note" in item_id or "book" in item_id:
					default_icon = load("res://assets/Icon32x32/book.png")
				else:
					default_icon = load("res://assets/Icon32x32/item.png")

			var data: Dictionary = {
				"id": item_id,
				"name": item_name if not item_name.is_empty() else item_id.capitalize(),
				"icon": default_icon,
				"description": description
			}
			slots[i] = data
			item_added.emit(i, data)
			inventory_updated.emit()
			print("[InventoryManager] Item added: %s at slot %d" % [item_id, i + 1])
			return i

	print("[InventoryManager] Inventory is full (%d/%d slots)" % [MAX_SLOTS, MAX_SLOTS])
	return -1

## เลือกช่องไอเทม (slot_index: 0=เลข 1, 1=เลข 2, 2=เลข 3)
## หากกดเลขเดิมซ้ำ จะยกเลิกการเลือก (ไม่ถือของชิ้นใดเลย)
func select_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return

	if selected_slot == slot_index:
		# กดเลขเดิมซ้ำ -> ไม่ถือของชิ้นใดเลย
		deselect()
	else:
		selected_slot = slot_index
		var active_item: Dictionary = get_active_item()
		slot_selected.emit(selected_slot, active_item)
		inventory_updated.emit()
		print("[InventoryManager] Selected slot: %d (%s)" % [slot_index + 1, active_item.get("name", "Empty")])

## ไม่ถือของชิ้นใดเลย (กด V หรือเรียกใช้โดยตรง)
func deselect() -> void:
	if selected_slot != -1:
		selected_slot = -1
		slot_selected.emit(-1, {})
		inventory_updated.emit()
		print("[InventoryManager] Deselected: Holding nothing")

## ข้อมูลไอเทมในช่องที่กำลังเลือกอยู่ (หรือ {} ถ้าไม่ได้เลือก)
func get_active_item() -> Dictionary:
	if selected_slot >= 0 and selected_slot < MAX_SLOTS:
		return slots[selected_slot]
	return {}

## ID ของไอเทมที่กำลังถืออยู่ (หรือ "" ถ้าไม่ได้เลือก)
func get_active_item_id() -> String:
	return get_active_item().get("id", "")

## ตรวจสอบว่ามีไอเทมตาม ID ในกระเป๋าหรือไม่
func has_item(item_id: String) -> bool:
	for slot in slots:
		if not slot.is_empty() and slot.get("id", "") == item_id:
			return true
	return false

## ตรวจสอบว่าผู้เล่นได้รับโน้ตนี้แล้วหรือไม่ (ทั้งในกระเป๋าหรือแปะบนกระดานแล้ว)
func has_knowledge_note(note_id: String) -> bool:
	if pinned_notes.has(note_id):
		return true
	return has_item(note_id)

## นำไอเทมออกจากกระเป๋า
func remove_item(item_id: String) -> bool:
	for i in range(MAX_SLOTS):
		if not slots[i].is_empty() and slots[i].get("id", "") == item_id:
			var removed_data: Dictionary = slots[i]
			slots[i] = {}
			if selected_slot == i:
				deselect()
			item_removed.emit(i, removed_data)
			inventory_updated.emit()
			print("[InventoryManager] Item removed: %s from slot %d" % [item_id, i + 1])
			return true
	return false

## ล้างของทั้งหมดในกระเป๋า
func clear() -> void:
	_init_slots()
	deselect()
	investigation_phase = 0
	pinned_notes.clear()
	inventory_updated.emit()

func _init_pencil_sfx() -> void:
	if _pencil_sfx_player:
		return
	_pencil_sfx_player = AudioStreamPlayer.new()
	_pencil_sfx_player.name = "PencilSFXPlayer"
	var sfx_idx: int = AudioServer.get_bus_index("SFX")
	_pencil_sfx_player.bus = "SFX" if sfx_idx != -1 else "Master"
	add_child(_pencil_sfx_player)
	
	var sample_rate: int = 22050
	var duration: float = 0.38
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var stroke_env: float = 0.0
		if t < 0.11:
			stroke_env = sin(t / 0.11 * PI)
		elif t >= 0.13 and t < 0.24:
			stroke_env = sin((t - 0.13) / 0.11 * PI)
		elif t >= 0.26 and t < 0.37:
			stroke_env = sin((t - 0.26) / 0.11 * PI)
		
		var noise: float = randf_range(-1.0, 1.0) * 0.75
		var resonance: float = sin(t * 3100.0 * TAU) * 0.25
		var sample_val: float = (noise + resonance) * stroke_env * 0.22
		var sample_int: int = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample_int)
	
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	_pencil_sfx_player.stream = wav

func play_pencil_sfx() -> void:
	if not _pencil_sfx_player:
		_init_pencil_sfx()
	if _pencil_sfx_player and _pencil_sfx_player.stream:
		_pencil_sfx_player.play()

func _init_paper_pin_sfx() -> void:
	if _paper_pin_player:
		return
	_paper_pin_player = AudioStreamPlayer.new()
	_paper_pin_player.name = "PaperPinPlayer"
	var sfx_idx: int = AudioServer.get_bus_index("SFX")
	_paper_pin_player.bus = "SFX" if sfx_idx != -1 else "Master"
	add_child(_paper_pin_player)
	
	var sample_rate: int = 22050
	var duration: float = 0.15
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = exp(-t * 28.0)
		var pop: float = sin(t * 450.0 * TAU) * 0.6 + randf_range(-0.4, 0.4) * 0.4
		var sample_val: float = pop * env * 0.3
		var sample_int: int = int(clamp(sample_val, -1.0, 1.0) * 32767.0)
		data.encode_s16(i * 2, sample_int)
	
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	_paper_pin_player.stream = wav

func play_paper_pin_sfx() -> void:
	if not _paper_pin_player:
		_init_paper_pin_sfx()
	if _paper_pin_player and _paper_pin_player.stream:
		_paper_pin_player.play()

## แจกโน้ตองค์ความรู้เข้ากระเป๋า 3 ช่อง พร้อมเสียงดินสอและ Toast
func award_knowledge_note(note_id: String, parent_context: Node = null) -> int:
	if not KNOWLEDGE_NOTES.has(note_id):
		push_warning("[InventoryManager] Unknown note_id: %s" % note_id)
		return -1
	
	if pinned_notes.has(note_id):
		return -1
	for slot in slots:
		if not slot.is_empty() and slot.get("id", "") == note_id:
			return -1
	
	play_pencil_sfx()
	
	var note_info: Dictionary = KNOWLEDGE_NOTES[note_id]
	var note_name: String = note_info.get("name", "📝 โน้ตความรู้")
	var note_desc: String = note_info.get("description", "")
	var note_icon: Texture2D = load("res://assets/Icon32x32/book.png")
	
	var slot_idx: int = add_item(note_id, note_name, note_icon, note_desc)
	show_knowledge_toast("✏️ จดบันทึกองค์ความรู้ใหม่ลงกระเป๋าแล้ว!\n(นำไปแปะที่ NoteBoard เพื่ออ่านสรุป)", parent_context)
	return slot_idx

## แสดงแบนเนอร์ Toast แจ้งเตือนสั้นๆ ด้านบนของจอ
func show_knowledge_toast(message: String, parent_context: Node = null) -> void:
	var target_parent: Node = parent_context
	if not target_parent:
		var tree: SceneTree = get_tree()
		if tree and tree.root:
			target_parent = tree.root
	if not target_parent:
		return
	
	var toast_layer: CanvasLayer = CanvasLayer.new()
	toast_layer.layer = 120
	target_parent.add_child(toast_layer)
	
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	panel.offset_left = 60.0
	panel.offset_top = 8.0
	panel.offset_right = -60.0
	panel.offset_bottom = 36.0
	
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.16, 0.24, 0.95)
	sb.border_color = Color(0.95, 0.82, 0.35, 0.9)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_right = 4
	sb.corner_radius_bottom_left = 4
	sb.content_margin_left = 8.0
	sb.content_margin_top = 3.0
	sb.content_margin_right = 8.0
	sb.content_margin_bottom = 3.0
	panel.add_theme_stylebox_override("panel", sb)
	
	var label: Label = Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 6)
	label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75, 1.0))
	panel.add_child(label)
	toast_layer.add_child(panel)
	
	var timer := target_parent.get_tree().create_timer(3.0)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(toast_layer):
			toast_layer.queue_free()
	)

## แปะโน้ตที่กำลังเลือกอยู่ลงกระดาน NoteBoard
func pin_active_note_to_board() -> String:
	var active_id: String = get_active_item_id()
	if active_id.begins_with("note_") and KNOWLEDGE_NOTES.has(active_id):
		if not pinned_notes.has(active_id):
			pinned_notes.append(active_id)
		remove_item(active_id)
		play_paper_pin_sfx()
		return active_id
	return ""

## แปะโน้ตความรู้ทั้งหมดในกระเป๋าลงกระดาน NoteBoard
func pin_all_inventory_notes_to_board() -> Array[String]:
	var pinned_list: Array[String] = []
	for i in range(MAX_SLOTS):
		if not slots[i].is_empty():
			var item_id: String = slots[i].get("id", "")
			if item_id.begins_with("note_") and KNOWLEDGE_NOTES.has(item_id):
				if not pinned_notes.has(item_id):
					pinned_notes.append(item_id)
				pinned_list.append(item_id)
				remove_item(item_id)
	if not pinned_list.is_empty():
		play_paper_pin_sfx()
	return pinned_list

## กำหนดการแสดงผล Inventory (ซ่อนเมื่อไม่ได้อยู่ใน Playground เช่น ตอนใช้คอม)
func set_inventory_visible(visible_state: bool) -> void:
	is_visible = visible_state

func show_inventory() -> void:
	is_visible = true

func hide_inventory() -> void:
	is_visible = false

func is_inventory_active() -> bool:
	if not is_visible:
		return false
	var tree = get_tree()
	if tree and tree.root:
		var inv_bar = tree.root.find_child("InventoryBar", true, false)
		if inv_bar and is_instance_valid(inv_bar) and not inv_bar.visible:
			return false
	return true

## จัดการปุ่มกดลัด Item1, Item2, Item3 และ EmptyHands (หรือคีย์ 1, 2, 3, V)
func _unhandled_input(event: InputEvent) -> void:
	# ไม่ทำงานหาก Inventory ถูกซ่อนอยู่ (ไม่ได้อยู่ใน Playground เช่น ขณะใช้คอมพิวเตอร์)
	if not is_inventory_active():
		return

	# ไม่จับคีย์หากกำลังพิมพ์ในกล่องข้อความ
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused and (focused is LineEdit or focused is TextEdit):
		return

	if event.is_action_pressed("Item1"):
		select_slot(0)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Item2"):
		select_slot(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("Item3"):
		select_slot(2)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("EmptyHands"):
		deselect()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				select_slot(0)
				get_viewport().set_input_as_handled()
			KEY_2:
				select_slot(1)
				get_viewport().set_input_as_handled()
			KEY_3:
				select_slot(2)
				get_viewport().set_input_as_handled()
			KEY_V:
				deselect()
				get_viewport().set_input_as_handled()
