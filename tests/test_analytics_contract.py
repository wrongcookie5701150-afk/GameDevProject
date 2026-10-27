import pytest
from fastapi.testclient import TestClient
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from backend_api.main import app

client = TestClient(app)

# กำหนด Path ไปยังโฟลเดอร์ game_client
GAME_CLIENT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../game_client"))
if not os.path.exists(GAME_CLIENT_DIR):
    GAME_CLIENT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../game-client"))
SCENES_DIR = os.path.join(GAME_CLIENT_DIR, "scenes")
PUZZLES_DIR = os.path.join(GAME_CLIENT_DIR, "ui", "puzzles")
SCRIPTS_DIR = os.path.join(GAME_CLIENT_DIR, "Scripts" if os.path.exists(os.path.join(GAME_CLIENT_DIR, "Scripts")) else "scripts")

def create_base_payload(scene_id: str, task_id: str, metrics: dict):
    return {
        "session_id": "test-session-uuid-1234",
        "player_id": "player_qa_tester",
        "scene_id": scene_id,
        "task_id": task_id,
        "event_type": "puzzle_submitted",
        "duration_seconds": 12.5,
        "is_correct": True,
        "attempt_count": 1,
        "hint_used": False,
        "metrics": metrics
    }


def test_end_to_end_scene_transition_paths_exist():
    transitions = [
        ("ui/menus/Main_menu.gd", "res://scenes/scene_01_intro/Scene_01_Intro.tscn"),
        ("scenes/scene_01_intro/cutscene_01_intro.gd", "res://scenes/world_scenes/scene_02_tutorial/Scene_02_Tutorial.tscn"),
        ("scenes/world_scenes/scene_02_tutorial/scene_02_tutorial.gd", "res://scenes/scene_03_incident/Scene_03_Incident.tscn"),
        ("scenes/scene_03_incident/Scene_03_Incident.gd", "res://scenes/world_scenes/scene_04_investigation_intro/Scene_04_Investigation_Intro.tscn"),
        ("scenes/world_scenes/scene_04_investigation_intro/scene_04_investigation_intro.gd", "res://scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.tscn"),
        ("scenes/scene_05_taodam_desktop/Scene_05_TaoDam_Desktop.gd", "res://scenes/scene_06_recovery/Scene_06_Recovery.tscn"),
        ("scenes/scene_06_recovery/Scene_06_Recovery.gd", "res://ui/menus/MainMenu.tscn"),
    ]
    for source_path, target_path in transitions:
        source_file = os.path.join(GAME_CLIENT_DIR, source_path)
        target_file = os.path.join(GAME_CLIENT_DIR, target_path.removeprefix("res://"))
        assert os.path.isfile(source_file), source_file
        assert os.path.isfile(target_file), target_file
        with open(source_file, encoding="utf-8") as source:
            assert target_path in source.read(), f"{source_path} does not route to {target_path}"

# ==============================================================================
# Issue #3: Scene 2 & Scene 4
# ==============================================================================

@pytest.mark.issue3
@pytest.mark.task04
def test_issue3_task04_typing_game():
    """Task 04: มินิเกมพิมพ์งาน 300 คำ (Scene 2)"""
    # 1. บังคับตรวจไฟล์จริง: ต้องมีไฟล์ Scene หรือ Node ของ Typing Game อยู่จริง
    scene_file = os.path.join(SCENES_DIR, "world_scenes", "scene_02_tutorial", "Scene_02_Tutorial.tscn")
    puzzle_file = os.path.join(PUZZLES_DIR, "Puzzle_Typing_Game.tscn")
    assert os.path.exists(scene_file) or os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Scene_02_Tutorial.tscn หรือ Puzzle_Typing_Game.tscn ใน game-client/scenes/"
    )

    # 2. ตรวจสอบ API Contract
    valid = create_base_payload("Scene_02", "T04", {"wpm": 45.0, "accuracy": 98.2})
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200
    assert "assigned_cluster" in res_valid.json()

    invalid = create_base_payload("Scene_02", "T04", {"wpm": 45.0})
    res_invalid = client.post("/api/v1/telemetry/event", json=invalid)
    assert res_invalid.status_code == 422


@pytest.mark.issue3
@pytest.mark.task06
def test_issue3_task06_event_log():
    """Task 06: ตรวจ Windows Event Log Timeline 19:02:10 (Scene 4)"""
    # 1. บังคับตรวจไฟล์จริง
    puzzle_file = os.path.join(PUZZLES_DIR, "Puzzle_Event_Log.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_Event_Log.tscn ใน game-client/scenes/"
    )

    # 2. ตรวจสอบ API Contract
    valid = create_base_payload("Scene_04", "T06", {"selected_timestamp": "19:02:10"})
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200

    invalid = create_base_payload("Scene_04", "T06", {})
    res_invalid = client.post("/api/v1/telemetry/event", json=invalid)
    assert res_invalid.status_code == 422


@pytest.mark.issue3
@pytest.mark.task07
def test_issue3_task07_typosquatting():
    """Task 07: ตรวจสอบ Drive History (Typosquatting) (Scene 4)"""
    # 1. บังคับตรวจไฟล์จริง
    puzzle_file = os.path.join(PUZZLES_DIR, "Puzzle_Drive_History.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_Drive_History.tscn ใน game-client/scenes/"
    )

    # 2. ตรวจสอบ API Contract
    valid = create_base_payload(
        "Scene_04",
        "T07",
        {"selected_email": "mesasohot.sukj@universcity.example", "domain_checked": "universcity.example"}
    )
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200

    invalid = create_base_payload("Scene_04", "T07", {"selected_email": "mesa@test.com"})
    res_invalid = client.post("/api/v1/telemetry/event", json=invalid)
    assert res_invalid.status_code == 422


# ==============================================================================
# Issue #5: Scene 5 & Scene 6
# ==============================================================================

@pytest.mark.issue5
@pytest.mark.task08
def test_issue5_task08_hash_verify():
    """Task 08: ตรวจสอบ MD5 Hash Integrity บนเต่าดำ (Scene 5)"""
    puzzle_file = os.path.join(PUZZLES_DIR, "Puzzle_Hash_Verify.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_Hash_Verify.tscn ใน game-client/scenes/"
    )

    valid = create_base_payload("Scene_05", "T08", {"hash_algorithm": "MD5", "match_status": True})
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200


@pytest.mark.issue5
@pytest.mark.task10
def test_task10_helper_name_decoder_metrics():
    valid = create_base_payload("Scene_05", "T10", {"decoded_output": "Office_Update_Helper"})
    assert client.post("/api/v1/telemetry/event", json=valid).status_code == 200

    invalid = create_base_payload("Scene_05", "T10", {})
    assert client.post("/api/v1/telemetry/event", json=invalid).status_code == 422


@pytest.mark.issue5
@pytest.mark.task11
def test_task11_helper_mode_decoder_metrics():
    valid = create_base_payload(
        "Scene_05",
        "T11",
        {"decoded_target": "Project_Folder", "decoded_mode": "FILE_WIPE"}
    )
    assert client.post("/api/v1/telemetry/event", json=valid).status_code == 200


@pytest.mark.issue5
@pytest.mark.task12
def test_task12_persistence_sequence_metrics():
    valid = create_base_payload("Scene_05", "T12", {"sequence_steps": ["disable_task", "restore_backup"]})
    assert client.post("/api/v1/telemetry/event", json=valid).status_code == 200


@pytest.mark.issue5
@pytest.mark.task13
def test_task13_backup_recovery():
    """Task 13: กฎ 3-2-1 Safe Backup (Scene 6)"""
    puzzle_file = os.path.join(PUZZLES_DIR, "Puzzle_321_Backup.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_321_Backup.tscn ใน game-client/scenes/"
    )

    valid = create_base_payload(
        "Scene_06",
        "T13",
        {"recovery_point": "before_1902", "isolated_sync": True}
    )
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200

    invalid = create_base_payload("Scene_06", "T13", {"recovery_point": "before_1902"})
    res_invalid = client.post("/api/v1/telemetry/event", json=invalid)
    assert res_invalid.status_code == 422


@pytest.mark.issue5
@pytest.mark.task14
def test_task14_incident_report():
    """Task 14: Final incident report (Scene 6)"""
    report_file = os.path.join(PUZZLES_DIR, "Puzzle_Last_Boss_Summary.tscn")
    assert os.path.exists(report_file)

    valid = create_base_payload("Scene_06", "T14", {"conclusions_score": 100})
    assert client.post("/api/v1/telemetry/event", json=valid).status_code == 200

    invalid = create_base_payload("Scene_06", "T14", {})
    assert client.post("/api/v1/telemetry/event", json=invalid).status_code == 422


@pytest.mark.issue5
@pytest.mark.task15
def test_task15_ksa_evaluation():
    """Task 15: K-S-A evaluation (Scene 6)"""
    evaluation_file = os.path.join(GAME_CLIENT_DIR, "ui", "overlays", "KSA_Evaluation_UI.tscn")
    assert os.path.exists(evaluation_file)

    valid = create_base_payload(
        "Scene_06",
        "T15",
        {"knowledge_score": 80, "skills_score": 90, "attitude_score": 100}
    )
    assert client.post("/api/v1/telemetry/event", json=valid).status_code == 200

    invalid = create_base_payload("Scene_06", "T15", {"knowledge_score": 80})
    assert client.post("/api/v1/telemetry/event", json=invalid).status_code == 422