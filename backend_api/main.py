from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime

app = FastAPI(
    title="Cyber Game Telemetry & Analytics API",
    description="API Gateway สำหรับรับ Event Log จาก Godot Engine และส่งต่อไปยัง Analytics/ML Pipeline",
    version="1.0.0"
)

# 1. Pydantic Models (Schema Definition)
class TelemetryEvent(BaseModel):
    session_id: str = Field(..., description="UUID ประจำรอบการเล่น")
    player_id: str = Field(..., description="รหัสผู้เล่น")
    scene_id: str = Field(..., description="ชื่อฉาก เช่น Scene_02, Scene_04, Scene_05, Scene_06")
    task_id: str = Field(..., description="รหัสภารกิจ เช่น Task_04, Task_06, Task_08")
    event_type: str = Field(..., description="ประเภทเหตุการณ์ เช่น submit_answer, click, hint_requested")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="เวลาที่เกิดเหตุการณ์ (UTC)")
    duration_seconds: float = Field(..., ge=0.0, description="ระยะเวลาที่ใช้ (วินาที)")
    is_correct: Optional[bool] = Field(None, description="ความถูกต้องของคำตอบ (ถ้ามี)")
    attempt_count: int = Field(default=1, ge=1, description="จำนวนครั้งที่ลองทำ")
    hint_used: bool = Field(default=False, description="ผู้เล่นกดดูคำใบ้หรือไม่")
    metrics: Dict[str, Any] = Field(
        default_factory=dict,
        description="พารามิเตอร์เฉพาะของแต่ละ Puzzle สำหรับทำ Analytics"
    )

class DynamicGameplayResponse(BaseModel):
    status: str
    message: str
    assigned_cluster: str          # "Beginner" หรือ "Expert"
    adaptive_hint_enabled: bool
    difficulty_multiplier: float

# 2. Validation Logic สำหรับตรวจสอบพารามิเตอร์ของแต่ละ Task
REQUIRED_TASK_METRICS = {
    "Task_04": ["wpm", "accuracy"],                   # Scene 2: มินิเกมพิมพ์งาน
    "Task_06": ["selected_timestamp"],                # Scene 4: Windows Event Log Timeline
    "Task_07": ["selected_email", "domain_checked"],   # Scene 4: Drive History (Typosquatting)
    "Task_08": ["hash_algorithm", "match_status"],    # Scene 5: EV Drive Hash Integrity
    "Task_11": ["decoded_output"],                     # Scene 5: Base64 Decoder
    "Task_13": ["decoded_target", "decoded_mode"],     # Scene 5: Hex & Base64 Decoder (Helper.dat)
    "Task_14": ["sequence_steps"],                     # Scene 5: ลำดับขั้นตอนหยุด Persistence 7 ขั้นตอน
    "Task_15": ["recovery_point", "isolated_sync"],    # Scene 6: 3-2-1 Safe Backup Recovery
    "Task_16": ["conclusions_score"]                   # Scene 6: สรุปบทเรียน The Last Boss
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

# 3. API Endpoints
@app.get("/")
async def root():
    return {"service": "Cyber Game Telemetry Backend", "status": "running"}

@app.post("/api/telemetry", response_model=DynamicGameplayResponse, status_code=status.HTTP_200_OK)
@app.post("/api/v1/telemetry/event", response_model=DynamicGameplayResponse, status_code=status.HTTP_200_OK)
async def ingest_telemetry_event(payload: TelemetryEvent):
    validate_task_metrics(payload)

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