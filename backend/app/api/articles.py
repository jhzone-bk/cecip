from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..core.database import get_db
router = APIRouter()
@router.get("/")
async def list_articles(db: Session = Depends(get_db)):
    return {"articles": []}
@router.get("/{article_id}")
async def get_article(article_id: int, db: Session = Depends(get_db)):
    return {"article": {}}
