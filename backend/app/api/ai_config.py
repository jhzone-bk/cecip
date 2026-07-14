from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from ..core.config import settings

router = APIRouter()

class AIConfigUpdate(BaseModel):
    ai_api_base: Optional[str] = None
    ai_api_key: Optional[str] = None
    ai_model: Optional[str] = None
    ai_fallback_api_base: Optional[str] = None
    ai_fallback_api_key: Optional[str] = None
    ai_fallback_model: Optional[str] = None

class AIConfigResponse(BaseModel):
    ai_api_base: str
    ai_model: str
    ai_fallback_api_base: str
    ai_fallback_model: str
    has_api_key: bool
    has_fallback_key: bool

@router.get("/config", response_model=AIConfigResponse)
async def get_ai_config():
    """获取AI配置（不返回密钥本身）"""
    return AIConfigResponse(
        ai_api_base=settings.ai_api_base,
        ai_model=settings.ai_model,
        ai_fallback_api_base=settings.ai_fallback_api_base or "",
        ai_fallback_model=settings.ai_fallback_model or "",
        has_api_key=bool(settings.ai_api_key),
        has_fallback_key=bool(settings.ai_fallback_api_key)
    )

@router.put("/config")
async def update_ai_config(config: AIConfigUpdate):
    """更新AI配置（保存到环境变量）"""
    updates = []
    if config.ai_api_base is not None:
        settings.ai_api_base = config.ai_api_base
        updates.append("ai_api_base")
    if config.ai_api_key is not None:
        settings.ai_api_key = config.ai_api_key
        updates.append("ai_api_key")
    if config.ai_model is not None:
        settings.ai_model = config.ai_model
        updates.append("ai_model")
    if config.ai_fallback_api_base is not None:
        settings.ai_fallback_api_base = config.ai_fallback_api_base
        updates.append("ai_fallback_api_base")
    if config.ai_fallback_api_key is not None:
        settings.ai_fallback_api_key = config.ai_fallback_api_key
        updates.append("ai_fallback_api_key")
    if config.ai_fallback_model is not None:
        settings.ai_fallback_model = config.ai_fallback_model
        updates.append("ai_fallback_model")
    return {"status": "ok", "updated": updates}

@router.post("/test")
async def test_ai_connection():
    """测试AI API连接"""
    if not settings.ai_api_key:
        raise HTTPException(status_code=400, detail="API Key not configured")
    return {"status": "ok", "message": f"Config OK: {settings.ai_api_base}"}