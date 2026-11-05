extends BaseClickSelectPuzzle

@onready var components: ItemList = $Panel/Content/Components
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel
@onready var hint_button: Button = $Panel/Content/HintButton

func _ready() -> void:
	super._ready()
	_add_component("word/document.xml", "document_xml")
	_add_component("word/vbaProject.bin", "vba_project")
	_add_component("word/_rels/document.xml.rels", "document_relationships")
	components.item_selected.connect(_on_component_selected)
	hint_button.pressed.connect(_on_hint_pressed)

func start_puzzle() -> void:
	super.start_puzzle()
	if not is_resolved and components:
		components.deselect_all()
		components.mouse_filter = Control.MOUSE_FILTER_STOP

func _add_component(label: String, component_id: String) -> void:
	var index: int = components.add_item(label)
	components.set_item_metadata(index, {
		"inspected_component": label,
		"component_id": component_id,
		"file_name": "Final_Report_Revision_v4.docx"
	})

func _on_component_selected(index: int) -> void:
	var metadata: Dictionary = components.get_item_metadata(index)
	submit_selection(StringName(metadata["component_id"]), metadata)

func _build_telemetry_param(
	is_correct: bool,
	duration_seconds: float,
	metrics: Dictionary
) -> BaseTelemetryParam:
	var param: ForensicAnalysisTelemetryParam = ForensicAnalysisTelemetryParam.new()
	param.scene_id = scene_id
	param.task_id = String(task_id)
	param.event_type = "macro_component_selected"
	param.duration_seconds = duration_seconds
	param.is_correct = is_correct
	param.attempt_count = attempt_count
	param.hint_used = hint_used
	param.metrics = metrics.duplicate(true)
	param.evidence_file = str(metrics.get("file_name", "Final_Report_Revision_v4.docx"))
	param.inspected_component = str(metrics.get("inspected_component", ""))
	param.sync_metrics()
	return param

func on_solve_success() -> void:
	feedback_label.text = "✅ พบโค้ด Macro ฝังอยู่ใน word/vbaProject.bin!"
	if hint_button:
		hint_button.disabled = true
	for i: int in range(components.item_count):
		components.set_item_disabled(i, true)
	components.mouse_filter = Control.MOUSE_FILTER_IGNORE

func on_solve_failed() -> void:
	feedback_label.text = "❌ ส่วนประกอบนี้เป็นโครงสร้างเอกสารปกติ ให้คลิกเลือก word/vbaProject.bin ที่เป็นโค้ด Macro"

func _on_hint_pressed() -> void:
	hint_used = true
	feedback_label.text = "💡 คำใบ้: โค้ดมาโครของ Word จะถูกฝังอยู่ในไฟล์ไบนารีชื่อ word/vbaProject.bin (บรรทัดที่ 2)"
