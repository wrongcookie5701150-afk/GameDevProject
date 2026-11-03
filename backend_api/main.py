from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime
import json
import os
import uuid

app = FastAPI(
    title="Cyber Game Telemetry & Analytics API",
    description="API Gateway สำหรับรับ Event Log จาก Godot Engine และบันทึกลง Azure Table Storage",
    version="1.2.0"
)

# ------------------------------------------------------------------------------
# 1. Pydantic Models (Schema Definition)
# ------------------------------------------------------------------------------

class TelemetryEvent(BaseModel):
    session_id: str = Field(..., description="UUID ประจำรอบการเล่น")
    player_id: str = Field(..., description="รหัสผู้เล่น")
    scene_id: str = Field(..., description="ชื่อฉาก เช่น Scene_02, Scene_04, Scene_05, Scene_06")
    task_id: str = Field(default="", description="รหัสภารกิจ เช่น Task_04, Task_06, Task_08 (เว้นว่างได้ถ้าเป็น session-level event)")
    event_type: str = Field(..., description="ประเภทเหตุการณ์ เช่น submit_answer, click, hint_requested, heartbeat, session_start, session_end")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="เวลาที่เกิดเหตุการณ์ (UTC)")
    duration_seconds: float = Field(default=0.0, ge=0.0, description="ระยะเวลาที่ใช้ (วินาที)")
    is_correct: Optional[bool] = Field(None, description="ความถูกต้องของคำตอบ (ถ้ามี)")
    attempt_count: int = Field(default=1, ge=1, description="จำนวนครั้งที่ลองทำ")
    hint_used: bool = Field(default=False, description="ผู้เล่นกดดูคำใบ้หรือไม่")
    metrics: Dict[str, Any] = Field(
        default_factory=dict,
        description="พารามิเตอร์เฉพาะของแต่ละ Puzzle หรือข้อมูลเสริมสำหรับทำ Analytics"
    )

class DynamicGameplayResponse(BaseModel):
    status: str
    message: str
    assigned_cluster: str          # "Beginner" หรือ "Expert"
    adaptive_hint_enabled: bool
    difficulty_multiplier: float

class HeartbeatPayload(BaseModel):
    session_id: str
    player_id: str
    scene_id: Optional[str] = "unknown"
    active_playtime_seconds: float = Field(..., ge=0.0)
    idle_time_seconds: float = Field(default=0.0, ge=0.0)
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class PlayerPlaytimeSummary(BaseModel):
    player_id: str
    total_playtime_seconds: float
    total_sessions: int
    last_active_timestamp: Optional[datetime]
    completed_tasks_count: int

# ------------------------------------------------------------------------------
# 2. Azure Storage Integration (Fallback to In-Memory if not configured)
# ------------------------------------------------------------------------------

AZURE_STORAGE_CONNECTION_STRING = os.environ.get("AZURE_STORAGE_CONNECTION_STRING")
table_client_events = None
table_client_playtimes = None

if AZURE_STORAGE_CONNECTION_STRING:
    try:
        from azure.data.tables import TableServiceClient
        service = TableServiceClient.from_connection_string(conn_str=AZURE_STORAGE_CONNECTION_STRING)
        table_client_events = service.get_table_client("telemetryevents")
        table_client_playtimes = service.get_table_client("gameplaytimes")
    except Exception as e:
        print(f"Warning: Failed to initialize Azure Table Client: {e}")

# In-memory storage mock
PLAYER_SESSIONS_DB: Dict[str, Dict[str, Any]] = {}
EVENT_LOGS_DB: List[Dict[str, Any]] = []

# ------------------------------------------------------------------------------
# 3. Validation Logic สำหรับตรวจสอบพารามิเตอร์ของแต่ละ Task
# ------------------------------------------------------------------------------

REQUIRED_TASK_METRICS = {
    "T04": ["wpm", "accuracy"],
    "T06": ["selected_timestamp"],
    "T07": ["selected_email", "domain_checked"],
    "T08": ["hash_algorithm", "match_status"],
    "T10": ["decoded_output"],
    "T11": ["decoded_target", "decoded_mode"],
    "T12": ["sequence_steps"],
    "T13": ["recovery_point", "isolated_sync"],
    "T14": ["conclusions_score"],
    "T15": ["knowledge_score", "skills_score", "attitude_score"],
    "Task_04": ["wpm", "accuracy"],
    "Task_06": ["selected_timestamp"],
    "Task_07": ["selected_email", "domain_checked"],
    "Task_08": ["hash_algorithm", "match_status"],
    "Task_11": ["decoded_output"],
    "Task_13": ["decoded_target", "decoded_mode"],
    "Task_14": ["sequence_steps"],
    "Task_15": ["recovery_point", "isolated_sync"],
    "Task_16": ["conclusions_score"]
}

def validate_task_metrics(payload: TelemetryEvent) -> None:
    if payload.task_id in REQUIRED_TASK_METRICS:
        missing_keys = [
            key for key in REQUIRED_TASK_METRICS[payload.task_id]
            if key not in payload.metrics
        ]
        if missing_keys:
            raise HTTPException(
                status_code=422,
                detail={
                    "error": "Missing Required Metrics",
                    "task_id": payload.task_id,
                    "missing_keys": missing_keys,
                    "message": f"ภารกิจ {payload.task_id} ต้องการพารามิเตอร์ {missing_keys} ใน metrics เพื่อทำ Analytics"
                }
            )

# ------------------------------------------------------------------------------
# 4. API Endpoints
# ------------------------------------------------------------------------------

@app.get("/")
async def root():
    return {
        "service": "Cyber Game Telemetry Backend (Azure)",
        "version": "1.2.0",
        "azure_storage_connected": table_client_events is not None,
        "status": "running"
    }

@app.post("/api/telemetry", response_model=DynamicGameplayResponse, status_code=status.HTTP_200_OK)
@app.post("/api/v1/telemetry/event", response_model=DynamicGameplayResponse, status_code=status.HTTP_200_OK)
async def ingest_telemetry_event(payload: TelemetryEvent):
    validate_task_metrics(payload)

    # 1. บันทึกลง Azure Table Storage (ถ้าต่อ Azure ไว้)
    if table_client_events:
        try:
            entity = {
                "PartitionKey": payload.player_id,
                "RowKey": f"{payload.session_id}_{datetime.utcnow().timestamp()}_{uuid.uuid4().hex[:6]}",
                "session_id": payload.session_id,
                "player_id": payload.player_id,
                "scene_id": payload.scene_id,
                "task_id": payload.task_id,
                "event_type": payload.event_type,
                "timestamp": payload.timestamp.isoformat(),
                "duration_seconds": payload.duration_seconds,
                "is_correct": payload.is_correct if payload.is_correct is not None else False,
                "attempt_count": payload.attempt_count,
                "hint_used": payload.hint_used,
                "metrics_json": json.dumps(payload.metrics, ensure_ascii=False)
            }
            table_client_events.create_entity(entity=entity)
        except Exception as err:
            print(f"Error saving to Azure Table: {err}")

    # 2. บันทึก Memory Cache สำรอง
    event_dict = payload.model_dump()
    EVENT_LOGS_DB.append(event_dict)

    p_id = payload.player_id
    if p_id not in PLAYER_SESSIONS_DB:
        PLAYER_SESSIONS_DB[p_id] = {
            "player_id": p_id,
            "total_playtime_seconds": 0.0,
            "sessions": set(),
            "last_active": payload.timestamp,
            "completed_tasks": set()
        }
    PLAYER_SESSIONS_DB[p_id]["sessions"].add(payload.session_id)
    PLAYER_SESSIONS_DB[p_id]["last_active"] = payload.timestamp
    if payload.is_correct is True and payload.task_id:
        PLAYER_SESSIONS_DB[p_id]["completed_tasks"].add(payload.task_id)

    # Dynamic Difficulty / Player Clustering
    is_expert = (payload.duration_seconds < 20.0) and (not payload.hint_used) and (payload.is_correct is not False)
    cluster = "Expert" if is_expert else "Beginner"
    adaptive_hint = True if cluster == "Beginner" else False
    diff_multiplier = 1.2 if cluster == "Expert" else 1.0

    return DynamicGameplayResponse(
        status="success",
        message="Telemetry event logged successfully",
        assigned_cluster=cluster,
        adaptive_hint_enabled=adaptive_hint,
        difficulty_multiplier=diff_multiplier
    )

@app.post("/api/v1/telemetry/heartbeat", status_code=status.HTTP_200_OK)
async def record_heartbeat(payload: HeartbeatPayload):
    p_id = payload.player_id
    
    # 1. บันทึกลง Azure Table Storage
    if table_client_playtimes:
        try:
            entity = {
                "PartitionKey": "PLAYTIME",
                "RowKey": p_id,
                "player_id": p_id,
                "last_session_id": payload.session_id,
                "last_scene_id": payload.scene_id,
                "active_playtime_seconds": payload.active_playtime_seconds,
                "last_active_timestamp": payload.timestamp.isoformat()
            }
            table_client_playtimes.upsert_entity(entity=entity)
        except Exception as err:
            print(f"Error saving heartbeat to Azure Table: {err}")

    # 2. บันทึกลง Memory Store
    if p_id not in PLAYER_SESSIONS_DB:
        PLAYER_SESSIONS_DB[p_id] = {
            "player_id": p_id,
            "total_playtime_seconds": 0.0,
            "sessions": set([payload.session_id]),
            "last_active": payload.timestamp,
            "completed_tasks": set()
        }
    
    PLAYER_SESSIONS_DB[p_id]["total_playtime_seconds"] = max(
        PLAYER_SESSIONS_DB[p_id]["total_playtime_seconds"],
        payload.active_playtime_seconds
    )
    PLAYER_SESSIONS_DB[p_id]["last_active"] = payload.timestamp

    return {
        "status": "success",
        "player_id": p_id,
        "recorded_playtime": PLAYER_SESSIONS_DB[p_id]["total_playtime_seconds"]
    }

@app.get("/api/v1/players/{player_id}/playtime", response_model=PlayerPlaytimeSummary)
async def get_player_playtime(player_id: str):
    # 1. ถ้ามี Azure Table ให้ดึงจาก Azure ก่อน
    if table_client_playtimes:
        try:
            entity = table_client_playtimes.get_entity(partition_key="PLAYTIME", row_key=player_id)
            return PlayerPlaytimeSummary(
                player_id=player_id,
                total_playtime_seconds=float(entity.get("active_playtime_seconds", 0.0)),
                total_sessions=1,
                last_active_timestamp=datetime.fromisoformat(entity.get("last_active_timestamp")) if entity.get("last_active_timestamp") else None,
                completed_tasks_count=0
            )
        except Exception:
            pass

    # 2. ถ้าไม่มีใน Azure ให้ดึงจาก In-Memory
    if player_id not in PLAYER_SESSIONS_DB:
        return PlayerPlaytimeSummary(
            player_id=player_id,
            total_playtime_seconds=0.0,
            total_sessions=0,
            last_active_timestamp=None,
            completed_tasks_count=0
        )
    
    data = PLAYER_SESSIONS_DB[player_id]
    return PlayerPlaytimeSummary(
        player_id=player_id,
        total_playtime_seconds=data["total_playtime_seconds"],
        total_sessions=len(data["sessions"]),
        last_active_timestamp=data["last_active"],
        completed_tasks_count=len(data["completed_tasks"])
    )
