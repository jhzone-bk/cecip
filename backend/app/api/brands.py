from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..core.database import get_db
router = APIRouter()
@router.get("/")
async def list_brands(db: Session = Depends(get_db)):
    return {"brands": []}
@router.get("/{brand_id}")
async def get_brand(brand_id: int, db: Session = Depends(get_db)):
    return {"brand": {}}
