extends Control

const SCENE_04_PATH: String = "res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn"

@onready var notification_panel: Panel = $NotificationPanel
@onready var notification_label: Label = $NotificationPanel/NotificationLabel
@onready var folder_view: Control = $FolderView
@onready var ransom_note: Control = $RansomNote
@onready var ransom_continue_button: Button = $RansomNote/Content/ContinueButton
@onready var march_chat_panel: Panel = $MarchChatPanel
@onready var continue_button: Button = $MarchChatPanel/Content/ContinueButton

var _notification_messages: Array[String] = [
	"Weather alert: unusually hot conditions expected tonight.",
	"Browser update: install the latest update to stay protected.",
	"Antivirus: no threats found."
]

func _ready() -> void:
	folder_view.hide()
	ransom_note.hide()
	march_chat_panel.hide()
	ransom_continue_button.pressed.connect(_on_ransom_dismissed)
	continue_button.pressed.connect(_on_continue_pressed)
	_run_incident_sequence()

func _run_incident_sequence() -> void:
	for message: String in _notification_messages:
		notification_label.text = message
		notification_panel.show()
		await get_tree().create_timer(1.4).timeout
		notification_panel.hide()
		await get_tree().create_timer(0.35).timeout

	folder_view.show()
	$FolderView/Content/StatusLabel.text = "Project files changed."
	$FolderView/Content/ReportFileLabel.text = "Report_Final.docx.locked"
	$FolderView/Content/DiagramFileLabel.text = "Network_Diagram.png.locked"
	$FolderView/Content/ResearchFileLabel.text = "Research_Data.xlsx.locked"
	$FolderView/Content/PresentationFileLabel.text = "Presentation.pptx.locked"
	ransom_note.show()

func _on_ransom_dismissed() -> void:
	ransom_note.hide()
	march_chat_panel.show()

func _on_continue_pressed() -> void:
	var result: Error = get_tree().change_scene_to_file(SCENE_04_PATH)
	if result != OK:
		push_error("Unable to load Scene 4: %s (error %d)" % [SCENE_04_PATH, result])
