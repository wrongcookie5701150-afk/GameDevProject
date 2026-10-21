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
SCRIPTS_DIR = os.path.join(GAME_CLIENT_DIR, "Scripts" if os.path.exists(os.path.join(GAME_CLIENT_DIR, "Scripts")) else "scripts")

def create_base_payload(scene_id: str, task_id: str, metrics: dict):
    return {
        "session_id": "test-session-uuid-1234",
        "player_id": "player_qa_tester",
        "scene_id": scene_id,
        "task_id": task_id,
        "event_type": "submit_answer",
        "duration_seconds": 12.5,
        "is_correct": True,
        "attempt_count": 1,
        "hint_used": False,
        "metrics": metrics
    }

# ==============================================================================
# Issue #3: Scene 2 & Scene 4
# ==============================================================================

@pytest.mark.issue3
@pytest.mark.task04
def test_issue3_task04_typing_game():
    """Task 04: มินิเกมพิมพ์งาน 300 คำ (Scene 2)"""
    # 1. บังคับตรวจไฟล์จริง: ต้องมีไฟล์ Scene หรือ Node ของ Typing Game อยู่จริง
    scene_file = os.path.join(SCENES_DIR, "Scene_02_Tutorial.tscn")
    puzzle_file = os.path.join(SCENES_DIR, "Puzzle_Typing_Game.tscn")
    assert os.path.exists(scene_file) or os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Scene_02_Tutorial.tscn หรือ Puzzle_Typing_Game.tscn ใน game-client/scenes/"
    )

    # 2. ตรวจสอบ API Contract
    valid = create_base_payload("Scene_02", "Task_04", {"wpm": 45.0, "accuracy": 98.2})
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200
    assert "assigned_cluster" in res_valid.json()

    invalid = create_base_payload("Scene_02", "Task_04", {"wpm": 45.0})
    res_invalid = client.post("/api/v1/telemetry/event", json=invalid)
    assert res_invalid.status_code == 422


@pytest.mark.issue3
@pytest.mark.task06
def test_issue3_task06_event_log():
    """Task 06: ตรวจ Windows Event Log Timeline 19:02:10 (Scene 4)"""
    # 1. บังคับตรวจไฟล์จริง
    puzzle_file = os.path.join(SCENES_DIR, "Puzzle_Event_Log.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_Event_Log.tscn ใน game-client/scenes/"
    )

    # 2. ตรวจสอบ API Contract
    valid = create_base_payload("Scene_04", "Task_06", {"selected_timestamp": "19:02:10"})
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200

    invalid = create_base_payload("Scene_04", "Task_06", {})
    res_invalid = client.post("/api/v1/telemetry/event", json=invalid)
    assert res_invalid.status_code == 422


@pytest.mark.issue3
@pytest.mark.task07
def test_issue3_task07_typosquatting():
    """Task 07: ตรวจสอบ Drive History (Typosquatting) (Scene 4)"""
    # 1. บังคับตรวจไฟล์จริง
    puzzle_file = os.path.join(SCENES_DIR, "Puzzle_Drive_History.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_Drive_History.tscn ใน game-client/scenes/"
    )

    # 2. ตรวจสอบ API Contract
    valid = create_base_payload(
        "Scene_04",
        "Task_07",
        {"selected_email": "mesasohot.sukj@universcity.example", "domain_checked": "universcity.example"}
    )
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200

    invalid = create_base_payload("Scene_04", "Task_07", {"selected_email": "mesa@test.com"})
    res_invalid = client.post("/api/v1/telemetry/event", json=invalid)
    assert res_invalid.status_code == 422


# ==============================================================================
# Issue #5: Scene 5 & Scene 6
# ==============================================================================

@pytest.mark.issue5
@pytest.mark.task08
def test_issue5_task08_hash_verify():
    """Task 08: ตรวจสอบ MD5 Hash Integrity บนเต่าดำ (Scene 5)"""
    puzzle_file = os.path.join(SCENES_DIR, "Puzzle_Hash_Verify.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_Hash_Verify.tscn ใน game-client/scenes/"
    )

    valid = create_base_payload("Scene_05", "Task_08", {"hash_algorithm": "MD5", "match_status": True})
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200


@pytest.mark.issue5
@pytest.mark.task15
def test_issue5_task15_backup_recovery():
    """Task 15: กฎ 3-2-1 Safe Backup (Scene 6)"""
    puzzle_file = os.path.join(SCENES_DIR, "Puzzle_321_Backup.tscn")
    assert os.path.exists(puzzle_file), (
        "❌ ยังไม่ได้สร้างไฟล์ Puzzle_321_Backup.tscn ใน game-client/scenes/"
    )

    valid = create_base_payload(
        "Scene_06",
        "Task_15",
        {"recovery_point": "before_1902", "isolated_sync": True}
    )
    res_valid = client.post("/api/v1/telemetry/event", json=valid)
    assert res_valid.status_code == 200