extends BaseClickSelectPuzzle

@onready var entries: ItemList = $Panel/Content/Entries
@onready var feedback_label: Label = $Panel/Content/FeedbackLabel

func _ready() -> void:
	super._ready()
	_add_entry("18:58:07 | Report_Final.docx appeared in shared folder", "18:58:07")
	_add_entry("19:02:10 | WINWORD.EXE opened Report_Final.docx", "19:02:10")
	_add_entry("19:03:16 | User selected Enable Content", "19:03:16")
	_add_entry("21:21:50 | Office_Update_Helper started", "21:21:50")
	entries.item_selected.connect(_on_entry_selected)

func _add_entry(label: String, timestamp: String) -> void:
	var index: int = entries.add_item(label)
	entries.set_item_metadata(index, {"selected_timestamp": timestamp})

func _on_entry_selected(index: int) -> void:
	var metadata: Dictionary = entries.get_item_metadata(index)
	submit_selection(StringName(metadata["selected_timestamp"]), metadata)

func on_solve_success() -> void:
	feedback_label.text = "Correct: WINWORD.EXE opened the report at 19:02:10."
	entries.disabled = true

func on_solve_failed() -> void:
	feedback_label.text = "That entry is not the document-open event. Check the process and timestamp."
