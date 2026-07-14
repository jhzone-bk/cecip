from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..core.database import get_db

router = APIRouter()

@router.get("/dashboard")
async def get_dashboard(db: Session = Depends(get_db)):
    return {"today_crawl": 0, "pending_review": 0, "ai_queue": 0, "published_week": 0}

@router.get("/review-queue")
async def get_review_queue(db: Session = Depends(get_db)):
    return {"items": []}
