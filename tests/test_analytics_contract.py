import pytest
from fastapi.testclient import TestClient
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from backend_api.main import app

client = TestClient(app)

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

@pytest.mark.parametrize("scene_id, task_id, valid_metrics, missing_metrics", [
    ("Scene_02", "Task_04", {"wpm": 45.0, "accuracy": 98.2}, {"wpm": 45.0}),
    ("Scene_04", "Task_06", {"selected_timestamp": "19:02:10"}, {}),
    (
        "Scene_04",
        "Task_07",
        {"selected_email": "mesasohot.sukj@universcity.example", "domain_checked": "universcity.example"},
        {"selected_email": "mesa@test.com"}
    ),
    ("Scene_05", "Task_08", {"hash_algorithm": "MD5", "match_status": True}, {"hash_algorithm": "MD5"}),
    ("Scene_05", "Task_11", {"decoded_output": "Office_Update_Helper"}, {}),
    (
        "Scene_05",
        "Task_13",
        {"decoded_target": "Project_Folder", "decoded_mode": "FILE_WIPE"},
        {"decoded_target": "Project_Folder"}
    ),
    ("Scene_05", "Task_14", {"sequence_steps": [1, 2, 3, 4, 5, 6, 7]}, {}),
    (
        "Scene_06",
        "Task_15",
        {"recovery_point": "before_1902", "isolated_sync": True},
        {"recovery_point": "before_1902"}
    ),
    ("Scene_06", "Task_16", {"conclusions_score": 3}, {})
])
def test_task_analytics_contract(scene_id, task_id, valid_metrics, missing_metrics):
    payload_valid = create_base_payload(scene_id, task_id, valid_metrics)
    response = client.post("/api/v1/telemetry/event", json=payload_valid)
    assert response.status_code == 200, f"Failed on valid payload for {task_id}: {response.text}"
    assert "assigned_cluster" in response.json()

    if missing_metrics != valid_metrics:
        payload_invalid = create_base_payload(scene_id, task_id, missing_metrics)
        response_invalid = client.post("/api/v1/telemetry/event", json=payload_invalid)
        assert response_invalid.status_code == 422


def test_missing_global_fields():
    broken_payload = {
        "player_id": "player_qa_tester",
        "scene_id": "Scene_02",
        "task_id": "Task_04"
    }
    response = client.post("/api/v1/telemetry/event", json=broken_payload)
    assert response.status_code == 422