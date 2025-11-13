from fastapi import APIRouter, Depends
from app.deps import get_current_user
from app import crud, schemas
from sqlalchemy.orm import Session
from app.database import SessionLocal

router = APIRouter(prefix="/cattle", tags=["cattle"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register")
def register_cattle(
    cattle: schemas.CattleCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user)
):
    # Only logged-in users reach here
    owner_id = current_user["user_id"]
    new_cattle = crud.create_cattle(db, owner_id, cattle.dict())
    return new_cattle

