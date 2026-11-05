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
	inventory_updated.emit()

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
