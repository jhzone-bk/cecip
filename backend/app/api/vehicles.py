from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..core.database import get_db
router = APIRouter()
@router.get("/")
async def list_vehicles(db: Session = Depends(get_db)):
    return {"vehicles": []}
@router.get("/{vehicle_id}")
async def get_vehicle(vehicle_id: int, db: Session = Depends(get_db)):
    return {"vehicle": {}}
