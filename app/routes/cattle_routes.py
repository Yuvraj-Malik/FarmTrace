from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, Header
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.auth_utils import decode_token
from app import crud, cloudinary_utils, ai_model
from datetime import datetime
from typing import Optional
import requests
from app.config import NODE_API_URL
from app.models import Cattle, CattlePhoto

router = APIRouter()


# -------------------- DB Dependency --------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# -------------------- Auth Helper --------------------
def get_user_from_auth(authorization: Optional[str] = Header(None)):
    if not authorization:
        raise HTTPException(401, "Missing Authorization header")

    try:
        token = authorization.split(" ")[1]
    except:
        raise HTTPException(401, "Invalid token format")

    data = decode_token(token)
    if not data:
        raise HTTPException(401, "Invalid or expired token")

    return data    # returns: {"id": user_id, "role": "farmer" | "vet"}


# -------------------- Register Cattle --------------------
@router.post("/register")
async def register_cattle(
    tag_id: str,
    breed: str = None,
    dob: Optional[str] = None,
    location: str = None,
    photo: UploadFile = File(None),
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    user = get_user_from_auth(authorization)
    owner_id = user["id"]

    # Check duplicate tag_id
    existing = db.query(Cattle).filter(Cattle.tag_id == tag_id).first()
    if existing:
        raise HTTPException(400, "Tag ID already exists")

    # Upload photo (optional)
    photo_url = None
    if photo:
        photo_url = cloudinary_utils.upload_file(photo.file, folder=f"cattle/{tag_id}")

    # Prepare cattle entry
    cattle_data = {
        "tag_id": tag_id,
        "breed": breed,
        "location": location
    }

    if dob:
        try:
            cattle_data["dob"] = datetime.fromisoformat(dob)
        except:
            raise HTTPException(400, "Invalid DOB format. Use YYYY-MM-DD")

    # Save cattle to DB
    cattle = crud.create_cattle(db, owner_id, cattle_data)

    # Save photo if available
    if photo_url:
        cp = CattlePhoto(cattle_id=cattle.id, url=photo_url)
        db.add(cp)
        db.commit()

    # Blockchain sync (non-blocking)
    try:
        r = requests.post(
            f"{NODE_API_URL}/registerCattle",
            json={"tagId": tag_id, "breed": breed, "location": location, "dob": dob},
            timeout=5
        )
        tx_hash = r.json().get("tx_hash")
        if tx_hash:
            cattle.tx_hash = tx_hash
            db.add(cattle)
            db.commit()
    except Exception as e:
        print("Blockchain error:", e)

    return {
        "message": "Cattle registered",
        "cattle": {
            "id": cattle.id,
            "tag_id": cattle.tag_id,
            "tx_hash": cattle.tx_hash
        }
    }


# -------------------- Mark for Sale --------------------
@router.post("/{cattle_id}/sell-request")
def sell_request(
    cattle_id: int,
    payload: dict,
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    user = get_user_from_auth(authorization)
    owner_id = user["id"]

    cattle = db.query(Cattle).filter(Cattle.id == cattle_id).first()
    if not cattle:
        raise HTTPException(404, "Cattle not found")

    if cattle.owner_id != owner_id:
        raise HTTPException(403, "You are not the owner")

    cattle.status = "For Sale"
    db.commit()

    # Optional: Blockchain sync
    try:
        r = requests.post(
            f"{NODE_API_URL}/transferOwnership",
            json={
                "cattleId": cattle_id,
                "newOwner": payload.get("newOwner"),
                "price": payload.get("price")
            }
        )
        tx_hash = r.json().get("tx_hash")
    except:
        tx_hash = None

    return {"message": "Marked for sale", "tx_hash": tx_hash}


# -------------------- Get All Cattle For Sale --------------------
@router.get("/for-sale")
def get_for_sale(db: Session = Depends(get_db)):
    cattle_list = crud.list_cattle_for_sale(db)
    return [
        {
            "cattle_id": c.tag_id,
            "breed": c.breed,
            "location": c.location,
            "owner": c.owner_id,
            "status": c.status
        }
        for c in cattle_list
    ]


# -------------------- My Cattle --------------------
@router.get("/my-cattle")
def my_cattle(authorization: Optional[str] = Header(None), db: Session = Depends(get_db)):
    user = get_user_from_auth(authorization)
    owner_id = user["id"]

    list_c = crud.get_cattle_by_owner(db, owner_id)

    return [
        {
            "cattle_id": c.tag_id,
            "breed": c.breed,
            "status": c.status,
            "tx_hash": c.tx_hash
        }
        for c in list_c
    ]


# -------------------- Analyze Photo --------------------
@router.post("/{cattle_id}/analyze-photo")
async def analyze_photo(
    cattle_id: int,
    photo: UploadFile = File(...),
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    user = get_user_from_auth(authorization)

    # Upload photo to Cloudinary
    url = cloudinary_utils.upload_file(photo.file, folder=f"analysis/{cattle_id}")

    # Run ML model
    image_bytes = await photo.read()
    result = ai_model.predict_infection(image_bytes)

    return {"photo_url": url, "analysis": result}
