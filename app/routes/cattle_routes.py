from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, Form
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional

from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.database import SessionLocal
from app.auth_utils import decode_token
from app import crud, cloudinary_utils, ai_model
from app.models import Cattle, CattlePhoto, MedicalRecord

security = HTTPBearer()

# Remove dependencies from router
router = APIRouter(
    prefix="/cattle",
    tags=["Cattle"]
)


# -------------------- DB Dependency --------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# -------------------- Auth Helper --------------------
def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Extract & verify JWT - returns user data."""
    print(f"🔍 DEBUG: Received authorization header")
    
    token = credentials.credentials
    print(f"🔍 DEBUG: Token (first 50 chars) = {token[:50]}...")
    
    data = decode_token(token)
    print(f"🔍 DEBUG: Decoded data = {data}")

    if not data:
        print("❌ DEBUG: Token decode failed")
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    print(f"✅ DEBUG: User authenticated - ID: {data.get('id')}, Role: {data.get('role')}")
    return data


# -------------------- Register Cattle --------------------
@router.post("/register")
async def register_cattle(
    tag_id: str = Form(...),
    breed: str = Form(None),
    dob: Optional[str] = Form(None),
    location: str = Form(None),
    photo: UploadFile = File(None),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    print(f"✅ Starting cattle registration for user {current_user['id']}")
    owner_id = current_user["id"]

    # Check duplicate tag_id
    existing = db.query(Cattle).filter(Cattle.tag_id == tag_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Tag ID already exists")

    # Upload photo (optional)
    photo_url = None
    if photo:
        print(f"📸 Uploading photo for tag_id: {tag_id}")
        photo_url = cloudinary_utils.upload_file(
            photo.file, folder=f"cattle/{tag_id}"
        )
        print(f"✅ Photo uploaded: {photo_url}")

    # Prepare cattle data
    cattle_data = {
        "tag_id": tag_id,
        "breed": breed,
        "location": location
    }

    if dob:
        try:
            cattle_data["dob"] = datetime.fromisoformat(dob)
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid DOB format. Use YYYY-MM-DD. Error: {str(e)}")

    # Save cattle entry
    print(f"💾 Saving cattle to database...")
    cattle = crud.create_cattle(db, owner_id, cattle_data)
    print(f"✅ Cattle saved with ID: {cattle.id}")

    # Save photo in DB
    if photo_url:
        db.add(CattlePhoto(cattle_id=cattle.id, url=photo_url))
        db.commit()
        print(f"✅ Photo record saved")

    return {
        "message": "Cattle registered successfully",
        "cattle": {
            "id": cattle.id,
            "tag_id": cattle.tag_id,
            "breed": cattle.breed,
            "location": cattle.location
        }
    }


# -------------------- My Cattle --------------------
@router.get("/my-cattle")
def my_cattle(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    owner_id = current_user["id"]
    list_cattle = crud.get_cattle_by_owner(db, owner_id)

    return [
        {
            "cattle_id": c.tag_id,
            "breed": c.breed,
            "status": c.status,
            "tx_hash": c.tx_hash
        }
        for c in list_cattle
    ]


# -------------------- Analyze Photo --------------------
@router.post("/{cattle_id}/analyze-photo")
async def analyze_photo(
    cattle_id: int,
    photo: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    print(f"🔍 Analyzing photo for cattle_id: {cattle_id}")
    
    # Check cattle exists
    cattle = db.query(Cattle).filter(Cattle.id == cattle_id).first()
    if not cattle:
        raise HTTPException(status_code=404, detail="Cattle not found")

    # Farmers can only analyze their own
    if current_user["role"] == "farmer" and cattle.owner_id != current_user["id"]:
        raise HTTPException(status_code=403, detail="You do not own this cattle")

    # Upload photo to Cloudinary
    photo_url = cloudinary_utils.upload_file(
        photo.file, folder=f"analysis/{cattle_id}"
    )

    # Read bytes for ML
    photo.file.seek(0)  # Reset file pointer
    image_bytes = await photo.read()
    result = ai_model.predict_infection(image_bytes)

    # Store medical record
    record = MedicalRecord(
        cattle_id=cattle_id,
        image_url=photo_url,
        diagnosis=result["label"],
        score=result["score"]
    )
    db.add(record)
    db.commit()

    return {
        "message": "Analysis complete",
        "photo_url": photo_url,
        "result": result,
        "record_id": record.id
    }